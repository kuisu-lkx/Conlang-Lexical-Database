--##############################################################################
-- SUBSCRIPT: Global shared state
-- TODO TODO TODO split into subscripts: ipa, ortography etc.
--##############################################################################

local S = {}

-- ############################################################################
-- Global entry tables
-- ############################################################################

S.entries = {}

S.compounds = {}

S.options = {
    status = false,
    translation = false,
    note = false,
    morphology = false,
    abbreviated = true,
    color = false,
    dense = false,
    changelog = false,
    citations = false,
    paradigm_ipa = false,
    screen_frame = true,
}

S.file_patterns = {

    entries = {
        "%.lex%.lua$",
        "%.prt%.lua$",
    },

    compounds = {
        "%.cmp%.lua$",
    },

}

S.debug_mode = false

-- ############################################################################
-- Tables used by paradigm.lua --TODO
-- ############################################################################

S.case_order = {

    "NOM",
    "VOC",
    "ACC",
    "DAT",
    "LOC",
    "ABL",
    "INS",
    "GEN",

}

S.case_rank = {}

for i, case in ipairs(S.case_order) do
    S.case_rank[case] = i
end

--[[Human readable for later printout of paradigm
S.cases = {

    NOM = {

    name = "Nominative",
    abbr = "NOM"

    },

    VOC = {

    name = "Vocative",
    abbr = "VOC"

    },

...

}
]]

S.inflections = {

    nominal = {

        n1 = {
            NOM = {stem = "expanded", sg = "", gc = "le", pl = "li"},
            VOC = {stem = "expanded", sg = "", gc = "", pl = ""},
            ACC = {stem = "expanded", sg = "h", gc = "he", pl = "hi"},
            DAT = {stem = "expanded", sg = "mō", gc = "mō", pl = "moi"},
            LOC = {stem = "expanded", sg = "s", gc = "se", pl = "si"},
            ABL = {stem = "expanded", sg = "þē", gc = "þē", pl = "þai"},
            INS = {stem = "expanded", sg = "na", gc = "nae", pl = "nai"},
            GEN = {stem = "expanded", sg = "n", gc = "ne", pl = "ni"},
        },
        n2 = {
            NOM = {stem = "contracted", sg = "", gc = "e", pl = "i"},
            VOC = {stem = "expanded", sg = "", gc = "", pl = ""},
            ACC = {stem = "expanded", sg = "h", gc = "he", pl = "hi"},
            DAT = {stem = "contracted", sg = "ō", gc = "ō", pl = "oi"},
            LOC = {stem = "expanded", sg = "s", gc = "se", pl = "si"},
            ABL = {stem = "contracted", sg = "ē", gc = "ē", pl = "ai"},
            INS = {stem = "contracted", sg = "ēna", gc = "ēnae", pl = "ēnai"},
            GEN = {stem = "expanded", sg = "n", gc = "ne", pl = "ni"},
        },
        n3 = {
            NOM = {stem = "contracted", sg = "", gc = "e", pl = "i"},
            VOC = {stem = "expanded", sg = "", gc = "", pl = ""},
            ACC = {stem = "expanded", sg = "h", gc = "he", pl = "hi"},
            DAT = {stem = "contracted", sg = "ō", gc = "ō", pl = "oi"},
            LOC = {stem = "expanded", sg = "s", gc = "se", pl = "si"},
            ABL = {stem = "contracted", sg = "ē", gc = "ē", pl = "ai"},
            INS = {stem = "contracted", sg = "ēna", gc = "ēnae", pl = "ēnai"},
            GEN = {stem = "expanded", sg = "n", gc = "ne", pl = "ni"},
        },
        n4 = {
            NOM = {stem = "contracted", sg = "", gc = "e", pl = "i"},
            VOC = {stem = "contracted", sg = "a", gc = "ae", pl = "ai"},
            ACC = {stem = "contracted", sg = "ah", gc = "eh", pl = "ih"},
            DAT = {stem = "contracted", sg = "ō", gc = "ō", pl = "oi"},
            LOC = {stem = "contracted", sg = "as", gc = "aes", pl = "ais"},
            ABL = {stem = "contracted", sg = "ē", gc = "ē", pl = "ai"},
            INS = {stem = "contracted", sg = "ēna", gc = "ēnae", pl = "ēnai"},
            GEN = {stem = "contracted", sg = "an", gc = "aen", pl = "ain"},
        },
        n5 = {
            NOM = {stem = "contracted", sg = "", gc = "e", pl = "i"},
            VOC = {stem = "expanded", sg = "", gc = "", pl = ""},
            ACC = {stem = "contracted", sg = "ah", gc = "eh", pl = "ih"},
            DAT = {stem = "contracted", sg = "ō", gc = "ō", pl = "oi"},
            LOC = {stem = "expanded", sg = "s", gc = "se", pl = "si"},
            ABL = {stem = "contracted", sg = "ē", gc = "ē", pl = "ai"},
            INS = {stem = "expanded", sg = "na", gc = "nae", pl = "nai"},
            GEN = {stem = "expanded", sg = "n", gc = "ne", pl = "ni"},
        },--[[
        n6 = {
            NOM = {stem = "", sg = "", gc = "", pl = ""},
            VOC = {stem = "", sg = "", gc = "", pl = ""},
            ACC = {stem = "", sg = "", gc = "", pl = ""},
            DAT = {stem = "", sg = "", gc = "", pl = ""},
            LOC = {stem = "", sg = "", gc = "", pl = ""},
            ABL = {stem = "", sg = "", gc = "", pl = ""},
            INS = {stem = "", sg = "", gc = "", pl = ""},
            GEN = {stem = "", sg = "", gc = "", pl = ""},
        },]]
    },
    verbal = {
        v = {} -- big TODO
    }
}

