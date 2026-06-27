local S = require("state")
local U = require("util")
local IPA = require("ipa")
local unicode = require("unicode")

--#############################################################################
-- SUBSCRIPT FOR ENTRY PROCESSING
--#############################################################################

local E = {}

local entry_dir = "../entries"

--#############################################################################
-- INPUT FILE LOADER
-- Loads all input files *.root.lua and *part.lua and saves their datasets in
-- the global entries table in state.lua.
--#############################################################################

function E.load_entries()

    local lfs = require("lfs")
    local files = {}
    local function scan(dir)

        for file in lfs.dir(dir) do
            if file ~= "." and file ~= ".." then

                local path = dir .. "/" .. file
                local attr = lfs.attributes(path)

                if attr.mode == "directory" then

                    scan(path)

                else

                    local lower = file:lower()

                    if lower:match("%.root%.lua$")
                        or lower:match("%.part%.lua$")
                    then
                        table.insert(files, path)
                    end
                end
            end
        end
    end

    scan(entry_dir)

    table.sort(files)

    for _, file in ipairs(files) do
        local entries = dofile(file)
        for _, entry in ipairs(entries) do
            table.insert(S.entries, entry)
        end
    end
end

--#############################################################################
-- TRANSLATION CONSTRUCTOR
--
-- Short form:
--     translation("horse")
--
-- Long form:
--     translation{
--         text   = "wild horse",
--         index  = {"horse"},
--         before = "somebody",
--         after  = "archaic"
--     }
--
-- Returns a normalized translation table.
--#############################################################################

function E.translation(arg)

    if type(arg) == "string" then
        arg = {
            text = arg
        }
    end

    if arg[1] then
        arg.text = arg[1]
    end

    arg.text   = arg.text   or ""
    arg.before = arg.before or ""
    arg.after  = arg.after  or ""

    if arg.index == nil or #arg.index == 0 then
        arg.index = {arg.text}
    elseif type(arg.index) ~= "table" then
        arg.index = {arg.index}
    end

    return {
        kind   = "translation",
        text   = arg.text,
        index  = arg.index,
        before = arg.before,
        after  = arg.after,
    }
end


--#############################################################################
-- FIND ENTRIES
--#############################################################################

function find_entries(key, value)

    local result = {}

    for _, entry in ipairs(S.entries) do

        if entry[key] == value then
            table.insert(result, entry)
        end

    end

    return result

end

--#############################################################################
-- GROUP CONSTRUCTOR
--
-- Example:
--
-- group{
--     info = "with Med.",
--
--     translation("meet"),
--     translation("encounter")
-- }
--#############################################################################

function E.group(tbl)

    local translations = {}

    for _, item in ipairs(tbl) do
        table.insert(translations, item)
    end

    return {
        kind = "group",
        info = tbl.info or "",
        translations = translations
    }
end

--#############################################################################
-- CLASS CONSTRUCTOR
--
-- Example:
--
-- class{
--     type = "v",
--
--     group{ ... },
--     group{ ... }
-- }
--#############################################################################

function E.class(tbl)

    local groups = {}

    for _, item in ipairs(tbl) do
        table.insert(groups, item)
    end

    return {
        kind = "class",
        type = tbl.type or "",
        groups = groups
    }
end

--#############################################################################
-- ENTRY CONSTRUCTOR
--
-- Normalizes all top-level entry fields.
--#############################################################################


function E.entry(tbl)

    local classes = {}


    for _, item in ipairs(tbl) do
        table.insert(classes, item)
    end

    if tbl.expandedstem == "~" then
        tbl.expandedstem = tbl.contractedstem
    end

    return {
        kind           = "entry",
        citation       = "",
        headindex      = tbl.headindex      or 0,
        contractedstem = tbl.contractedstem or "",
        expandedstem   = tbl.expandedstem   or "",
        modifier       = tbl.modifier       or "",
        prefix         = tbl.prefix         or "",
        postfix        = tbl.postfix        or "",
        stemclass      = tbl.stemclass      or "",
        ipa_cstem      = "",
        ipa_estem      = "",
        ipa_head       = "",
        intermedstem   = tbl.intermedstem   or "",
        comment        = tbl.comment        or "",
        classes        = classes
    }
end

--#############################################################################
-- INPUT FILE API
--
-- Makes constructors available to entry source files loaded via dofile().
--#############################################################################

