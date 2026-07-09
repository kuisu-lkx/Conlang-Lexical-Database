local S = require("state")
local unicode = require("unicode")
local ANSI = require("cli.ansi")

--##############################################################################
-- SUBSCRIPT: Util functions
--##############################################################################

local U = {}

--==============================================================================
-- SECTION: Debugging
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Debug message printer
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.debug(str)

    if S.debug_mode then
        print(str)

    end

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Dump token stream table
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.dump_table(tbl, indent)

    indent = indent or ""

    local keys = {}

    for key in pairs(tbl) do

        table.insert(keys, key)

    end

    table.sort(
        keys,
        function(a, b)
            return tostring(a) < tostring(b)
        end
    )

    for _, key in ipairs(keys) do

        local value = tbl[key]

        if type(value) == "table" then

            print(
                indent
                .. ANSI.bold_dim(tostring(key))
                .. ANSI.dim(" = ")
                --.. ANSI.dim(" = {")
            )

            U.dump_table(
                value,
                indent .. "    "
            )

            --print(
            --    indent
            --    .. ANSI.dim("}")
            --)

        else

            print(
                indent
                .. ANSI.bold_dim(tostring(key))
                .. ANSI.dim(" = ")
                .. tostring(value)
            )

        end

    end

end

--==============================================================================
-- SECTION: Alphabetical sorter with selectable sort alphabet
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Determines position in lookup table
--------------------------------------------------------------------------------

local function get_position(character, lookup)

    return lookup[character] or math.huge

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Filter for utf-8 characters
--------------------------------------------------------------------------------

local function utf8_chars(text)

    local chars = {}

    for char in text:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
        chars[#chars + 1] = char

    end

    return chars

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Compare position of two characters
--------------------------------------------------------------------------------

local function compare_alphabetical(a, b, alphabet)

    a = a or ""
    b = b or ""

    local a_chars = utf8_chars(unicode.utf8.lower(a))
    local b_chars = utf8_chars(unicode.utf8.lower(b))

    local length = math.min(#a_chars, #b_chars)

    for i = 1, length do

        local a_position = get_position(a_chars[i], alphabet)
        local b_position = get_position(b_chars[i], alphabet)

        if a_position ~= b_position then

            return a_position < b_position

        end

    end

    return #a_chars < #b_chars

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Sort entries alphabetically
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.sort_by_alphabet(getter, alphabet, entries)

    table.sort(entries, function(a, b)

        return compare_alphabetical(
            getter(a),
            getter(b),
            alphabet
        )

    end)

end

--==============================================================================
-- SECTION: Category sorter with selectable sort order
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Sort by order TODO
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.sort_by_order(getter, order, entries)

    local rank = {}

    for i, value in ipairs(order) do

        rank[value] = i

    end

    local last = #order + 1
-- TODO second order alphabetical search: make alphabet selection available
    table.sort(entries, function(a, b)

        local ka = getter(a)
        local kb = getter(b)

        local ra = rank[ka]
        local rb = rank[kb]

        if ra and rb then

            return ra < rb

        elseif ra then

            return true

        elseif rb then

            return false

        else

            return ka < kb

        end

    end)

end

--==============================================================================
-- SECTION: Morphological helper functions
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Test if two syllables need a linking -h- inbetween them
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.needs_linking_h(syllable1, syllable2)

    local first = unicode.utf8.sub(syllable2, 1, 1)
    local last  = unicode.utf8.sub(syllable1, -1, -1)

    for i = 1, #S.vowels do

        if S.vowels[i] == first or S.diphthongs[i] == first then

            for j = 1, #S.vowels do

                if S.vowels[j] == last or S.diphthongs[i] == last then

                    return true

                end

            end

        end

    end

    return false

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Assemble full stem string of a given format
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.assemble_stem(format)

    local result = ""

    if format.modifier then
        result = result .. format.modifier
    end

    if format.before then
        result = result .. format.before
    end

    result = result .. format.main

    if format.after then
        result = result .. format.after
    end

    return result

end

--==============================================================================
-- SECTION: Query functions
--==============================================================================

local extract = {

    lemma = {},

    stem = {},

    affix = {},

    source = {},

}

extract.lemma.head = function(entry)
    return entry.lemma.head.key
    end

extract.stem.form = function(entry)
    return entry.stem.contracted.form
    end

extract.stem.class = function(entry)
    return entry.stem.class
    end

extract.affix.prefix = function(entry)
    return lemma.head.prefix
    end

extract.affix.suffix = function(entry)
    return lemma.head.suffix
    end

extract.source.filename = function(entry)
    return entry.source.filename
    end

-- Input abbreviations for search_entries()
local extractors = {
    lemma = extract.lemma.head,
    stem = extract.stem.form,
    class = extract.stem.class,
    prefix = extract.affix.prefix,
    postfix = extract.affix.suffix,
    filename = extract.source.filename,
}

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Resolve wildcard search patterns
--------------------------------------------------------------------------------

local function resolve_pattern(value)

    local use_pattern =
        value:find("[%*%?]") ~= nil

    if not use_pattern then

        return function(field)
            return field == value
            end

    end

    local pattern = value
    pattern = pattern:gsub("%.", "%%.")
    pattern = pattern:gsub("%*", ".*")
    pattern = pattern:gsub("%?", ".")
    pattern = "^" .. pattern .. "$"

    return function(field)
        return field:match(pattern)
    end

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: TODO still used? duplicate of search_entries()?
--------------------------------------------------------------------------------

local function search(list, extractor, value)

    local result = {}
    local matcher = resolve_pattern(value)

    for _, object in ipairs(list) do

        local field = tostring(extractor(object) or "")

        if matcher(field) then

            table.insert(result, object)

        end

    end

    return result

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Search entries
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.search_entries(name, value)

    local extractor = extractors[name]

    if not extractor then

        error("Unknown extractor: " .. tostring(name))

    end

    local result = {}
    local matcher = resolve_pattern(value)

    for _, entry in ipairs(S.entries) do

        local field = tostring(extractor(entry) or "")

        if matcher(field) then

            table.insert(result, entry)

        end

    end

    return result

end

--call like: U.search_entries(extractor, "ma*")

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Find stem and return the entry TODO use U.find_lemma()
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.find_stem(stem, index)

    index = index or 0

    for _, entry in ipairs(S.entries) do

        if U.assemble_stem(entry.stem.contracted.format.unicode) == stem
        and entry.lemma.head.index == index
        then
            return entry
        end

    end

    error(
        ("No stem found: %s (%d)")
        :format(stem, index)
    )

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Find entry by lemma
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function U.find_lemma(key, index, prefix, suffix)

    index = index or 0
    prefix = prefix or ""
    suffix = suffix or ""

    for _, entry in ipairs(S.entries) do

        if entry.lemma.head.key == key
        and entry.lemma.head.index == index
        and entry.lemma.head.prefix == prefix
        and entry.lemma.head.suffix == suffix
        then
            return entry
        end

    end

    error(
        ("No lemma found: %s (%d)")
        :format(key, index)
    )

end

--##############################################################################
-- RETURN
--##############################################################################

return U