-- ############################################################################
-- TODO
-- ############################################################################

S.vowels = {"A", "a", "Á", "á", "À", "à", "Ä", "ä", "Ā", "ā", "E", "e",
    "É", "é", "È", "è", "Ë", "ë", "Ē", "ē", "I", "i", "Í", "í", "Ì", "ì", "Ī",
    "ī", "O", "o", "Ó", "ó", "Ò", "ò", "Ö", "ö", "Ō", "ō", "U", "u", "Ú", "ú",
    "Ù", "ù", "Ü", "ü", "Ū", "ū", "Y", "y", "Ý", "ý", "â", "ê", "î", "ô", "û",}

S.diphthongs = { "ie", "io", "iu", "ia", "ei", "eu", "ea", "oi", "oe", "ou",
    "oa", "ui", "ue", "ua", "ai", "ae", "au", "IE", "IO", "IU", "IA", "EI",
    "EU", "EA", "OI", "OE", "OU", "OA", "UI", "UE", "UA", "AI", "AE", "AU",
    "Ie", "Io", "Iu", "Ia", "Ei", "Eu", "Ea", "OI", "Oe", "Ou", "Oa", "Ui",
    "Ue", "Ua", "Ai", "Ae", "Au",}

--[[
S.common_before =
{
    { '0' },
    { '1' },
    { '2' },
    { '3' },
    { '4' },
    { '5' },
    { '6' },
    { '7' },
    { '8' },
    { '9' },
}

S.common_after =
{
    { ' ' },
    { '¹' },
    { '²' },
    { '³' },
    { '⁴' },
    { '⁵' },
    { '⁶' },
    { '⁷' },
    { '⁸' },
    { '⁹' },
}
]]

S.lkx_alphabet =
{
    { 'a', 'á', 'à', 'ä' },
    { 'ā', 'â' },
    { 'b' },
    { 'd' },
    { 'e', 'é', 'è', 'ë' },
    { 'ē', 'ê' },
    { 'f' },
    { 'g' },
    { 'h' },
    { 'i', 'í', 'ì', 'ï' },
    { 'ī', 'î' },
    { 'k' },
    { 'l' },
    { 'm' },
    { 'n' },
    { 'ŋ' },
    { 'o', 'ó', 'ò', 'ö' },
    { 'ō', 'ô' },
    { 'p' },
    { 'q' },
    { 'r' },
    { 's' },
    { 't' },
    { 'u', 'ú', 'ù', 'ü' },
    { 'ū', 'û' },
    { 'v' },
    { 'x' },
    { 'y' },
    { 'þ' },
}

