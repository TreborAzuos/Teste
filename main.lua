-- Gerado pelo Editor Visual Lupi. Edite o projeto visual para alterar objetos.
-- Projeto: teste
require "palette"
require "sprites"

local WORLD_WIDTH, WORLD_HEIGHT = 480, 270
local StartingLives = 3
local PlayerScore = 0
local PlayerLives = StartingLives
local PlayerMessage = ""
local MessageScreens = {}
local CurrentMessageScreen = nil
local function showPlayerMessage(screenId, frame)
    local screen = MessageScreens[screenId]
    if screen then PlayerMessage = screenId; CurrentMessageScreen = screen end
end
local GameFrame = 0
local PlayerPortalTarget = nil
local PlayerKeys = {}
local PlayerCheckpoint = nil
local PlayerDamageCooldown = 0
local PlayerPortalCooldown = 0
local RestartAfterDeath = false
local StartMessageShown = false
local PlayerActions = {}
local PlayerActionDraw = nil
local PlayerAttackDraw = nil
local PlayerFacingLeft = false
local PlayerFacingAngle = 0
local PlayerAttack = { active = false, remaining = 0, frame = 0, direction = 1, directionX = 1, directionY = 0, angle = 0, hitbox = nil, hitTargets = {}, x = 0, y = 0, traveled = 0, width = 8, height = 8 }
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

