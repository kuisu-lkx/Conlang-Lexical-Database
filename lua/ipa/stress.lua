local S = require("state")
local U = require("util")
local RULES = require("ipa.rules")

--##############################################################################
-- SUBSCRIPT: Determine stress
--##############################################################################

local STRESS = {}

--==============================================================================
-- SECTION: Determine words stress position
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Returns the nucleus index carrying an explicit stress mark.
--------------------------------------------------------------------------------

local function find_explicit_stress(tokens)

    for i, token in ipairs(tokens) do

        if S.vowels_explicit_stress[token] then
            return i

        end

    end

    return nil

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Find the onset of the stressed syllable
--
-- I prefer to place the IPA stress mark in front of the stressed syllable
-- instead of the stressed nucleus.
--------------------------------------------------------------------------------

local function stress_onset(tokens, nucleus_pos)

    local pos = nucleus_pos

    while pos > 1 do

        local previous = tokens[pos - 1]

        if RULES.is_nucleus(previous) then
            break

        end

        pos = pos - 1

    end

    return pos

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION:
--
-- Returns the token position of the stressed syllable nucleus.
--
-- Returns:
--     nil   : no stress
--     table : stressed nucleus position, stress marker position
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
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function STRESS.find_stress(tokens, stemclass, stress_rule)

    if stress_rule == "none" then
        --print("RETURN: none")
        return nil

    end

    ---------------------------------------------------------------------------
    -- Classes without stress
    ---------------------------------------------------------------------------

    if not (
        stemclass == "n1" or
        stemclass == "n2" or
        stemclass == "n3" or
        stemclass == "n4" or
        stemclass == "n5" or
        stemclass == "v1" or
        stemclass == "v2"
    ) then
        --print("RETURN: wrong class")
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

        return {
            marker = 1
        }

    end

    ---------------------------------------------------------------------------
    -- Determine stressed nucleus
    ---------------------------------------------------------------------------

    local nucleus

    local explicit = find_explicit_stress(tokens)

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
    -- Return both positions of primary stress
    ---------------------------------------------------------------------------

    if not nucleus then
        error("No stress nucleus found.")

    end

--[[
    local stress = {

        secondary = {
            nucleus = 0,
            marker  = 0
        },

        primary = {
            nucleus = nucleus,
            marker  = stress_onset(tokens, nucleus)
        },

    }
]]
    return {
        nucleus = nucleus,
        marker  = stress_onset(tokens, nucleus)
    }

end

--##############################################################################
-- RETURN
--##############################################################################

return STRESS
