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
    -- Arguments
    ------------------------------------------------

    for i = 2, #words do
        out[i] = split_key_value(words[i])
    end

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
