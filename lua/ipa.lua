local S = require("state")
local U = require("util")

--#############################################################################
-- SUBSCRIPT IPA GENERATION
--#############################################################################

local IPA = {}

--#############################################################################
-- TOKENIZE
--
-- Splits a stem into phonological units.
--
-- Examples:
--
-- fanaheak
-- -> f a n a h ea k
--
-- baint
-- -> b ai n t
--#############################################################################

function IPA.tokenize(stem)

    local chars = U.utf8_chars(stem)

    local tokens = {}

    local i = 1

    while i <= #chars do

        ------------------------------------------------------------
        -- Try diphthong first
        ------------------------------------------------------------

        local two = (chars[i] or "") .. (chars[i + 1] or "")

        if S.diphthong_ipa[two] then

            table.insert(tokens, two)

            i = i + 2

        else

            table.insert(tokens, chars[i])

            i = i + 1

        end
    end

    return tokens
end

--#############################################################################
-- FIND EXPLICIT STRESS
--
-- Returns the nucleus index carrying an explicit stress mark.
--#############################################################################

function IPA.find_explicit_stress(tokens)

    for i, token in ipairs(tokens) do

        if S.vowels_explicit_stress[token] then
            return i
        end

    end

    return nil

end

--#############################################################################
-- FIND STRESS ONSET
--#############################################################################

local function stress_onset(tokens, nucleus_pos)

    local pos = nucleus_pos

    while pos > 1 do

        local previous = tokens[pos - 1]

        if IPA.is_nucleus(previous) then
            break
        end

        pos = pos - 1

    end

    return pos

end


--#############################################################################
-- FIND STRESS
--
-- Returns the token position of the stressed syllable nucleus.
--
-- Returns:
--     nil     = no stress
--     integer = stressed nucleus token
--
-- Examples:
--
-- eak
--     ea k
--     ^
--
-- fanaheak
--     f a n a h ea k
--         ^
--
--#############################################################################