S.eng_alphabet =
{
    { 'a', 'á', 'à', 'ä' },
    { 'b' },
    { 'c' },
    { 'd' },
    { 'e', 'é', 'è', 'ë' },
    { 'f' },
    { 'g' },
    { 'h' },
    { 'i', 'í', 'ì', 'ï' },
    { 'j' },
    { 'k' },
    { 'l' },
    { 'm' },
    { 'n' },
    { 'o', 'ó', 'ò', 'ö' },
    { 'p' },
    { 'q' },
    { 'r' },
    { 's' },
    { 't' },
    { 'u', 'ú', 'ù', 'ü' },
    { 'v' },
    { 'w' },
    { 'x' },
    { 'y' },
    { 'z' },
}

S.vowels_long = {"ā", "ē", "ī", "ō", "ū",}

S.vowels_short = {"a", "e", "i", "o", "u",}

-- ############################################################################
-- Tables used by ipa.lua
-- ############################################################################

-------------------------------------------------------------------------------
-- Vowels
-------------------------------------------------------------------------------

-- Look-up table to substitute short vowels with their long equivalent
S.short_to_long = {
    ['a'] = 'ā',
    ['e'] = 'ē',
    ['i'] = 'ī',
    ['o'] = 'ō',
    ['u'] = 'ū'
}

-- Look-up table to substitute long vowels with their short equivalent
S.long_to_short = {
    ['ā'] = 'a',
    ['ē'] = 'e',
    ['ī'] = 'i',
    ['ō'] = 'o',
    ['ū'] = 'u'
}

-- IPA representations of unstressed vowels
S.vowel_ipa_unstressed = {
    ["i"] = "ɪ",
    ["e"] = "ɛ",
    ["o"] = "ɔ",
    ["u"] = "ʊ",
    ["a"] = "ʌ",
    ["ī"] = "i",
    ["ē"] = "e",
    ["ō"] = "o",
    ["ū"] = "u",
    ["ā"] = "a"
}

-- IPA representations of stressed vowels
S.vowel_ipa_stressed = {
    ["i"] = "ɪ",
    ["e"] = "ɛ",
    ["o"] = "ɔ",
    ["u"] = "ʊ",
    ["a"] = "ʌ",
    ["ī"] = "iː",
    ["ē"] = "eː",
    ["ō"] = "oː",
    ["ū"] = "uː",
    ["ā"] = "aː",
}

-- Vowels with explicitly marked stress
S.vowels_explicit_stress = {
    ["á"] = true,
    ["é"] = true,
    ["í"] = true,
    ["ó"] = true,
    ["ú"] = true,
    ["â"] = true,
    ["ê"] = true,
    ["î"] = true,
    ["ô"] = true,
    ["û"] = true,
}

-- Look-up table to translate vowels with explicitly marked stress into normal
-- vowels after stress determination and before IPA rendering
S.vowel_explicit_base = {
    ["á"] = "a",
    ["é"] = "e",
    ["í"] = "i",
    ["ó"] = "o",
    ["ú"] = "u",
    ["â"] = "ā",
    ["ê"] = "ē",
    ["î"] = "ī",
    ["ô"] = "ō",
    ["û"] = "ū",
}

-- Look-up table to translate vowels with explicitly marked stress into their
-- equivalent vowel with secondary stress marking
S.vowel_explicit_secondary = {
    ["á"] = "à",
    ["é"] = "è",
    ["í"] = "ì",
    ["ó"] = "ò",
    ["ú"] = "ù",
    ["â"] = "â",
    ["ê"] = "ê",
    ["î"] = "î",
    ["ô"] = "ô",
    ["û"] = "û",
}

-------------------------------------------------------------------------------
-- Diphtongs
-------------------------------------------------------------------------------

