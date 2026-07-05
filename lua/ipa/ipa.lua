--local S = require("state")
local U = require("util")
local STRESS = require("ipa.stress")
local TOKEN = require("ipa.token")
local RENDER = require("ipa.render")

--##############################################################################
-- SUBSCRIPT: Generate IPA
--##############################################################################

local IPA = {}

--==============================================================================
-- SECTION: Generate IPA renders from unicode inputs, observing phonology rules
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Make simple word IPA
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function IPA.make_word_ipa(
    stem,
    prefix,
    suffix,
    stemclass,
    stressrule
)

    prefix = prefix or ""
    suffix = suffix or ""

    local tokens = {}
    local stress = {}
    local stem_offset = 0
    local suffix_offset = 0

    ----------------------------------------------------------------------------
    -- Assemble token streams of head and modifier individually
    ----------------------------------------------------------------------------

    tokens, stress.primary, stem_offset, suffix_offset =
        TOKEN.assemble_stream(stem, prefix, suffix, stemclass, stressrule)

    ----------------------------------------------------------------------------
    -- Render IPA
    ----------------------------------------------------------------------------

    --local main_offset = stem_offset + 1

    local before, main, after =
    RENDER.ipa(
        tokens,
        stress,
        stem_offset,
        suffix_offset
    )

    ----------------------------------------------------------------------------
    -- Return parts of entry.stem.format.ipa for simple word
    ----------------------------------------------------------------------------

    return before, main, after

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Make compound word IPA
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function IPA.make_compound_ipa(modifier_stem, head_stem, modifier, head)

    local head_tokens = {}
    local modifier_tokens = {}

    local stress = {}

    local head_stem_offset = 0
    local head_suffix_offset = 0

    ----------------------------------------------------------------------------
    -- Assemble token streams of head and modifier individually
    ----------------------------------------------------------------------------

    head_tokens, stress.primary, head_stem_offset, head_suffix_offset =
        TOKEN.assemble_stream(
            head_stem.format.unicode.main,
            head_stem.format.unicode.before,
            head_stem.format.unicode.after,
            head.stem.class,
            head_stem.stressrule
        )

    local head_offset = head_stem_offset

    modifier_tokens, stress.secondary =
        TOKEN.assemble_stream(
            modifier_stem.format.unicode.main,
            modifier_stem.format.unicode.before,
            modifier_stem.format.unicode.after,
            modifier.stem.class,
            modifier_stem.stressrule
        )

    ----------------------------------------------------------------------------
    -- Insert linking h in between them if necessary and move stress marker
    ----------------------------------------------------------------------------

    if U.needs_linking_h(modifier_tokens[#modifier_tokens], head_tokens[1]) then

        table.insert(head_tokens, 1, "h")

        stress.primary.nucleus = stress.primary.nucleus + 1

        -- don't move stress marker if head begins with it, otherwise do
        if stress.primary.marker > 1 then

            stress.primary.marker = stress.primary.marker + 1
            head_stem_offset = head_stem_offset + 1

        end

    end

    ----------------------------------------------------------------------------
    -- Assemble compounds token stream
    ----------------------------------------------------------------------------

    local tokens =
        TOKEN.concatenate_stream(modifier_tokens, head_tokens)

    stress.primary.nucleus =
        stress.primary.nucleus + #modifier_tokens
    stress.primary.marker =
        stress.primary.marker + #modifier_tokens

    ----------------------------------------------------------------------------
    -- Render IPA
    ----------------------------------------------------------------------------

    -- add "+ head_offset" to exclude head prefix from abbreviated ipa
    local main_offset = #modifier_tokens + head_stem_offset + 0
    local after_offset = #modifier_tokens + head_suffix_offset +1
    local head_offset = #modifier_tokens
    local before, main, after, modifier =
    RENDER.ipa(
        tokens,
        stress,
        main_offset,
        after_offset,
        head_offset
    )

    ----------------------------------------------------------------------------
    -- Return parts of entry.stem.format.ipa for compound word
    ----------------------------------------------------------------------------

    return before, main, after, modifier

end

--##############################################################################
-- RETURN
--##############################################################################

return IPA
