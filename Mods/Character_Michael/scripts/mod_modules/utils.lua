Utils = {}

function Utils:giveItem(inst, name, val)
    if not val then val = 1 end
    for i=1, val, 1 do
        local newBee = GLOBAL.SpawnPrefab(name)
        inst.components.inventory:GiveItem(newBee)
    end
end

return Utils
