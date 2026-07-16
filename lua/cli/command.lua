local S = require("state")
local U = require("util")
--local E = require("entry.entry")
--local PARSER = require("cli.parser")
local listVIEW = require("cli.view.list")
local fullVIEW = require("cli.view.full")



--##############################################################################
-- SUBSCRIPT: CLI commands
--##############################################################################

local COMMAND = {}


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

function COMMAND.find_by_key(key, value)

    local matches = U.search_entries(key, value)--TODO replace with query search!

    print(#matches .. " match(es)")

    for _, entry in ipairs(matches) do
        print(entry.stem.contracted.form)
    end

    return matches

end


function COMMAND.execute(argv)

    local cmd = argv[1]

    if cmd == "list" then

        listVIEW.print_screen(argv)

    elseif cmd == "show" then
        fullVIEW.print_screen(argv)

    elseif cmd == "find" then
        COMMAND.find_by_key(argv[2].value, argv[3].value)

    --elseif cmd == "translate" then
        --print_translations(argv[2])
    else
        error("Unknown command: " .. cmd)
    end

end

--##############################################################################
-- RETURN
--##############################################################################

return COMMAND
