local S = require("state")
local unicode = require("unicode")
local TOKEN = require("ipa.token")
local WORD = require("entry.word")

--##############################################################################
-- SUBSCRIPT: Generates the stem forms of nominals
--##############################################################################

local NOMINAL = {}

--==============================================================================
-- SECTION: Make contracted stem forms
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION:
-- Decides entries final stemclass and generates the contracted stem forms
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function make_contractedstem(entry)

    ----------------------------------------------------------------------------
    -- Add subtable
    ----------------------------------------------------------------------------

    entry.stem.contracted = {}

    ----------------------------------------------------------------------------
    -- Determine stressrule
    ----------------------------------------------------------------------------

    if entry.stem.class == "n5" then
        entry.stem.contracted.stressrule = "penultimate"

    else
        entry.stem.contracted.stressrule = "ultimate"

    end

    ----------------------------------------------------------------------------
    -- Fill in entry
    ----------------------------------------------------------------------------

    WORD.build_word(
        entry.lemma.head,
        entry.stem.contracted,
        entry.affix.prefix,
        entry.affix.suffix,
        entry.stem.class
    )

end

--==============================================================================
-- SECTION: Make expanded stem forms
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION:
-- Determine entries final stemclass and generates the expanded stem forms
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function make_expandedstem(entry)

    local input = entry.lemma.head
    local output = ""

    local prefix = entry.affix.prefix
    local suffix = entry.affix.suffix

    local class = ""
    local stressrule = ""

    local matched = false

    ----------------------------------------------------------------------------
    -- Do not change entry if stemclass is not a nominal
    -- (only nominals can form an expanded stem)
    ----------------------------------------------------------------------------

    if not (
        entry.stem.class == "n"
    ) then
        return
    end

    ----------------------------------------------------------------------------
    -- N5
    -- Geminate + i + palatal consonant (l, n, r, s)
    -- aþþir -> aþri
    ----------------------------------------------------------------------------

    if not matched then
        local t = TOKEN.tokenize(input)

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

                matched = true
                class = "n5"
                stressrule = "penultimate"
                output = base .. gem1 .. last .. penult

            end
        end
    end

    ----------------------------------------------------------------------------
    -- N1
    -- Ends in long vowel or diphthong
    ----------------------------------------------------------------------------

    if not matched then

        for _, final in ipairs(S.n1_finals) do

            if input:match(final .. "$") then
                matched = true
                class = "n1"
                stressrule = "ultimate"
                output = input
                break

            end

        end

    end

    ----------------------------------------------------------------------------
    -- N2
    -- Diphthong + 1-2 consonants
    ----------------------------------------------------------------------------

    if not matched then

        for _, diphthong in ipairs(S.diphthongs) do

            local consonants =
                input:match(
                    diphthong .. "([%a][%a]?)$"
                )

            if consonants then

                local first = unicode.utf8.sub(diphthong, 1, 1)

                local second = unicode.utf8.sub(diphthong, 2, 2)

                local long_first = first

                if S.short_to_long[first] then
                    long_first = S.short_to_long[first]
                end

                local string =
                    input:gsub(
                        diphthong .. consonants .. "$",
                        long_first .. consonants .. second
                    )

                matched = true
                class = "n2"
                stressrule = "penultimate"
                output = string
                break

            end

        end

    end

    ----------------------------------------------------------------------------
    -- N3
    -- Long vowel + 1-2 consonants
    ----------------------------------------------------------------------------

    if not matched then

        for _, long in ipairs(S.vowels_long) do

            local short = S.long_to_short[long]

            local consonants =
                input:match(
                    long .. "([%a][%a]?)$"
                )

            if consonants then

                local string =
                    input:gsub(
                        long .. consonants .. "$",
                        short ..
                        consonants ..
                        short
                    )

                matched = true
                class = "n3"
                stressrule = "penultimate"
                output = string
                break

            end

        end

    end

    ----------------------------------------------------------------------------
    -- N4
    -- Short vowel + 1-2 consonants
    ----------------------------------------------------------------------------

    if not matched then

        for _, short in ipairs(S.vowels_short) do

            if input:match(
                short .. "[%a][%a]?$"
            ) then

                matched = true
                class = "n4"
                stressrule = "ultimate"
                output = ""
                break

            end

        end

    end
--[[
    ----------------------------------------------------------------------------
    -- N6 -- TODO redefine, rewrite
    -- consonant + e
    -- me -> ma
    ----------------------------------------------------------------------------

    local consonant =
        contractedstem:match("^(.+)e$")
    extended_ipa = IPA.make_ipa(consonant .. "a", "n6", "ultimate")
    if consonant then
        return consonant .. "a", extended_ipa, "n6"
    end
    ]]

    ----------------------------------------------------------------------------
    -- Fallback
    ----------------------------------------------------------------------------

    if not matched then

        class = "n?"
        stressrule = "none"
        output = input

    end

    ----------------------------------------------------------------------------
    -- Fill in entry
    ----------------------------------------------------------------------------

    entry.stem.class = class

    if output ~= "" then

        entry.stem.expanded = {}
        entry.stem.expanded.stressrule = stressrule

        WORD.build_word(
            output,
            entry.stem.expanded,
            prefix,
            suffix,
            entry.stem.class
        )

    end

end

--==============================================================================
-- SECTION: Public interface
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Public interface
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function NOMINAL.make_entry(entry)

    make_expandedstem(entry) -- has to run first. determines stem.class
    make_contractedstem(entry)

end

--##############################################################################
-- RETURN
--##############################################################################

return NOMINAL
