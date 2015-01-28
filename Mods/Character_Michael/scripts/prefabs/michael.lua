local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset( "ANIM", "anim/player_basic.zip" ),
    Asset( "ANIM", "anim/player_idles_shiver.zip" ),
    Asset( "ANIM", "anim/player_actions.zip" ),
    Asset( "ANIM", "anim/player_actions_axe.zip" ),
    Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
    Asset( "ANIM", "anim/player_actions_shovel.zip" ),
    Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
    Asset( "ANIM", "anim/player_actions_eat.zip" ),
    Asset( "ANIM", "anim/player_actions_item.zip" ),
    Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
    Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
    Asset( "ANIM", "anim/player_actions_fishing.zip" ),
    Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
    Asset( "ANIM", "anim/player_bush_hat.zip" ),
    Asset( "ANIM", "anim/player_attacks.zip" ),
    Asset( "ANIM", "anim/michael.zip" ),
    Asset( "ANIM", "anim/player_rebirth.zip" ),
    Asset( "ANIM", "anim/player_jump.zip" ),
    Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
    Asset( "ANIM", "anim/player_teleport.zip" ),
    Asset( "ANIM", "anim/wilson_fx.zip" ),
    Asset( "ANIM", "anim/player_one_man_band.zip" ),
    Asset( "ANIM", "anim/shadow_hands.zip" ),
    Asset( "SOUND", "sound/sfx.fsb" ),
    Asset( "SOUND", "sound/wilson.fsb" ),
    Asset( "ANIM", "anim/beard.zip" ),

    Asset( "ANIM", "anim/ghost_michael_build.zip" ),
}
local prefabs = {
    "bee",
    "honey"
}
local start_inv = {
    -- Custom starting items
    "armorwood",
    "spear",
    "pickaxe",
    "shovel",
    "bee"
}

-- This initializes for both clients and the host
local common_postinit = function(inst) 
    inst.MiniMapEntity:SetIcon( "michael.tex" ) -- Minimap icon
end

----  POSTINIT  ----
local TUNE = TUNING.MICHAEL

local function onEat(inst, food)
    if food and food.components.edible then
        local ds = food.components.edible:GetSanity(inst) -- delta sanity
        if food.prefab == "honey" then -- bear likes this FRESH food
            if ds == 0 then ds = TUNE.HONEY_SANITY end
        elseif food.prefab == "berries" then 
            if ds == 0 then ds = TUNE.BERRIES_SANITY end
        elseif food.prefab:find("_cap") then -- and dislikes this
            if ds > 0 then ds = -ds end -- in fact, sanity doesn't rise or fall
        end
        inst.components.sanity:DoDelta(ds)
    end
end

-- This initializes for the host only
local master_postinit = function(inst)
    inst.soundsname = "wolfgang"
    -- Stats    
    inst.components.health:SetMaxHealth(TUNE.HEALTH)
    inst.components.hunger:SetMax(TUNE.HUNGER)
    inst.components.sanity:SetMax(TUNE.SANITY)

    inst:AddTag("michael")
    -- Utils:giveItem(inst, "bee", 1) -- spawn bee in inv for test

    inst.components.eater:SetOnEatFn(onEat)
end

return MakePlayerCharacter("michael", prefabs, assets, common_postinit, master_postinit, start_inv)
