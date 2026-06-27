local S = require("state")
local U = require("util")
local E = require("entry")
local unicode = require("unicode")

--#############################################################################
-- SCRIPT FOR CLI-BASED ENTRY-DATABASE MAITENANCE
--#############################################################################

--#############################################################################
-- Prepare entries
--#############################################################################

-- Load all source files
E.load_entries()

-- Resolve compounds and generated fields
E.normalize_entries()

--#############################################################################
-- PRINT ENTRY (SHORT FORM)
---------------------------

-- Accepts either:
--     print_entry("fanaheak")
------------------------------

-- or:
--     print_entry(entry)
--#############################################################################

function print_entry(arg)

local entry
    if type(arg) == "table" then
        entry = arg
    else
        entry = U.find_entry("citation", arg)
    end

local citation_string = ""
    if entry.citation ~= "" then
        citation_string = entry.citation .. ""
    end

local headindex_string = ""
    if entry.headindex ~= 0 then
        headindex_string = "(" .. tostring(entry.headindex) .. ")"
    end

local ipa_head_string = ""
    if entry.ipa_head ~= "" then
        ipa_head_string = " [" .. entry.ipa_head .. "]"
    end

local contractedstem_string = ""
    if entry.contractedstem ~= "" then
        contractedstem_string = " " .. entry.contractedstem
    end

local expandedstem_string = ""
    if entry.expandedstem ~= "" then
        expandedstem_string = " " .. entry.expandedstem
    end

local ipa_cstem_string = ""
    if entry.ipa_cstem ~= "" then
        ipa_cstem_string = " [" .. entry.ipa_cstem
    end

local ipa_estem_string = "]"
    if entry.ipa_estem ~= "" then
        ipa_estem_string = " " .. entry.ipa_estem .. "]"
    end

local stemclass_string = ""
    if entry.stemclass ~= "" then
        stemclass_string = " (" .. entry.stemclass .. ")"
    end

--[[
local _string = ""
    if entry. ~= "" then
        _string = " " .. entry.
    end
]]

print(
    citation_string
    .. headindex_string
    .. ipa_head_string
    .. ":"
    .. contractedstem_string
    .. expandedstem_string
    .. ipa_cstem_string
    .. ipa_estem_string
    .. stemclass_string
)

end

--#############################################################################
-- RECURSIVE TABLE DUMPER
-------------------------

-- Internal helper used by print_entry_full().
--#############################################################################

local function dump_table(tbl, indent)

indent = indent or ""

local keys = {}

for key in pairs(tbl) do
    table.insert(keys, key)
end

table.sort(
    keys,
    function(a, b)
        return tostring(a) < tostring(b)
    end
)

for _, key in ipairs(keys) do
    local value = tbl[key]
    if type(value) == "table" then
        print(
            indent
            .. tostring(key)
            .. " = {"
        )
        dump_table(
            value,
            indent .. "    "
        )
        print(
            indent
            .. "}"
        )
    else
        print(
            indent
            .. tostring(key)
            .. " = "
            .. tostring(value)
        )
    end
end

end

--#############################################################################
-- PRINT ENTRY (FULL)
---------------------

-- Dumps every key and nested table.

-- Accepts either:
--     print_entry_full("fanaheak")
-----------------------------------

-- or:
--     print_entry_full(entry)
--#############################################################################

function print_entry_full(arg)

local entry

if type(arg) == "table" then
    entry = arg
else
    entry = U.find_entry("citation", arg)
end

print("----------------------------------------")

dump_table(entry)

print("----------------------------------------")

end

--#############################################################################
-- FIND BY KEY
--------------

-- Example:

--     find_by_key(
--         "contractedstem",
--         "eak"
--     )
--------

-- Returns matching entries and prints their
-- citations.
--#############################################################################

function find_by_key(key, value)


local matches =
    U.find_entries(
        key,
        value
    )

print(
    #matches
    .. " match(es)"
)

for _, entry in ipairs(matches) do

    print(
        entry.citation
    )

end

return matches

end

--#############################################################################
-- Simple argument parser
--#############################################################################

--#############################################################################
-- ASCII SHORTHAND
--#############################################################################

local ascii_shorthand = {

    ["a:"] = "ā",
    ["e:"] = "ē",
    ["i:"] = "ī",
    ["o:"] = "ō",
    ["u:"] = "ū",

    ["A:"] = "Ā",
    ["E:"] = "Ē",
    ["I:"] = "Ī",
    ["O:"] = "Ō",
    ["U:"] = "Ū",

    ["t:"] = "þ",
    ["T:"] = "Þ",
    ["n:"] = "ŋ",
    ["N:"] = "Ŋ",

}

local function normalize_arg(str)

    if not str then
        return str
    end

    for ascii, utf8 in pairs(ascii_shorthand) do
        str = str:gsub(ascii, utf8)
    end

    return str

end

--normalize ascii shorthand
for i = 1, #arg do
    arg[i] = normalize_arg(arg[i])
end

--parse command
local cmd = arg[1]

if cmd == "print" then
    print_entry(arg[2])

elseif cmd == "print_list" then
    for i = 2, #arg do
        print_entry(arg[i])
    end

elseif cmd == "print_all" then
    for _, entry in ipairs(S.entries) do
        print_entry(entry)
    end

elseif cmd == "print_full" then
    print_entry_full(arg[2])

elseif cmd == "find" then
    find_by_key(arg[2], arg[3])

end

