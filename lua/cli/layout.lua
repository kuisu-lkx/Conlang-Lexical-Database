local U = require("util")
local ANSI = require("cli.ansi")

--##############################################################################
-- SUBSCRIPT: CLI layout engine
--##############################################################################

local LAYOUT = {}

function LAYOUT.visible_length(text)

    -- Remove ANSI escape sequences
    text = text:gsub("\27%[[0-9;]*m", "")

    return utf8.len(text) or 0

end



local function pad_line(line, width, mode)

    local diff = width - LAYOUT.visible_length(line)

    if diff <= 0 then
        return line
    end

    if mode == "right" then

        return string.rep(" ", diff) .. line

    elseif mode == "center" then

        local left = math.floor(diff / 2)
        local right = diff - left

        return
            string.rep(" ", left)
            .. line ..
            string.rep(" ", right)

    else

        return
            line ..
            string.rep(" ", diff)

    end

end

local function block(lines)

    local width = 0

    for _, line in ipairs(lines) do
        width = math.max(width, LAYOUT.visible_length(line))
    end

    for i, line in ipairs(lines) do
        lines[i] = pad_line(line, width, "left")
    end

    return {
        kind = "block",
        width = width,
        height = #lines,
        lines = lines,
        fill = " "
    }

end

--[[
function LAYOUT.pad_horizontal(child, width, align)

    local diff = width - child.width

    if diff <= 0 then
        return child
    end

    local left = 0
    local right = 0

    if align == "right" then

        left = diff

    elseif align == "center" then

        left = math.floor(diff / 2)
        right = diff - left

    else

        right = diff

    end

    return LAYOUT.pad{

        child = child,

        left = left,
        right = right

    }

end]]


function LAYOUT.pad_horizontal(block, width, align)

    align = align or "left"

    ---------------------------------------------------
    -- Already wide enough
    ---------------------------------------------------

    if block.width >= width then

        return block

    end

    ---------------------------------------------------
    -- Determine padding
    ---------------------------------------------------

    local diff = width - block.width

    local left = 0
    local right = 0

    if align == "right" then

        left = diff

    elseif align == "center" then

        left = math.floor(diff / 2)
        right = diff - left

    else -- left

        right = diff

    end

    ---------------------------------------------------
    -- Assemble
    ---------------------------------------------------



    return LAYOUT.hstack{

        spacing = 0,

        align = "top",

        children = {

            LAYOUT.spacer{

                width = left

            },

            block,

            LAYOUT.spacer{

                width = right

            }

        }

    }

end

function LAYOUT.pad_vertical(child, height, valign)
--U.dump_table(tbl.child)
    --local child  = block
    --local height = tbl.height
    --align  = align or "center"
    local fill   = " "--tbl.fill or " "
--print("AAAAAAAA" .. align)
    ---------------------------------------------------
    -- Already correct height
    ---------------------------------------------------
--print(child.height .. " / " .. height)
    if child.height >= height then
        return child
    end

    local diff = height - child.height

    local top = 0
    local bottom = 0
--print("VALIGN:" .. valign)
    if valign == "bottom" then

        top = diff

    elseif valign == "center" then

        top = math.floor(diff / 2)
        bottom = diff - top

    else -- "top"

        bottom = diff

    end

    ---------------------------------------------------
    -- Build new padded lines
    ---------------------------------------------------

    local lines = {}

    -- top padding
    for _ = 1, top do

        table.insert(

            lines,

            string.rep(fill, child.width)

        )

    end

    -- content
    for _, line in ipairs(child.lines) do

        table.insert(lines, line)

    end

    -- bottom padding
    for _ = 1, bottom do

        table.insert(

            lines,

            string.rep(fill, child.width)

        )

    end
--U.dump_table(lines)
    return block(lines)

end



function LAYOUT.pad(tbl)

    local child = tbl.child

    local left   = tbl.left   or 0
    local right  = tbl.right  or 0
    local top    = tbl.top    or 0
    local bottom = tbl.bottom or 0

    local fill = tbl.fill or child.fill

    local lines = {}

    local width = child.width + left + right

    ---------------------------------------------------
    -- Top
    ---------------------------------------------------

    for _ = 1, top do

        table.insert(

            lines,

            string.rep(fill, width)

        )

    end

    ---------------------------------------------------
    -- Child
    ---------------------------------------------------

    for _, line in ipairs(child.lines) do

        table.insert(

            lines,

            string.rep(fill, left)
            .. line ..
            string.rep(fill, right)

        )

    end

    ---------------------------------------------------
    -- Bottom
    ---------------------------------------------------

    for _ = 1, bottom do

        table.insert(

            lines,

            string.rep(fill, width)

        )

    end

    return block(lines)

end

