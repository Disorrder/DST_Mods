Utils = {}

function Utils:giveItem(inst, name, val)
    if not val then val = 1 end
    for i=1, val, 1 do
        local newBee = SpawnPrefab(name)
        inst.components.inventory:GiveItem(newBee)
    end
end

function Utils.tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

---- Keyboard ----
local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
local keyboard = {}
for i = 1,#alpha do keyboard[alpha[i]] =  i + KEY_A - 1 end
Utils.keyboard = keyboard

---- Logging ----
local Log = {
    buffer = "",
    all_path = "../mich-history.log",
    path = "../mich.log", -- realtime
    file = nil
}

function Log:read()
    local f = io.open(self.path, "r")
    if not f then return end
    self.buffer = f:read("*a")
    f:close()
    return self.buffer
end

function Log:clear()
    self.buffer = ""
    local f = io.open(self.path, "w")
    f:close()
end

function Log:save()
    local f = io.open(self.all_path, "r")
    local buf = f:read("*a") .. self.buffer
    f:close()

    f = io.open(self.all_path, "w")
    f:write("--- SESSION START ---\n")
    f:write(self.buffer)
    f:write("--- SESSION END ---\n\n\n")
    f:close()
    self:clear()
end

function Log:log(...)
    if TUNING.MICHAEL.debug then
        print(...)

        -- file output
        local args = {...}
        local argsLen = Utils.tableLength(args)

        self.file = io.open(self.path, "w")

        local time = os.date("%d/%m/%y %H:%M:%S")
        local str = "["..time.."]: "

        for i,v in ipairs(args) do
            if type(v) == "table" then
                if v.prefab then v = "pf_"..v.prefab end
            end
            str = str .. tostring(v)
            if i < argsLen then str = str .. ", " end
        end
        str = str .. "\n"
        self.buffer = self.buffer .. str

        self.file:write(self.buffer)
        self.file:close()
    end
end

function Utils.log(...)
    Log:log(...)
end

Log:read()
Utils.Log = Log
------------------------

log = Utils.log -- write to GLOBAL
return Utils
