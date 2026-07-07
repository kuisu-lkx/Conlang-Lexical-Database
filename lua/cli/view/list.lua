local S = require("state")
local U = require("util")
local ANSI = require("cli.ansi")
local BLOCK = require("cli.block")

--##############################################################################
-- SUBSCRIPT: CLI formatter for list view
--##############################################################################

local listVIEW = {}

--==============================================================================
-- SECTION: Local variables
--==============================================================================

local roman = {
    "I",
    "II",
    "III",
    "IV",
    "V",
    "VI",
    "VII",
    "IIX", -- TODO "VIII" ?
    "IX",
    "X",
}

--==============================================================================
-- SECTION: String formatters
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Format contracted stem string
--------------------------------------------------------------------------------

local function contracted_stem(entry, format, options)

    if not entry.stem.contracted then

        if format == "text" then
            return ""

        elseif format == "ipa" then
            return ANSI.dim(" [" .. out)

        end

    end

    local stem_contracted = {}

    if format == "text" then

        if options.morphology then
            stem_contracted = entry.stem.contracted.format.morphology

        else
            stem_contracted = entry.stem.contracted.format.unicode

        end

    elseif format == "ipa" then
        stem_contracted = entry.stem.contracted.format.ipa

    end

    local out = U.assemble_stem(stem_contracted)

    if format == "text" then

        if options.color then

            if entry.stem.class:match("^v") then
                out = ANSI.bold_yellow(out)

            elseif entry.stem.class:match("^n") then
                out = ANSI.bold_blue(out)

            else
                out = ANSI.bold(out)

            end

        else
            out = ANSI.bold(out)

        end

    elseif format == "ipa" then
        out = ANSI.dim(" [" .. out)

    end

    return out

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Format expanded stem string
--------------------------------------------------------------------------------

local function expanded_stem(entry, format, options)

    if not entry.stem.expanded then

        if format == "text" then

            if entry.stem.class:match("^n") then
                return " –"

            else
                return ""

            end

        elseif format == "ipa" then

            if entry.stem.class:match("^n") then
                return ANSI.dim(" –]")

            else
                return ANSI.dim("]")

            end

        end

    end

    local stem_expanded = {}

    if format == "text" then

        if options.morphology then
            stem_expanded = entry.stem.expanded.format.morphology

        else
            stem_expanded = entry.stem.expanded.format.unicode

        end

    elseif format == "ipa" then
        stem_expanded = entry.stem.expanded.format.ipa

    end

    local out = ""

    if U.assemble_stem(entry.stem.contracted.format.unicode) ==
        U.assemble_stem(entry.stem.expanded.format.unicode)
    and options.abbreviated then

        out = "~"

    else

        if stem_expanded.before ~= ""
        or (stem_expanded.modifier and stem_expanded.modifier ~= "") then

            if options.abbreviated then
                out = out .. "~"

            else

                if stem_expanded.modifier then
                    out = out .. stem_expanded.modifier .. stem_expanded.before

                else
                    out = out .. stem_expanded.before

                end

            end

        end

        out = out .. stem_expanded.main .. stem_expanded.after

    end

    if format == "text" then
        out = " " .. out

    elseif format == "ipa" then
        out = " " .. ANSI.dim(out .. "]")

    end

    return out

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Format status string TODO use BLOCK!
--------------------------------------------------------------------------------

local function status(entry, options)

    if options.status then

        if not entry.meta.status then
            return ""
        end

        local out = ""

        out = " ⟪" .. entry.meta.status .. "⟫"

        if options.color then

            if entry.meta.status == "canon" then
                out = out

            elseif entry.meta.status == "deprecated" then
                out = ANSI.red(out)

            elseif entry.meta.status == "draft" then
                out = ANSI.yellow(out)

            elseif entry.meta.status == "review" then
                out = ANSI.magenta(out)

            elseif entry.meta.status == "good" then
                out = ANSI.green(out)

            elseif entry.meta.status == "new" then
                out = ANSI.blue(out)

            else
                out = ANSI.orange(out)

            end

        else
            out = ANSI.bold(out)

        end

        return out

    else

        return ""

    end

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Format translations string TODO use BLOCK!
--------------------------------------------------------------------------------

function listVIEW.translations_string(entry)

    local out = {}

    local multiple_classes = #entry.classes > 1

    for class_index, class in ipairs(entry.classes) do

        table.insert(out, "       ")

        --if multiple_classes then -- <- uncomment to not display class numerals if only one class
        table.insert(out, ANSI.bold(roman[class_index] .. ". "))
        --end

        if class.type ~= "" then
            table.insert(out, class.type .. ": ")
        end

        local multiple_groups = #class.groups > 1

        for group_index, group in ipairs(class.groups) do

            if multiple_groups then
                table.insert(out, ANSI.bold(string.format("%d. ", group_index)))
            end

            if group.info ~= "" then
                table.insert(out, ANSI.dim("[" .. group.info .. "] "))
            end

            for translation_index, translation in ipairs(group.translations) do

                if translation.before ~= "" then
                    table.insert(out, ANSI.italic_dim(translation.before .. " "))
                end

                table.insert(out, translation.text)

                if translation.after ~= "" then
                    table.insert(out, ANSI.italic_dim(" " .. translation.after))
                end

                if translation_index < #group.translations then
                    table.insert(out, ", ")
                else
                    table.insert(out, ". ")
                end

            end

        end

        if class_index < #entry.classes then
            table.insert(out, "\n")
        end

    end
U.dump_table(out)

    return table.concat(out)

end

--==============================================================================
-- SECTION: Public Functions
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Print translations only in list view
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function listVIEW.print_translations(arg)

    local entry

    if type(arg) == "table" then
        entry = arg
    else
        entry = U.find_stem(arg)
    end

    print(translations_string(entry))

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Print entry in list view
--
-- Accepts either:
--     print_entry("fanaheak", options)
--
-- or:
--     print_entry(entry, options)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function listVIEW.print_entry(arg)

    local entry
    local options = S.options

    if type(arg) == "table" then
        entry = arg
    else
        entry = U.find_stem(arg)
    end

    local out = ""

    if not options.dense then
        out = out .. "\n"
    end

    out = out
        .. ANSI.bold("◆ ")
        .. contracted_stem(entry, "text", options)
        .. expanded_stem(entry, "text", options)
        .. contracted_stem(entry, "ipa", options)
        .. expanded_stem(entry, "ipa", options)
        .. status(entry, options)

    if entry.stem.class ~= "" then
        out = out .. " " .. entry.stem.class
    end

    if options.notes
    and entry.meta.notes then
        out = out .. " ■ " .. ANSI.dim("(has note)")
    end

    if options.translation then
        out = out .. ":\n" .. listVIEW.translations_string(entry)
    end

    if entry.meta.warning then
        out = out .. "\n      " .. ANSI.red(" ■ " .. entry.meta.warning)
    end

    if options.notes
    and entry.meta.attention then
        out = out .. "\n      " .. ANSI.yellow(" ■ " .. entry.meta.attention)
    end

    if options.citations then -- TODO
        out = out
        .. "\n      "
        --.. " ■ citations:"
        --.. " ※ " text, page ...
    end

    if options.changelog then -- TODO
        out = out
        .. "\n      "
        .. " ■ " .. ANSI.dim("date edited: ") .. entry.meta.date_edited
        .. " / " .. ANSI.dim("date added: ") .. entry.meta.date_added
        --.. "\n       ◇ " date: change

    end

    -- TODO display parents and siblings (via lemma-search)

    print(out)

end

--##############################################################################
-- RETURN
--##############################################################################

return listVIEW