-- IPA representations of diphtongs
S.diphthong_ipa = {
    ["ie"] = "ɪ̯ɛ",
    ["io"] = "ɪ̯ɔ",
    ["iu"] = "ɪ̯ʊ",
    ["ia"] = "ɪ̯ʌ",
    ["ei"] = "ɛɪ̯",
    ["oi"] = "ɔɪ̯",
    ["ui"] = "ʊɪ̯",
    ["ai"] = "aɪ̯",
    ["oe"] = "ɔɪ̯",
    ["ue"] = "ʊɪ̯",
    ["ae"] = "aɪ̯",
    ["eu"] = "yː",
    ["ou"] = "ɔʊ̯",
    ["au"] = "aʊ̯",
    ["ea"] = "ɛʌ̯",
    ["oa"] = "ɔɑ̯",
    ["ua"] = "ʊɑ̯",
}

-- Diphtongs that are reduced before a palatalized consonant
S.diphthong_palat = {
    ["ai"] = true,
    ["oi"] = true,
    ["ui"] = true,
    ["ei"] = true
}

-- IPA representations of diphtongs that are reduced before a palatalized
-- consonant
S.diphthong_ipa_reduced = {
    ["ai"] = "a",
    ["oi"] = "ɔ",
    ["ui"] = "ʊ",
    ["ei"] = "ɛ"
}

-------------------------------------------------------------------------------
-- Consonants
-------------------------------------------------------------------------------

-- IPA representations of consonants
S.consonant_ipa = {
    ["p"] = "p",
    ["b"] = "b",
    ["f"] = "ɸ",
    ["v"] = "β",
    ["m"] = "m",
    ["t"] = "t",
    ["d"] = "d",
    ["þ"] = "θ",
    ["n"] = "n",
    ["k"] = "k",
    ["g"] = "g",
    ["x"] = "x",
    ["q"] = "ɣ",
    ["ŋ"] = "ŋ",
    ["l"] = "ɫ̪",
    ["r"] = "ɾ",
    ["s"] = "s",
    ["h"] = "h",
}

-- Consonants that can undergo palatalization
S.consonants_palat_lookup = {
    ["r"] = true,
    ["s"] = true,
    ["l"] = true,
    ["n"] = true
}

-- IPA representations of palatalized consonants
S.consonant_ipa_palatal = {
    ["l"] = "ʎ",
    ["r"] = "ɹ̠",
    ["s"] = "ɕ",
    ["n"] = "ɲ"
}

-- Consonants that can undergo lenition
S.consonants_lenit_lookup = {
    ["p"] = true,
    ["b"] = true,
    ["t"] = true,
    ["d"] = true,
    ["k"] = true,
    ["g"] = true,
    ["l"] = true,
    ["r"] = true,
    ["s"] = true,
}

-- IPA representations of lenited consonants
S.consonant_ipa_lenited = {
    ["ph"] = "ɸ",
    ["bh"] = "β",
    ["th"] = "θ",
    ["dh"] = "ð",
    ["kh"] = "x",
    ["gh"] = "ɣ",
    ["lh"] = "l̥",
    ["rh"] = "r̥",
    ["sh"] = "h"
}

S.geminates = {
    ["pp"] = "p",
    ["bb"] = "b",
    ["ff"] = "f",
    ["vv"] = "v",
    ["mm"] = "m",
    ["tt"] = "t",
    ["dd"] = "d",
    ["þþ"] = "þ",
    ["nn"] = "n",
    ["kk"] = "k",
    ["gg"] = "g",
    ["xx"] = "x",
    ["qq"] = "q",
    ["ŋŋ"] = "ŋ",
    ["ll"] = "l",
    ["rr"] = "r",
    ["ss"] = "s",
    ["hh"] = "h",
}

-----------------------------------------------------
S.n1_finals = {}

for _, vowel in ipairs(S.vowels_long) do

    table.insert(S.n1_finals, vowel)

end

for _, diphthong in ipairs(S.diphthongs) do

    table.insert(S.n1_finals, diphthong)

end

---------------------------------------------------
S.stemclass_order = {
    "n1",
    "n2",
    "n3",
    "n4",
    "n5",
    "v",
}

-------------------------------------------------
S.lkx_alphabet_lookup = {}

for i, group in ipairs(S.lkx_alphabet) do

    for _, char in ipairs(group) do

        S.lkx_alphabet_lookup[char] = i

    end

end

--##############################################################################
-- RETURN
--##############################################################################

return S
