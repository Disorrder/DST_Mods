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
            -- Utils.giveItem(attacker, "bee", 1) -- spawn bee in inv for test
        end
    end
end

AddPrefabPostInit("bee", beeChangeLoot)
