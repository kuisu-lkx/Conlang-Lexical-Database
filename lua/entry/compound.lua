local S = require("state")
local U = require("util")
local IPA = require("ipa.ipa")
local unicode = require("unicode")
local TOKEN = require("ipa.token")
local CONSTRUCTOR = require("entry.constructor")

--##############################################################################
-- SUBSCRIPT: Assembles modifier and head into compound words
--##############################################################################

local COMPOUND = {}

--==============================================================================
-- SECTION: Compound generator
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION:
-- Generates the different stem formats and populates entry fields
--------------------------------------------------------------------------------

local function build_compound_stem(
    modifier_stem,
    head_stem,
    entry_stem,
    head_stemclass
)
    ----------------------------------------------------------------------------
    -- Add subtables
    ----------------------------------------------------------------------------

    entry_stem.format = {}
    entry_stem.format.unicode = {}
    entry_stem.format.morphology = {}

    ----------------------------------------------------------------------------
    -- Add modifier format fields
    ----------------------------------------------------------------------------

    entry_stem.format.unicode.modifier =
        U.assemble_stem(modifier_stem.format.unicode)
    entry_stem.format.morphology.modifier =
        U.assemble_stem(modifier_stem.format.morphology) .. ":"

    ----------------------------------------------------------------------------
    -- Add head format fields for "before" and "main"
    ----------------------------------------------------------------------------

    if head_stem.format.unicode.before ~= "" then

        ------------------------------------------------------------------------
        -- Attach linking h to "before" if present and neccessary
        ------------------------------------------------------------------------

        if U.needs_linking_h(
            entry_stem.format.unicode.modifier,
            head_stem.format.unicode.before
        ) then

            entry_stem.format.unicode.before =
                "h" .. head_stem.format.unicode.before
            entry_stem.format.morphology.before =
                "h" .. head_stem.format.morphology.before

        else
            entry_stem.format.unicode.before =
                head_stem.format.unicode.before
            entry_stem.format.morphology.before =
                head_stem.format.morphology.before

        end

        ------------------------------------------------------------------------
        -- Attach "main"
        ------------------------------------------------------------------------

        entry_stem.format.unicode.main = head_stem.format.unicode.main
        entry_stem.format.morphology.main = head_stem.format.morphology.main

    else
        ------------------------------------------------------------------------
        -- Attach linking h to "main" if neccessary
        ------------------------------------------------------------------------

        entry_stem.format.unicode.before = ""
        entry_stem.format.morphology.before = ""

        if U.needs_linking_h(
            entry_stem.format.unicode.modifier,
            head_stem.format.unicode.main
        ) then

            entry_stem.format.unicode.main =
                "h" .. head_stem.format.unicode.main
            entry_stem.format.morphology.main =
                "h" .. head_stem.format.morphology.main

        else
            entry_stem.format.unicode.main =
                head_stem.format.unicode.main
            entry_stem.format.morphology.main =
                head_stem.format.morphology.main

        end

    end

    ----------------------------------------------------------------------------
    -- Add head format fields for "after"
    ----------------------------------------------------------------------------

    entry_stem.format.unicode.after = head_stem.format.unicode.after
    entry_stem.format.morphology.after = head_stem.format.morphology.after

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION:
-- Generates the compounds entry and populates entry fields
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function COMPOUND.make_compound(compound)

    ----------------------------------------------------------------------------
    -- Find modifier and head entry
    ----------------------------------------------------------------------------

    local modifier =
        U.find_stem(
            compound.modifier.form,-- TODO rename input var
            compound.modifier.index
        )

    local head =
        U.find_stem(
            compound.head.form,-- TODO rename input var
            compound.head.index
        )

    ----------------------------------------------------------------------------
    -- Generate new entry
    ----------------------------------------------------------------------------

    local entry =
        CONSTRUCTOR.entry{
            comment = compound.comment,

            table.unpack(compound.classes),
            -- TODO meta = table.unpack(compound.changes)
        }

    ----------------------------------------------------------------------------
    -- Fill inherited fields
    ----------------------------------------------------------------------------

    entry.lemma.head = head.lemma.head
    entry.lemma.head_index = head.lemma.head_index
    entry.lemma.head.prefix = head.lemma.head.prefix
    entry.lemma.head.suffix = head.lemma.head.suffix
    entry.lemma.modifier = {}
    entry.lemma.modifier.key = modifier.lemma.head.key
    entry.lemma.modifier.index = modifier.lemma.head.index
    entry.lemma.modifier.prefix = modifier.lemma.head.prefix
    entry.lemma.modifier.suffix = modifier.lemma.head.suffix
    entry.source = compound.source

    ----------------------------------------------------------------------------
    -- Generate and fill head contracted stem forms
    ----------------------------------------------------------------------------

    entry.stem.class = head.stem.class
    entry.stem.contracted = {}
    entry.stem.contracted.stressrule = head.stem.contracted.stressrule

    if head.affix.prefix
    and head.affix.prefix ~= "" then
        entry.affix.prefix = head.affix.prefix
    end

    if head.affix.suffix
    and head.affix.suffix ~= "" then
        entry.affix.suffix = head.affix.suffix
    end

    ----------------------------------------------------------------------------
    -- Generate and fill modifier stem forms
    ----------------------------------------------------------------------------

    local modifier_stem = {}

    --choose the right stem form for the modifier to combine
    if modifier.stem.expanded then
        modifier_stem = modifier.stem.expanded
    else
        modifier_stem = modifier.stem.contracted
    end

    build_compound_stem(
        modifier_stem,
        head.stem.contracted,
        entry.stem.contracted,
        head.stem.class
    )

    entry.stem.contracted.format.ipa = {}

    entry.stem.contracted.format.ipa.before,
    entry.stem.contracted.format.ipa.main,
    entry.stem.contracted.format.ipa.after,
    entry.stem.contracted.format.ipa.modifier
        = IPA.make_compound_ipa(
            modifier_stem,
            head.stem.
            contracted,
            modifier,
            head
        )

    ----------------------------------------------------------------------------
    -- Generate and fill head expanded stem forms if neccessary
    ----------------------------------------------------------------------------

    if head.stem.expanded then

        entry.stem.expanded = {}
        entry.stem.expanded.stressrule = head.stem.expanded.stressrule

        build_compound_stem(
            modifier_stem,
            head.stem.expanded,
            entry.stem.expanded,
            head.stem.class
        )

        entry.stem.expanded.format.ipa = {}

        entry.stem.expanded.format.ipa.before,
        entry.stem.expanded.format.ipa.main,
        entry.stem.expanded.format.ipa.after,
        entry.stem.expanded.format.ipa.modifier
            = IPA.make_compound_ipa(
                modifier_stem,
                head.stem.expanded,
                modifier,
                head
            )

    end

    ----------------------------------------------------------------------------
    -- RETURN
    ----------------------------------------------------------------------------

    return entry

end

--##############################################################################
-- RETURN
--##############################################################################

return COMPOUND