function LAYOUT.frame(tbl)

    local child = tbl.child

    local style = tbl.style

    local hpadding = tbl.hpadding or 0

    local vpadding = tbl.vpadding or 0

    local sides = tbl.sides or {

        top = true,
        bottom = true,
        left = true,
        right = true

    }

    ---------------------------------------------------
    -- Optional inner padding
    ---------------------------------------------------

    if hpadding > 0
    or vpadding > 0 then
--U.dump_table(child)
        child = LAYOUT.pad{

            child = child,

            left = hpadding,
            right = hpadding,
            top = vpadding,
            bottom = vpadding

        }

    end

    ---------------------------------------------------
    -- Build output
    ---------------------------------------------------

    local lines = {}

    ---------------------------------------------------
    -- Top
    ---------------------------------------------------

    if sides.top then

        local line = ""

        if sides.left then

            line = line .. style.tl

        end

        line = line .. string.rep(

            style.h,

            child.width

        )

        if sides.right then

            line = line .. style.tr

        end

        table.insert(lines, line)

    end

    ---------------------------------------------------
    -- Middle
    ---------------------------------------------------

    for _, row in ipairs(child.lines) do

        local line = ""

        if sides.left then

            line = line .. style.v

        end

        line = line .. row

        if sides.right then

            line = line .. style.v

        end

        table.insert(lines, line)

    end

    ---------------------------------------------------
    -- Bottom
    ---------------------------------------------------

    if sides.bottom then

        local line = ""

        if sides.left then

            line = line .. style.bl

        end

        line = line .. string.rep(

            style.h,

            child.width

        )

        if sides.right then

            line = line .. style.br

        end

        table.insert(lines, line)

    end

    return block(lines)

end



function LAYOUT.text(tbl)
--print(tbl.text)
    local text = tbl.text or ""

    local lines = {}

    -- Split multiline text
    for line in (text .. "\n"):gmatch("(.-)\n") do

        table.insert(lines, line)

    end

    return block(lines)

end

function LAYOUT.spacer(tbl)

    local width  = tbl.width  or 0
    local height = tbl.height or 1

    local lines = {}

    for _ = 1, height do

        table.insert(
            lines,
            string.rep(" ", width)
        )

    end

    return block(lines)

end

function LAYOUT.rule(tbl)

    local width = tbl.width or 0

    local character = tbl.character or "─"

    return block{

        string.rep(character, width)

    }

end



function LAYOUT.hstack(tbl)

    local children = tbl.children or {}

    local spacing = tbl.spacing or 0

    local align_mode = tbl.align or "top"

    ---------------------------------------------------
    -- Determine maximum height
    ---------------------------------------------------

    local height = 0

    for _, child in ipairs(children) do

        height = math.max(height, child.height)

    end

    --print("HSTACK HEIGHT", height)

    --for i, child in ipairs(children) do
        --print(i, child.height)
    --end

    ---------------------------------------------------
    -- Pad children vertically
    ---------------------------------------------------

    local padded = {}

    for _, child in ipairs(children) do

        local lines = {}

        local diff = height - child.height

        local top = 0
        local bottom = 0

        local filler = child.fill or " "

        if align_mode == "bottom" then

            top = diff

        elseif align_mode == "center" then

            top = math.floor(diff / 2)
            bottom = diff - top

        else -- top

            bottom = diff

        end

        -- Top padding

        for _ = 1, top do

            table.insert(
                lines,
                string.rep(filler, child.width)
            )

        end

        -- Child

        for _, line in ipairs(child.lines) do

            table.insert(
                lines,
                pad_line(
                    line,
                    child.width,
                    "left"
                )
            )

        end

        -- Bottom padding

        for _ = 1, bottom do

            table.insert(
                lines,
                string.rep(filler, child.width)
            )

        end

        table.insert(padded, lines)

    end

    ---------------------------------------------------
    -- Assemble output
    ---------------------------------------------------

    local out = {}

    for row = 1, height do

        local line = ""

        for column, child in ipairs(children) do

            --print(
            --    column,
            --    "'" .. padded[column][row] .. "'"
            --)

            line = line .. padded[column][row]

            if column < #children then

                line = line .. string.rep(" ", spacing)

            end

        end

        table.insert(out, line)

    end



    return block(out)

end

function LAYOUT.vstack(tbl)

    local children = tbl.children or {}

    local spacing = tbl.spacing or 0

    local align_mode = tbl.align or "left"

    ---------------------------------------------------
    -- Determine maximum width
    ---------------------------------------------------

    local width = 0

    for _, child in ipairs(children) do

        width = math.max(width, child.width)

    end

    ---------------------------------------------------
    -- Assemble lines
    ---------------------------------------------------

    local lines = {}

    for i, child in ipairs(children) do

        for _, line in ipairs(child.lines) do

            table.insert(
                lines,
                pad_line(line, width, align_mode)
            )

        end

        if i < #children then

            for _ = 1, spacing do

                table.insert(
                    lines,
                    string.rep(" ", width)
                )

            end

        end

    end

    return block(lines)

end


--##############################################################################
-- RETURN
--##############################################################################

return LAYOUT
