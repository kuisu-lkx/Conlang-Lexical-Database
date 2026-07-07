local S = require("state")
local U = require("util")

--##############################################################################
-- SUBSCRIPT:
-- Generate inflection paradigms from stem forms and add them to the entry
--##############################################################################

local PARADIGM = {}

--==============================================================================
-- SECTION: Generate inflection paradigms for nominals
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Generate paradigm and fill entry fields
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function PARADIGM.make_nominal(entry)

    local paradigm = { }
     -- TODO make input format switchable for ipa or morphology view paradigm

    if (
        entry.stem.class == "n1" or
        entry.stem.class == "n2" or
        entry.stem.class == "n3" or
        entry.stem.class == "n4" or
        entry.stem.class == "n5"
    ) then

        for case, endings in pairs(S.inflections.nominal[entry.stem.class]) do

            local base

            if endings.stem == "contracted" then
                base = U.assemble_stem(entry.stem.contracted.format.unicode)

            elseif endings.stem == "expanded" then
                base = U.assemble_stem(entry.stem.expanded.format.unicode)

            else
                --error
                return

            end

            paradigm[case] = {
                stem = endings.stem,
                sg = base .. endings.sg,
                gc = base .. endings.gc,
                pl = base .. endings.pl
            }

        end

        return paradigm

    else
        return nil

    end

end

--##############################################################################
-- RETURN
--##############################################################################

return PARADIGM