MessageScreens = {
  ["95ba878d-55db-4270-95e1-be37413b9fc3"] = { text = "Bem vindo!", background_enabled = false, background_color = ASSET_PALETTE_SIZE + 0, frame_enabled = true, frame_x = 48, frame_y = 54, frame_width = 384, frame_height = 144, frame_color = ASSET_PALETTE_SIZE + 1, border_color = ASSET_PALETTE_SIZE + 9, border_thickness = 7, border_sprite = nil, border_sprite_type = "sprite", border_sprite_width = 16, border_sprite_height = 16, text_x = 240, text_y = 86, text_align = "center", line_height = 18, prompt_enabled = true, prompt_x = 190, prompt_y = 230, text_color = ASSET_PALETTE_SIZE + 7 },
  ["8f498d8a-e368-42a2-882f-a60663ae8436"] = { text = "Você Morreu!", background_enabled = false, background_color = ASSET_PALETTE_SIZE + 0, frame_enabled = true, frame_x = 48, frame_y = 54, frame_width = 384, frame_height = 144, frame_color = ASSET_PALETTE_SIZE + 0, border_color = ASSET_PALETTE_SIZE + 7, border_thickness = 2, border_sprite = nil, border_sprite_type = "sprite", border_sprite_width = 16, border_sprite_height = 16, text_x = 240, text_y = 86, text_align = "center", line_height = 18, prompt_enabled = true, prompt_x = 190, prompt_y = 230, text_color = ASSET_PALETTE_SIZE + 7 },
}
local objects = {
    { name = "Retângulo 1", kind = "rect", color = ASSET_PALETTE_SIZE + 2, map_id = "map-1", x = 8, y = 0, width = 473, height = 270, collision = false, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 8, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Linha 1", kind = "line", color = ASSET_PALETTE_SIZE + 1, map_id = "map-1", x1 = 1, y1 = 206, x2 = 479, y2 = 206, collision = true, trigger = false, invisible = true, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 1, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 2", kind = "rect", color = ASSET_PALETTE_SIZE + 5, map_id = "map-1", x = 0, y = 206, width = 480, height = 63, collision = false, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 0, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Triângulo 1", kind = "triangle", color = ASSET_PALETTE_SIZE + 4, map_id = "map-1", x = 190, y = 16, width = 56, height = 36, collision = false, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = true, auto_axis = "x", auto_origin = 190, auto_distance = 64, auto_speed = 3, auto_collide = false, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 4", kind = "rect", color = ASSET_PALETTE_SIZE + 7, map_id = "map-1", x = 201, y = 148, width = 111, height = 18, collision = true, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 201, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 5", kind = "rect", color = ASSET_PALETTE_SIZE + 1, map_id = "map-1", x = 483, y = 205, width = 475, height = 64, collision = true, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 483, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Círculo 2", kind = "circle", color = ASSET_PALETTE_SIZE + 8, map_id = "map-1", x = 551, y = 56, radius = 18, collision = true, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = true, auto_axis = "y", auto_origin = 56, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Círculo 3", kind = "circle", color = ASSET_PALETTE_SIZE + 9, map_id = "map-1", x = 779, y = 105, radius = 18, collision = true, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = true, auto_axis = "x", auto_origin = 779, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Círculo 4", kind = "circle", color = ASSET_PALETTE_SIZE + 1, map_id = "map-1", x = 344, y = 21, radius = 18, collision = false, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 344, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 6", kind = "rect", color = ASSET_PALETTE_SIZE + 10, map_id = "map-1", x = 372, y = 21, width = 56, height = 36, collision = false, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 372, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Círculo 4", kind = "circle", color = ASSET_PALETTE_SIZE + 1, map_id = "map-1", x = 317, y = 99, radius = 18, collision = true, trigger = true, invisible = false, surface = false, interaction = "portal", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "map-1", target_x = 885, target_y = 176, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 317, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Círculo 5", kind = "circle", color = ASSET_PALETTE_SIZE + 1, map_id = "map-1", x = 885, y = 176, radius = 18, collision = false, trigger = false, invisible = false, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 885, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Retângulo 6", kind = "rect", color = ASSET_PALETTE_SIZE + 1, map_id = "map-1", x = 739, y = 168, width = 23, height = 36, collision = true, trigger = true, invisible = true, surface = false, interaction = "portal", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "b57387a1-e895-463d-a55e-3aa4970caa8c", target_x = 20, target_y = 200, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 739, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor sprite 020e6098-3e2b-4b28-9c35-f5753131e596", kind = "rect", color = ASSET_PALETTE_SIZE + 0, map_id = "map-1", x = 318, y = 137, width = 32, height = 32, collision = true, trigger = false, invisible = true, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 318, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor sprite 78a6ea80-185b-48d6-ad1c-ea9cfe48664b", kind = "rect", color = ASSET_PALETTE_SIZE + 0, map_id = "map-1", x = 26, y = 179, width = 20, height = 21, collision = true, trigger = false, invisible = true, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = true, speed = 2, auto = false, auto_axis = "x", auto_origin = 26, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = true, gravity_force = 0.35, jump = true, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor sprite 0db5e9c5-aba4-4eb0-a5cf-7b123cf1f819", kind = "rect", color = ASSET_PALETTE_SIZE + 0, map_id = "map-1", x = 265, y = 120, width = 32, height = 32, collision = true, trigger = true, invisible = true, surface = false, interaction = "enemy", score_value = 100, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "checkpoint", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 265, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor sprite 921c4438-833a-4b0f-a0dc-29261d0e761b", kind = "rect", color = ASSET_PALETTE_SIZE + 0, map_id = "map-1", x = 91, y = 79, width = 16, height = 16, collision = true, trigger = true, invisible = true, surface = false, interaction = "collectible", score_value = 100, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = true, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 91, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor tiles 4-9,10", kind = "rect", color = ASSET_PALETTE_SIZE + 0, map_id = "map-1", x = 64, y = 160, width = 96, height = 1, collision = true, trigger = false, invisible = true, surface = true, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 64, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
    { name = "Colisor tiles 5-7,7", kind = "rect", color = ASSET_PALETTE_SIZE + 0, map_id = "map-1", x = 80, y = 112, width = 48, height = 16, collision = true, trigger = false, invisible = true, surface = false, interaction = "", score_value = 0, life_bonus = 0, life_damage = 1, health = 1, knockback = 8, enemy_response = "knockback", activation_mode = "contact", checkpoint_enabled = false, checkpoint_mode = "interaction", message_screen_id = "", key_id = "", required_key_id = "", target_map_id = "", target_x = 0, target_y = 0, active = true, defeated = false, movement = false, speed = 2, auto = false, auto_axis = "x", auto_origin = 80, auto_distance = 64, auto_speed = 1, auto_collide = true, auto_direction = 1, vy = 0, gravity = false, gravity_force = 0.35, jump = false, jump_force = 6, jump_button = BTN_Z },
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
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation1[((math.floor(frame / 8) % #authoredMap1Layer2Animation1) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation2[((math.floor(frame / 8) % #authoredMap1Layer2Animation2) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation3[((math.floor(frame / 8) % #authoredMap1Layer2Animation3) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation4[((math.floor(frame / 8) % #authoredMap1Layer2Animation4) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation5[((math.floor(frame / 8) % #authoredMap1Layer2Animation5) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation6[((math.floor(frame / 8) % #authoredMap1Layer2Animation6) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation7[((math.floor(frame / 8) % #authoredMap1Layer2Animation7) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation8[((math.floor(frame / 8) % #authoredMap1Layer2Animation8) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation9[((math.floor(frame / 8) % #authoredMap1Layer2Animation9) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation10[((math.floor(frame / 8) % #authoredMap1Layer2Animation10) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation11[((math.floor(frame / 8) % #authoredMap1Layer2Animation11) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation12[((math.floor(frame / 8) % #authoredMap1Layer2Animation12) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation13[((math.floor(frame / 8) % #authoredMap1Layer2Animation13) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation14[((math.floor(frame / 8) % #authoredMap1Layer2Animation14) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation15[((math.floor(frame / 8) % #authoredMap1Layer2Animation15) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation16[((math.floor(frame / 8) % #authoredMap1Layer2Animation16) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation17[((math.floor(frame / 8) % #authoredMap1Layer2Animation17) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation18[((math.floor(frame / 8) % #authoredMap1Layer2Animation18) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation19[((math.floor(frame / 8) % #authoredMap1Layer2Animation19) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation20[((math.floor(frame / 8) % #authoredMap1Layer2Animation20) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation21[((math.floor(frame / 8) % #authoredMap1Layer2Animation21) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation22[((math.floor(frame / 8) % #authoredMap1Layer2Animation22) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation23[((math.floor(frame / 8) % #authoredMap1Layer2Animation23) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation24[((math.floor(frame / 8) % #authoredMap1Layer2Animation24) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation25[((math.floor(frame / 8) % #authoredMap1Layer2Animation25) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation26[((math.floor(frame / 8) % #authoredMap1Layer2Animation26) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation27[((math.floor(frame / 8) % #authoredMap1Layer2Animation27) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation28[((math.floor(frame / 8) % #authoredMap1Layer2Animation28) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation29[((math.floor(frame / 8) % #authoredMap1Layer2Animation29) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation30[((math.floor(frame / 8) % #authoredMap1Layer2Animation30) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation31[((math.floor(frame / 8) % #authoredMap1Layer2Animation31) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation32[((math.floor(frame / 8) % #authoredMap1Layer2Animation32) + 1)]
        authoredMap1Layer2.tilesets["tilemap.sunny.1"] = authoredMap1Layer2Animation33[((math.floor(frame / 8) % #authoredMap1Layer2Animation33) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation34[((math.floor(frame / 8) % #authoredMap1Layer1Animation34) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation35[((math.floor(frame / 8) % #authoredMap1Layer1Animation35) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation36[((math.floor(frame / 8) % #authoredMap1Layer1Animation36) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation37[((math.floor(frame / 8) % #authoredMap1Layer1Animation37) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation38[((math.floor(frame / 8) % #authoredMap1Layer1Animation38) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation39[((math.floor(frame / 8) % #authoredMap1Layer1Animation39) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation40[((math.floor(frame / 8) % #authoredMap1Layer1Animation40) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation41[((math.floor(frame / 8) % #authoredMap1Layer1Animation41) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation42[((math.floor(frame / 8) % #authoredMap1Layer1Animation42) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation43[((math.floor(frame / 8) % #authoredMap1Layer1Animation43) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation44[((math.floor(frame / 8) % #authoredMap1Layer1Animation44) + 1)]
        authoredMap1Layer1.tilesets["tilemap.sunny.1"] = authoredMap1Layer1Animation45[((math.floor(frame / 8) % #authoredMap1Layer1Animation45) + 1)]
end
local authoredMap2Layer3 = {
  metadata = { width = 30, height = 17, tile_size = 16 },
  tilesets = {
    ["wtt"] = "wtt",
  },
  ["wtt"] = {
      [421] = 0,
      [422] = 0,
      [423] = 0,
      [424] = 0,
      [425] = 0,
      [426] = 0,
      [427] = 2,
      [428] = 2,
      [429] = 2,
      [430] = 2,
      [431] = 2,
      [432] = 2,
      [433] = 2,
      [434] = 4,
      [435] = 4,
      [436] = 4,
      [437] = 4,
      [438] = 4,
      [439] = 4,
      [440] = 4,
      [441] = 4,
      [442] = 4,
      [443] = 4,
      [444] = 6,
      [445] = 6,
      [446] = 6,
      [447] = 6,
      [448] = 6,
      [449] = 6,
      [450] = 6,
  },
}
local authoredMap2Layer1 = {
  metadata = { width = 30, height = 17, tile_size = 16 },
  tilesets = {
    ["wtt"] = "wtt",
    ["tilemap.sunny.1"] = "tilemap.sunny.1",
  },
  ["wtt"] = {
      [451] = 5,
      [452] = 5,
      [453] = 5,
      [454] = 5,
      [455] = 5,
      [456] = 5,
      [457] = 5,
      [458] = 5,
      [459] = 5,
      [460] = 5,
      [461] = 5,
      [462] = 5,
      [463] = 5,
      [464] = 5,
      [465] = 5,
      [466] = 5,
      [496] = 5,
      [497] = 5,
      [467] = 5,
      [468] = 5,
      [469] = 5,
      [470] = 5,
      [471] = 5,
      [472] = 5,
      [473] = 5,
      [474] = 5,
      [475] = 5,
      [476] = 5,
      [477] = 5,
      [478] = 5,
      [479] = 5,
      [480] = 5,
      [510] = 5,
      [509] = 5,
      [508] = 5,
      [507] = 5,
      [506] = 5,
      [505] = 5,
      [504] = 5,
      [503] = 5,
      [502] = 5,
      [501] = 5,
      [500] = 5,
      [499] = 5,
      [498] = 5,
      [495] = 5,
      [494] = 5,
      [493] = 5,
      [492] = 5,
      [491] = 5,
      [490] = 5,
      [489] = 5,
      [488] = 5,
      [487] = 5,
      [486] = 5,
      [485] = 5,
      [484] = 5,
      [483] = 5,
      [482] = 5,
      [481] = 5,
  },
  ["tilemap.sunny.1"] = {
      [181] = 48,
      [182] = 48,
      [183] = 48,
      [184] = 48,
      [185] = 48,
      [186] = 48,
      [187] = 48,
      [188] = 48,
      [189] = 48,
      [190] = 48,
      [191] = 48,
      [192] = 48,
      [193] = 48,
      [194] = 48,
      [195] = 48,
      [196] = 48,
      [197] = 48,
      [198] = 48,
      [199] = 48,
      [200] = 48,
      [201] = 48,
      [202] = 48,
      [203] = 48,
      [204] = 48,
      [205] = 48,
      [206] = 48,
      [207] = 48,
      [208] = 48,
      [209] = 48,
      [210] = 48,
      [231] = 30,
      [261] = 30,
      [291] = 30,
      [321] = 30,
      [351] = 30,
      [381] = 30,
      [411] = 30,
      [232] = 30,
      [262] = 30,
      [292] = 30,
      [322] = 30,
      [352] = 30,
      [382] = 30,
      [412] = 30,
  },
}
local authoredMap2Layer1Animation1 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation2 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation3 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation4 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation5 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation6 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation7 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation8 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation9 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation10 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation11 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation12 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation13 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation14 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation15 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation16 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation17 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation18 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation19 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation20 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation21 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation22 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation23 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation24 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation25 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation26 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation27 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation28 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation29 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation30 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation31 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation32 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation33 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation34 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation35 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation36 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation37 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation38 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation39 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation40 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation41 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation42 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation43 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local authoredMap2Layer1Animation44 = { "tilemap.sunny.1", "tilemap.sunny.2", "tilemap.sunny.3", "tilemap.sunny.4" }
local function authoredMap2Update(frame)
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation1[((math.floor(frame / 8) % #authoredMap2Layer1Animation1) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation2[((math.floor(frame / 8) % #authoredMap2Layer1Animation2) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation3[((math.floor(frame / 8) % #authoredMap2Layer1Animation3) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation4[((math.floor(frame / 8) % #authoredMap2Layer1Animation4) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation5[((math.floor(frame / 8) % #authoredMap2Layer1Animation5) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation6[((math.floor(frame / 8) % #authoredMap2Layer1Animation6) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation7[((math.floor(frame / 8) % #authoredMap2Layer1Animation7) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation8[((math.floor(frame / 8) % #authoredMap2Layer1Animation8) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation9[((math.floor(frame / 8) % #authoredMap2Layer1Animation9) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation10[((math.floor(frame / 8) % #authoredMap2Layer1Animation10) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation11[((math.floor(frame / 8) % #authoredMap2Layer1Animation11) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation12[((math.floor(frame / 8) % #authoredMap2Layer1Animation12) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation13[((math.floor(frame / 8) % #authoredMap2Layer1Animation13) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation14[((math.floor(frame / 8) % #authoredMap2Layer1Animation14) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation15[((math.floor(frame / 8) % #authoredMap2Layer1Animation15) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation16[((math.floor(frame / 8) % #authoredMap2Layer1Animation16) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation17[((math.floor(frame / 8) % #authoredMap2Layer1Animation17) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation18[((math.floor(frame / 8) % #authoredMap2Layer1Animation18) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation19[((math.floor(frame / 8) % #authoredMap2Layer1Animation19) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation20[((math.floor(frame / 8) % #authoredMap2Layer1Animation20) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation21[((math.floor(frame / 8) % #authoredMap2Layer1Animation21) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation22[((math.floor(frame / 8) % #authoredMap2Layer1Animation22) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation23[((math.floor(frame / 8) % #authoredMap2Layer1Animation23) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation24[((math.floor(frame / 8) % #authoredMap2Layer1Animation24) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation25[((math.floor(frame / 8) % #authoredMap2Layer1Animation25) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation26[((math.floor(frame / 8) % #authoredMap2Layer1Animation26) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation27[((math.floor(frame / 8) % #authoredMap2Layer1Animation27) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation28[((math.floor(frame / 8) % #authoredMap2Layer1Animation28) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation29[((math.floor(frame / 8) % #authoredMap2Layer1Animation29) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation30[((math.floor(frame / 8) % #authoredMap2Layer1Animation30) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation31[((math.floor(frame / 8) % #authoredMap2Layer1Animation31) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation32[((math.floor(frame / 8) % #authoredMap2Layer1Animation32) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation33[((math.floor(frame / 8) % #authoredMap2Layer1Animation33) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation34[((math.floor(frame / 8) % #authoredMap2Layer1Animation34) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation35[((math.floor(frame / 8) % #authoredMap2Layer1Animation35) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation36[((math.floor(frame / 8) % #authoredMap2Layer1Animation36) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation37[((math.floor(frame / 8) % #authoredMap2Layer1Animation37) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation38[((math.floor(frame / 8) % #authoredMap2Layer1Animation38) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation39[((math.floor(frame / 8) % #authoredMap2Layer1Animation39) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation40[((math.floor(frame / 8) % #authoredMap2Layer1Animation40) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation41[((math.floor(frame / 8) % #authoredMap2Layer1Animation41) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation42[((math.floor(frame / 8) % #authoredMap2Layer1Animation42) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation43[((math.floor(frame / 8) % #authoredMap2Layer1Animation43) + 1)]
        authoredMap2Layer1.tilesets["tilemap.sunny.1"] = authoredMap2Layer1Animation44[((math.floor(frame / 8) % #authoredMap2Layer1Animation44) + 1)]
end
local ProjectMaps = {
  ["map-1"] = { name = "Mapa 1", width = 60, height = 17, world_width = 960, world_height = 270, tile_size = 16, layers = { authoredMap1Layer1, authoredMap1Layer2, authoredMap1Layer3, authoredMap1Layer4 }, update = authoredMap1Update },
  ["b57387a1-e895-463d-a55e-3aa4970caa8c"] = { name = "Mapa 2", width = 30, height = 17, world_width = 480, world_height = 270, tile_size = 16, layers = { authoredMap2Layer1, authoredMap2Layer3 }, update = authoredMap2Update },
}
local ActiveMapId = "b57387a1-e895-463d-a55e-3aa4970caa8c"
local ActiveMap = ProjectMaps[ActiveMapId]
WORLD_WIDTH, WORLD_HEIGHT = ActiveMap.world_width, ActiveMap.world_height
local InitialMapId = ActiveMapId
local InitialObjectState = {}
for index, object in ipairs(objects) do
    InitialObjectState[index] = { x = object.x, y = object.y, map_id = object.map_id, active = object.active, collision = object.collision, health = object.health, defeated = object.defeated, auto_direction = object.auto_direction, vy = object.vy, hitByPlayer = object.hitByPlayer }
end
local InitialGroupState = {}

local function restartGame()
    PlayerScore = 0
    PlayerLives = StartingLives
    PlayerKeys = {}
    PlayerCheckpoint = nil
    PlayerDamageCooldown = 0
    PlayerPortalCooldown = 0
    PlayerPortalTarget = nil
    RestartAfterDeath = false
    PlayerMessage = ""
    CurrentMessageScreen = nil
    StartMessageShown = false
    GameFrame = 0
    PlayerFacingLeft = false
    PlayerFacingAngle = 0
    PlayerActions = {}
    PlayerActionDraw = nil
    PlayerAttackDraw = nil
    PlayerAttack = { active = false, remaining = 0, frame = 0, direction = 1, directionX = 1, directionY = 0, angle = 0, hitbox = nil, hitTargets = {}, x = 0, y = 0, traveled = 0, width = 8, height = 8 }
    for index, object in ipairs(objects) do
        local initial = InitialObjectState[index]
        object.x, object.y, object.map_id = initial.x, initial.y, initial.map_id
        object.active, object.collision = initial.active, initial.collision
        object.health, object.defeated = initial.health, initial.defeated
        object.auto_direction, object.vy = initial.auto_direction, initial.vy
        object.hitByPlayer = initial.hitByPlayer
    end
    
    ActiveMapId = InitialMapId
    ActiveMap = ProjectMaps[ActiveMapId]
    WORLD_WIDTH, WORLD_HEIGHT = ActiveMap.world_width, ActiveMap.world_height
    cameraX, cameraY = 0, 0
    cameraLockX, cameraLockY = 0, 0
    cameraPreviousX, cameraPreviousY = nil, nil
end

local spriteFrames3 = { resolveSpriteAsset("assets/animations/bird/1.png"), resolveSpriteAsset("assets/animations/bird/2.png"), resolveSpriteAsset("assets/animations/bird/3.png"), resolveSpriteAsset("assets/animations/bird/4.png") }

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
                    if not isMember and other.map_id == ActiveMapId and other.collision and not other.trigger then
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
                if otherIndex ~= index and other.map_id == ActiveMapId and other.collision and not other.trigger then
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
    PlayerAttack.remaining = 0
    PlayerAttack.frame = 0
    PlayerAttack.direction = PlayerFacingLeft and -1 or 1
    PlayerAttack.angle = PlayerFacingAngle
    PlayerAttack.hitTargets = {}
    PlayerAttack.hitbox = nil
    local playerX1, playerY1, playerX2, playerY2 = bounds(objects[15])
    PlayerAttack.width = 21
    PlayerAttack.height = 13
    PlayerAttack.directionX = math.cos(math.rad(PlayerAttack.angle))
    PlayerAttack.directionY = math.sin(math.rad(PlayerAttack.angle))
    PlayerAttack.direction = PlayerAttack.directionX < 0 and -1 or 1
    local playerCenterX, playerCenterY = (playerX1 + playerX2) / 2, (playerY1 + playerY2) / 2
    local halfWidth, halfHeight = (playerX2 - playerX1) / 2, (playerY2 - playerY1) / 2
    local edgeX = math.abs(PlayerAttack.directionX) > 0.001 and halfWidth / math.abs(PlayerAttack.directionX) or math.huge
    local edgeY = math.abs(PlayerAttack.directionY) > 0.001 and halfHeight / math.abs(PlayerAttack.directionY) or math.huge
    local spawnDistance = math.min(edgeX, edgeY) + math.max(PlayerAttack.width, PlayerAttack.height) / 2
    local projectileCenterX = playerCenterX + PlayerAttack.directionX * spawnDistance
    local projectileCenterY = playerCenterY + PlayerAttack.directionY * spawnDistance
    PlayerAttack.x = projectileCenterX - PlayerAttack.width / 2
    PlayerAttack.y = projectileCenterY - PlayerAttack.height / 2
    PlayerAttack.traveled = 0
    PlayerAttack.hitbox = { kind = "rect", x = PlayerAttack.x, y = PlayerAttack.y, width = PlayerAttack.width, height = PlayerAttack.height }
    for targetIndex, target in ipairs(objects) do
        if targetIndex ~= 15 then target.hitByPlayer = false end
    end
end


local function updatePlayerAttack()
    if not PlayerAttack.active then PlayerAttack.hitbox = nil; return end
    PlayerAttack.frame = PlayerAttack.frame + 1
    local stepLeft = math.min(4, 160 - PlayerAttack.traveled)
    while stepLeft > 0.001 and PlayerAttack.active do
        local step = math.min(1, stepLeft)
        local nextX = PlayerAttack.x + PlayerAttack.directionX * step
        local nextY = PlayerAttack.y + PlayerAttack.directionY * step
        local nextHitbox = { kind = "rect", x = nextX, y = nextY, width = PlayerAttack.width, height = PlayerAttack.height }
        local hitTarget = nil
        for targetIndex, target in ipairs(objects) do
            if targetIndex ~= 15 and target.map_id == ActiveMapId and target.collision and overlaps(nextHitbox, target) then
                hitTarget = targetIndex
                break
            end
        end
        if hitTarget then
            PlayerAttack.hitTargets[hitTarget] = true
            if objects[hitTarget].interaction == "enemy" then
                objects[hitTarget].health = objects[hitTarget].health - 1
                if objects[hitTarget].health <= 0 then
                    objects[hitTarget].defeated = true
                    objects[hitTarget].active = false
                    objects[hitTarget].collision = false
                    PlayerScore = PlayerScore + objects[hitTarget].score_value
                else objects[hitTarget].hitByPlayer = true end
            else objects[hitTarget].hitByPlayer = true end
            PlayerAttack.active = false
            PlayerAttack.hitbox = nil
            break
        end
        if nextX < 0 or nextY < 0 or nextX + PlayerAttack.width > WORLD_WIDTH or nextY + PlayerAttack.height > WORLD_HEIGHT then
            PlayerAttack.active = false
            PlayerAttack.hitbox = nil
            break
        end
        PlayerAttack.x = nextX
        PlayerAttack.y = nextY
        PlayerAttack.traveled = PlayerAttack.traveled + step
        PlayerAttack.hitbox = { kind = "rect", x = PlayerAttack.x, y = PlayerAttack.y, width = PlayerAttack.width, height = PlayerAttack.height }
        stepLeft = stepLeft - step
    end
    if PlayerAttack.active and PlayerAttack.traveled >= 160 then PlayerAttack.active = false; PlayerAttack.hitbox = nil end
end

local PlayerDeathMessage = "8f498d8a-e368-42a2-882f-a60663ae8436"
local PlayerMapStartX, PlayerMapStartY = 26, 179
local function respawnPlayer(useCheckpoint)
    local player = objects[15]
    if useCheckpoint and PlayerCheckpoint and PlayerCheckpoint.map_id == ActiveMapId then
        player.x, player.y = PlayerCheckpoint.x, PlayerCheckpoint.y
    else
        player.x, player.y = PlayerMapStartX, PlayerMapStartY
    end
    player.vy = 0
    cameraX, cameraY = 0, 0
    cameraLockX, cameraLockY = 0, 0
    cameraPreviousX, cameraPreviousY = nil, nil
end
local function damagePlayer(amount, attacker, frame)
    if PlayerDamageCooldown > 0 or PlayerLives <= 0 then return end
    local wasAlive = PlayerLives > 0
    PlayerLives = math.max(0, PlayerLives - amount)
    PlayerDamageCooldown = 30
    if attacker and attacker.interaction == "enemy" and PlayerLives > 0 then
        if attacker.enemy_response == "map-start" then
            respawnPlayer(false)
        elseif attacker.enemy_response == "checkpoint" then
            respawnPlayer(true)
        else
        local playerLeft, playerTop, playerRight, playerBottom = bounds(objects[15])
        local enemyLeft, enemyTop, enemyRight, enemyBottom = bounds(attacker)
        local playerX, playerY = (playerLeft + playerRight) / 2, (playerTop + playerBottom) / 2
        local enemyX, enemyY = (enemyLeft + enemyRight) / 2, (enemyTop + enemyBottom) / 2
        local dx = playerX - enemyX
        local dy = playerY - enemyY
        local length = math.sqrt(dx * dx + dy * dy)
        if length < 0.001 then dx = PlayerFacingLeft and 1 or -1; dy = 0; length = 1 end
        move_object(15, dx / length * attacker.knockback, dy / length * attacker.knockback)
        end
    end
    if wasAlive and PlayerLives <= 0 then PlayerAttack.active = false; RestartAfterDeath = true; showPlayerMessage(PlayerDeathMessage, frame) end
end

local function updatePlayerInteractions(frame)
    if PlayerDamageCooldown > 0 then PlayerDamageCooldown = PlayerDamageCooldown - 1 end
    if PlayerPortalCooldown > 0 then PlayerPortalCooldown = PlayerPortalCooldown - 1 end
    if PlayerLives <= 0 then return end
    local player = objects[15]
    local changedMap = false
    for targetIndex, target in ipairs(objects) do
        if targetIndex ~= 15 and target.map_id == ActiveMapId and target.active and target.collision and overlaps(player, target) then
            if target.checkpoint_enabled then
                local checkpointActivated = target.checkpoint_mode == "contact" or target.checkpoint_mode == "button" and PlayerActions.interact
                if target.checkpoint_mode == "interaction" then
                    if target.interaction == "door" or target.interaction == "portal" then
                        local keyReady = target.required_key_id == "" or PlayerKeys[target.required_key_id]
                        checkpointActivated = keyReady and (target.activation_mode == "contact" or target.activation_mode == "button" and PlayerActions.interact) and PlayerPortalCooldown <= 0
                    else checkpointActivated = true end
                end
                if checkpointActivated then PlayerCheckpoint = { map_id = ActiveMapId, x = target.x, y = target.y } end
            end
            if target.interaction == "collectible" then
                target.active = false; target.collision = false
                PlayerScore = PlayerScore + target.score_value
                PlayerLives = PlayerLives + target.life_bonus
                showPlayerMessage(target.message_screen_id, frame)
            elseif target.interaction == "key" then
                target.active = false; target.collision = false
                PlayerKeys[target.key_id] = true
                showPlayerMessage(target.message_screen_id, frame)
            elseif target.interaction == "hazard" or target.interaction == "enemy" then
                showPlayerMessage(target.message_screen_id, frame)
                damagePlayer(target.life_damage, target, frame)
            elseif target.interaction == "door" or target.interaction == "portal" then
                local hasRequiredKey = target.required_key_id == "" or PlayerKeys[target.required_key_id]
                local activated = target.activation_mode == "contact" or (target.activation_mode == "button" and PlayerActions.interact)
                if hasRequiredKey and activated and PlayerPortalCooldown <= 0 then
                    if target.target_map_id == "" or target.target_map_id == ActiveMapId then
                        player.map_id = ActiveMapId
                        player.x, player.y = target.target_x, target.target_y
                        cameraX, cameraY = 0, 0
                        cameraLockX, cameraLockY = 0, 0
                        cameraPreviousX, cameraPreviousY = nil, nil
                    elseif ProjectMaps[target.target_map_id] then
                        ActiveMapId = target.target_map_id
                        ActiveMap = ProjectMaps[ActiveMapId]
                        WORLD_WIDTH, WORLD_HEIGHT = ActiveMap.world_width, ActiveMap.world_height
                        player.map_id = ActiveMapId
                        player.x, player.y = target.target_x, target.target_y
                        changedMap = true
                        PlayerCheckpoint = nil
                        PlayerAttack.active = false
                        cameraX, cameraY = 0, 0
                        cameraLockX, cameraLockY = 0, 0
                        cameraPreviousX, cameraPreviousY = nil, nil
                    end
                    PlayerPortalCooldown = 30
                    showPlayerMessage(target.message_screen_id, frame)
                elseif activated and PlayerPortalCooldown <= 0 then
                    showPlayerMessage(target.message_screen_id, frame)
                end
            end
        end
        if changedMap then break end
    end
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
    if not StartMessageShown then StartMessageShown = true; showPlayerMessage("95ba878d-55db-4270-95e1-be37413b9fc3", frame) end
    local messageWasActive = PlayerMessage ~= ""
    if messageWasActive then
        if ui.btnp(LEFT) or ui.btnp(RIGHT) or ui.btnp(UP) or ui.btnp(DOWN) or ui.btnp(BTN_Z) or ui.btnp(BTN_X) or ui.btnp(BTN_F) or ui.btnp(BTN_G) or ui.btnp(BTN_Q) or ui.btnp(BTN_E) then
            PlayerMessage = ""; CurrentMessageScreen = nil
            if RestartAfterDeath then restartGame() end
        end
    else
        if PlayerLives <= 0 and RestartAfterDeath and (ui.btnp(LEFT) or ui.btnp(RIGHT) or ui.btnp(UP) or ui.btnp(DOWN) or ui.btnp(BTN_Z) or ui.btnp(BTN_X) or ui.btnp(BTN_F) or ui.btnp(BTN_G) or ui.btnp(BTN_Q) or ui.btnp(BTN_E)) then restartGame()
        else GameFrame = GameFrame + 1 end
    end
    frame = GameFrame
    if not messageWasActive and PlayerLives > 0 then
    if objects[4].map_id == ActiveMapId then
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
    end
    if objects[7].map_id == ActiveMapId then
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
    end
    if objects[8].map_id == ActiveMapId then
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
    end
    PlayerActions.moveLeft = PlayerLives > 0 and ui.btn(LEFT)
    PlayerActions.moveRight = PlayerLives > 0 and ui.btn(RIGHT)
    PlayerActions.jump = PlayerLives > 0 and ui.btnp(BTN_Z)
    PlayerActions.attack = PlayerLives > 0 and ui.btnp(BTN_X)
    if PlayerActions.moveLeft and PlayerActions.moveUp then PlayerFacingAngle = 225 elseif PlayerActions.moveRight and PlayerActions.moveUp then PlayerFacingAngle = 315 elseif PlayerActions.moveLeft then PlayerFacingAngle = 180 elseif PlayerActions.moveRight then PlayerFacingAngle = 0 elseif PlayerActions.moveUp then PlayerFacingAngle = 270 end
    PlayerFacingLeft = math.cos(math.rad(PlayerFacingAngle)) < -0.001
    local playerDx = 0
    if PlayerActions.moveLeft then playerDx = playerDx - objects[15].speed end
    if PlayerActions.moveRight then playerDx = playerDx + objects[15].speed end
    local playerLeft, _, _, playerRight = bounds(objects[15])
    if playerDx < 0 then playerDx = math.max(playerDx, -playerLeft)
    elseif playerDx > 0 then playerDx = math.min(playerDx, WORLD_WIDTH - playerRight) end
    move_object(15, playerDx, 0)
    objects[15].vy = math.min(objects[15].vy + objects[15].gravity_force, 12)
    local playerRemainingY = objects[15].vy
    local playerGrounded = false
    while math.abs(playerRemainingY) > 0.001 do
        local playerStepY = playerRemainingY > 0 and math.min(1, playerRemainingY) or math.max(-1, playerRemainingY)
        local playerBeforeY = object_y(15)
        move_object(15, 0, playerStepY)
        if object_y(15) == playerBeforeY then
            playerGrounded = playerRemainingY > 0
            objects[15].vy = 0
            break
        end
        playerRemainingY = playerRemainingY - playerStepY
    end
    if PlayerActions.jump and playerGrounded then objects[15].vy = -objects[15].jump_force end
    if PlayerActions.attack then startPlayerAttack() end
    updatePlayerAttack()
    updatePlayerInteractions(frame)
    PlayerActionDraw = nil
    PlayerAttackDraw = nil
    if objects[15].vy < 0 then
        PlayerActionDraw = nil
    elseif PlayerActions.moveLeft then
        PlayerActionDraw = function(x, y) ui.tile(resolveSpriteAsset("assets/prepared/krun.png"), ({ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 })[((math.floor(frame / 8) % 16) + 1)], x, y, PlayerFacingLeft, false) end
    elseif PlayerActions.moveRight then
        PlayerActionDraw = function(x, y) ui.tile(resolveSpriteAsset("assets/prepared/krun.png"), ({ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 })[((math.floor(frame / 8) % 16) + 1)], x, y, PlayerFacingLeft, false) end
    end
    if PlayerAttack.active then PlayerAttackDraw = function(x, y) ui.tile(resolveSpriteAsset("assets/prepared/swatk.png"), ({ 0, 1, 2, 3, 4, 5, 6, 7 })[((math.floor((PlayerAttack.frame - 1) / 8) % 8) + 1)], x, y, PlayerAttack.direction < 0, false) end end
    end

    ui.camera(0, 0)
    if not messageWasActive and ActiveMap then ActiveMap.update(frame) end

    if ActiveMapId == "map-1" then ui.map(authoredMap1Layer1) end
    if ActiveMapId == "b57387a1-e895-463d-a55e-3aa4970caa8c" then ui.map(authoredMap2Layer1) end
    if objects[1].map_id == ActiveMapId then
        if objects[1].active and not objects[1].invisible then ui.rectfill(objects[1].x, objects[1].y, objects[1].x + objects[1].width, objects[1].y + objects[1].height, objects[1].color) end
    end
    if objects[2].map_id == ActiveMapId then
    
    end
    if objects[3].map_id == ActiveMapId then
        if objects[3].active and not objects[3].invisible then ui.rectfill(objects[3].x, objects[3].y, objects[3].x + objects[3].width, objects[3].y + objects[3].height, objects[3].color) end
    end
    if objects[4].map_id == ActiveMapId then
        if objects[4].active and not objects[4].invisible then ui.trisfill(objects[4].x + objects[4].width / 2, objects[4].y, objects[4].x + objects[4].width, objects[4].y + objects[4].height, objects[4].x, objects[4].y + objects[4].height, objects[4].color) end
    end
    if objects[5].map_id == ActiveMapId then
        if objects[5].active and not objects[5].invisible then ui.rectfill(objects[5].x, objects[5].y, objects[5].x + objects[5].width, objects[5].y + objects[5].height, objects[5].color) end
    end
    if objects[6].map_id == ActiveMapId then
        if objects[6].active and not objects[6].invisible then ui.rectfill(objects[6].x, objects[6].y, objects[6].x + objects[6].width, objects[6].y + objects[6].height, objects[6].color) end
    end
    if objects[8].map_id == ActiveMapId then
        if objects[8].active and not objects[8].invisible then ui.circfill(objects[8].x + objects[8].radius, objects[8].y + objects[8].radius, objects[8].radius, objects[8].color) end
    end
    if objects[10].map_id == ActiveMapId then
        if objects[10].active and not objects[10].invisible then ui.rectfill(objects[10].x, objects[10].y, objects[10].x + objects[10].width, objects[10].y + objects[10].height, objects[10].color) end
    end
    if objects[13].map_id == ActiveMapId then
    
    end
    if ActiveMapId == "map-1" then ui.map(authoredMap1Layer2) end
    if objects[7].map_id == ActiveMapId then
        if objects[7].active and not objects[7].invisible then ui.circfill(objects[7].x + objects[7].radius, objects[7].y + objects[7].radius, objects[7].radius, objects[7].color) end
    end
    if objects[9].map_id == ActiveMapId then
        if objects[9].active and not objects[9].invisible then ui.circfill(objects[9].x + objects[9].radius, objects[9].y + objects[9].radius, objects[9].radius, objects[9].color) end
    end
    if ActiveMapId == "map-1" then if objects[14].active then ui.spr(resolveSpriteAsset("assets/created/grassblock.png"), 318, 137, false, false) end end
    if ActiveMapId == "map-1" then ui.map(authoredMap1Layer3) end
    if ActiveMapId == "b57387a1-e895-463d-a55e-3aa4970caa8c" then ui.map(authoredMap2Layer3) end
    if ActiveMapId == "map-1" then ui.map(authoredMap1Layer4) end
    if objects[11].map_id == ActiveMapId then
        if objects[11].active and not objects[11].invisible then ui.circfill(objects[11].x + objects[11].radius, objects[11].y + objects[11].radius, objects[11].radius, objects[11].color) end
    end
    if objects[12].map_id == ActiveMapId then
        if objects[12].active and not objects[12].invisible then ui.circfill(objects[12].x + objects[12].radius, objects[12].y + objects[12].radius, objects[12].radius, objects[12].color) end
    end
    if objects[15].map_id == ActiveMapId then if objects[15].active then if PlayerActionDraw then PlayerActionDraw(objects[15].x, objects[15].y) else ui.tile(resolveSpriteAsset("assets/prepared/kidle.png"), ({ 0, 1, 2, 3 })[((math.floor(frame / 8) % 4) + 1)], objects[15].x, objects[15].y, PlayerFacingLeft, false) end
    if PlayerAttack.active and PlayerAttackDraw and PlayerAttack.hitbox then PlayerAttackDraw(PlayerAttack.x, PlayerAttack.y) end end end
    if ActiveMapId == "map-1" then if objects[16].active then ui.spr(spriteFrames3[((math.floor(frame / 8) % #spriteFrames3) + 1)], 265, 120, false, false) end end
    if ActiveMapId == "map-1" then if objects[17].active then ui.tile(resolveSpriteAsset("assets/prepared/wtt.png"), 68, 91, 79, false, false) end end
    ui.camera(0, 0)
    ui.print("Pontos: " .. tostring(PlayerScore), 8, 8, ASSET_PALETTE_SIZE + 7)
    for lifeIndex = 1, PlayerLives do ui.spr(resolveSpriteAsset("assets/player/main.png"), 8 + (lifeIndex - 1) * 16, 24) end
    if CurrentMessageScreen then
        local messageScreen = CurrentMessageScreen
        if messageScreen.background_enabled then ui.rectfill(0, 0, 480, 270, messageScreen.background_color) end
        if messageScreen.frame_enabled then
            local x, y = messageScreen.frame_x, messageScreen.frame_y
            local w, h = messageScreen.frame_width, messageScreen.frame_height
            ui.rectfill(x, y, x + w, y + h, messageScreen.frame_color)
            if messageScreen.border_sprite then
                local sw, sh = math.max(1, messageScreen.border_sprite_width), math.max(1, messageScreen.border_sprite_height)
                ui.clip(x, y, w, h)
                for px = x, x + w, sw do
                    if messageScreen.border_sprite_type == "tile" then ui.tile(messageScreen.border_sprite, 0, px, y); ui.tile(messageScreen.border_sprite, 0, px, y + h - sh)
                    else ui.spr(messageScreen.border_sprite, px, y); ui.spr(messageScreen.border_sprite, px, y + h - sh) end
                end
                for py = y, y + h, sh do
                    if messageScreen.border_sprite_type == "tile" then ui.tile(messageScreen.border_sprite, 0, x, py); ui.tile(messageScreen.border_sprite, 0, x + w - sw, py)
                    else ui.spr(messageScreen.border_sprite, x, py); ui.spr(messageScreen.border_sprite, x + w - sw, py) end
                end
                ui.clip(0, 0, 480, 270)
            else
                ui.rectfill(x, y, x + w, y + messageScreen.border_thickness, messageScreen.border_color)
                ui.rectfill(x, y + h - messageScreen.border_thickness, x + w, y + h, messageScreen.border_color)
                ui.rectfill(x, y, x + messageScreen.border_thickness, y + h, messageScreen.border_color)
                ui.rectfill(x + w - messageScreen.border_thickness, y, x + w, y + h, messageScreen.border_color)
            end
        end
        local lineY = messageScreen.text_y
        if messageScreen.frame_enabled then ui.clip(messageScreen.frame_x, messageScreen.frame_y, messageScreen.frame_width, messageScreen.frame_height) end
        for line in string.gmatch(messageScreen.text .. "\n", "(.-)\n") do
            local lineX = messageScreen.text_x
            if messageScreen.text_align == "center" then lineX = lineX - (#line * 4)
            elseif messageScreen.text_align == "right" then lineX = lineX - (#line * 8) end
            ui.print(line, lineX, lineY, messageScreen.text_color)
            lineY = lineY + messageScreen.line_height
        end
        if messageScreen.frame_enabled then ui.clip(0, 0, 480, 270) end
        if messageScreen.prompt_enabled then ui.print("Pressione qualquer botão", messageScreen.prompt_x, messageScreen.prompt_y, messageScreen.text_color) end
    end
end
