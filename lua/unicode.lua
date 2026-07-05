--#############################################################################
-- SUBSCRIPT UNICODE ABSTRACTION
--#############################################################################

local unicode = {}

--==============================================================================
-- SECTION: Character tables
--==============================================================================

unicode.utf8 = {}

local upper_map = {

    ["ā"] = "Ā",
    ["ē"] = "Ē",
    ["ī"] = "Ī",
    ["ō"] = "Ō",
    ["ū"] = "Ū",

    ["þ"] = "Þ",
    ["ŋ"] = "Ŋ",

}

--test if new entry is necessary:
--print(string.upper("ä"))
--if output "Ä": no new entry needed

local lower_map = {}

for k, v in pairs(upper_map) do
    lower_map[v] = k
end

--==============================================================================
-- SECTION: utf-8 string manipulations
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Return utf-8 substring
-- Works like string.sub(), but counts Unicode characters instead of bytes.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function unicode.utf8.sub(str, first, last)

    local chars = {}

    for _, codepoint in utf8.codes(str) do
        table.insert(chars, utf8.char(codepoint))
    end

    local len = #chars

    first = first or 1
    last  = last  or len

    ------------------------------------------------------------
    -- Negative indices
    ------------------------------------------------------------

    if first < 0 then
        first = len + first + 1
    end

    if last < 0 then
        last = len + last + 1
    end

    return table.concat(chars, "", first, last)

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Return upper case utf-8 character
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function unicode.utf8.upper(str)

    local result = {}

    for _, codepoint in utf8.codes(str) do

        local ch = utf8.char(codepoint)

        table.insert(
            result,
            upper_map[ch]
            or string.upper(ch)
        )

    end

    return table.concat(result)

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Return lower case utf-8 character
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function unicode.utf8.lower(str)

    local result = {}

    for _, codepoint in utf8.codes(str) do

        local ch = utf8.char(codepoint)

        table.insert(
            result,
            lower_map[ch]
            or string.lower(ch)
        )

    end

    return table.concat(result)

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Return length of utf-8 string
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function unicode.utf8.len(str)

    return utf8.len(str)

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Convert a utf-8 string into a table of characters
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function unicode.utf8.chars(str)

    local chars = {}

    for _, codepoint in utf8.codes(str) do
        table.insert(chars, utf8.char(codepoint))
    end

    return chars

end

--##############################################################################
-- RETURN
--##############################################################################

return unicode

--how to test:
--print(unicode.utf8.sub("ābc", -1, -1))
--print(unicode.utf8.upper("āēīōū"))
--print(unicode.utf8.lower("ĀĒĪŌŪ"))
--print(unicode.utf8.upper("þŋ"))
