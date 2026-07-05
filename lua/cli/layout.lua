local U = require("util")
local ANSI = require("cli.ansi")

--##############################################################################
-- SUBSCRIPT: CLI layout engine
--##############################################################################

local LAYOUT = {}

local function pad_horizontal(line, width, mode)

    local diff = width - #line

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
        width = math.max(width, #line)
    end

    for i, line in ipairs(lines) do
        lines[i] = pad_horizontal(line, width, "left")
    end

    return {
        kind = "block",
        width = width,
        height = #lines,
        lines = lines
    }

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

function LAYOUT.rule(...)

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

    ---------------------------------------------------
    -- Pad children vertically
    ---------------------------------------------------

    local padded = {}

    for _, child in ipairs(children) do

        local lines = {}

        local diff = height - child.height

        local top = 0
        local bottom = 0

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
                string.rep(" ", child.width)
            )

        end

        -- Child

        for _, line in ipairs(child.lines) do

            table.insert(
                lines,
                pad_horizontal(
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
                string.rep(" ", child.width)
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
                pad_horizontal(line, width, align_mode)
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
