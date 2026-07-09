local S = require("state")
--local U = require("util")
--##############################################################################
-- SUBSCRIPT: Query engine
--##############################################################################

local QUERY = {}











local extract = {

    lemma = {},

    stem = {},

    affix = {},

    source = {},

}

extract.lemma.head = function(entry)
    return entry.lemma.head.key
    end

extract.lemma.modifier = function(entry)
--U.dump_table(entry)
    if entry.lemma.modifier then
        return entry.lemma.modifier.key
    end
end

extract.stem.form = function(entry)
    return entry.stem.contracted.form
    end

extract.stem.class = function(entry)
    return entry.stem.class
    end

extract.affix.prefix = function(entry)
    return entry.lemma.head.prefix
    end

extract.affix.suffix = function(entry)
    return entry.lemma.head.suffix
    end

extract.source.filename = function(entry)
    return entry.source.filename
    end

-- Input abbreviations for search_entries()
local extractors = {
    lemma = extract.lemma.head,
    modifier = extract.lemma.modifier,
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



function QUERY.evaluate_query(query, entry)

    local extractor =
        extractors[query.key]

    local matcher =
        resolve_pattern(query.value)

    local field =
        extractor(entry)

    ------------------------------------------------
    -- Missing field
    ------------------------------------------------

    local result = false

    if field ~= nil then

        result = matcher(
            tostring(field)
        )

    end

    ------------------------------------------------
    -- Negation
    ------------------------------------------------

    if query.negated then
        result = not result
    end

    return result

end

function QUERY.search_entries(query)

    local result = {}

    for _, entry in ipairs(S.entries) do

        if QUERY.evaluate_query(
            query,
            entry
        ) then

            table.insert(
                result,
                entry
            )

        end

    end

    return result

end

--##############################################################################
-- RETURN
--##############################################################################

return QUERY

