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

for i = 1, #arg do

    arg[i] = normalize_arg(arg[i])

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Parse command line options
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function PARSER.parse_options()

    local positional = {}

    local options = {
        status = false,
        translation = false,
        notes = false,
        morphology = false,
        abbreviated = true,
        color = false,
        dense = false,
        changelog = false,
        citations = false,
    }

    for _, a in ipairs(arg) do-- TODO print help, options table

        if a:sub(1, 2) == "--" then

            if a == "--status" then
                options.status = true

            elseif a == "--translation" then
                options.translation = true

            elseif a == "--note" then
                options.notes = true

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
                    options.notes = true

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

    return positional, options

end

--##############################################################################
-- RETURN
--##############################################################################

return PARSER
