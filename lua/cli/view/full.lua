local U = require("util")
local ANSI = require("cli.ansi")
--local tableVIEW = require("cli.view.table")
local LAYOUT = require("cli.layout")
local TABLE = require("cli.table")

--##############################################################################
-- SUBSCRIPT: CLI formatter for list view
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

function fullVIEW.print_entry_full(arg, options)

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



    local multiline = "line1\nline2\nline3"

--print(multiline)

    local paradigm = TABLE.make{

        rows = {
            {ANSI.bold_red("Singular"), multiline, ANSI.bold("Plural")},
            {"Nom.", entry.paradigm.NOM.sg, "eaki"},
            {"Nom.", entry.paradigm.NOM.sg, multiline}
        },

        options = {
            padding = 5,
            spacing = 1,
            vertical_after = {1},
            horizontal_after = {1,2},
            align = {"left", "center", "center"},
            valign = {"center", "top", "bottom"},
            style = TABLE.style.light_dim
        }

    }

    local explanation = LAYOUT.text{

        text = "Explanatory text,\nblabla bla bla\nblabla",
        align = "left"

    }

--U.dump_table(explanation)
    local framed_explanation = LAYOUT.frame{

        child = explanation,

        style = TABLE.style.light_dim,

        hpadding = 0,
        vpadding = 1,

        sides = {

            top = true,
            bottom = true,
            left = true,
            right = true

        }

    }

    local middle = LAYOUT.hstack{

        spacing = 8,
        align = "center",
        children = {
            --paradigm,
            framed_explanation
        }

    }



    --print("PARADIGM", paradigm.height)
    --print("MIDDLE", middle.height)

    --print("PARADIGM")
    --U.dump_table(paradigm.lines)

    --print("MIDDLE")
    --U.dump_table(middle.lines)

    print(table.concat(middle.lines, "\n"))


end












--##############################################################################
-- RETURN
--##############################################################################

return fullVIEW
