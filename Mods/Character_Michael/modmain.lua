PrefabFiles = {
    "michael",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/michael.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/michael.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/michael.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/michael.xml" ),
    
    Asset( "IMAGE", "images/selectscreen_portraits/michael_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/michael_silho.xml" ),

    Asset( "IMAGE", "bigportraits/michael.tex" ),
    Asset( "ATLAS", "bigportraits/michael.xml" ),
    
    Asset( "IMAGE", "images/map_icons/michael.tex" ),
    Asset( "ATLAS", "images/map_icons/michael.xml" ),
    
    Asset( "IMAGE", "images/avatars/avatar_michael.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_michael.xml" ),
    
    Asset( "IMAGE", "images/avatars/avatar_ghost_michael.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_michael.xml" ),

}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
STRINGS.CHARACTER_TITLES.michael = "Michael, a spirit of bears"
STRINGS.CHARACTER_NAMES.michael = "Michael"
STRINGS.CHARACTER_DESCRIPTIONS.michael = "*Might become bear when fights (WIP)\n*Love honey and berries, but hate bees (WIP)"
STRINGS.CHARACTER_QUOTES.michael = "\"AR-R-R-RGH\""

-- Custom speech strings
STRINGS.CHARACTERS.michael = require "speech_michael"

-- The character's name as appears in-game 
STRINGS.NAMES.michael = "Michael"

-- The default responses of examining the character
STRINGS.CHARACTERS.GENERIC.DESCRIBE.michael = {
    GENERIC = "[GENERIC] It's Esc!",
    ATTACKER = "[ATTACKER] That Esc looks shifty...",
    MURDERER = "[MURDERER] Murderer!",
    REVIVER = "[REVIVER] Esc, friend of ghosts.",
    GHOST = "[GHOST] Esc could use a heart.",
}

-- Let the game know character is male, female, or robot
table.insert(GLOBAL.CHARACTER_GENDERS.MALE, "michael")

AddMinimapAtlas("images/map_icons/michael.xml")
AddModCharacter("michael")

---- HELPERS ----
function giveItem(inst, name, val)
    if not val then val = 1 end
    for i=1, val, 1 do
        local newBee = GLOBAL.SpawnPrefab(name)
        inst.components.inventory:GiveItem(newBee)
    end
end

--- PREFABS ---
local function beeChangeLoot(bee)
    bee.components.combat.onkilledbyother = function(inst, attacker)
        -- print("Bee is killed")
        if attacker:HasTag("michael") then
            -- print("By Michael")
            for k,v in pairs(bee.components.lootdropper.randomloot) do
                bee.components.lootdropper.randomloot[k] = nil -- clearing loot table
            end
            bee.components.lootdropper:AddRandomLoot("honey", 15)
            bee.components.lootdropper:AddRandomLoot("stinger", 5)
            -- giveItem(attacker, "bee", 1) -- spawn bee in inv for test
        end
    end
end
AddPrefabPostInit("bee", beeChangeLoot)