function IPA.find_stress(tokens, stemclass, stress_rule)

    ---------------------------------------------------------------------------
    -- Classes without stress
    ---------------------------------------------------------------------------

    if not (
        stemclass == "n1" or
        stemclass == "n2" or
        stemclass == "n3" or
        stemclass == "n4" or
        stemclass == "n5" or
        stemclass == "v"
    ) then
        return nil
    end

    ---------------------------------------------------------------------------
    -- Collect syllable nuclei
    ---------------------------------------------------------------------------

    local nuclei = {}

    for i, token in ipairs(tokens) do

        if S.vowel_ipa_stressed[token]
        or S.diphthong_ipa[token] then

            table.insert(nuclei, i)

        end
    end

    ---------------------------------------------------------------------------
    -- No vowels found
    ---------------------------------------------------------------------------

    if #nuclei == 0 then
        return nil
    end

    ---------------------------------------------------------------------------
    -- Determine stressed nucleus
    ---------------------------------------------------------------------------

    local nucleus

    local explicit = IPA.find_explicit_stress(tokens)

    if explicit then
        nucleus = explicit

    elseif stress_rule == "ultimate" then

        nucleus = nuclei[#nuclei]

    elseif stress_rule == "penultimate" then

        if #nuclei == 1 then
            nucleus = nuclei[1]
        else
            nucleus = nuclei[#nuclei - 1]
        end

    end

    ---------------------------------------------------------------------------
    -- Return both positions
    ---------------------------------------------------------------------------

    return {

        nucleus = nucleus,

        marker =
            stress_onset(
                tokens,
                nucleus
            )

    }

end

--#############################################################################
-- IS NUCLEUS
--#############################################################################

function IPA.is_nucleus(token)

    return
        S.vowel_ipa_stressed[token] ~= nil
        or
        S.diphthong_ipa[token] ~= nil

end

--#############################################################################
-- IS LENITED START
--
-- Returns true if the consonant at position i begins
-- a lenited consonant (ph, bh, th, ...).
--#############################################################################

function IPA.is_lenited_start(tokens, i)

    local c1 = tokens[i]
    local c2 = tokens[i + 1]

    if c1 == nil or c2 ~= "h" then
        return false
    end

    return S.consonants_lenit_lookup[c1] == true

end

--#############################################################################
-- LENITED IPA
--
-- Returns:
--     IPA string if consonant+h forms a lenited pair
--     nil otherwise
--#############################################################################

function IPA.get_lenited_ipa(current, next)

    local pair = current .. next

    return S.consonant_ipa_lenited[pair]

end

--#############################################################################
-- CAN TRIGGER PALATALIZATION
--
-- Returns true if the token can trigger palatalization.
--#############################################################################

function IPA.can_trigger_palatalization(token)

    return
        token == "i"
        or token == "ī"
        or S.diphthong_palat[token] ~= nil

end

--#############################################################################
-- TRIGGERS PALATALIZATION
--
-- i points at:
--
--     i
--     ī
--     ai
--     oi
--     ui
--     ei
--
-- Returns true if the following environment permits
-- palatalization.
--#############################################################################

function IPA.triggers_palatalization(tokens, i)

    local trigger = tokens[i]

    ------------------------------------------------------------
    -- Must be a valid trigger.
    ------------------------------------------------------------

    if not IPA.can_trigger_palatalization(trigger) then
        return false
    end

    ------------------------------------------------------------
    -- Need at least one following consonant.
    ------------------------------------------------------------

    local c1 = tokens[i + 1]

    if c1 == nil then
        return false
    end

    ------------------------------------------------------------
    -- First consonant must be palatalizable.
    ------------------------------------------------------------

    if not S.consonants_palat_lookup[c1] then
        return false
    end

    ------------------------------------------------------------
    -- Lenited consonants block palatalization.
    ------------------------------------------------------------

    if IPA.is_lenited_start(tokens, i + 1) then
        return false
    end

    return true

end

--#############################################################################
-- PALATALIZATION REACHES
--
-- Returns true if palatalization triggered at trigger_index
-- reaches the consonant at target_index.
--
-- The trigger itself must already have been validated.
--#############################################################################

function IPA.palatalization_reaches(tokens, trigger_index, target_index)

    local i = trigger_index + 1

    while i <= #tokens do

        ------------------------------------------------------------
        -- Skip the "h" of a lenited consonant.
        ------------------------------------------------------------

        if tokens[i] == "h" then
            i = i + 1
            goto continue
        end

        ------------------------------------------------------------
        -- Stop at first nucleus.
        ------------------------------------------------------------

        if IPA.is_nucleus(tokens[i]) then
            return false
        end

        ------------------------------------------------------------
        -- Only consonants matter from here.
        ------------------------------------------------------------

        if S.consonant_ipa[tokens[i]]
        or S.consonants_lenit_lookup[tokens[i]]
        then

            --------------------------------------------------------
            -- Obstacle:
            -- non-palatalizable OR lenited.
            --------------------------------------------------------

            if IPA.is_lenited_start(tokens, i)
            or not S.consonants_palat_lookup[tokens[i]]
            then
                return false
            end

            --------------------------------------------------------
            -- We reached the requested consonant.
            --------------------------------------------------------

            if i == target_index then
                return true
            end
        end

        ::continue::

        i = i + 1

    end

    return false

end

--#############################################################################
-- IS PALATALIZED CONSONANT
--
-- Returns true if the consonant at position i
-- is palatalized by the preceding token.
--#############################################################################

function IPA.is_palatalized_consonant(tokens, i)

    local token = tokens[i]

    if not S.consonants_palat_lookup[token] then
        return false
    end

    ------------------------------------------------------------
    -- Look left for a trigger.
    ------------------------------------------------------------

    for j = i - 1, 1, -1 do

        if IPA.can_trigger_palatalization(tokens[j]) then

            return IPA.palatalization_reaches(
                tokens,
                j,
                i
            )

        end

        --------------------------------------------------------
        -- Earlier nucleus blocks propagation.
        --------------------------------------------------------

        if IPA.is_nucleus(tokens[j]) then
            return false
        end

    end

    return false

end

--#############################################################################
-- IS REDUCED DIPHTHONG
--
-- Returns true if the diphthong loses its glide
-- because it successfully triggered palatalization.
--#############################################################################

function IPA.is_reduced_diphthong(tokens, i)

    local token = tokens[i]

    if S.diphthong_ipa_reduced[token] == nil then
        return false
    end

    return IPA.triggers_palatalization(tokens, i)

end

--#############################################################################
-- IS GEMINATE
--
-- Returns true if token i is the first consonant
-- of a geminate pair.
--#############################################################################

function IPA.is_geminate(tokens, i)

    local current = tokens[i]
    local next    = tokens[i + 1]

    if current == nil or next == nil then
        return false
    end

    if current ~= next then
        return false
    end

    return S.consonant_ipa[current] ~= nil

end

--#############################################################################
-- GET GEMINATED IPA
--#############################################################################

function IPA.get_geminated_ipa(tokens, i)

    local consonant = tokens[i]

    ------------------------------------------------------------
    -- rr
    ------------------------------------------------------------

    if consonant == "r" then
        return "r"
    end

    ------------------------------------------------------------
    -- hh
    ------------------------------------------------------------

    if consonant == "h" then
        return "h"
    end

    ------------------------------------------------------------
    -- Palatalized consonants
    ------------------------------------------------------------

    if IPA.is_palatalized_consonant(tokens, i) then

        return
            S.consonant_ipa_palatal[consonant]
            .. "ː"

    end

    ------------------------------------------------------------
    -- Normal consonants
    ------------------------------------------------------------

    return
        S.consonant_ipa[consonant]
        .. "ː"

end

--#############################################################################
-- RENDER IPA
--
-- Converts tokens into IPA.
--
-- Rendering order:
--
-- 1. Stress marking
-- 2. Lenition
-- 3. Reduced diphthongs
-- 4. Geminated consonants
-- 5. Palatalized consonants
-- 6. Normal diphthongs
-- 7. Vowels
-- 8. Consonants
--#############################################################################

function IPA.render(tokens, stress)

    local ipa = {}

    local i = 1

    while i <= #tokens do

        local token = tokens[i]

        ------------------------------------------------------------
        -- Ignore stress diacritics for ipa look-up
        ------------------------------------------------------------

        local render_token = token

        if S.vowel_explicit_base[token] then
            render_token = S.vowel_explicit_base[token]
        end

        ------------------------------------------------------------
        -- Stress mark
        ------------------------------------------------------------

        if stress
        and i == stress.marker
        then

            table.insert(ipa, "ˈ")

        end



        ------------------------------------------------------------
        -- Lenition
        ------------------------------------------------------------

        local lenited

        if tokens[i + 1] then

            lenited =
            IPA.get_lenited_ipa(
                token,
                tokens[i + 1]
            )

        end

        if lenited then

            table.insert(
                ipa,
                lenited
            )

            i = i + 2
        else
            local step = 1

            ------------------------------------------------------------
            -- Reduced Diphthongs
            ------------------------------------------------------------

            if IPA.is_reduced_diphthong(tokens, i) then

                table.insert(
                    ipa,
                    S.diphthong_ipa_reduced[token]
                )

            ------------------------------------------------------------
            -- Geminated consonants
            ------------------------------------------------------------


            elseif IPA.is_geminate(tokens, i) then

                table.insert(
                    ipa,
                    IPA.get_geminated_ipa(tokens, i)
                )

                step = 2

            ------------------------------------------------------------
            -- Palatalized consonants
            ------------------------------------------------------------

            elseif IPA.is_palatalized_consonant(tokens, i) then

                table.insert(
                    ipa,
                    S.consonant_ipa_palatal[token]
                )

            ------------------------------------------------------------
            -- Diphthongs
            ------------------------------------------------------------

            elseif S.diphthong_ipa[token] then

                table.insert(
                    ipa,
                    S.diphthong_ipa[token]
                )

            ------------------------------------------------------------
            -- Vowels
            ------------------------------------------------------------

            elseif S.vowel_ipa_stressed[render_token] then

                if stress
                and i == stress.nucleus
                then

                    table.insert(
                        ipa,
                        S.vowel_ipa_stressed[render_token]
                    )

                else

                    table.insert(
                        ipa,
                        S.vowel_ipa_unstressed[render_token]
                    )

                end

            ------------------------------------------------------------
            -- Consonants
            ------------------------------------------------------------

            elseif S.consonant_ipa[token] then

                table.insert(
                    ipa,
                    S.consonant_ipa[token]
                )

            ------------------------------------------------------------
            -- Unknown token
            ------------------------------------------------------------

            else

                table.insert(ipa, token)

            end

            i = i + step

        end

    end

    return table.concat(ipa)


end

--#############################################################################
-- MAKE IPA
--#############################################################################

function IPA.make_ipa(stem, stemclass, stress_rule)

    local tokens =
        IPA.tokenize(stem)

    local stress =
        IPA.find_stress(
            tokens,
            stemclass,
            stress_rule
        )

    return IPA.render(
        tokens,
        stress
    )

end

--#############################################################################
-- DEBUG IPA
--#############################################################################

function IPA.debug_render(word)

    local tokens = IPA.tokenize(word)

    print("----------------------------------------")
    print("WORD:   ", word)

    io.write("TOKENS: ")
    for _, token in ipairs(tokens) do
        io.write(token .. " ")
    end
    print()

    local stress = IPA.find_stress(tokens, "n1")

    if stress then

    print(
        "STRESS:",
        "marker=" .. stress.marker,
        "nucleus=" .. stress.nucleus
    )

    else

        print("STRESS:", "nil")

    end
    print("IPA:    ", IPA.render(tokens, stress))
    print()

end

function IPA.run_tests()

    IPA.debug_render("til")
    IPA.debug_render("tīl")
    IPA.debug_render("tail")
    IPA.debug_render("tael")
    IPA.debug_render("tains")
    IPA.debug_render("taint")

    IPA.debug_render("alla")
    IPA.debug_render("anna")
    IPA.debug_render("assa")
    IPA.debug_render("arra")
    IPA.debug_render("ahha")

end

--IPA.run_tests()

return IPA
