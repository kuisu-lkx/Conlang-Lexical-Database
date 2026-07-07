local U = require("util")
local S = require("state")
local ANSI = require("cli.ansi")
--local tableVIEW = require("cli.view.table")
local LAYOUT = require("cli.layout")
local TABLE = require("cli.table")
local BLOCK = require("cli.block")


local unicode = require("unicode")

--##############################################################################
-- SUBSCRIPT: CLI formatter for full view
--##############################################################################

local fullVIEW = {}

--==============================================================================
-- SECTION: TODO
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Add padding after strings
--------------------------------------------------------------------------------


local function nominal_paradigm()

    local rows = {
        {"", ANSI.bold_dim("Singular"), ANSI.bold("Generic"), ANSI.bold("Plural")},
        {"Nom.", "eak", "eaki", "xxx"}
    }

    local table = tableVIEW.print{

        rows = rows,

        options = {
            spacing = 3,
            vertical_after = {1,2},
            horizontal_after = {1},
            style = tableVIEW.style.double,
            box = false,
            align = {"left", "center", "center", "center"}
        }
    }

    return table

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: TODO
-- PRINT ENTRY (FULL) - TODO make view script
---------------------

-- Dumps every key and nested table.

-- Accepts either:
--     print_entry_full("fanaheak")
-----------------------------------

-- or:
--     print_entry_full(entry)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function fullVIEW.print_entry(arg)

    local options = S.options
U.dump_table(options)
    local entry

    if type(arg) == "table" then
        entry = arg

    else
        entry = U.find_stem(arg)

    end

    --print("----------------------------------------")

    --U.dump_table(entry)

    --nominal_paradigm()


    --print("----------------------------------------")



    local multiline = "line1\nline2line3"

    -- make formatted nominal paradigm

local framed_paradigm = {}

if entry.stem.class:match("^n") then

    local paradigm = {}


    local paradigm_formated = {}

    for case, endings in pairs(S.inflections.nominal[entry.stem.class]) do

        local base = ""
        local format = {}

        if options.morphology then

            if endings.stem == "contracted" then
                format = entry.stem.contracted.format.morphology
            elseif endings.stem == "expanded" then
                format = entry.stem.expanded.format.morphology
            end

        else

            if endings.stem == "contracted" then
                format = entry.stem.contracted.format.unicode
            elseif endings.stem == "expanded" then
                format = entry.stem.expanded.format.unicode
            end

        end

        if options.abbreviated then
            base = base .. "~"
        else

            if format.modifier then
                base = base .. format.modifier
            end

            if format.before then
                base = base .. format.before
            end
        end
        --TODO format stems differently (maybe only in morphology mode)
        if endings.stem == "contracted" then
            base = base .. format.main
        elseif endings.stem == "expanded" then
            base = base .. format.main
        end



        if format.after then
            base = base .. format.after
        end

        if options.morphology then
        base = base .. "·"
        end



        paradigm_formated[case] = {
            stem = endings.stem,
            sg = base .. ANSI.bold(endings.sg),
            gc = base .. ANSI.bold(endings.gc),
            pl = base .. ANSI.bold(endings.pl)
        }

    end






    local paradigm_lines = {}
    for case, forms in pairs(paradigm_formated) do
        local line = {}
        local singular = forms.sg
        local generic = forms.gc
        local plural = forms.pl

        --TODO add real ipa of forms
        if options.paradigm_ipa then
            local ipa = "[" .. U.assemble_stem(entry.stem.contracted.format.ipa) .. "]"

            singular = singular .. "\n" .. ANSI.dim(ipa)
            generic = generic .. "\n" .. ANSI.dim(ipa)
            plural = plural .. "\n" .. ANSI.dim(ipa)
        end

        line = {case, singular, generic, plural}
        table.insert(paradigm_lines, line)

    end

    table.sort(paradigm_lines, function(a, b)

    return S.case_rank[a[1]] < S.case_rank[b[1]]

    end)
    -- TODO replace case abbr.
    -- Format case only after sorting
    for _, lines in ipairs(paradigm_lines) do
        lines[1] = ANSI.bold_dim(lines[1])
    end

    paradigm = TABLE.make{

        rows = {
            {"", ANSI.bold_dim("Singular"), ANSI.bold_dim("Generic"), ANSI.bold_dim("Plural")},
            paradigm_lines[1],
            paradigm_lines[2],
            paradigm_lines[3],
            paradigm_lines[4],
            paradigm_lines[5],
            paradigm_lines[6],
            paradigm_lines[7],
            paradigm_lines[8],
        },

        options = {
            padding = 1,
            spacing = 1,
            vertical_after = {1},
            horizontal_after = {1},
            align = {"left", "left", "left", "left"},
            valign = {"center", "center", "center", "center"},
            style = TABLE.style.light_dim
        }

    }

    framed_paradigm = LAYOUT.frame{

        child = paradigm,

        style = TABLE.style.light_dim,

        hpadding = 1,
        vpadding = 0,

        sides = {

            top = true,
            bottom = true,
            left = true,
            right = true

        }

    }

end

    local title_text = ""

    if options.morphology then
        title_text = U.assemble_stem(entry.stem.contracted.format.morphology)
    else
        title_text = U.assemble_stem(entry.stem.contracted.format.unicode)
    end

    title_text = unicode.utf8.upper(title_text)

    if options.color then

        if entry.stem.class:match("^v") then
            title_text = ANSI.bold_yellow(title_text)

        elseif entry.stem.class:match("^n") then
            title_text = ANSI.bold_blue(title_text)

        else
            title_text = ANSI.bold(title_text)

        end

    else
        title_text = ANSI.bold(title_text)
    end

    local title = LAYOUT.text{

        text = title_text,
        align = "center"

    }

    local status = BLOCK.status(entry)

    local title_line = LAYOUT.hstack{

        spacing = 8,
        align = "center",
        children = {
            title,
            status
            --empty_line
        }

    }




    local explanation = LAYOUT.text{

        text = "Explanatory text,\nblabla bla bla\nblabla",
        align = "left"

    }

--U.dump_table(explanation)

    --replace paradigm by empty line if empty, TODO move into make paradigm-section function
    local middle_paradigm = {}
    if next(framed_paradigm) then
        middle_paradigm = framed_paradigm
    else
        middle_paradigm = BLOCK.empty_screen_line()
    end

    local middle = LAYOUT.hstack{

        spacing = 8,
        align = "center",
        children = {
            middle_paradigm,
            --explanation
            --empty_line
        }

    }





    local screen = LAYOUT.vstack{

        spacing = 0,
        align = "left",
        children = {
            title_line,
            BLOCK.empty_screen_line(),
            BLOCK.translation(entry, 76),
            --middle
        }

    }

    local framed_screen = LAYOUT.frame{

        child = screen,

        style = TABLE.style.double,

        hpadding = 1,
        vpadding = 0,

        sides = {

            top = true,
            bottom = true,
            left = true,
            right = true

        }

    }

    --print("PARADIGM", paradigm.height)
    --print("MIDDLE", middle.height)

    --print("PARADIGM")
    --U.dump_table(paradigm.lines)

    --print("MIDDLE")
    --U.dump_table(middle.lines)

    print(table.concat(framed_screen.lines, "\n"))


end












--##############################################################################
-- RETURN
--##############################################################################

return fullVIEW