entry       = E.entry
class       = E.class
group       = E.group
translation = E.translation

--#############################################################################
-- CITATION CONSTRUCTOR
-- Generates unique citations for every non-compounded entry
--#############################################################################

function E.make_citation(entry)

    local citation_string
    local citation_ipa

    citation_string =
        entry.prefix
        .. entry.contractedstem
        .. entry.postfix

    citation_ipa =
        IPA.make_ipa(entry.prefix, "prefix", "none")
        .. entry.ipa_cstem
        .. IPA.make_ipa(entry.postfix, "postfix", "none")

    return citation_string, citation_ipa

end

--#############################################################################
-- COMPOUND CONSTRUCTOR
-- Generates unique citations for every compounded entry
-- Has to run after make_citation()
--#############################################################################

function E.make_compound(entry)

    local citation_string
    local citation_ipa
    local modifier_string
    local modifier_ipa
    local head_string
    local head_ipa

    ---------------------------------------------------------------------------
    -- Construct modifier_string and modifier_ipa
    ---------------------------------------------------------------------------

    -- look up given modifier citation in entries
    local modifier_entry =
        U.find_entry(
            "citation",
            entry.modifier
        )

    -- error if nothing found
    if not modifier_entry then
        error(
            "Modifier not found in citations: "
            .. entry.modifier
        )
    end

    -- get correct stem-form for composition from modifiers entry
    if modifier_entry.expandedstem == "" then
        modifier_string = modifier_entry.contractedstem
        modifier_ipa = modifier_entry.ipa_cstem
    else
        modifier_string = modifier_entry.expandedstem
        modifier_ipa = modifier_entry.ipa_estem
    end

    -- if stress is explicitly marked in modifier: swap acute -> grave to
    -- indicate secondary stress
    for primary, secondary in pairs(S.vowel_explicit_secondary) do
        modifier_string = modifier_string:gsub(primary, secondary)
    end

    -- swap ipa stress mark of compstem to secondary stress
    modifier_ipa = modifier_ipa:gsub("ˈ", "ˌ")

    -- add prefix and postfix
    modifier_ipa =
        IPA.make_ipa(modifier_entry.prefix, "", "none")
        .. modifier_ipa
        .. IPA.make_ipa(modifier_entry.postfix, "", "none")

    -- assemble modifier_string
    modifier_string =
        modifier_entry.prefix
        .. modifier_string
        .. modifier_entry.postfix

    ---------------------------------------------------------------------------
    -- Construct head_string and head_ipa
    ---------------------------------------------------------------------------

    -- assemble head_string
    head_string =
        entry.prefix
        .. entry.contractedstem
        .. entry.postfix

    -- construct head_ipa: add linking element, prefix and suffix and rerender
    -- stress if neccessary through make_ipa()
    if entry.prefix == "" then
        if U.needs_linking_h(modifier_string, entry.contractedstem) then
            head_ipa =
                IPA.make_ipa(
                    "h" .. entry.contractedstem,
                    entry.stemclass,
                    "ultimate")
                .. IPA.make_ipa(entry.postfix, "", "none")
        else
            head_ipa =
                entry.ipa_cstem
                .. IPA.make_ipa(entry.postfix, "", "none")
        end
    else
        if U.needs_linking_h(modifier_string, entry.prefix) then
            head_ipa =
                IPA.make_ipa("h" .. entry.prefix, "", "none")
                .. entry.ipa_cstem
                .. IPA.make_ipa(entry.postfix, "", "none")
        else
            head_ipa =
                IPA.make_ipa(entry.prefix, "", "none")
                .. entry.ipa_cstem
                .. IPA.make_ipa(entry.postfix, "", "none")
        end
    end


    ---------------------------------------------------------------------------
    -- Construct citation_string and citation_ipa
    ---------------------------------------------------------------------------

    citation_ipa =
        modifier_ipa
        .. head_ipa

    -- Insert linking element if neccessary
    if U.needs_linking_h(modifier_string, entry.contractedstem) then
        citation_string = modifier_string .. "h" .. head_string
    else
        citation_string = modifier_string .. head_string
    end

    return citation_string, citation_ipa

end

--#############################################################################
-- EXPANDED STEM GENERATOR
--
-- Generates:
--     expandedstem
--     derived stemclass
--
-- Returns:
--     expandedstem, stemclass
--#############################################################################

