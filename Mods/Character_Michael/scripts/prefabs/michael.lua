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

    Asset( "ANIM", "anim/michael.zip" ),
    Asset( "ANIM", "anim/werebear_build.zip" ),
    Asset( "ANIM", "anim/werelizard_build.zip" ),

    Asset( "ANIM", "anim/ghost_michael_build.zip" ),

    Asset("IMAGE", "images/colour_cubes/beaver_vision_cc.tex"),
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

-- Combat
local function onHit(inst, attacker, damage)
    log("onhit", inst, attacker, damage)
    local damagebonus
    if attacker then
        damagebonus = TUNE["DAMAGE_FROM_"..attacker.prefab:upper()]
    end
    if damagebonus then
        damagebonus = damage * damagebonus
        inst.components.health:DoDelta(-damagebonus)
        log("damagebonus on hit is", damagebonus)
    else
        inst.components.health:DoDelta(-damage)
    end
end

local function keepTarget(inst, target)
    log("keepTarget", inst, target)
    inst.components.rage:SetLoserate(TUNE.RAGE_LOSE)
end

local function attackOther(inst, data)
    local target = data.target
    local weapon = data.weapon
    local projectile = data.projectile
    inst.components.rage:DoDelta(TUNE.HIT_RAGE)
    inst.components.sanity:DoDelta(TUNE.HIT_SANITY)
    log("rage: "..inst.components.rage.current, "sanity: "..inst.components.sanity.current)
end

-- Eater
local function onEat(inst, food)
    if food and food.components.edible then
        local ds = food.components.edible:GetSanity(inst) -- delta sanity
        if food.prefab == "honey" then -- bear likes this FRESH food
            if ds == 0 then ds = TUNE.HONEY_SANITY end
        elseif food.prefab == "berries" then
            if ds == 0 then ds = TUNE.BERRIES_SANITY end
        elseif food.prefab:find("_cap") then -- and don't like so much this (shrooms)
            if ds > 0 then ds = -ds end -- in fact, sanity doesn't rise or fall
        end
        inst.components.sanity:DoDelta(ds)
    end
end

-- Werebear --
local function becomeLizard(inst)
    inst:AddTag("bear")
    inst.Transform:SetScale(1.6, 1.6, 1.6, 1.6)
    log("-- becomeLizard start --")
    inst.AnimState:SetBuild("werelizard_build")
    log('build is set')
    inst.AnimState:SetBank("werelizard")
    log('bank is set')
    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
    log('sound played')

    inst.Light:Enable(true)
    log('Light enabled')
    TheWorld:PushEvent("overridecolourcube", "images/colour_cubes/beaver_vision_cc.tex")
    log('colorcube is overrided')
    log('-- becomeLizard end --')
end

local function becomeBear(inst)
    inst:AddTag("bear")
    inst.Transform:SetScale(1.5, 1.5, 1.5, 1.5)
    inst.AnimState:SetBuild("werebear_build")
    inst.AnimState:SetBank("werebear")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
    inst.AnimState:PlayAnimation("idle") -- if need
    inst:SetStateGraph("SGwerebear")
    -- inst.sg:GoToState("transform_pst")

    inst.Light:Enable(true)
    -- TheWorld:PushEvent("overridecolourcube", "images/colour_cubes/beaver_vision_cc.tex")
end

local function becomeHuman(inst)
    inst:RemoveTag("bear")
    inst.Transform:SetScale(1, 1, 1, 1)
    inst.AnimState:SetBuild("michael")
    inst.AnimState:SetBank("wilson")
    inst:SetStateGraph("SGwilson")

    inst.Light:Enable(false)
    TheWorld:PushEvent("overridecolourcube")
end

local function testAnim(inst)
    local anims = TUNE.testAnim
    inst.AnimState:PlayAnimation(anims[1])
    for i = 2, #anims do
        inst.AnimState:PushAnimation(anims[i])
    end
end


-- This initializes for the host only
local master_postinit = function(inst)
    inst.soundsname = "wolfgang"
    -- Stats
    inst.components.health:SetMaxHealth(TUNE.HEALTH)
    inst.components.hunger:SetMax(TUNE.HUNGER)
    inst.components.sanity:SetMax(TUNE.SANITY)

    inst.components.combat:SetDefaultDamage(TUNE.UNARMED_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNE.ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNE.ATTACK_RANGE)

    inst:AddComponent("rage")
    inst.components.rage:SetMax(TUNE.RAGE)
    inst.components.rage:SetMaxLimit(TUNE.RAGE_LIMIT)
    inst.components.rage:SetLoserate(TUNE.RAGE_LOSE)

    inst:AddTag("michael")
    becomeHuman(inst)

    -- Light
    inst.Light:SetRadius(5)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.6)
    inst.Light:SetColour(245/255, 130/255, 110/255)

    -- Combat
    inst.components.combat:SetOnHit(onHit)
    inst.components.combat:SetKeepTargetFunction(keepTarget)
    inst:ListenForEvent("onattackother", attackOther)

    -- Eater
    inst.components.eater:SetOnEatFn(onEat)

    -- Rage
    inst:ListenForEvent("bear_start", becomeBear)
    -- inst:ListenForEvent("bear_end", becomeHuman)

    -- TEST ANIM
    TheInput:AddKeyDownHandler(Utils.keyboard.P, function() testAnim(inst) end)
    TheInput:AddKeyDownHandler(Utils.keyboard.O, function()
        if inst:HasTag("bear") then becomeHuman(inst) else becomeBear(inst) end
    end)
    TheInput:AddKeyDownHandler(Utils.keyboard.L, function()
        log("L pressed")
        if inst:HasTag("bear") then becomeHuman(inst) else becomeLizard(inst) end
    end)
end

return MakePlayerCharacter("michael", prefabs, assets, common_postinit, master_postinit, start_inv)
