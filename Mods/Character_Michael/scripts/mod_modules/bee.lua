local TUNE = TUNING.MICHAEL

local function changeLoot(bee)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    bee.components.combat.onkilledbyother = function(inst, attacker)
        if attacker:HasTag("michael") then
            for k,v in pairs(bee.components.lootdropper.randomloot) do
                bee.components.lootdropper.randomloot[k] = nil -- clearing loot table
            end
            bee.components.lootdropper:AddRandomLoot("honey", TUNE.BEE_HONEY_WEIGHT)
            bee.components.lootdropper:AddRandomLoot("stinger", TUNE.BEE_STINGER_WEIGHT)
            if TUNE.get_bee_after_killing then
                Utils:giveItem(attacker, "bee", 1) -- spawn bee in inv for test. TODO if no bees in inv
            end
        end
    end
end

AddPrefabPostInit("bee", changeLoot)
