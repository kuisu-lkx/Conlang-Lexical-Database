local U = require("util")
local S = require("state")
local ANSI = require("cli.ansi")
local LAYOUT = require("cli.layout")
local TABLE = require("cli.table")


local unicode = require("unicode")

--##############################################################################
-- SUBSCRIPT: CLI formatter for full view
--##############################################################################

local BLOCK = {}

local roman = {
    "I",
    "II",
    "III",
    "IV",
    "V",
    "VI",
    "VII",
    "IIX", -- TODO "VIII" ?
    "IX",
    "X",
}

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Format status string
--------------------------------------------------------------------------------

function BLOCK.status(entry)

    local options = S.options

    if options.status then

        if not entry.meta.status then
            return LAYOUT.text{

                text = "",
                align = "center"

            }
        end

        local out = ""

        out = " ⟪" .. entry.meta.status .. "⟫"

        if options.color then

            if entry.meta.status == "canon" then
                out = out

            elseif entry.meta.status == "deprecated" then
                out = ANSI.red(out)

            elseif entry.meta.status == "draft" then
                out = ANSI.yellow(out)

            elseif entry.meta.status == "review" then
                out = ANSI.magenta(out)

            elseif entry.meta.status == "good" then
                out = ANSI.green(out)

            elseif entry.meta.status == "new" then
                out = ANSI.blue(out)

            else
                out = ANSI.orange(out)

            end

        else
            out = ANSI.bold(out)

        end

        return LAYOUT.text{

            text = out,
            align = "center"

        }

    else

        return LAYOUT.text{

            text = "",
            align = "center"

        }


    end

end

function BLOCK.empty_screen_line()

    return LAYOUT.text{
        text = string.rep(" ", 76), -- allow for frame + padding
        align = "center"
    }

end

function BLOCK.translation(entry, width)

    local width = width or 76

    local out = {}

    local multiple_classes = #entry.classes > 1

    for class_index, class in ipairs(entry.classes) do

        --table.insert(out, "       ")

        --if multiple_classes then -- <- uncomment to not display class numerals if only one class
        table.insert(out, ANSI.bold(roman[class_index] .. ". "))
        --end

        if class.type ~= "" then
            table.insert(out, class.type .. ": ")
        end

        local multiple_groups = #class.groups > 1

        for group_index, group in ipairs(class.groups) do

            if multiple_groups then
                table.insert(out, ANSI.bold(string.format("%d. ", group_index)))
            end

            if group.info ~= "" then
                table.insert(out, ANSI.dim("[" .. group.info .. "] "))
            end

            for translation_index, translation in ipairs(group.translations) do

                if translation.before ~= "" then
                    table.insert(out, ANSI.italic_dim(translation.before .. " "))
                end

                table.insert(out, translation.text)

                if translation.after ~= "" then
                    table.insert(out, ANSI.italic_dim(" " .. translation.after))
                end

                if translation_index < #group.translations then
                    table.insert(out, ", ")
                else
                    table.insert(out, ". ")
                end

            end

        end

        if class_index < #entry.classes then
            table.insert(out, "\n")
        end

    end


    return LAYOUT.text_wrapped{
        text = table.concat(out),
        width = width
    }

end


--##############################################################################
-- RETURN
--##############################################################################

return BLOCK
