local U = require("util")
local ANSI = require("cli.ansi")

--##############################################################################
-- SUBSCRIPT: CLI formatter for table view
--##############################################################################

local tableVIEW = {}

--==============================================================================
-- SECTION: TODO
--==============================================================================

--==============================================================================
-- SECTION: TABLE STYLES
--==============================================================================

tableVIEW.style = {

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
















--==============================================================================
-- SECTION: TODO
--==============================================================================

local function visible_length(text)

    -- Remove ANSI escape sequences
    local plain = text:gsub("\27%[[0-9;]*m", "")

    return #plain

end

--[[input:
rows = {

{"", "Singular", "Plural"},
{"Nom.", "eak", "eaki"}

}
]]


local function column_widths(rows)

    local widths = {}

    for _, row in ipairs(rows) do

        for column, cell in ipairs(row) do

            widths[column] = math.max(

                widths[column] or 0,
                visible_length(cell)

            )

        end

    end

    return widths

end

local function align(text, width, mode)

    local length = visible_length(text)
    local padding = width - length

    if padding <= 0 then
        return text
    end

    mode = mode or "left"

    if mode == "right" then

        return
            string.rep(" ", padding)
            .. text

    elseif mode == "center" then

        local left  = math.floor(padding / 2)
        local right = padding - left

        return
            string.rep(" ", left)
            .. text
            .. string.rep(" ", right)

    else -- left

        return (
            text
            .. string.rep(" ", padding)
        )

    end

end

local function contains(tbl, value)

    for _, v in ipairs(tbl) do

        if v == value then

            return true

        end

    end

    return false

end

local function format_row(row, widths, options)

    local out = {}

    local spacing = string.rep(" ", options.spacing)

    local style = options.style

    for column = 1, #widths do

        local cell = row[column] or ""

        table.insert(
            out,
            align(
                cell,
                widths[column],
                options.align[column]
            )
        )

        ------------------------------------------------------------------------
        -- Separator after this column
        ------------------------------------------------------------------------

        if column < #widths then

            if contains(options.vertical_after, column) then

                table.insert(out, spacing)
                table.insert(out, style.v)
                table.insert(out, spacing)

            else

                table.insert(out, spacing)

            end

        end

    end

    return table.concat(out)

end

local function make_rule(widths, options, kind)

    local out = {}

    local spacing = string.rep(" ", options.spacing)

    local style = options.style

    --------------------------------------------------------------------------
    -- Select rule characters
    --------------------------------------------------------------------------

    local left, middle, right

    if kind == "top" then

        left   = style.tl
        middle = style.t
        right  = style.tr

    elseif kind == "bottom" then

        left   = style.bl
        middle = style.b
        right  = style.br

    else -- middle

        left   = style.l
        middle = style.c
        right  = style.r

    end

    --------------------------------------------------------------------------
    -- Left border
    --------------------------------------------------------------------------

    if options.box then

        table.insert(out, left)

    end

    --------------------------------------------------------------------------
    -- Segments
    --------------------------------------------------------------------------

    for column = 1, #widths do

        table.insert(
            out,
            string.rep(
                style.h,
                widths[column]
            )
        )

        if column < #widths then

            if contains(options.vertical_after, column) then

                table.insert(
                    out,
                    string.rep(style.h, options.spacing)
                )

                table.insert(out, middle)

                table.insert(
                    out,
                    string.rep(style.h, options.spacing)
                )

            else

                string.rep(style.h, options.spacing)

            end

        end

    end

    --------------------------------------------------------------------------
    -- Right border
    --------------------------------------------------------------------------

    if options.box then

        table.insert(out, right)

    end

    return table.concat(out)

end























local function render(tbl)

    local rows = tbl.rows
    local options = tbl.options or {}

    local widths = column_widths(rows)

    local out = {}

    --------------------------------------------------------------------------
    -- Top rule
    --------------------------------------------------------------------------

    if options.box then

        table.insert(
            out,
            make_rule(
                widths,
                options,
                "top"
            )
        )

    end

    --------------------------------------------------------------------------
    -- Rows
    --------------------------------------------------------------------------

    for row_number, row in ipairs(rows) do

        table.insert(
            out,
            format_row(
                row,
                widths,
                options
            )
        )

        ----------------------------------------------------------------------
        -- Horizontal rule after this row
        ----------------------------------------------------------------------

        if contains(options.horizontal_after, row_number) then

            table.insert(
                out,
                make_rule(
                    widths,
                    options,
                    "middle"
                )
            )

        end

    end

    --------------------------------------------------------------------------
    -- Bottom rule
    --------------------------------------------------------------------------

    if options.box then

        table.insert(
            out,
            make_rule(
                widths,
                options,
                "bottom"
            )
        )

    end

    return table.concat(out, "\n")

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: TODO
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function tableVIEW.print(tbl)

    local options = tbl.options or {}

    options.spacing = options.spacing or 3

    options.vertical_after = options.vertical_after or {}

    options.horizontal_after = options.horizontal_after or {}

    options.align = options.align or {}

    options.style = options.style or tableVIEW.style.light

    options.box = options.box or false

    local out = render(tbl)

    print(out)

    return out

end

--##############################################################################
-- RETURN
--##############################################################################

return tableVIEW