function E.make_expandedstem(entry)

    local contractedstem = entry.contractedstem

    local stemclass = entry.stemclass

    if not (
        stemclass == "n"
    ) then
        return entry.expandedstem, entry.stemclass
    end

    ---------------------------------------------------------------------------
    -- N5
    -- Geminate + i + palatal consonant
    -- aþþir -> aþri
    ---------------------------------------------------------------------------

    do
        local gem1, gem2, pal =
            contractedstem:match("(.)%(1)i([r])$")

        if gem1 and gem2 and pal then
            return
                contractedstem:gsub("(.)%1i([r])$", "%1%2i"),
                "n5"
        end
    end

    ---------------------------------------------------------------------------
    -- N1
    -- Ends in long vowel or diphthong
    ---------------------------------------------------------------------------

    for _, vowel in ipairs(S.vowels_long) do

        if contractedstem:match(vowel .. "$") then
            return contractedstem, "n1"
        end
    end

    for _, diphthong in ipairs(S.diphthongs) do

        if contractedstem:match(diphthong .. "$") then
            return contractedstem, "n1"
        end
    end

    ---------------------------------------------------------------------------
    -- N2
    -- Diphthong + 1-2 consonants
    ---------------------------------------------------------------------------

    for _, diphthong in ipairs(S.diphthongs) do

        local consonants =
            contractedstem:match(
                diphthong .. "([%a][%a]?)$"
            )

        if consonants then

            local first =
                unicode.utf8.sub(diphthong, 1, 1)

            local second =
                unicode.utf8.sub(diphthong, 2, 2)

            local long_first = first

            if S.short_to_long[first] then
                long_first = S.short_to_long[first]
            end

            local stem =
                contractedstem:gsub(
                    diphthong .. consonants .. "$",
                    long_first ..
                    consonants ..
                    second
                )

            return stem, "n2"
        end
    end

    ---------------------------------------------------------------------------
    -- N3
    -- Long vowel + 1-2 consonants
    ---------------------------------------------------------------------------

    for _, long in ipairs(S.vowels_long) do

        local short = S.long_to_short[long]

        local consonants =
            contractedstem:match(
                long .. "([%a][%a]?)$"
            )

        if consonants then

            local stem =
                contractedstem:gsub(
                    long .. consonants .. "$",
                    short ..
                    consonants ..
                    short
                )

            return stem, "n3"
        end
    end

    ---------------------------------------------------------------------------
    -- N4
    -- Short vowel + 1-2 consonants
    ---------------------------------------------------------------------------

    for _, short in ipairs(S.vowels_short) do

        if contractedstem:match(
            short .. "[%a][%a]?$"
        ) then

            return contractedstem, "n4"
        end
    end

    ---------------------------------------------------------------------------
    -- N6
    -- consonant + e
    -- me -> ma
    ---------------------------------------------------------------------------

    local consonant =
        contractedstem:match("^(.+)e$")

    if consonant then
        return consonant .. "a", "n6"
    end

    ---------------------------------------------------------------------------
    -- Fallback
    ---------------------------------------------------------------------------

    return contractedstem, stemclass
end

--#############################################################################
-- NORMALIZE ENTRIES
-- Adds generated content into dataset
--#############################################################################

function E.normalize_entries()

    for _, entry in ipairs(S.entries) do

        entry.expandedstem, entry.stemclass = E.make_expandedstem(entry)

    end

    for _, entry in ipairs(S.entries) do

        entry.ipa_cstem =
        IPA.make_ipa(
            entry.contractedstem,
            entry.stemclass,
            "ultimate"
        )

        entry.ipa_estem =
        IPA.make_ipa(
            entry.expandedstem,
            entry.stemclass,
            "penultimate"
        )

    end

    for _, entry in ipairs(S.entries) do

        if entry.modifier == "" then

            entry.citation, entry.ipa_head = E.make_citation(entry)

        end

    end


    for _, entry in ipairs(S.entries) do
        if entry.modifier ~= "" then
            entry.citation, entry.ipa_head = E.make_compound(entry)

        end
    end


end

return E



--[[How to structure mainscript

-- Load all source files
E.load_entries()

-- Resolve compounds and generated fields
E.normalize_entries()

-- Build output structures
D.build_dictionary()
I.build_translation_index()
R.build_root_index()
...
]]






