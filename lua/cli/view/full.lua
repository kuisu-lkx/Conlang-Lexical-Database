local U = require("util")
local S = require("state")
local ANSI = require("cli.ansi")
local LAYOUT = require("cli.layout")
local TABLE = require("cli.table")
local BLOCK = require("cli.block")
local unicode = require("unicode")
local QUERY = require("cli.query")
local linenoise = require("linenoise")
--##############################################################################
-- SUBSCRIPT: CLI screen formatter for full view
-- TODO comment functions
--##############################################################################

local fullVIEW = {}

--==============================================================================
-- SECTION: Assemble sections
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble title section
--------------------------------------------------------------------------------

local function title_section(entry)

    local title_children = {}

    ----------------------------------------------------------------------------
    -- TODO
    ----------------------------------------------------------------------------

    local title_text = ""

    if S.options.morphology then
        title_text = U.assemble_stem(entry.stem.contracted.format.morphology)
    else
        title_text = U.assemble_stem(entry.stem.contracted.format.unicode)
    end

    title_text = unicode.utf8.upper(title_text)

    if S.options.color then

        if entry.stem.class:match("^v") then
            title_text = ANSI.bold_yellow(title_text)
        elseif entry.stem.class:match("^n") then
            title_text = ANSI.bold_blue(title_text)
        else
            title_text = ANSI.bold(title_text)
        end

    else
        title_text = ANSI.bold(title_text)
    end

    local title = LAYOUT.text{text = ANSI.bold_dim("  Entry: ") .. title_text, align = "center"}

    table.insert(
        title_children,
        title
    )

    if S.options.status then

        table.insert(
            title_children,
            LAYOUT.text{
                text = string.rep(" ", 54-title.width),
                align = "right"
            }
        )

        table.insert(
            title_children,
            LAYOUT.text{text = ANSI.bold_dim("Status: "), align = "right"}
        )

        table.insert(
            title_children,
            BLOCK.status(entry)
        )

    end

    return LAYOUT.hstack{
        spacing = 0,
        align = "center",
        children = title_children
    }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble lemma section
--------------------------------------------------------------------------------

local function lemma_section(entry)

    local head =
        U.find_lemma(
            entry.lemma.head.key,
            entry.lemma.head.index,
            entry.lemma.head.prefix,
            entry.lemma.head.suffix
        )

    local rows_lemma = {
        {
            ANSI.bold_dim(" Head:"),
            ANSI.bold(head.lemma.head.key) .. "   ",
            ANSI.bold_dim("Index:"),
            head.lemma.head.index .. "   ",
            ANSI.bold_dim("Prefix:"),
            head.lemma.head.prefix .. "   ",
            ANSI.bold_dim("Suffix:"),
            head.lemma.head.suffix .. "   ",
        },
    }

    if entry.lemma.modifier then

        local modifier =
        U.find_lemma(
            entry.lemma.modifier.key,
            entry.lemma.modifier.index,
            entry.lemma.modifier.prefix,
            entry.lemma.modifier.suffix
        )

        table.insert(
            rows_lemma,
            {
                ANSI.bold_dim("Modifier:"),
                ANSI.bold(modifier.lemma.head.key) .. "   ",
                ANSI.bold_dim("Index:"),
                modifier.lemma.head.index .. "   ",
                ANSI.bold_dim("Prefix:"),
                entry.lemma.modifier.prefix .. "   ",
                ANSI.bold_dim("Suffix:"),
                entry.lemma.modifier.suffix .. "   ",
            }
        )

    end

        local lemma_info_table = TABLE.make{
            rows = rows_lemma,
            options = {
                padding = 0,
                spacing = 1,
                vertical_after = {},
                horizontal_after = {0},
                align = {
                    "right", "left", "right", "left",
                    "right", "left", "right", "left"
                },
                valign = {
                    "center", "center", "center", "center",
                    "center", "center", "center", "center"
                },
                style = TABLE.style.light_dim
            }
        }

        local lemma_info_hstack = LAYOUT.hstack{
            spacing = 0,
            align = "left",
            children = {
                BLOCK.indent(2),
                lemma_info_table,
            }
        }

        return LAYOUT.vstack{
            spacing = 0,
            align = "left",
            children = {
                LAYOUT.text{
                    text =
                    ANSI.dim(string.rep("─", 6))
                    .. ANSI.bold_dim(" LEMMA ")
                    .. ANSI.dim(string.rep("─", 63)),
                    align = "left"},
                    lemma_info_hstack
            }
        }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble stem section
--------------------------------------------------------------------------------

