local U = require("util")
local ANSI = require("cli.ansi")
local tableVIEW = require("cli.view.table")

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

    nominal_paradigm()


    --print("----------------------------------------")

end












--##############################################################################
-- RETURN
--##############################################################################

return fullVIEW
