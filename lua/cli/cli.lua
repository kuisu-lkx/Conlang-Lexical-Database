local S = require("state")
local U = require("util")
local E = require("entry.entry")
local PARSER = require("cli.parser")
--local listVIEW = require("cli.view.list")
--local fullVIEW = require("cli.view.full")
local COMMAND = require("cli.command")

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


function CLI.shell()

    print("Hello :3")

    while true do

        io.write("lkx> ")

        local input = io.read()

        if not input then
            break
        end

        if input == "" then
            goto continue
        end

        local argv = PARSER.parse_string(input)

        if argv[1] == "exit" then
            break
        end

        local ok, err = pcall(function()
            COMMAND.execute(argv)
        end)

        if not ok then
            print(err)
        end

        ::continue::

    end

end








local argv = PARSER.parse_options()

if #argv == 0 then
    CLI.shell()
else
    COMMAND.execute(argv)
end


--##############################################################################
-- RETURN
--##############################################################################

return CLI