local function stem_section(entry)

    local contracted_ipa = BLOCK.contracted_stem(entry, "[ipa]")

    local rows = {
        {
            ANSI.bold_dim("Class:"),
            ANSI.bold(entry.stem.class) .. "   ",
            ANSI.bold_dim("Contracted:"),
            BLOCK.contracted_stem(entry, "text"),
            contracted_ipa,
        },
    }

    if entry.stem.expanded then

        local expanded_ipa = BLOCK.expanded_stem(entry, "[ipa]", true)

        table.insert(
            rows,
            {
                "",
                "",
                ANSI.bold_dim("Expanded:"),
                BLOCK.expanded_stem(entry, "text", true),
                expanded_ipa,
            }
        )

    end

    local stem_info_table = TABLE.make{
        rows = rows,
        options = {
            padding = 0,
            spacing = 1,
            vertical_after = {},
            horizontal_after = {0},
            align = {"right", "left", "right", "left", "left"},
            valign = {"center", "center", "center", "center", "center"},
            style = TABLE.style.light_dim
        }
    }

    local stem_info_hstack = LAYOUT.hstack{
        spacing = 0,
        align = "left",
        children = {
            BLOCK.indent(2),
            stem_info_table,
        }
    }

    return LAYOUT.vstack{
        spacing = 0,
        align = "left",
        children = {
            LAYOUT.text{
                text =
                    ANSI.dim(string.rep("─", 6))
                    .. ANSI.bold_dim(" STEM ")
                    .. ANSI.dim(string.rep("─", 64)),
                align = "left"},
            stem_info_hstack
        }
    }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble translation section
--------------------------------------------------------------------------------

local function translation_section(entry)

    local translation_hstack = LAYOUT.hstack{
        spacing = 0,
        align = "left",
        children = {
            BLOCK.indent(2),
            BLOCK.translation(entry, 71)
        }
    }

    return LAYOUT.vstack{
        spacing = 0,
        align = "left",
        children = {
            LAYOUT.text{
                text =
                ANSI.dim(string.rep("─", 6))
                .. ANSI.bold_dim(" TRANSLATION ")
                .. ANSI.dim(string.rep("─", 57)),
                align = "left"},
                translation_hstack
        }
    }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble paradigm section
--------------------------------------------------------------------------------

local function nominal_paradigm_section(entry)
    local framed_paradigm = {}
    local paradigm = {}
    local paradigm_formated = {}

    for case, endings in pairs(S.inflections.nominal[entry.stem.class]) do

        local base = ""
        local format = {}

        if S.options.morphology then

            if endings.stem == "contracted" then
                format = entry.stem.contracted.format.morphology
            elseif endings.stem == "expanded" then
                format = entry.stem.expanded.format.morphology
            end

        else

            if endings.stem == "contracted" then
                format = entry.stem.contracted.format.unicode
            elseif endings.stem == "expanded" then
                format = entry.stem.expanded.format.unicode
            end

        end

        if format.before ~= ""
        or (format.modifier and format.modifier ~= "") then


            if S.options.abbreviated then
                base = base .. "~"

            else

                if format.modifier then
                    base = base .. format.modifier .. format.before
                else
                    base = base .. format.before
                end

            end

        end

        --TODO format stems differently (maybe only in morphology mode)
        if endings.stem == "contracted" then
            base = base .. format.main
        elseif endings.stem == "expanded" then
            base = base .. format.main
        end

        if format.after then
            base = base .. format.after
        end

        if S.options.morphology then
            base = base .. "·"
        end

        paradigm_formated[case] = {
            stem = endings.stem,
            sg = base .. ANSI.bold(endings.sg),
            gc = base .. ANSI.bold(endings.gc),
            pl = base .. ANSI.bold(endings.pl)
        }

    end

    local paradigm_lines = {}

    for case, forms in pairs(paradigm_formated) do
        local line = {}
        local singular = forms.sg
        local generic = forms.gc
        local plural = forms.pl

        --TODO add real ipa of forms
        if S.options.paradigm_ipa then
            local ipa =
                "[" .. U.assemble_stem(entry.stem.contracted.format.ipa) .. "]"

            singular = singular .. "\n" .. ANSI.dim(ipa)
            generic = generic .. "\n" .. ANSI.dim(ipa)
            plural = plural .. "\n" .. ANSI.dim(ipa)
        end

        line = {case, singular, generic, plural}
        table.insert(paradigm_lines, line)

    end

    table.sort(paradigm_lines, function(a, b)
        return S.case_rank[a[1]] < S.case_rank[b[1]]
    end)
    -- TODO replace case abbr.
    -- Format case only after sorting
    for _, lines in ipairs(paradigm_lines) do
        lines[1] = ANSI.bold_dim(lines[1])
    end

    paradigm = TABLE.make{
        rows = {
            {ANSI.bold(entry.stem.class), ANSI.bold_dim("Singular"), ANSI.bold_dim("Generic"), ANSI.bold_dim("Plural")},
            paradigm_lines[1],
            paradigm_lines[2],
            paradigm_lines[3],
            paradigm_lines[4],
            paradigm_lines[5],
            paradigm_lines[6],
            paradigm_lines[7],
            paradigm_lines[8],
        },
        options = {
            padding = 1,
            spacing = 1,
            vertical_after = {1},
            horizontal_after = {1},
            align = {"left", "left", "left", "left"},
            valign = {"center", "center", "center", "center"},
            style = TABLE.style.light_dim
        }
    }

    framed_paradigm = LAYOUT.frame{
        child = paradigm,
        style = TABLE.style.light_dim,
        hpadding = 1,
        vpadding = 0,
        sides = {
            top = true,
            bottom = true,
            left = true,
            right = true
        }
    }

    local paradigm_hstack = LAYOUT.hstack{
        spacing = 0,
        align = "left",
        children = {
            BLOCK.indent(2),
            paradigm,
        }
    }

    return LAYOUT.vstack{
        spacing = 0,
        align = "left",
        children = {
            LAYOUT.text{
                text =
                ANSI.dim(string.rep("─", 6))
                .. ANSI.bold_dim(" PARADIGM ")
                .. ANSI.dim(string.rep("─", 60)),
                align = "left"},
                paradigm_hstack
        }
    }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble warning section
