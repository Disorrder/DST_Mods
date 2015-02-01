local Rage = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.maxlimit = 100
    self.current = 0
    self.hold = false
    
    self.loserate = 0
    self.task = self.inst:DoPeriodicTask(1, function() self:LongUpdate(1) end)
end,
nil,
{
    -- replica???
    -- max = onmax,
    -- current = oncurrent,
})

function Rage:OnSave()
    if self.current ~= 0 then
        return {rage = self.current}
    end
end

function Rage:OnLoad(data)
    if data.rage then
        self.current = data.rage
        self:DoDelta(0)
    end
end

function Rage:LongUpdate(dt)
    self:Change(-self.loserate * dt)
end

function Rage:Pause()
    self.hold = true
end

function Rage:Resume()
    self.hold = false
end

function Rage:SetMax(amount)
    self.max = math.min(amount, self.maxlimit)
end

function Rage:SetMaxLimit(amount)
    self.maxlimit = amount
end

function Rage:SetLoserate(amount)
    self.loserate = amount
end

function Rage:Hold(state)
    if state == nil then state = true end
    self.hold = state
end

function Rage:DoDelta(delta)
    self.current = math.min(math.max(self.current + delta, 0), self.max)   
    local combat = self.inst.components.combat
    combat.damagebonus = TUNING.MICHAEL.RAGE_ATK_SCALE * self.current
    -- log("Rage:DoDelta", delta, self.current, combat.damagebonus)
    self.inst.components.talker:Say("Rage: "..self.current..", DmgBonus: "..combat.damagebonus)
end

function Rage:GetPercent()
    return self.current / self.max
end

function Rage:SetPercent(p)
    local old = self.current
    local current = p*self.max
    local delta = self:DoDelta(current - old)
end

function Rage:Change(delta)
    if not self.hold then
        self:DoDelta(delta)
    end
end

return Rage
