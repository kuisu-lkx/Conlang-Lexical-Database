-- ############################################################################
-- EXAMPLE INPUT FILE
-- All lexemes are stored in files named lexeme.root.lua or particle-group.part.lua
--
-- The directory structure is as follows:
--
-- database/
--      /entries/
--          /A/
--              aa.root.lua
--          ...
--          /Z/
--          posessives.part.lua
--      /lua/
--          codefiles.lua
--      database-interface.lua (to be completed)
--
-- ############################################################################

return{

-- ############################################################################
entry{
    contractedstem = "TEST",
    stemclass      = "n",
    class{
        type = "n",
        group{
            info = "",
            translation{text = "test", index = {}, },
            translation{text = "experiment", index = {}, },
        },
    },
    class{
        type = "v",
        group{
            info = "",
            translation{text = "test", index = {}, before = "to conduct a "},
        },
    },
},
-- ############################################################################
entry{
    contractedstem = "EXPERIMENT",
    stemclass      = "n",
    class{
        type = "n",
        group{
            info = "",
            translation{text = "experiment", index = {}, },
            translation{text = "test", index = {}, },
        },
    },
    class{
        type = "v",
        group{
            info = "",
            translation{text = "experiment", index = {}, before = "to conduct an "},
        },
    },
},
-- ############################################################################

} -- return closing bracket
