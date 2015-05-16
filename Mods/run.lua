--- Author : TheSim
--- Time   : 13.05.2015 12:37

require'rex_pcre'
require'lfs'

local modName='Character_Michael'
local steamRegPath1 = [[HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam]]
local steamRegPath2 = [[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam]]
local srcDir = [[.]]

local exec = os.execute
local match = rex_pcre.match
local attrs = lfs.attributes
-- такая вот кривая функция для чтения реестра
local function readRegistryString(key,attr)
  local cmd = io.popen('reg query '..key..' /v '..attr)
  for l in cmd:lines() do
    local a,b = match(l,[[^\s+]]..attr..[[\s+\S+\s+(.*?)$]])
    if a then
      cmd:close()
      return a
    end
  end
  cmd:close()
end

-- Ищем стим
local steamPath = readRegistryString(steamRegPath1, 'InstallPath')
steamPath = steamPath or readRegistryString(steamRegPath2,'InstallPath')

if not steamPath then error 'Unable to find steam' end
local gamePath= steamPath .. [[\SteamApps\common\Don't Starve Together Beta]]
local modPath = gamePath..[[\mods\]]..modName
local modTools=steamPath..[[\SteamApps\common\Don't Starve Mod Tools Release\mod_tools]]

-- Копируем все нужное из папки источников
local traverse
traverse = function(absPath, relPath, fileFn, dirFn)
  if dirFn == nil then
    dirFn = fileFn
    fileFn = relPath
    relPath =''
  end
  dirFn = dirFn or traverse
  absPath = absPath ..[[\]]
  relPath = relPath ..[[\]]
  for file in lfs.dir(absPath) do
    if file~='.' and file ~='..' then
      if attrs(absPath..file).mode == 'directory' then
        dirFn(absPath..file, relPath..file, fileFn, dirFn) -- да, рекурсия это плохо
      else
        fileFn(absPath..file, relPath..file)
      end
    end
  end
end

local tmpF = io.open('tmp.bat','w')
tmpF:write('cd "'..modTools.. '"\n')
local keyDirs = {
  ['\\exported'] = function(absPath, relPath)
    absPath = absPath..[[\]]
    relPath = relPath..[[\]]
    for file in lfs.dir(absPath) do
      if file~='.' and file ~='..' then
        if attrs(absPath..file).mode == 'directory' then
          local line = '"'..modTools..'\\scml.exe" "'
            ..absPath..file..'\\'..file..'.scml" "'
            ..modPath..relPath..file..'"'
          line = string.gsub(line,[[\]],[[/]])
          tmpF:write(line..'\n')
        end
      end
    end
  end,
}

traverse(srcDir..[[\]]..modName, function(file)
    -- print(file)
  end,
  function(full, filename, fileFn, dirFn)
    local fn = keyDirs[filename]
    if fn then
      fn(full, filename)
    else
      traverse(full, fileFn, dirFn)
    end
  end
)

tmpF:close()
exec'cmd /C tmp.bat'
os.remove'tmp.bat'
-- фиксим все что нужно фиксить

-- Запускаем стим
--exec(steamPath..'/Steam.exe steam://rungameid/322330')
