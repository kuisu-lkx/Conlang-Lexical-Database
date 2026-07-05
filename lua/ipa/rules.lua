local S = require("state")

--##############################################################################
-- SUBSCRIPT: Phonological rules for IPA rendering of tokens
--##############################################################################

local RULES = {}

--==============================================================================
-- SECTION: Vowels, diphtongs
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Test if token is nucleus
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function RULES.is_nucleus(token)

    return
        S.vowel_ipa_stressed[token] ~= nil
        or
        S.diphthong_ipa[token] ~= nil

end

--==============================================================================
-- SECTION: Lenition
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Test for lenited consonant
--
-- Returns true if the consonant at position i begins
-- a lenited consonant (ph, bh, th, ...).
--------------------------------------------------------------------------------

local function is_lenited_start(tokens, i)

    local c1 = tokens[i]
    local c2 = tokens[i + 1]

    if c1 == nil or c2 ~= "h" then
        return false
    end

    return S.consonants_lenit_lookup[c1] == true

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Look up IPA for lenited consonant
--
-- Returns:
--     IPA string if consonant+h forms a lenited pair
--     nil otherwise
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function RULES.get_lenited_ipa(current, next)

    local pair = current .. next

    return S.consonant_ipa_lenited[pair]

end

--==============================================================================
-- SECTION: Palatalization
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Test for palatalization triggers
--
-- Returns true if the token can trigger palatalization.
--------------------------------------------------------------------------------

local function can_trigger_palatalization(token)

    return
        token == "i"
        or token == "ī"
        or S.diphthong_palat[token] ~= nil

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Test if palatalization is actually triggered
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
--------------------------------------------------------------------------------

local function triggers_palatalization(tokens, i)

    local trigger = tokens[i]

    ----------------------------------------------------------------------------
    -- Must be a valid trigger.
    ----------------------------------------------------------------------------

    if not can_trigger_palatalization(trigger) then
        return false
    end

    ----------------------------------------------------------------------------
    -- Need at least one following consonant.
    ----------------------------------------------------------------------------

    local c1 = tokens[i + 1]

    if c1 == nil then
        return false
    end

    ----------------------------------------------------------------------------
    -- First consonant must be palatalizable.
    ----------------------------------------------------------------------------

    if not S.consonants_palat_lookup[c1] then
        return false
    end

    ----------------------------------------------------------------------------
    -- Lenited consonants block palatalization.
    ----------------------------------------------------------------------------

    if is_lenited_start(tokens, i + 1) then
        return false
    end

    ----------------------------------------------------------------------------
    -- RETURN
    ----------------------------------------------------------------------------

    return true

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION:
--
-- Returns true if palatalization triggered at trigger_index
-- reaches the consonant at target_index.
--
-- The trigger itself must already have been validated.
--------------------------------------------------------------------------------

local function palatalization_reaches(tokens, trigger_index, target_index)

    local i = trigger_index + 1

    while i <= #tokens do

        ------------------------------------------------------------------------
        -- Skip the "h" of a lenited consonant.
        ------------------------------------------------------------------------

        if tokens[i] == "h" then

            i = i + 1
            goto continue

        end

        ------------------------------------------------------------------------
        -- Stop at first nucleus.
        ------------------------------------------------------------------------

        if RULES.is_nucleus(tokens[i]) then

            return false

        end

        ------------------------------------------------------------------------
        -- Only consonants matter from here.
        ------------------------------------------------------------------------

        if S.consonant_ipa[tokens[i]]
        or S.consonants_lenit_lookup[tokens[i]]
        then

            --------------------------------------------------------------------
            -- Obstacle:
            -- non-palatalizable OR lenited.
            --------------------------------------------------------------------

            if is_lenited_start(tokens, i)
            or not S.consonants_palat_lookup[tokens[i]]
            then

                return false

            end

            --------------------------------------------------------------------
            -- We reached the requested consonant.
            --------------------------------------------------------------------

            if i == target_index then

                return true

            end

        end

        ::continue::

        i = i + 1

    end

    ----------------------------------------------------------------------------
    -- RETURN
    ----------------------------------------------------------------------------

    return false

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Test if palatalized
--
-- Returns true if the consonant at position i
-- is palatalized by the preceding token.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function RULES.is_palatalized_consonant(tokens, i)

    local token = tokens[i]

    if not S.consonants_palat_lookup[token] then

        return false

    end

    ----------------------------------------------------------------------------
    -- Look left for a trigger.
    ----------------------------------------------------------------------------

    for j = i - 1, 1, -1 do

        if can_trigger_palatalization(tokens[j]) then

            return palatalization_reaches(
                tokens,
                j,
                i
            )

        end

        ------------------------------------------------------------------------
        -- Earlier nucleus blocks propagation.
        ------------------------------------------------------------------------

        if RULES.is_nucleus(tokens[j]) then

            return false

        end

    end

    return false

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Test if diphtong is reduced
--
-- Returns true if the diphthong loses its glide
-- because it successfully triggered palatalization.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function RULES.is_reduced_diphthong(tokens, i)

    local token = tokens[i]

    if S.diphthong_ipa_reduced[token] == nil then

        return false

    end

    return triggers_palatalization(tokens, i)

end

--==============================================================================
-- SECTION: Geminates
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Test if geminate
--
-- Returns true if token i is the first consonant
-- of a geminate pair.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function RULES.is_geminate(tokens, i)

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

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Get geminate IPA
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function RULES.get_geminated_ipa(tokens, i)

    local consonant = tokens[i]

    ----------------------------------------------------------------------------
    -- rr
    ----------------------------------------------------------------------------

    if consonant == "r" then
        return "r"
    end

    ----------------------------------------------------------------------------
    -- hh
    ----------------------------------------------------------------------------

    if consonant == "h" then
        return "h"
    end

    ----------------------------------------------------------------------------
    -- Palatalized consonants
    ----------------------------------------------------------------------------

    if RULES.is_palatalized_consonant(tokens, i) then
        return S.consonant_ipa_palatal[consonant] .. "ː"
    end

    ----------------------------------------------------------------------------
    -- Normal consonants
    ----------------------------------------------------------------------------

    return S.consonant_ipa[consonant] .. "ː"

end

--##############################################################################
-- RETURN
--##############################################################################

return RULES
