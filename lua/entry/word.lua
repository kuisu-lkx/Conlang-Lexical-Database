local U = require("util")
local IPA = require("ipa.ipa")

--##############################################################################
-- SUBSCRIPT: Assembles morphemes into simple words
--##############################################################################

local WORD = {}

--==============================================================================
-- SECTION: Assemble simple word table
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION:
-- Generates the different stem formats and populates entry fields
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function WORD.build_word(seed, stem, prefix, suffix, stemclass)

    prefix = prefix or ""
    suffix = suffix or ""

    local stem_string = seed
    --local head_string = stem.bare

    if prefix ~= "" and U.needs_linking_h(prefix, stem_string) then
        stem_string = "h" .. stem_string

    end

    stem.format = {}
    stem.format.unicode = {}
    stem.format.ipa = {}
    stem.format.morphology = {}

    local ipa_prefix, ipa_main, ipa_suffix =
    IPA.make_word_ipa(
        stem_string,
        prefix,
        suffix,
        stemclass,
        stem.stressrule
    )

    if prefix ~= "" then
        stem.format.unicode.before = prefix
        stem.format.morphology.before = prefix .. "·"
        stem.format.ipa.before = ipa_prefix

    else
        stem.format.unicode.before = ""
        stem.format.morphology.before = ""
        stem.format.ipa.before = ""

    end

    stem.format.unicode.main = stem_string
    stem.format.morphology.main = stem_string
    stem.format.ipa.main = ipa_main

    if suffix ~= "" then
        stem.format.unicode.after = suffix
        stem.format.morphology.after = "·" .. suffix
        stem.format.ipa.after = ipa_suffix

    else
        stem.format.unicode.after = ""
        stem.format.morphology.after = ""
        stem.format.ipa.after = ""

    end

end

--##############################################################################
-- RETURN
--##############################################################################

return WORD
