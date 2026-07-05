local S = require("state")
local U = require("util")
local E = require("entry.entry")
local PARSER = require("cli.parser")
local listVIEW = require("cli.view.list")

--##############################################################################
-- SUBSCRIPT: Command line interface
--##############################################################################

local CLI = {}

--==============================================================================
-- SECTION: Prepare entries
--==============================================================================

--U.debug("DEBUG MODE ON")

-- Generate entries for simple words
E.generate_entries()

-- Generate entries for compound words
E.generate_compounds()

-- Generate paradigms
E.generate_paradigms()

--==============================================================================
-- SECTION: Sort entries
--==============================================================================

U.sort_by_alphabet(
    -- assembled unicode form
    function(e)
        return U.assemble_stem(e.stem.contracted.format.unicode)
    end,
    S.lkx_alphabet_lookup,
    S.entries
)
--[[
U.sort_by_order(
    function(e) return e.stem.class end,
    S.stemclass_order,
    S.entries
)
]]

--==============================================================================
-- SECTION: TODO: Functions to move
--==============================================================================

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

function CLI.print_entry_full(arg)

    local entry

    if type(arg) == "table" then
        entry = arg

    else
        entry = U.find_stem(arg)

    end

    print("----------------------------------------")

    U.dump_table(entry)

    print("----------------------------------------")

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: TODO
-- FIND BY KEY - TODO move to util?
--------------

-- Example:

--     find_by_key(
    --         "contractedstem",
--         "eak"
--     )
--------

-- Returns matching entries and prints their
-- citations.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CLI.find_by_key(key, value)

    local matches = U.search_entries(key, value)

    print(#matches .. " match(es)")

    for _, entry in ipairs(matches) do
        print(entry.stem.contracted.form)
    end

    return matches

end

--==============================================================================
-- SECTION: Interface commands
--==============================================================================

--parse command
local argv, options = PARSER.parse_options()

local cmd = argv[1]

-- menu
if cmd == "print" then
    listVIEW.print_entry(argv[2], options)

elseif cmd == "print_list" then

    for i = 2, #argv do
        listVIEW.print_entry(argv[i], options)
    end

    print("") --newline

elseif cmd == "print_all" then

    for _, entry in ipairs(S.entries) do
        listVIEW.print_entry(entry, options)
    end

    print("") --newline

elseif cmd == "print_full" then
    CLI.print_entry_full(argv[2])

elseif cmd == "find" then
    CLI.find_by_key(argv[2], argv[3])

elseif cmd == "translate" then
    --print_translations(argv[2])

end

--##############################################################################
-- RETURN
--##############################################################################

return CLI
