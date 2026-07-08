local S = require("state")
local WORD = require("entry.word")
local TOKEN = require("ipa.token")

--##############################################################################
-- SUBSCRIPT: Generates the stem forms of verbs
--##############################################################################

local VERB = {}

--==============================================================================
-- SECTION: Make stem forms
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION:
-- Decides entries final stemclass and generates the contracted stem forms
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function VERB.make_entry(entry)

    local input = entry.lemma.head.key

    local prefix = entry.lemma.head.prefix
    local suffix = entry.lemma.head.suffix

    local class = ""
    local stressrule = ""

    ----------------------------------------------------------------------------
    -- Add subtable
    -- Verbs are derived from contracted stem
    ----------------------------------------------------------------------------

    entry.stem.contracted = {}

    ----------------------------------------------------------------------------
    -- Determine stressrule
    ----------------------------------------------------------------------------

    local t = TOKEN.tokenize(input)

    -- determine if verb is derived from stemmclass n5 nominal
    if #t >= 4 then

        local last = t[#t]
        local penult = t[#t-1]

        local gem2 = t[#t-2]
        local gem1 = t[#t-3]

        local base = {}

        for i = 1, #t - 4 do
            table.insert(base, t[i])
        end

        base = table.concat(base)

        if gem1 == gem2
        and S.consonants_palat_lookup[ last ]
        and penult == "i" then

            stressrule = "penultimate"

        else
            stressrule = "ultimate"

        end

    else
        stressrule = "ultimate"

    end

    ----------------------------------------------------------------------------
    -- Determine verb class
    ----------------------------------------------------------------------------

    if suffix == "e" then
        class = "v1"

    elseif suffix == "i" then
        class = "v2"

    else
        -- TODO error
        return

    end

    ----------------------------------------------------------------------------
    -- Fill in entry
    ----------------------------------------------------------------------------

    entry.stem.class = class
    entry.stem.contracted.stressrule = stressrule

    WORD.build_word(
        input,
        entry.stem.contracted,
        prefix,
        suffix,
        class
    )

end

--##############################################################################
-- RETURN
--##############################################################################

return VERB
