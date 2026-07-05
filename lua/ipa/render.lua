local S = require("state")
local RULES = require("ipa.rules")

--##############################################################################
-- SUBSCRIPT: Render token stream into IPA string
--##############################################################################

local RENDER = {}

--==============================================================================
-- SECTION: Render IPA
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Convert tokens into IPA
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
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function RENDER.ipa(tokens, stress, main_offset, after_offset, head_offset)

    --main_offset = main_offset or 1
    head_offset = head_offset or 0

    local ipa = {}

    local i = 1

    while i <= #tokens do

        local token = tokens[i]

        ------------------------------------------------------------------------
        -- Ignore stress diacritics for ipa look-up
        ------------------------------------------------------------------------

        local render_token = token

        if S.vowel_explicit_base[token] then
            render_token = S.vowel_explicit_base[token]

        end

        ------------------------------------------------------------------------
        -- Stress mark
        ------------------------------------------------------------------------

        if stress
        and stress.secondary
        and i == stress.secondary.marker then

            table.insert(ipa, {token = i, text = "ˌ"})

        end

        if stress
        and stress.primary
        and i == stress.primary.marker then

            table.insert(ipa, {token = i, text = "ˈ"})

        end

        ------------------------------------------------------------------------
        -- Lenition
        ------------------------------------------------------------------------

        local lenited

        if tokens[i + 1] then

            lenited =
            RULES.get_lenited_ipa(
                token,
                tokens[i + 1]
            )

        end

        if lenited then

            table.insert(ipa, {token = i, text = lenited})

            i = i + 2

        else

            local step = 1

            --------------------------------------------------------------------
            -- Reduced Diphthongs
            --------------------------------------------------------------------

            if RULES.is_reduced_diphthong(tokens, i) then
                table.insert(
                    ipa, {token = i, text = S.diphthong_ipa_reduced[token]}
                )

            --------------------------------------------------------------------
            -- Geminated consonants
            --------------------------------------------------------------------

            elseif RULES.is_geminate(tokens, i) then
                table.insert(
                    ipa, {token = i, text = RULES.get_geminated_ipa(tokens, i)}
                )

                step = 2

            --------------------------------------------------------------------
            -- Palatalized consonants
            --------------------------------------------------------------------

            elseif RULES.is_palatalized_consonant(tokens, i) then
                table.insert(
                    ipa, {token = i, text = S.consonant_ipa_palatal[token]}
                )

            --------------------------------------------------------------------
            -- Diphthongs
            --------------------------------------------------------------------

            elseif S.diphthong_ipa[token] then
                table.insert(
                    ipa, {token = i, text = S.diphthong_ipa[token]}
                )

            --------------------------------------------------------------------
            -- Vowels
            --------------------------------------------------------------------

            elseif S.vowel_ipa_stressed[render_token] then

                local stressed =
                stress
                and stress.primary
                and i == stress.primary.nucleus


                if stressed then
                    table.insert(ipa, {token = i, text =
                        S.vowel_ipa_stressed[render_token]})

                else
                    table.insert(ipa, {token = i, text =
                        S.vowel_ipa_unstressed[render_token]})

                end

            --------------------------------------------------------------------
            -- Consonants
            --------------------------------------------------------------------

            elseif S.consonant_ipa[token] then
                table.insert(ipa, {token = i, text = S.consonant_ipa[token]})

            --------------------------------------------------------------------
            -- Unknown token
            --------------------------------------------------------------------

            else
                table.insert(ipa, {token = i, text = token})

            end

            i = i + step

        end

    end

    ----------------------------------------------------------------------------
    -- Divide token stream along derivational boundaries
    ----------------------------------------------------------------------------

    local before = {}
    local main = {}
    local after = {}
    local modifier = {}

    for _, piece in ipairs(ipa) do

        if piece.token <= head_offset then
            table.insert(modifier, piece.text)

        elseif piece.token <= main_offset then
            table.insert(before, piece.text)

        elseif piece.token > after_offset then
            table.insert(after, piece.text)

        else
            table.insert(main, piece.text)

        end

    end

    ----------------------------------------------------------------------------
    -- RETURN parts as (sub)strings
    ----------------------------------------------------------------------------

    return
        table.concat(before),
        table.concat(main),
        table.concat(after),
        table.concat(modifier)

end

--##############################################################################
-- RETURN
--##############################################################################

return RENDER
