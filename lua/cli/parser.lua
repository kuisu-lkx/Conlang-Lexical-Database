local S = require("state")
local U = require("util")


--##############################################################################
-- SUBSCRIPT: Simple argument parser
--##############################################################################

local PARSER = {}

--==============================================================================
-- SECTION: Resolve ASCII shorthand input
--==============================================================================

local ascii_shorthand = {

    ["a:"] = "ā",
    ["e:"] = "ē",
    ["i:"] = "ī",
    ["o:"] = "ō",
    ["u:"] = "ū",

    ["A:"] = "Ā",
    ["E:"] = "Ē",
    ["I:"] = "Ī",
    ["O:"] = "Ō",
    ["U:"] = "Ū",

    ["t:"] = "þ",
    ["T:"] = "Þ",
    ["n:"] = "ŋ",
    ["N:"] = "Ŋ",

}

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Normalize ASCII shorthand
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function normalize_arg(str)

    if not str then
        return str
    end

    for ascii, utf8 in pairs(ascii_shorthand) do
        str = str:gsub(ascii, utf8)
    end

    return str

end

local function normalize_argv(argv)

    for i = 1, #argv do
        argv[i] = normalize_arg(argv[i])
    end

    return argv
end




--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Split query token into key and value
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Split query token
--------------------------------------------------------------------------------



local function split_key_value(token)

    ------------------------------------------------
    -- Negation
    ------------------------------------------------

    local negated = false

    if token:sub(1,1) == "-" then
        negated = true
        token = token:sub(2)
    end

    ------------------------------------------------
    -- Explicit namespace
    ------------------------------------------------

    local key, value = token:match("^([^=]+)=(.*)$")

    if key then

        return {
            type = "predicate",
            key = key,
            value = normalize_arg(value),
            negated = negated,
        }

    end

    ------------------------------------------------
    -- Default namespace
    ------------------------------------------------

    return {
        type = "predicate",
        key = "lemma",
        value = normalize_arg(token),
        negated = negated,
    }

end

------------------------------------------------
-- Convert words into parser tokens
------------------------------------------------

local function tokenize(words)

    local tokens = {}

    for i = 2, #words do

        local word = words[i]

        ------------------------------------------------
        -- Operators
        ------------------------------------------------

        if word == "("
        or word == ")"
        or word == "&&"
        or word == "||"
        then

            table.insert(tokens, word)

        ------------------------------------------------
        -- Predicates
        ------------------------------------------------

        else

            table.insert(
                tokens,
                split_key_value(word)
            )

        end

    end

    return tokens

end

------------------------------------------------
-- Placeholder for future unary NOT operator
------------------------------------------------

local function fold_not(tokens)

    return tokens

end

local function fold_and(tokens)

    local out = {}

    local current = {}

    for _, token in ipairs(tokens) do

        ------------------------------------------------
        -- OR breaks AND groups
        ------------------------------------------------

        if token == "||" then

            if #current == 1 then
                table.insert(out, current[1])

            elseif #current > 1 then
                table.insert(out, {
                    type = "and",
                    children = current
                })
            end

            table.insert(out, token)

            current = {}

        ------------------------------------------------
        -- Explicit AND
        ------------------------------------------------

        elseif token == "&&" then
            -- explicit AND does not create a boundary
            -- just skip it

        ------------------------------------------------
        -- Continue current AND group
        ------------------------------------------------

        else

            table.insert(current, token)

        end

    end

    ------------------------------------------------
    -- Final group
    ------------------------------------------------

    if #current == 1 then
        table.insert(out, current[1])

    elseif #current > 1 then
        table.insert(out, {
            type = "and",
            children = current
        })
    end

    return out

end


local function fold_or(tokens)

    local children = {}

    for _, token in ipairs(tokens) do
        if token ~= "||" then
            table.insert(children, token)
        end
    end

    if #children == 1 then
        return children[1]
    end

    return {
        type = "or",
        children = children
    }
end

local function parse_parentheses(tokens)

    local out = {}

    local i = 1

    while i <= #tokens do

        ------------------------------------------------
        -- Start of group
        ------------------------------------------------

        if tokens[i] == "(" then

            local depth = 1

            local inner = {}

            i = i + 1

            while i <= #tokens and depth > 0 do

                if tokens[i] == "(" then

                    depth = depth + 1
                    table.insert(inner, tokens[i])

                elseif tokens[i] == ")" then

                    depth = depth - 1

                    if depth > 0 then
                        table.insert(inner, tokens[i])
                    end

                else

                    table.insert(inner, tokens[i])

                end

                i = i + 1

            end

            if depth ~= 0 then
                error("Unmatched '(' in query")
            end

            ------------------------------------------------
            -- Recursively parse inner expression
            ------------------------------------------------

            inner = parse_parentheses(inner)
            inner = fold_not(inner)
            inner = fold_and(inner)
            inner = fold_or(inner)

            table.insert(out, inner)

        ------------------------------------------------
        -- Unexpected closing bracket
        ------------------------------------------------

        elseif tokens[i] == ")" then

            error("Unexpected ')' in query")

        ------------------------------------------------
        -- Ordinary token
        ------------------------------------------------

        else

            table.insert(out, tokens[i])

            i = i + 1

        end

    end

    return out

end

function PARSER.parse_string(input)

    local words = {}

    for word in input:gmatch("%S+") do
        table.insert(words, word)
    end

    local out = {}

    ------------------------------------------------
    -- Command
    ------------------------------------------------

    out[1] = words[1]

    ------------------------------------------------
    -- Query pipeline
    ------------------------------------------------

    local tokens = tokenize(words)

    tokens = parse_parentheses(tokens)
    tokens = fold_not(tokens)
    tokens = fold_and(tokens)
    local query = fold_or(tokens)

    out[2] = query

    return out

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Parse command line options
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function PARSER.parse_options()

    local positional = {}

    local options = S.options

    for _, a in ipairs(arg) do-- TODO print help, options table

        if a:sub(1, 2) == "--" then

            if a == "--status" then
                options.status = true

            elseif a == "--translation" then
                options.translation = true

            elseif a == "--note" then
                options.note = true

            elseif a == "--morphology" then
                options.morphology = true

            elseif a == "--full" then
                options.abbreviated = false

            elseif a == "--color" then
                options.color = true

            elseif a == "--dense" then
                options.dense = true

            elseif a == "--changelog" then
                options.changelog = true

            elseif a == "--citations" then
                options.citations = true

            elseif a == "--paradigm_ipa" then
                options.paradigm_ipa = true

            elseif a == "--no_frame" then
                options.screen_frame = false

            else
                error("Unknown option: " .. a)

            end

        elseif a:sub(1, 1) == "-" and #a > 1 then

            for i = 2, #a do

                local flag = a:sub(i, i)

                if flag == "s" then
                    options.status = true

                elseif flag == "t" then
                    options.translation = true

                elseif flag == "n" then
                    options.note = true

                elseif flag == "m" then
                    options.morphology = true

                elseif flag == "f" then
                    options.abbreviated = false

                elseif flag == "c" then
                    options.color = true

                elseif flag == "d" then
                    options.dense = true

                else
                    error("Unknown option: -" .. flag)

                end

            end

        else
            table.insert(positional, a)

        end

    end

    return normalize_argv(positional)

end

--##############################################################################
-- RETURN
--##############################################################################

return PARSER
