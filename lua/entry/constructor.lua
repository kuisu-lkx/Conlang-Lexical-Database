local S = require("state")

--#############################################################################
-- SUBSCRIPT: Table constructors
--#############################################################################

local CONSTRUCTOR = {}

--==============================================================================
-- SECTION: Entry constructors
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Translation constructor
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
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CONSTRUCTOR.translation(arg)

    if type(arg) == "string" then
        arg = {text = arg}
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

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Group constructor
--
-- Example:
--
-- group{
--     info = "with Med.",
--
--     translation("meet"),
--     translation("encounter")
-- }
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CONSTRUCTOR.group(tbl)

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

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Class constructor
--
-- Example:
--
-- class{
--     type = "v",
--
--     group{ ... },
--     group{ ... }
-- }
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CONSTRUCTOR.class(tbl)

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

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Change constructor
-- TODO
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CONSTRUCTOR.change(tbl)

    return {
        kind = "change",
        date = tbl.date or "",
        note = tbl.note or ""
    }

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Citation constructor
-- TODO
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CONSTRUCTOR.citation(tbl)

    return {
        kind = "citation",
        source = tbl.source or ""
    }

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Entry constructor
-- Normalizes all top-level entry fields.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CONSTRUCTOR.entry(tbl)

    local classes = {}
    local citations = {}
    local changes = {}

    for _, item in ipairs(tbl) do

        if item.kind == "class" then
            table.insert(classes, item)

        elseif item.kind == "citation" then
            table.insert(citations, item)

        elseif item.kind == "change" then
            table.insert(changes, item)

        end

    end

    return {
        kind           = "entry",
        comment        = tbl.comment or "",

        source = {
            --directories = {},
            categories = {},-- TODO only save path in loader, later parse in meta.category
            --no_auto_cat = tbl.no_auto_cat or false,-- if not set
            file = "",
        },

        lemma = {
            head = {
                key = tbl.head or "",
                index = tbl.head_idx or 0,
                prefix = tbl.prefix or "",
                suffix = tbl.suffix or "",
            },
        },

        stem = {
            class         = tbl.class or "?",
            intermediate  = tbl.intermediate,
        },

        affix = {-- TODO replace everywhere and delete
            prefix = tbl.prefix,
            suffix = tbl.suffix,
        },

        meta = {
            status = tbl.status or "none",
            warning = tbl.warning,
            attention = tbl.attention,
            note = tbl.note, -- TODO make table
            changelog = changes,
            citations = citations,
        },

        classes        = classes,
    }

end

--==============================================================================
-- SECTION: Higher level constructors
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Compound constructor
-- Normalizes all top-level entry fields for compounds
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CONSTRUCTOR.compound(tbl)

    local classes = {}
    local citations = {}
    local changes = {}

    for _, item in ipairs(tbl) do

        if item.kind == "class" then
            table.insert(classes, item)

        elseif item.kind == "citation" then
            table.insert(citations, item)

        elseif item.kind == "change" then
            table.insert(changes, item)

        end

    end

    return {
        kind = "compound",

        source = {
            category = {},-- TODO no autogeneration for compounds
            file = "",
        },

        modifier = {
            form  = tbl.modifier,
            index = tbl.modifier_idx or 0,
            prefix = tbl.modifier_pfx or "",
            suffix = tbl.modifier_sfx or "",
        },

        head = {
            form  = tbl.head,
            index = tbl.head_idx or 0,
            prefix = tbl.head_pfx or "",
            suffix = tbl.head_sfx or "",
        },

        comment = tbl.comment or "",

        meta = {
            status = tbl.status or "none",
            --warning = tbl.warning,
            --attention = tbl.attention,
            --notes = tbl.note, -- TODO make table
            --changelog = changes,
            --citations = citations,
        },

        classes = classes,
        -- TODO add metadata
    }

end

--##############################################################################
-- RETURN
--##############################################################################

return CONSTRUCTOR
