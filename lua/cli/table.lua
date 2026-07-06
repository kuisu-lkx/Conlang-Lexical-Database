local LAYOUT = require("cli.layout")
local U = require("util")
local ANSI = require("cli.ansi")

--##############################################################################
-- SUBSCRIPT: Table widget
--##############################################################################
--[[
local TABLE = {}

local function make_separator(kind, style)

local function normalize_cells()

local function column_widths()

local function make_cell()

local function make_row()

local function make_rule()

function TABLE.make()

]]

local TABLE = {}

TABLE.style = {

    --==========================================================================
    -- ASCII
    --==========================================================================

    ascii = {

        h  = "-",
        v  = "|",

        tl = "+",
        tr = "+",
        bl = "+",
        br = "+",

        t  = "+",
        b  = "+",
        l  = "+",
        r  = "+",

        c  = "+"

    },

    --==========================================================================
    -- Unicode light
    --==========================================================================

    light_dim = {

        h  = ANSI.dim("─"),
        v  = ANSI.dim("│"),

        tl = ANSI.dim("┌"),
        tr = ANSI.dim("┐"),
        bl = ANSI.dim("└"),
        br = ANSI.dim("┘"),

        t  = ANSI.dim("┬"),
        b  = ANSI.dim("┴"),
        l  = ANSI.dim("├"),
        r  = ANSI.dim("┤"),

        c  = ANSI.dim("┼")

    },

    --==========================================================================
    -- Unicode light
    --==========================================================================

    light = {

        h  = "─",
        v  = "│",

        tl = "┌",
        tr = "┐",
        bl = "└",
        br = "┘",

        t  = "┬",
        b  = "┴",
        l  = "├",
        r  = "┤",

        c  = "┼"

    },

    --==========================================================================
    -- Unicode heavy
    --==========================================================================

    heavy = {

        h  = "━",
        v  = "┃",

        tl = "┏",
        tr = "┓",
        bl = "┗",
        br = "┛",

        t  = "┳",
        b  = "┻",
        l  = "┣",
        r  = "┫",

        c  = "╋"

    },

    --==========================================================================
    -- Unicode double
    --==========================================================================

    double = {

        h  = "═",
        v  = "║",

        tl = "╔",
        tr = "╗",
        bl = "╚",
        br = "╝",

        t  = "╦",
        b  = "╩",
        l  = "╠",
        r  = "╣",

        c  = "╬"

    }

}

local function normalize_options(tbl)

    local options = tbl.options or {}

    options.padding = options.padding or 1

    options.spacing = options.spacing or 3

    options.align = options.align or {}
    options.valign = options.valign or {}

    options.vertical_after = options.vertical_after or {}

    options.horizontal_after = options.horizontal_after or {}

    options.style = options.style or TABLE.style.light

    options.box = options.box or false

    return options

end

--==============================================================================
-- SECTION: Helpers
--==============================================================================

local function make_separator(kind, style)

    local character

    if kind == "vertical" then

        character = style.v

    elseif kind == "cross" then

        character = style.c

    elseif kind == "horizontal" then

        character = style.h

    end

    local separator = LAYOUT.text{

        text = character

    }

    -- Character used when the block is padded vertically
    separator.fill = character

    return separator

end

local function normalize_cells(rows)

    local normalized = {}

    for _, row in ipairs(rows) do

        local new_row = {}

        for _, cell in ipairs(row) do

            if type(cell) == "string" then

                table.insert(
                    new_row,
                    LAYOUT.text{
                        text = cell
                    }
                )

            else

                table.insert(
                    new_row,
                    cell
                )

            end

        end

        table.insert(
            normalized,
            new_row
        )

    end

    return normalized

end

local function column_widths(rows)

    local widths = {}

    for _, row in ipairs(rows) do

        for column, cell in ipairs(row) do

            widths[column] = math.max(
                widths[column] or 0,
                cell.width
            )

        end

    end
    --print("COLWID")
    --U.dump_table(widths)
    return widths

end

