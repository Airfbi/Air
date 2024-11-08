script.set_name("FFFF崩溃")
script.set_desc("XXXX崩溃")

local scriptMenu = menu.player_root()
local playerSelectMenu = scriptMenu:add_submenu("玩家", {}, nil, nil)
local localPlayerIndex = native.player.player_id()
local spawnedPlayers = {}

-- E: "قاستەل"
-- E: "لاعب التخريب"
-- E: "диверсиялық ойыншы"
-- E: "диверсант"
-- E: "jogador de sabotagem"

local function SpawnObjectForPlayer(playerIndex)
    -- E: "تحطم فعال بنسبة 100٪"
    if playerIndex == localPlayerIndex then
        return 
    end
    if spawnedPlayers[playerIndex] then
        return 
    end

    local playerPed = native.player.get_player_ped(playerIndex)

    local objectHash = native.misc.get_hash_key('s_chuckwagonawning01b')
    local posVec = native.entity.get_offset_from_entity_in_world_coords(playerPed, 0, 0.5, 0)

    for i = 1, 50 do
        local object = native.object.create_object_no_offset(objectHash, posVec.x, posVec.y, posVec.z, true, true, true, false)
        native.network.network_set_entity_only_exists_for_participants(object, false)

        if object ~= 0 and native.entity.does_entity_exist(object) then

            toast.add_success("F", "玩家 " .. playerIndex .. " 成功 (尝试次数: " .. i .. ")")
            spawnedPlayers[playerIndex] = true
            return 
        else

            toast.add_error("E", "玩家 " .. playerIndex .. " 失败 (尝试次数: " .. i .. ")")
        end
    end
end

local playerList = {}
for index = 0, 31 do
    if player.is_connected(index) then
        table.insert(playerList, tostring(index))
    end
end

local playerSelectOption = playerSelectMenu:add_list("玩家FFFF", playerList, false, {}, function(selectedPlayer)
    SpawnObjectForPlayer(tonumber(selectedPlayer))
end)

script.keep_alive()

script.on_shutdown(function()
    toast.add_info("中断FFFF", "中断")
end)