--------------------------------------------------------------------------------

local function warning_section(entry)

    return LAYOUT.hstack{
        spacing = 0,
        align = "left",
        children = {
            BLOCK.indent(2),
            LAYOUT.text{
                text = ANSI.red("■ " .. entry.meta.warning),
                align = "right"
            }
        }
    }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble attention section
--------------------------------------------------------------------------------

local function attention_section(entry)

    return LAYOUT.hstack{
        spacing = 0,
        align = "left",
        children = {
            BLOCK.indent(2),
            LAYOUT.text{
                text = ANSI.yellow("■ " .. entry.meta.attention),
                align = "right"
            }
        }
    }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble note section
--------------------------------------------------------------------------------

local function note_section(entry)

    return LAYOUT.hstack{
        spacing = 0,
        align = "left",
        children = {
            BLOCK.indent(2),
            LAYOUT.text{
                text = "■ " .. entry.meta.note,
                align = "right"
            }
        }
    }

end

--==============================================================================
-- SECTION: public
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Assemble screen from sections and print
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function fullVIEW.print_screen(argv)

    local entry = {}
    local matches = {}

    for i = 2, #argv do

        local query = argv[i]

        matches = QUERY.search_entries(query)

    end

    if #matches > 1 then

        print(ANSI.bold("Multiple matches found:"))

        for i = 1, #matches do
            print(
                ANSI.bold(i)
                .. ": "
                .. U.assemble_stem(matches[i].stem.contracted.format.unicode)
            )
        end

        print("Type number to choose match:")

        ::continue::

        local input = linenoise.linenoise("query> ")

        if input == "" then
            goto continue
        end

        input = tonumber(input)

        if not input
        or input > #matches then

            print("Invalid input!")
            goto continue

        end

        entry = matches[tonumber(input)]

    else

        entry = matches[1]

    end




    ----------------------------------------------------------------------------
    -- Select sections to display
    ----------------------------------------------------------------------------

    local screen_children = {}

    table.insert(screen_children, title_section(entry))

    if entry.meta.warning then
        table.insert(screen_children, warning_section(entry))
    end

    if S.options.note and entry.meta.attention then
        table.insert(screen_children, attention_section(entry))
    end

    if S.options.note and entry.meta.note then
        table.insert(screen_children, note_section(entry))
    end

    table.insert(screen_children, BLOCK.empty_screen_line())
    table.insert(screen_children, lemma_section(entry))

    table.insert(screen_children, BLOCK.empty_screen_line())
    table.insert(screen_children, stem_section(entry))

    if S.options.translation then
        table.insert(screen_children, BLOCK.empty_screen_line())
        table.insert(screen_children, translation_section(entry))
    end

    if entry.stem.class:match("^n") then
        table.insert(screen_children, BLOCK.empty_screen_line())
        table.insert(screen_children, nominal_paradigm_section(entry))
    end

    table.insert(screen_children, BLOCK.empty_screen_line())

    ----------------------------------------------------------------------------
    -- Stack sections vertically
    ----------------------------------------------------------------------------

    local screen = LAYOUT.vstack{
        spacing = 0,
        align = "left",
        children = screen_children
    }

    ----------------------------------------------------------------------------
    -- Add screen frame
    ----------------------------------------------------------------------------

    local framed_screen = LAYOUT.frame{
        child = screen,
        style = TABLE.style.double,
        hpadding = 1,
        vpadding = 0,
        sides = {
            top = true,
            bottom = true,
            left = true,
            right = true
        }
    }

    ----------------------------------------------------------------------------
    -- Print screen
    ----------------------------------------------------------------------------

    if S.options.screen_frame then
        print(table.concat(framed_screen.lines, "\n"))
    else
        print(table.concat(screen.lines, "\n"))
    end

end

--##############################################################################
-- RETURN
--##############################################################################

return fullVIEW
