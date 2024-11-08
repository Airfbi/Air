script.keep_alive()

local function encrypt(str, key)
    local encrypted_str = ""
    for i = 1, #str do
        local byte = string.byte(str, i)
        local key_byte = string.byte(key, (i % #key) + 1) 
        encrypted_str = encrypted_str .. string.char(byte + key_byte)
    end
    return encrypted_str
end

local function decrypt(str, key)
    local decrypted_str = ""
    for i = 1, #str do
        local byte = string.byte(str, i)
        local key_byte = string.byte(key, (i % #key) + 1)  
        decrypted_str = decrypted_str .. string.char(byte - key_byte)
    end
    return decrypted_str
end

local key = "*Air*Lua Developers"

local main_menu = menu.script_root():add_submenu(decrypt(encrypt(" ", key), key), { decrypt(encrypt(" ", key), key) })

local function set_player_invisibility(player_idx, state)
    local playerPed = native.player.get_player_ped(player_idx)
    
    if state then
        native.entity.set_entity_visible(playerPed, false, false)
        toast.add_success(decrypt(encrypt(" ", key), key), decrypt(encrypt(" ", key), key))
    else
        native.entity.set_entity_visible(playerPed, true, false)
        toast.add_info(decrypt(encrypt(" ", key), key), decrypt(encrypt(" ", key), key))
    end
end

local add_function_menu = main_menu:add_submenu(decrypt(encrypt(" ", key), key), { decrypt(encrypt(" ", key), key) })
local new_submenu = add_function_menu:add_submenu(decrypt(encrypt(" ", key), key), { decrypt(encrypt(" ", key), key) })

local invisibility_enabled = false

new_submenu:add_toggle(decrypt(encrypt(" ", key), key), {}, function(state)
    set_player_invisibility(0, state)  
end)

local WeaponManager = {}
WeaponManager.__index = WeaponManager

function WeaponManager.new()
    local self = setmetatable({}, WeaponManager)
    self.ped = nil
    self.weapon_hash = nil
    return self
end

function WeaponManager:toggle_visibility(state)
    local player_ped = native.player.get_player_ped(0)
    native.weapon._set_ped_all_weapons_visibility(player_ped, state)
    if state then
        toast.add_info(decrypt(encrypt(" ", key), key), decrypt(encrypt(" ", key), key))
    else
        toast.add_info(decrypt(encrypt(" ", key), key), decrypt(encrypt(" ", key), key))
    end
end

local manager = WeaponManager.new()

local weapon_submenu = new_submenu:add_submenu(decrypt(encrypt(" ", key), key), { decrypt(encrypt(" ", key), key) })
weapon_submenu:add_toggle(decrypt(encrypt(" ", key), key), {}, function(state)
    manager:toggle_visibility(not state)
end)

toast.add_success(decrypt(encrypt(" ", key), key), decrypt(encrypt(" ", key), key))