local function row_heights(rows)

    local heights = {}
    --U.dump_table(rows[1])
    for i, row in ipairs(rows) do
       --U.dump_table(row)
        for column, cell in ipairs(row) do
--print("RH:" .. row[column].height)
            heights[i] = math.max(
                heights[i] or 0,
                row[column].height
            )

        end

    end
--print("ROWHGT")
--U.dump_table(heights)
    return heights

end

local function contains(tbl, value)

    for _, v in ipairs(tbl) do

        if v == value then

            return true

        end

    end

    return false

end

--==============================================================================
-- SECTION: Builders
--==============================================================================

local function make_cell(cell, width, align, height, valign, padding)
--print("MAKECELL")
--print(height)
    ---------------------------------------------------
    -- Normalize input
    ---------------------------------------------------

    local content

    if type(cell) == "table"
       and cell.kind == "block"
    then

        content = cell

    else

        content = LAYOUT.text{text = tostring(cell)}

    end

    ---------------------------------------------------
    -- Horizontal padding
    ---------------------------------------------------

    content = LAYOUT.pad_horizontal(content, width, align)

    ---------------------------------------------------
    -- Vertical padding
    ---------------------------------------------------
--print(valign)
    content = LAYOUT.pad_vertical(content, height, valign)
    --U.dump_table(content)
    ---------------------------------------------------
    -- Cell padding TODO ???
    ---------------------------------------------------
    --print("CONTENT")
    --print(content.height)
    --U.dump_table(content.lines)
    return LAYOUT.hstack{

        spacing = 0,

        align = "top",

        children = {

            LAYOUT.spacer{width = padding},

            content,

            LAYOUT.spacer{width = padding}

        }

    }

end

local function make_row(row, widths, height, options)


    local children = {}

    for column, cell in ipairs(row) do

        --local row_height =
--U.dump_table(height)
--print(options.valign[column])
        ---------------------------------------------------
        -- Cell
        ---------------------------------------------------

        table.insert(

            children,

            make_cell(
                cell,
                widths[column],
                options.align[column],
                height,
                options.valign[column],
                options.padding
            )

        )

        ---------------------------------------------------
        -- Vertical separator
        ---------------------------------------------------

        if column < #row then

            if contains(options.vertical_after, column) then

                table.insert(

                    children,

                    make_separator("vertical", options.style)

                )

            else

                table.insert(

                    children,

                    LAYOUT.spacer{width = options.spacing}

                )

            end

        end

    end



    return LAYOUT.hstack{

        spacing = 0,

        align = "top",

        children = children

    }

end

local function make_rule(widths, options)

    local children = {}

    for column, width in ipairs(widths) do

        ---------------------------------------------------
        -- Horizontal rule
        ---------------------------------------------------

        table.insert(

            children,

            LAYOUT.rule{
                width = width + 2 * options.padding,
                character = options.style.h
            }

        )
        ---------------------------------------------------
        -- Crossings
        ---------------------------------------------------

        if column < #widths then

            if contains(options.vertical_after, column) then

                table.insert(

                    children,

                    make_separator("cross", options.style)

                )

            else

                table.insert(

                    children,

                    LAYOUT.rule{
                        width = options.spacing,
                        character = options.style.h
                    }

                )

            end

        end

    end

    return LAYOUT.hstack{spacing = 0, children = children}

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Build table block
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TABLE.make(tbl)

    local options = normalize_options(tbl)
    local rows = normalize_cells(tbl.rows)
    local widths = column_widths(rows)
    local heights = row_heights(rows)

    local children = {}

    for i, row in ipairs(rows) do

        table.insert(children, make_row(row, widths, heights[i], options))

        ---------------------------------------------------
        -- Horizontal separator
        ---------------------------------------------------

        if contains(options.horizontal_after, i) then
            table.insert(children, make_rule(widths, options) )
        end

    end

    local out = LAYOUT.vstack{spacing = 0, children = children}

    return out

end

function LAYOUT.rule(tbl)

    return LAYOUT.text{text = string.rep(tbl.character or "─", tbl.width or 0)}

end

--##############################################################################
-- RETURN
--##############################################################################

return TABLE
