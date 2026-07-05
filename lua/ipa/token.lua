local S = require("state")
local U = require("util")
local STRESS = require("ipa.stress")
local unicode = require("unicode")

--##############################################################################
-- SUBSCRIPT: Token stream generation
--##############################################################################

local TOKEN = {}

--==============================================================================
-- SECTION: Token stream generation
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Make token stream
--
-- Splits a stem into phonological units.
--
-- Examples:
--
-- fanaheak
-- -> f a n a h ea k
--
-- baint
-- -> b ai n
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TOKEN.tokenize(stem)

    local chars = unicode.utf8.chars(stem)

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

--==============================================================================
-- SECTION: Token stream manipulations
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Concatenate two token streams
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TOKEN.concatenate_stream(left, right)

    local tokens = {}

    local modifier_length = #left

    for _, token in ipairs(left) do

        table.insert(tokens, token)

    end

    for _, token in ipairs(right) do

        table.insert(tokens, token)

    end

    return tokens

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Assemble full token stream of a word from its morphemes
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TOKEN.assemble_stream(stem, prefix, suffix, stemclass, stressrule)

    prefix = prefix or ""
    suffix = suffix or ""

    if prefix ~= "" and U.needs_linking_h(prefix, stem) then

    stem = "h" .. stem

    end
    ------------------------------------------------------------
    -- Tokenize each morphological part separately
    ------------------------------------------------------------

    local prefix_tokens = TOKEN.tokenize(prefix)
    local stem_tokens   = TOKEN.tokenize(stem)
    local suffix_tokens = TOKEN.tokenize(suffix)

    ------------------------------------------------------------
    -- Lexical stress belongs to the stem only.
    --
    -- Prefixes shift lexical positions.
    -- Suffixes do not affect lexical stress.
    ------------------------------------------------------------

    local stress = {}
    local stem_offset = #prefix_tokens
    local suffix_offset = stem_offset + #stem_tokens

    stress =
        STRESS.find_stress(
            stem_tokens,
            stemclass,
            stressrule
        )

    stress.marker =
        stress.marker + stem_offset

    if stress.nucleus then

        stress.nucleus =
            stress.nucleus + stem_offset

    end
--[[
    if #prefix_tokens > 0 then
        if U.needs_linking_h(prefix_tokens[#prefix_tokens], stem_tokens[1]) then

            table.insert(stem_tokens, 1, "h")

            if stress.nucleus then
            stress.nucleus = stress.nucleus + 1
            end
            -- don't move stress marker if stem begins with it, otherwise do
            if stress.marker > 1 then

                stress.marker = stress.marker + 1
                offset = offset + 1

            end

        end
    end
    ]]
    ------------------------------------------------------------
    -- Assemble the complete token stream
    ------------------------------------------------------------

    local tokens = {}

    for _, token in ipairs(prefix_tokens) do

        table.insert(tokens, token)

    end

    for _, token in ipairs(stem_tokens) do

        table.insert(tokens, token)

    end

    for _, token in ipairs(suffix_tokens) do

        table.insert(tokens, token)

    end

    return tokens, stress, stem_offset, suffix_offset

end

--##############################################################################
-- RETURN
--##############################################################################

return TOKEN
