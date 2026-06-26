local S = require("state")
local unicode = require("unicode")

--#############################################################################
-- SUBSCRIPT FOR UTIL FUCTIONS
--#############################################################################

local U = {}
--[[
--#############################################################################
-- ALPHABETICAL SORTER
--#############################################################################

function local U.get_pos_in_alphabet(character)
    for i, group in ipairs(S.alphabet) do
        for _, c in ipairs(group) do
            if character == c then
                return i
            end
        end
    end
end

function local U.get_utf8_chars(s)
    local chars = {}
    for c in s:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
        chars[#chars+1] = c
    end
    return chars
end

function U.sort_alphabetical(a, b, alphabet)
    local a_chars = U.get_utf8_chars(unicode.utf8.lower(a))
    local b_chars = U.get_utf8_chars(unicode.utf8.lower(b))

    local length = math.min(#a_chars, #b_chars)

    for i = 1, length do
        local a_pos = U.get_pos_in_alphabet(a_chars[i], alphabet)
        local b_pos = U.get_pos_in_alphabet(b_chars[i], alphabet)

        if a_pos ~= b_pos then
            return a_pos < b_pos
        end
    end

    return #a_chars < #b_chars
end
]]
--#############################################################################
-- InsertH
--#############################################################################

function U.insertH(part1, part2)

    local first = unicode.utf8.sub(part2, 1, 1)
    local last  = unicode.utf8.sub(part1, -1, -1)

    for i = 1, #S.vowels do
        if S.vowels[i] == first then
            for j = 1, #S.vowels do
                if S.vowels[j] == last then
                    return "h"
                end
            end
        end
    end
    return ""
end

--#############################################################################
-- UTF8 SPLIT
--
-- Converts a UTF8 string into a table of characters.
--#############################################################################

function U.utf8_chars(str)

    local chars = {}

    for _, codepoint in utf8.codes(str) do
        table.insert(chars, utf8.char(codepoint))
    end

    return chars
end

--#############################################################################
-- FIND ENTRIES
--#############################################################################

function U.find_entries(key, value)

    local result = {}

    local use_pattern = value:find("[%*%?]") ~= nil

    local pattern = value

    pattern = pattern:gsub("%.", "%%.")
    pattern = pattern:gsub("%*", ".*")
    pattern = pattern:gsub("%?", ".")

    pattern = "^" .. pattern .. "$"

    for _, entry in ipairs(S.entries) do
        local field = tostring(entry[key] or "")

        if
            (not use_pattern and field == value)
            or
            (use_pattern and field:match(pattern))
            then
            table.insert(result, entry)
        end
    end
    return result
end

--#############################################################################
-- FIND ENTRY
--#############################################################################

function U.find_entry(key, value)

    local matches =
        U.find_entries(key, value)

    if #matches == 0 then
        error(
            "No entry found for "
            .. key
            .. "="
            .. value
        )
    end

    if #matches > 1 then
        error(
            "Multiple entries found for "
            .. key
            .. "="
            .. value
        )
    end

    return matches[1]

end

return U
