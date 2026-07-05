local S = require("state")
local PARADIGM = require("entry.paradigm")
local NOMINAL = require("entry.nominal")
local VERB = require("entry.verb")
local LOAD = require("entry.load")
local COMPOUND = require("entry.compound")

--##############################################################################
-- SUBSCRIPT: Initialize entries
--##############################################################################

local E = {}

--==============================================================================
-- SECTION: Normalize entries and generate fields
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Generate entries for simple words
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function E.generate_entries()

    LOAD.load_entries()

    for _, entry in ipairs(S.entries) do

        if entry.stem.class:match("^n") then
            NOMINAL.make_entry(entry)


        elseif entry.stem.class:match("^v") then
            VERB.make_entry(entry)
--[[ TODO:
        else

            PARTICLE.make_entry(entry)
        ]]

        end

    end

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Generate entries for compound words
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function E.generate_compounds()

    LOAD.load_compounds()

    for _, compound in ipairs(S.compounds) do

        local entry = COMPOUND.make_compound(compound)

        table.insert(S.entries, entry)

    end

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Generate inflection paradigms for entries
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function E.generate_paradigms()

        for _, entry in ipairs(S.entries) do
            --if class needed?
            entry.paradigm = PARADIGM.make_nominal(entry)

        end

end

--##############################################################################
-- RETURN
--##############################################################################

return E
