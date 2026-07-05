local S = require("state")
local CONSTRUCTOR = require("entry.constructor")
local lfs = require("lfs")

--##############################################################################
-- SUBSCRIPT: Load input source files
--##############################################################################

local LOAD = {}

--==============================================================================
-- SECTION: Determine source directory
--==============================================================================

local entry_dir

if lfs.attributes("../entries", "mode") == "directory" then
    entry_dir = "../entries"

else
    entry_dir = "../demo"

end

--==============================================================================
-- SECTION: Input file API
-- Makes constructors available to entry source files loaded via dofile().
--==============================================================================

entry       = CONSTRUCTOR.entry
class       = CONSTRUCTOR.class
group       = CONSTRUCTOR.group
translation = CONSTRUCTOR.translation
compound    = CONSTRUCTOR.compound
citation    = CONSTRUCTOR.citation
change      = CONSTRUCTOR.change

--==============================================================================
-- SECTION: Input file loader
--==============================================================================

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: Parse source path inte categories
--------------------------------------------------------------------------------

local function parse_source(path)

    -- remove the entry root
    local relative =
        path:gsub("^" .. entry_dir .. "/", "")

    local parts = {}

    -- split at "/"
    for part in relative:gmatch("[^/]+") do
        table.insert(parts, part)
    end

    local filename = table.remove(parts)

    return {

        path = table.concat(parts, "/") .. "/",
        filename = filename

    }

end

--------------------------------------------------------------------------------
-- LOCAL FUNCTION: File loader
--------------------------------------------------------------------------------

local function load_files(patterns, target)

    local files = {}

    ----------------------------------------------------------------------------
    -- LOCAL FUNCTION:
    -- Scan directories recursively, load input files and parse path and
    -- filename into source fields.
    ----------------------------------------------------------------------------

    local function scan(dir)

        for file in lfs.dir(dir) do

            if file ~= "." and file ~= ".." then

                local path = dir .. "/" .. file
                local attr = lfs.attributes(path)

                if attr.mode == "directory" then

                    scan(path)

                else

                    local lower = file:lower()

                    for _, pattern in ipairs(patterns) do

                        if lower:match(pattern) then

                            table.insert(files, {
                                path = path,
                                source = parse_source(path),
                            })
                            break

                        end

                    end

                end

            end

        end

    end

    scan(entry_dir)

    ----------------------------------------------------------------------------
    -- Sort files
    ----------------------------------------------------------------------------

    table.sort(files, function(a, b)
        return a.path < b.path
    end)

    ----------------------------------------------------------------------------
    -- Insert objects from input/source file into target table
    ----------------------------------------------------------------------------

    for _, file in ipairs(files) do

    local objects = dofile(file.path)

        for _, object in ipairs(objects) do

            object.source = file.source

            table.insert(target, object)

        end

    end

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Load entry input/source files
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function LOAD.load_entries()

    load_files(
        S.file_patterns.entries,
        S.entries
    )

end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FUNCTION: Load compound input/source files
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function LOAD.load_compounds()

    load_files(
        S.file_patterns.compounds,
        S.compounds
    )

end

--##############################################################################
-- RETURN
--##############################################################################

return LOAD
