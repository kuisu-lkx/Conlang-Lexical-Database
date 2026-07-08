local S = require("state")
local U = require("util")
local ANSI = require("cli.ansi")
local LAYOUT = require("cli.layout")
local TABLE = require("cli.table")
local BLOCK = require("cli.block")

--##############################################################################
-- SUBSCRIPT: CLI formatter for list view
--##############################################################################

local listVIEW = {}

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble word section
--------------------------------------------------------------------------------

local function word_section(entry)

    local word_section_children = {}

    table.insert(
        word_section_children,
        LAYOUT.text{text = ANSI.bold("◆ "), align = "right"}
    )

    table.insert(
        word_section_children,
        BLOCK.contracted_stem(entry, "text")
    )

    if entry.stem.expanded then
        table.insert(
            word_section_children,
            BLOCK.expanded_stem(entry, "text")
        )
    end

    if entry.stem.expanded then
        table.insert(
            word_section_children,
            BLOCK.contracted_stem(entry, "[ipa")
        )
        table.insert(
            word_section_children,
            BLOCK.expanded_stem(entry, "ipa]")
        )
    else
        table.insert(
            word_section_children,
            BLOCK.contracted_stem(entry, "[ipa]")
        )
    end

    table.insert(
        word_section_children,
        LAYOUT.text{text = ANSI.bold(entry.stem.class), align = "right"}
    )

    if S.options.status then
        table.insert(
            word_section_children,
            LAYOUT.text{text = "  ■", align = "right"}
        )
        table.insert(
            word_section_children,
            BLOCK.status(entry)
        )
    end

    if S.options.note and entry.meta.note then
        table.insert(
            word_section_children,
            LAYOUT.text{text = "  ■", align = "right"}
        )
        table.insert(
            word_section_children,
            LAYOUT.text{text = ANSI.dim("(has notes)"), align = "right"}
        )
    end

    return LAYOUT.hstack{
        spacing = 1,
        align = "left",
        children = word_section_children
    }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Assemble translation section
--------------------------------------------------------------------------------

local function translations_section(entry)
    return LAYOUT.hstack{
        spacing = 0,
        align = "left",
        children = {
            BLOCK.indent(3),
            BLOCK.translation(entry, 73)
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
            BLOCK.indent(3),
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
            BLOCK.indent(3),
            LAYOUT.text{
                text = ANSI.yellow("■ " .. entry.meta.attention),
                align = "right"
            }
        }
    }
end

--==============================================================================
-- SECTION: Public Functions
--==============================================================================

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Print entry in list view
--
-- Accepts either:
--     print_entry("fanaheak", options)
--
-- or:
--     print_entry(entry, options)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function entry_section(entry)

    ----------------------------------------------------------------------------
    -- Select sections to display
    ----------------------------------------------------------------------------

    local entry_children = {}

    table.insert(entry_children, BLOCK.empty_screen_line())

    table.insert(entry_children, word_section(entry))

    if S.options.translation then

        table.insert(entry_children, translations_section(entry))
    end

    if entry.meta.warning then
        table.insert(entry_children, warning_section(entry))

    end

    if S.options.note and entry.meta.attention then
        table.insert(entry_children, attention_section(entry))
    end

    if not S.options.dense then
        table.insert(entry_children, BLOCK.empty_screen_line())
    end

    if S.options.citations then -- TODO
        --out = out
        --.. "\n      "
        --.. " ■ citations:"
        --.. " ※ " text, page ...
    end

    if S.options.changelog then -- TODO
        --out = out
        --.. "\n      "
        --.. " ■ " .. ANSI.dim("date edited: ") .. entry.meta.date_edited
        --.. " / " .. ANSI.dim("date added: ") .. entry.meta.date_added
        --.. "\n       ◇ " date: change
    end

    ----------------------------------------------------------------------------
    -- Stack sections vertically
    ----------------------------------------------------------------------------

    return LAYOUT.vstack{
        spacing = 0,
        align = "left",
        children = entry_children
    }

end

function listVIEW.print_screen(argv)

    local screen_children = {}

    local entry

    if argv[2] == ":all" then

        for _, entry in ipairs(S.entries) do
            table.insert(screen_children, entry_section(entry))
        end

    else

        for i = 2, #argv do

            if type(argv[i]) == "table" then
                entry = arg
            else
                entry = U.find_stem(argv[i])
            end

            table.insert(screen_children, entry_section(entry))

        end

    end




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

    if S.options.screen_frame then
        print(table.concat(framed_screen.lines, "\n"))
    else
        print(table.concat(screen.lines, "\n"))
    end

end

--##############################################################################
-- RETURN
--##############################################################################

return listVIEW
