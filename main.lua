-- Gerado pelo Editor Visual Lupi. Edite o projeto visual para alterar objetos.
-- Projeto: teste
require "palette"
require "sprites"

local WORLD_WIDTH = 960
local WORLD_HEIGHT = 270
local PlayerActions = {}
local PlayerActionDraw = nil
local PlayerAttackDraw = nil
local PlayerFacingLeft = false
local PlayerAttack = { active = false, remaining = 0, frame = 0, direction = 1, hitbox = nil, hitTargets = {}, x = 0, y = 0 }
local cameraX, cameraY = 0, 0
local cameraLockX, cameraLockY = 0, 0
local cameraPreviousX, cameraPreviousY = nil, nil

local ProjectPalette = {
    0x0000,
    0x6C41,
    0x7C1A,
    0x03E0,
    0x01FF,
    0x03FF,
    0x6C41,
    0x0765,
    0x5F81,
    0x181F,
    0x19E4,
}
local ASSET_PALETTE_SIZE = #Palette
if ASSET_PALETTE_SIZE + #ProjectPalette > 256 then error("A paleta dos sprites e as cores do editor ultrapassam 256 índices.") end

local function resolveSpriteAsset(assetPath)
    local function childByName(parent, name)
        local direct = parent[name]
        if direct ~= nil then return direct end
        local wanted = string.lower(name)
        for key, value in pairs(parent) do
            if type(key) == "string" and string.lower(key) == wanted then return value end
        end
        return nil
    end
    local function lookup(root, relativePath)
        local current = root
        for segment in string.gmatch(relativePath, "[^/]+") do
            local key = segment
            if string.sub(key, -4):lower() == ".png" then key = string.sub(key, 1, -5) end
            if type(current) ~= "table" then return nil end
            current = childByName(current, key)
        end
        if type(current) == "table" and current.path then return current end
        return nil
    end
    local sprite = lookup(Sprites, assetPath)
    if sprite then return sprite end
    if string.sub(assetPath, 1, 7) == "assets/" then
        sprite = lookup(Sprites, string.sub(assetPath, 8))
        if sprite then return sprite end
    end
    local baseName = string.match(assetPath, "([^/]+)%.png$") or string.match(assetPath, "([^/]+)$")
    if Sprites.find then
        local ok, found = pcall(Sprites.find, baseName)
        if ok and found then return found end
    end
    local function search(node, seen)
        if type(node) ~= "table" or seen[node] then return nil end
        seen[node] = true
        local wanted = string.lower(baseName)
        local pathName = node.path and (string.match(node.path, "([^/]+)%.png$") or string.match(node.path, "([^/]+)$"))
        if node.path and ((type(node.name) == "string" and string.lower(node.name) == wanted) or (pathName and string.lower(pathName) == wanted)) then return node end
        local direct = childByName(node, baseName)
        if type(direct) == "table" and direct.path then return direct end
        for _, child in pairs(node) do
            local found = search(child, seen)
            if found then return found end
        end
        return nil
    end
    sprite = search(Sprites, {})
    if sprite then return sprite end
    error("Asset de sprite não encontrado: " .. assetPath)
end

