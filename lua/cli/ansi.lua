local S = require("state")

--##############################################################################
-- SUBSCRIPT: ANSI escape sequence formatting functions
--##############################################################################

local ANSI = {}

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTIONS: Inject ANSI escape sequence formatting into string
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function ANSI.red(text)
return "\27[38;5;196m" .. text .. "\27[0m"
end

function ANSI.bold_red(text)
return "\27[1;38;5;196m" .. text .. "\27[0m"
end

function ANSI.green(text)
return "\27[38;5;40m" .. text .. "\27[0m"
end

function ANSI.bold_green(text)
return "\27[1;38;5;40m" .. text .. "\27[0m"
end

function ANSI.yellow(text)
return "\27[38;5;220m" .. text .. "\27[0m"
end

function ANSI.bold_yellow(text)
return "\27[1;38;5;220m" .. text .. "\27[0m"
end

function ANSI.blue(text)
return "\27[38;5;33m" .. text .. "\27[0m"
end

function ANSI.bold_blue(text)
return "\27[1;38;5;33m" .. text .. "\27[0m"
end

function ANSI.magenta(text)
return "\27[35m" .. text .. "\27[0m"
end

function ANSI.bold_magenta(text)
return "\27[1;35m" .. text .. "\27[0m"
end

function ANSI.cyan(text)
return "\27[36m" .. text .. "\27[0m"
end

function ANSI.bold_cyan(text)
return "\27[1;36m" .. text .. "\27[0m"
end

function ANSI.orange(text)
return "\27[38;5;208m" .. text .. "\27[0m"
end

function ANSI.bold_orange(text)
return "\27[1;38;5;208m" .. text .. "\27[0m"
end

function ANSI.dim(text)
return "\27[2m" .. text .. "\27[0m"
end

function ANSI.bold_dim(text)
return "\27[1;2m" .. text .. "\27[0m"
end

function ANSI.italic_dim(text)
return "\27[3;2m" .. text .. "\27[0m"
end

function ANSI.italic(text)
return "\27[3m" .. text .. "\27[0m"
end

function ANSI.bold(text)
return "\27[1m" .. text .. "\27[0m"
end

--##############################################################################
-- RETURN
--##############################################################################

return ANSI
