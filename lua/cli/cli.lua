local S = require("state")
local U = require("util")
local E = require("entry.entry")
local PARSER = require("cli.parser")
local listVIEW = require("cli.view.list")
local fullVIEW = require("cli.view.full")

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
local argv = PARSER.parse_options()
local cmd = argv[1]

-- menu
--if cmd == "print" then
    --listVIEW.print_entry(argv[2])

if cmd == "list" then

    listVIEW.print_screen(argv)

elseif cmd == "show" then
    fullVIEW.print_screen(argv[2])

elseif cmd == "find" then
    CLI.find_by_key(argv[2], argv[3])

--elseif cmd == "translate" then
    --print_translations(argv[2])
else
    error("Unknown command: " .. cmd)
end

--##############################################################################
-- RETURN
--##############################################################################

return CLI