local objects = {
    { name = "Retângulo 1", kind = "rect", color = ASSET_PALETTE_SIZE + 2, x = 8, y = 0, width = 473, height = 270, collision = false, invisible = false, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 8, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Linha 1", kind = "line", color = ASSET_PALETTE_SIZE + 1, x1 = 1, y1 = 206, x2 = 479, y2 = 206, collision = true, invisible = true, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 1, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 2", kind = "rect", color = ASSET_PALETTE_SIZE + 5, x = 0, y = 206, width = 480, height = 63, collision = false, invisible = false, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 0, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Triângulo 1", kind = "triangle", color = ASSET_PALETTE_SIZE + 4, x = 190, y = 16, width = 56, height = 36, collision = false, invisible = false, surface = false, movement = false, speed = 2, auto = true, auto_axis = "x", auto_origin = 190, auto_distance = 64, auto_speed = 3, auto_collide = false, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 4", kind = "rect", color = ASSET_PALETTE_SIZE + 7, x = 201, y = 148, width = 111, height = 18, collision = true, invisible = false, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 201, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 5", kind = "rect", color = ASSET_PALETTE_SIZE + 1, x = 483, y = 205, width = 475, height = 64, collision = true, invisible = false, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 483, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Círculo 2", kind = "circle", color = ASSET_PALETTE_SIZE + 8, x = 551, y = 56, radius = 18, collision = true, invisible = false, surface = false, movement = false, speed = 2, auto = true, auto_axis = "y", auto_origin = 56, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Círculo 3", kind = "circle", color = ASSET_PALETTE_SIZE + 9, x = 779, y = 105, radius = 18, collision = true, invisible = false, surface = false, movement = false, speed = 2, auto = true, auto_axis = "x", auto_origin = 779, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Círculo 4", kind = "circle", color = ASSET_PALETTE_SIZE + 1, x = 344, y = 21, radius = 18, collision = false, invisible = false, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 344, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 6", kind = "rect", color = ASSET_PALETTE_SIZE + 10, x = 372, y = 21, width = 56, height = 36, collision = false, invisible = false, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 372, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor sprite 020e6098-3e2b-4b28-9c35-f5753131e596", kind = "rect", color = ASSET_PALETTE_SIZE + 0, x = 318, y = 137, width = 32, height = 32, collision = true, invisible = true, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 318, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor sprite 78a6ea80-185b-48d6-ad1c-ea9cfe48664b", kind = "rect", color = ASSET_PALETTE_SIZE + 0, x = 26, y = 179, width = 20, height = 21, collision = true, invisible = true, surface = false, movement = true, speed = 2, auto = false, auto_axis = "x", auto_origin = 26, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = true, gravity_force = 0.35, jump = true, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor tiles 4-9,10", kind = "rect", color = ASSET_PALETTE_SIZE + 0, x = 64, y = 160, width = 96, height = 1, collision = true, invisible = true, surface = true, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 64, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor tiles 5-7,7", kind = "rect", color = ASSET_PALETTE_SIZE + 0, x = 80, y = 112, width = 48, height = 16, collision = true, invisible = true, surface = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 80, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
}

local authoredMap1Layer2 = {
  metadata = { width = 60, height = 17, tile_size = 16 },
  tilesets = {
    ["leaves"] = "leaves",
    ["tilemap.sunny.1"] = "tilemap.sunny.1",
    ["wtt"] = "wtt",
  },
  ["leaves"] = {
      [91] = 0,
      [31] = 0,
      [151] = 0,
      [211] = 0,
      [271] = 0,
      [331] = 0,
      [391] = 0,
      [32] = 1,
      [92] = 1,
      [152] = 1,
      [212] = 1,
      [272] = 1,
      [392] = 1,
      [33] = 2,
      [93] = 2,
      [153] = 2,
      [213] = 2,
      [34] = 3,
      [94] = 3,
      [154] = 3,
      [214] = 3,
      [335] = 3,
      [275] = 3,
      [215] = 3,
      [155] = 3,
      [95] = 3,
      [35] = 3,
      [36] = 0,
      [518] = 9,
      [517] = 9,
      [520] = 10,
      [519] = 10,
      [522] = 12,
      [344] = 13,
      [343] = 13,
      [345] = 14,
      [225] = 14,
      [105] = 14,
      [45] = 14,
      [44] = 14,
      [40] = 11,
      [39] = 11,
      [37] = 4,
      [339] = 9,
      [279] = 9,
  },
  ["tilemap.sunny.1"] = {
      [167] = 30,
      [227] = 30,
      [168] = 31,
      [228] = 31,
      [707] = 30,
      [647] = 30,
      [587] = 30,
      [527] = 30,
      [467] = 30,
      [407] = 30,
      [347] = 30,
      [287] = 30,
      [288] = 31,
      [348] = 30,
      [408] = 31,
      [468] = 31,
      [528] = 31,
      [588] = 31,
      [648] = 31,
      [708] = 31,
      [286] = 38,
      [292] = 23,
      [352] = 23,
      [533] = 39,
      [166] = 38,
      [226] = 38,
      [346] = 38,
      [406] = 38,
      [466] = 38,
      [526] = 38,
      [586] = 38,
      [646] = 38,
      [706] = 38,
  },
  ["wtt"] = {
      [751] = 86,
      [752] = 86,
      [753] = 86,
      [754] = 86,
      [755] = 86,
      [756] = 86,
      [757] = 86,
      [758] = 86,
      [759] = 86,
      [760] = 86,
      [761] = 86,
      [762] = 86,
      [763] = 86,
      [764] = 86,
      [765] = 86,
      [766] = 86,
      [767] = 86,
      [768] = 86,
      [769] = 86,
      [770] = 86,
      [771] = 86,
      [772] = 86,
      [773] = 86,
      [774] = 86,
      [775] = 86,
      [776] = 86,
      [777] = 86,
      [778] = 86,
      [779] = 86,
      [780] = 86,
      [811] = 101,
      [812] = 101,
      [813] = 101,
      [814] = 101,
      [815] = 101,
      [816] = 101,
      [817] = 101,
      [818] = 101,
      [819] = 101,
      [820] = 101,
      [821] = 101,
      [822] = 101,
      [823] = 101,
      [824] = 101,
      [825] = 101,
      [826] = 101,
      [827] = 101,
      [828] = 101,
      [829] = 101,
      [830] = 101,
      [831] = 101,
      [832] = 101,
      [833] = 101,
      [834] = 101,
      [835] = 101,
      [836] = 101,
      [837] = 101,
      [838] = 101,
      [839] = 101,
      [840] = 101,
      [871] = 106,
      [872] = 106,
      [873] = 106,
      [874] = 106,
      [875] = 106,
      [876] = 106,
      [877] = 106,
      [878] = 106,
      [879] = 106,
      [880] = 106,
      [881] = 106,
      [882] = 106,
      [883] = 106,
      [884] = 106,
      [885] = 106,
      [886] = 106,
      [887] = 106,
      [888] = 106,
      [889] = 106,
      [890] = 106,
      [891] = 106,
      [892] = 106,
      [893] = 106,
      [894] = 106,
      [895] = 106,
      [896] = 106,
      [897] = 106,
      [898] = 106,
      [899] = 106,
      [900] = 106,
  },
}
local authoredMap1Layer1 = {
  metadata = { width = 60, height = 17, tile_size = 16 },
  tilesets = {
    ["tilemap.sunny.1"] = "tilemap.sunny.1",
  },
  ["tilemap.sunny.1"] = {
      [169] = 1062,
      [229] = 1062,
      [289] = 1062,
      [349] = 1062,
      [409] = 1062,
      [469] = 1062,
      [529] = 1062,
      [589] = 1062,
      [649] = 1062,
      [709] = 1062,
      [769] = 1062,
      [766] = 38,
  },
}
local authoredMap1Layer4 = {
  metadata = { width = 60, height = 17, tile_size = 16 },
  tilesets = {
    ["wtt"] = "wtt",
  },
  ["wtt"] = {
      [605] = 0,
      [606] = 0,
      [607] = 0,
      [608] = 0,
      [609] = 0,
      [610] = 0,
  },
}
local authoredMap1Layer3 = {
  metadata = { width = 60, height = 17, tile_size = 16 },
  tilesets = {
    ["wtt"] = "wtt",
  },
  ["wtt"] = {
      [426] = 0,
      [427] = 0,
      [428] = 0,
  },
}
local authoredMap1Layer2Animation1 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation2 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation3 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation4 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation5 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation6 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation7 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation8 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation9 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation10 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation11 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation12 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation13 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation14 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation15 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation16 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation17 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation18 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation19 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation20 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation21 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation22 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation23 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation24 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation25 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation26 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation27 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation28 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation29 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation30 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation31 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation32 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer2Animation33 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation34 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation35 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation36 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation37 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation38 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation39 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation40 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation41 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation42 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation43 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation44 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap1Layer1Animation45 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local function authoredMap1Update(frame)
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation1[((frame // 8) % #authoredMap1Layer2Animation1) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation2[((frame // 8) % #authoredMap1Layer2Animation2) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation3[((frame // 8) % #authoredMap1Layer2Animation3) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation4[((frame // 8) % #authoredMap1Layer2Animation4) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation5[((frame // 8) % #authoredMap1Layer2Animation5) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation6[((frame // 8) % #authoredMap1Layer2Animation6) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation7[((frame // 8) % #authoredMap1Layer2Animation7) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation8[((frame // 8) % #authoredMap1Layer2Animation8) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation9[((frame // 8) % #authoredMap1Layer2Animation9) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation10[((frame // 8) % #authoredMap1Layer2Animation10) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation11[((frame // 8) % #authoredMap1Layer2Animation11) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation12[((frame // 8) % #authoredMap1Layer2Animation12) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation13[((frame // 8) % #authoredMap1Layer2Animation13) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation14[((frame // 8) % #authoredMap1Layer2Animation14) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation15[((frame // 8) % #authoredMap1Layer2Animation15) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation16[((frame // 8) % #authoredMap1Layer2Animation16) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation17[((frame // 8) % #authoredMap1Layer2Animation17) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation18[((frame // 8) % #authoredMap1Layer2Animation18) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation19[((frame // 8) % #authoredMap1Layer2Animation19) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation20[((frame // 8) % #authoredMap1Layer2Animation20) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation21[((frame // 8) % #authoredMap1Layer2Animation21) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation22[((frame // 8) % #authoredMap1Layer2Animation22) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation23[((frame // 8) % #authoredMap1Layer2Animation23) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation24[((frame // 8) % #authoredMap1Layer2Animation24) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation25[((frame // 8) % #authoredMap1Layer2Animation25) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation26[((frame // 8) % #authoredMap1Layer2Animation26) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation27[((frame // 8) % #authoredMap1Layer2Animation27) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation28[((frame // 8) % #authoredMap1Layer2Animation28) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation29[((frame // 8) % #authoredMap1Layer2Animation29) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation30[((frame // 8) % #authoredMap1Layer2Animation30) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation31[((frame // 8) % #authoredMap1Layer2Animation31) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation32[((frame // 8) % #authoredMap1Layer2Animation32) + 1]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation33[((frame // 8) % #authoredMap1Layer2Animation33) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation34[((frame // 8) % #authoredMap1Layer1Animation34) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation35[((frame // 8) % #authoredMap1Layer1Animation35) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation36[((frame // 8) % #authoredMap1Layer1Animation36) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation37[((frame // 8) % #authoredMap1Layer1Animation37) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation38[((frame // 8) % #authoredMap1Layer1Animation38) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation39[((frame // 8) % #authoredMap1Layer1Animation39) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation40[((frame // 8) % #authoredMap1Layer1Animation40) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation41[((frame // 8) % #authoredMap1Layer1Animation41) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation42[((frame // 8) % #authoredMap1Layer1Animation42) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation43[((frame // 8) % #authoredMap1Layer1Animation43) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation44[((frame // 8) % #authoredMap1Layer1Animation44) + 1]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation45[((frame // 8) % #authoredMap1Layer1Animation45) + 1]
end
local ProjectMaps = {
  ["map-1"] = { name = "Mapa 1", width = 60, height = 17, tile_size = 16, layers = { authoredMap1Layer1, authoredMap1Layer2, authoredMap1Layer3, authoredMap1Layer4 }, update = authoredMap1Update },
}
local ActiveMapId = "map-1"
local ActiveMap = ProjectMaps[ActiveMapId]

local function bounds(object)
    if object.kind == "line" then
        return math.min(object.x1, object.x2) - 2, math.min(object.y1, object.y2) - 2, math.max(object.x1, object.x2) + 2, math.max(object.y1, object.y2) + 2
    end
    local width = object.kind == "circle" and object.radius * 2 or object.width
    local height = object.kind == "circle" and object.radius * 2 or object.height
    return object.x, object.y, object.x + width, object.y + height
end

local function overlaps(a, b)
    local ax1, ay1, ax2, ay2 = bounds(a)
    local bx1, by1, bx2, by2 = bounds(b)
    return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end

local function overlap_area(a, b)
    local ax1, ay1, ax2, ay2 = bounds(a)
    local bx1, by1, bx2, by2 = bounds(b)
    local width = math.min(ax2, bx2) - math.max(ax1, bx1)
    local height = math.min(ay2, by2) - math.max(ay1, by1)
    if width <= 0 or height <= 0 then return 0 end
    return width * height
end

local function crossed_surface(moving, previous, surface, axis, amount)
    if not surface.surface or axis ~= "y" or amount <= 0 then return false end
    local previousLeft, previousTop, previousRight, previousBottom = bounds(previous)
    local currentLeft, currentTop, currentRight, currentBottom = bounds(moving)
    return previousBottom <= surface.y and currentBottom > surface.y and currentLeft < surface.x + surface.width and currentRight > surface.x
end

local function object_y(index)
    local object = objects[index]
    return object.kind == "line" and object.y1 or object.y
end

local function object_axis_position(index, axis)
    local object = objects[index]
    if object.kind == "line" then return axis == "x" and object.x1 or object.y1 end
    return object[axis]
end

local function group_axis_position(groupIndex, axis)
    local group = groups[groupIndex]
    local minimum = axis == "x" and WORLD_WIDTH or WORLD_HEIGHT
    for _, index in ipairs(group.members) do
        local object = objects[index]
        local position
        if object.kind == "line" then
            position = axis == "x" and math.min(object.x1, object.x2) or math.min(object.y1, object.y2)
        else
            position = object[axis]
        end
        minimum = math.min(minimum, position)
    end
    return minimum
end

local function group_y(groupIndex)
    local group = groups[groupIndex]
    local minY = WORLD_HEIGHT
    for _, index in ipairs(group.members) do
        local _, y1 = bounds(objects[index])
        minY = math.min(minY, y1)
    end
    return minY
end

local function move_group(groupIndex, dx, dy, collisionOverride)
    local group = groups[groupIndex]
    local function shift(axis, amount)
        if amount == 0 then return end
        local previous = {}
        local minX, minY, maxX, maxY = WORLD_WIDTH, WORLD_HEIGHT, 0, 0
        for _, index in ipairs(group.members) do
            local object = objects[index]
            previous[index] = {x = object.x, y = object.y, x1 = object.x1, y1 = object.y1, x2 = object.x2, y2 = object.y2}
            if object.kind == "line" then
                if axis == "x" then object.x1 = object.x1 + amount; object.x2 = object.x2 + amount
                else object.y1 = object.y1 + amount; object.y2 = object.y2 + amount end
            else object[axis] = object[axis] + amount end
            local x1, y1, x2, y2 = bounds(object)
            minX, minY, maxX, maxY = math.min(minX, x1), math.min(minY, y1), math.max(maxX, x2), math.max(maxY, y2)
        end
        local correction = axis == "x" and (minX < 0 and -minX or (maxX > WORLD_WIDTH and WORLD_WIDTH - maxX or 0)) or (minY < 0 and -minY or (maxY > WORLD_HEIGHT and WORLD_HEIGHT - maxY or 0))
        if correction ~= 0 then
            for _, index in ipairs(group.members) do
                local object = objects[index]
                if object.kind == "line" then
                    if axis == "x" then object.x1 = object.x1 + correction; object.x2 = object.x2 + correction
                    else object.y1 = object.y1 + correction; object.y2 = object.y2 + correction end
                else object[axis] = object[axis] + correction end
            end
        end
        local blocked = false
        for _, index in ipairs(group.members) do
            local object = objects[index]
            if collisionOverride == true or (collisionOverride ~= false and object.collision) then
                for otherIndex, other in ipairs(objects) do
                    local isMember = false
                    for _, memberIndex in ipairs(group.members) do if memberIndex == otherIndex then isMember = true; break end end
                    if not isMember and other.collision then
                        local oldObject = {kind = object.kind, width = object.width, height = object.height, radius = object.radius}
                        for key, value in pairs(previous[index]) do if value ~= nil then oldObject[key] = value end end
                        if crossed_surface(object, oldObject, other, axis, amount) or (not other.surface and overlap_area(object, other) > overlap_area(oldObject, other)) then blocked = true; break end
                    end
                end
            end
            if blocked then break end
        end
        if blocked then
            for _, index in ipairs(group.members) do
                local object, old = objects[index], previous[index]
                for key, value in pairs(old) do if value ~= nil then object[key] = value end end
            end
        end
    end
    shift("x", dx)
    shift("y", dy)
end

local function move_object(index, dx, dy, collisionOverride)
    local object = objects[index]
    local function shift(axis, amount)
        if amount == 0 then return end
        local old = {x = object.x, y = object.y, x1 = object.x1, y1 = object.y1, x2 = object.x2, y2 = object.y2}
        if object.kind == "line" then
            object.x1 = object.x1 + (axis == "x" and amount or 0)
            object.x2 = object.x2 + (axis == "x" and amount or 0)
            object.y1 = object.y1 + (axis == "y" and amount or 0)
            object.y2 = object.y2 + (axis == "y" and amount or 0)
        else
            object[axis] = object[axis] + amount
        end
        local x1, y1, x2, y2 = bounds(object)
        local minX, minY = 0, 0
        local maxX, maxY = WORLD_WIDTH, WORLD_HEIGHT
        local correctionX = x1 < minX and minX - x1 or (x2 > maxX and maxX - x2 or 0)
        local correctionY = y1 < minY and minY - y1 or (y2 > maxY and maxY - y2 or 0)
        if axis == "x" and correctionX ~= 0 then
            if object.kind == "line" then object.x1 = object.x1 + correctionX; object.x2 = object.x2 + correctionX else object.x = object.x + correctionX end
        elseif axis == "y" and correctionY ~= 0 then
            if object.kind == "line" then object.y1 = object.y1 + correctionY; object.y2 = object.y2 + correctionY else object.y = object.y + correctionY end
        end
        if collisionOverride == true or (collisionOverride ~= false and object.collision) then
            for otherIndex, other in ipairs(objects) do
                if otherIndex ~= index and other.collision then
                    local oldObject = {kind = object.kind, width = object.width, height = object.height, radius = object.radius}
                    for key, value in pairs(old) do if value ~= nil then oldObject[key] = value end end
                    if crossed_surface(object, oldObject, other, axis, amount) or (not other.surface and overlap_area(object, other) > overlap_area(oldObject, other)) then
                    if object.kind == "line" then
                        object.x1 = old.x1; object.x2 = old.x2
                        object.y1 = old.y1; object.y2 = old.y2
                    else object[axis] = old[axis] end
                    return
                    end
                end
            end
        end
    end
    shift("x", dx)
    shift("y", dy)
end

local function startPlayerAttack()
    PlayerAttack.active = true
    PlayerAttack.remaining = 64
    PlayerAttack.frame = 0
    PlayerAttack.direction = PlayerFacingLeft and -1 or 1
    PlayerAttack.hitTargets = {}
    for targetIndex, target in ipairs(objects) do
        if targetIndex ~= 12 then target.hitByPlayer = false end
    end
end

local function updatePlayerAttack()
    if not PlayerAttack.active then PlayerAttack.hitbox = nil; return end
    if PlayerAttack.remaining <= 0 then PlayerAttack.active = false; PlayerAttack.hitbox = nil; return end
    PlayerAttack.frame = PlayerAttack.frame + 1
    local playerX1, playerY1, playerX2, playerY2 = bounds(objects[12])
    local reach = math.max(8, playerX2 - playerX1)
    local attackHeight = math.max(8, playerY2 - playerY1)
    local attackX = PlayerAttack.direction < 0 and (playerX1 - reach) or playerX2
    local hitbox = { kind = "rect", x = attackX, y = playerY1, width = reach, height = attackHeight }
    PlayerAttack.hitbox = hitbox
    PlayerAttack.x = attackX
    PlayerAttack.y = playerY1
    for targetIndex, target in ipairs(objects) do
        if targetIndex ~= 12 and target.collision and overlaps(hitbox, target) and not PlayerAttack.hitTargets[targetIndex] then
            PlayerAttack.hitTargets[targetIndex] = true
            target.hitByPlayer = true
        end
    end
    PlayerAttack.remaining = PlayerAttack.remaining - 1
end

function loop(frame)
    for index, color in ipairs(Palette) do
        ui.palset(index - 1, color)
    end
    for index, color in ipairs(ProjectPalette) do
        ui.palset(ASSET_PALETTE_SIZE + index - 1, color)
    end

    ui.clip(0, 0, 480, 270)
    ui.camera(0, 0)
    ui.cls(ASSET_PALETTE_SIZE + 0)
    if objects[4].auto then
        local currentAuto4 = object_axis_position(4, objects[4].auto_axis)
        local targetAuto4 = objects[4].auto_direction > 0 and (objects[4].auto_origin + objects[4].auto_distance) or objects[4].auto_origin
        local distanceAuto4 = targetAuto4 - currentAuto4
        local step4 = math.min(math.abs(distanceAuto4), objects[4].auto_speed) * objects[4].auto_direction
        if step4 ~= 0 then
            local remainingAuto4 = step4
            local blockedAuto4 = false
            while math.abs(remainingAuto4) > 0.001 do
                local stepSub4 = remainingAuto4 > 0 and math.min(1, remainingAuto4) or math.max(-1, remainingAuto4)
                local beforeAuto4 = object_axis_position(4, objects[4].auto_axis)
                move_object(4, stepSub4, 0, objects[4].auto_collide)
                local afterAuto4 = object_axis_position(4, objects[4].auto_axis)
                if afterAuto4 == beforeAuto4 then blockedAuto4 = true; break end
                remainingAuto4 = remainingAuto4 - stepSub4
            end
            if math.abs(distanceAuto4) <= objects[4].auto_speed or blockedAuto4 then objects[4].auto_direction = -objects[4].auto_direction end
        else
            objects[4].auto_direction = -objects[4].auto_direction
        end
    end
    if objects[7].auto then
        local currentAuto7 = object_axis_position(7, objects[7].auto_axis)
        local targetAuto7 = objects[7].auto_direction > 0 and (objects[7].auto_origin + objects[7].auto_distance) or objects[7].auto_origin
        local distanceAuto7 = targetAuto7 - currentAuto7
        local step7 = math.min(math.abs(distanceAuto7), objects[7].auto_speed) * objects[7].auto_direction
        if step7 ~= 0 then
            local remainingAuto7 = step7
            local blockedAuto7 = false
            while math.abs(remainingAuto7) > 0.001 do
                local stepSub7 = remainingAuto7 > 0 and math.min(1, remainingAuto7) or math.max(-1, remainingAuto7)
                local beforeAuto7 = object_axis_position(7, objects[7].auto_axis)
                move_object(7, 0, stepSub7, objects[7].auto_collide)
                local afterAuto7 = object_axis_position(7, objects[7].auto_axis)
                if afterAuto7 == beforeAuto7 then blockedAuto7 = true; break end
                remainingAuto7 = remainingAuto7 - stepSub7
            end
            if math.abs(distanceAuto7) <= objects[7].auto_speed or blockedAuto7 then objects[7].auto_direction = -objects[7].auto_direction end
        else
            objects[7].auto_direction = -objects[7].auto_direction
        end
    end
    if objects[8].auto then
        local currentAuto8 = object_axis_position(8, objects[8].auto_axis)
        local targetAuto8 = objects[8].auto_direction > 0 and (objects[8].auto_origin + objects[8].auto_distance) or objects[8].auto_origin
        local distanceAuto8 = targetAuto8 - currentAuto8
        local step8 = math.min(math.abs(distanceAuto8), objects[8].auto_speed) * objects[8].auto_direction
        if step8 ~= 0 then
            local remainingAuto8 = step8
            local blockedAuto8 = false
            while math.abs(remainingAuto8) > 0.001 do
                local stepSub8 = remainingAuto8 > 0 and math.min(1, remainingAuto8) or math.max(-1, remainingAuto8)
                local beforeAuto8 = object_axis_position(8, objects[8].auto_axis)
                move_object(8, stepSub8, 0, objects[8].auto_collide)
                local afterAuto8 = object_axis_position(8, objects[8].auto_axis)
                if afterAuto8 == beforeAuto8 then blockedAuto8 = true; break end
                remainingAuto8 = remainingAuto8 - stepSub8
            end
            if math.abs(distanceAuto8) <= objects[8].auto_speed or blockedAuto8 then objects[8].auto_direction = -objects[8].auto_direction end
        else
            objects[8].auto_direction = -objects[8].auto_direction
        end
    end
    PlayerActions.moveLeft = ui.btn(LEFT)
    PlayerActions.moveRight = ui.btn(RIGHT)
    PlayerActions.jump = ui.btnp(BTN_Z)
    PlayerActions.attack = ui.btnp(BTN_X)
    if PlayerActions.moveLeft then PlayerFacingLeft = true elseif PlayerActions.moveRight then PlayerFacingLeft = false end
    local playerDx = 0
    if PlayerActions.moveLeft then playerDx = playerDx - objects[12].speed end
    if PlayerActions.moveRight then playerDx = playerDx + objects[12].speed end
    move_object(12, playerDx, 0)
    objects[12].vy = math.min(objects[12].vy + objects[12].gravity_force, 12)
    local playerRemainingY = objects[12].vy
    local playerGrounded = false
    while math.abs(playerRemainingY) > 0.001 do
        local playerStepY = playerRemainingY > 0 and math.min(1, playerRemainingY) or math.max(-1, playerRemainingY)
        local playerBeforeY = object_y(12)
        move_object(12, 0, playerStepY)
        if object_y(12) == playerBeforeY then
            playerGrounded = playerRemainingY > 0
            objects[12].vy = 0
            break
        end
        playerRemainingY = playerRemainingY - playerStepY
    end
    if PlayerActions.jump and playerGrounded then objects[12].vy = -objects[12].jump_force end
    if PlayerActions.attack then startPlayerAttack() end
    updatePlayerAttack()
    PlayerActionDraw = nil
    PlayerAttackDraw = nil
    if objects[12].vy < 0 then
        PlayerActionDraw = nil
    elseif PlayerActions.moveLeft then
        PlayerActionDraw = function(x, y) ui.tile(resolveSpriteAsset("assets/prepared/krun.png"), ({ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 })[((frame // 8) % 16) + 1], x, y, PlayerFacingLeft, false) end
    elseif PlayerActions.moveRight then
        PlayerActionDraw = function(x, y) ui.tile(resolveSpriteAsset("assets/prepared/krun.png"), ({ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 })[((frame // 8) % 16) + 1], x, y, PlayerFacingLeft, false) end
    end
    if PlayerAttack.active then PlayerAttackDraw = function(x, y) ui.tile(resolveSpriteAsset("assets/prepared/swatk.png"), ({ 0, 1, 2, 3, 4, 5, 6, 7 })[math.min(((PlayerAttack.frame - 1) // 8) + 1, 8)], x, y, PlayerAttack.direction < 0, false) end end

    local targetLeft, targetTop, targetRight, targetBottom = bounds(objects[12])
    local targetCenterX = (targetLeft + targetRight) / 2
    local targetCenterY = (targetTop + targetBottom) / 2
    local directionX = cameraPreviousX and targetCenterX - cameraPreviousX or 0
    local directionY = cameraPreviousY and targetCenterY - cameraPreviousY or 0
    cameraPreviousX, cameraPreviousY = targetCenterX, targetCenterY
    local margin = 16
    if cameraLockX == 1 then
        if targetCenterX > cameraX + margin or directionX < 0 then cameraLockX = 0 end
    elseif cameraLockX == -1 then
        if targetCenterX < cameraX + 480 - margin or directionX > 0 then cameraLockX = 0 end
    end
    if cameraLockY == 1 then
        if targetCenterY > cameraY + margin or directionY < 0 then cameraLockY = 0 end
    elseif cameraLockY == -1 then
        if targetCenterY < cameraY + 270 - margin or directionY > 0 then cameraLockY = 0 end
    end
    if cameraLockX == 0 then
        if targetCenterX < cameraX + margin and cameraX > 0 then cameraX = math.max(0, cameraX - 480); cameraLockX = -1
        elseif targetCenterX > cameraX + 480 - margin and cameraX < WORLD_WIDTH - 480 then cameraX = math.min(WORLD_WIDTH - 480, cameraX + 480); cameraLockX = 1 end
    end
    if cameraLockY == 0 then
        if targetCenterY < cameraY + margin and cameraY > 0 then cameraY = math.max(0, cameraY - 270); cameraLockY = -1
        elseif targetCenterY > cameraY + 270 - margin and cameraY < WORLD_HEIGHT - 270 then cameraY = math.min(WORLD_HEIGHT - 270, cameraY + 270); cameraLockY = 1 end
    end
    ui.camera(cameraX, cameraY)
    if ActiveMap then ActiveMap.update(frame) end

    ui.map(authoredMap1Layer1)
    if not objects[1].invisible then ui.rectfill(objects[1].x, objects[1].y, objects[1].x + objects[1].width, objects[1].y + objects[1].height, objects[1].color) end
    if not objects[3].invisible then ui.rectfill(objects[3].x, objects[3].y, objects[3].x + objects[3].width, objects[3].y + objects[3].height, objects[3].color) end
    if not objects[4].invisible then ui.trisfill(objects[4].x + objects[4].width / 2, objects[4].y, objects[4].x + objects[4].width, objects[4].y + objects[4].height, objects[4].x, objects[4].y + objects[4].height, objects[4].color) end
    if not objects[5].invisible then ui.rectfill(objects[5].x, objects[5].y, objects[5].x + objects[5].width, objects[5].y + objects[5].height, objects[5].color) end
    if not objects[6].invisible then ui.rectfill(objects[6].x, objects[6].y, objects[6].x + objects[6].width, objects[6].y + objects[6].height, objects[6].color) end
    if not objects[8].invisible then ui.circfill(objects[8].x + objects[8].radius, objects[8].y + objects[8].radius, objects[8].radius, objects[8].color) end
    if not objects[10].invisible then ui.rectfill(objects[10].x, objects[10].y, objects[10].x + objects[10].width, objects[10].y + objects[10].height, objects[10].color) end
    ui.map(authoredMap1Layer2)
    if not objects[7].invisible then ui.circfill(objects[7].x + objects[7].radius, objects[7].y + objects[7].radius, objects[7].radius, objects[7].color) end
    if not objects[9].invisible then ui.circfill(objects[9].x + objects[9].radius, objects[9].y + objects[9].radius, objects[9].radius, objects[9].color) end
    ui.spr(resolveSpriteAsset("assets/created/grassblock.png"), 318, 137, false, false)
    ui.map(authoredMap1Layer3)
    ui.map(authoredMap1Layer4)
    if PlayerActionDraw then PlayerActionDraw(objects[12].x, objects[12].y) else ui.tile(resolveSpriteAsset("assets/prepared/kidle.png"), ({ 0, 1, 2, 3 })[((frame // 8) % 4) + 1], objects[12].x, objects[12].y, PlayerFacingLeft, false) end
    if PlayerAttack.active and PlayerAttackDraw and PlayerAttack.hitbox then PlayerAttackDraw(PlayerAttack.x, PlayerAttack.y) end
end
