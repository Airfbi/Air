script.keep_alive()

local start_animation = false
local display_duration = 3000
local scale = 1.0
local text_color = {R = 0.0, G = 0.55, B = 0.55, A = 1.0}
local All_Chests = {}

local languages = {
    ["简体中文"] = {
        time_text = "时间: ",
        id_text = "ID: ",
        invis_on = "隐身已开启",
        invis_off = "隐身已关闭",
        entity_deleted = "金条宝箱已删除",
        spawn_success = "新金条 %s 金条宝箱",
        menu_label = "VIP菜单: ",
        success_msg = "脚本加载完成",
        script_name = "Air体验版本V7.0",
        toggle_hud = "平视显示测试 - 已加载!"
    },
    ["English"] = {
        time_text = "Time: ",
        id_text = "ID: ",
        invis_on = "Invisibility enabled",
        invis_off = "Invisibility disabled",
        entity_deleted = "Gold chest deleted",
        spawn_success = "Spawned %s gold chests",
        menu_label = "VIP Menu: ",
        success_msg = "Script loaded successfully",
        script_name = "Air Experience Version V7.0",
        toggle_hud = "Heads-up display test - loaded!"
    },
    ["Русский"] = {
        time_text = "Время: ",
        id_text = "ИД: ",
        invis_on = "Невидимость включена",
        invis_off = "Невидимость отключена",
        entity_deleted = "Золотой сундук удален",
        spawn_success = "Создано %s золотых сундуков",
        menu_label = "VIP Меню: ",
        success_msg = "Скрипт загружен успешно",
        script_name = "Воздушный опыт Версия V7.0",
        toggle_hud = "Тест дисплея - загружен!"
    },
    ["Deutsch"] = {
        time_text = "Zeit: ",
        id_text = "ID: ",
        invis_on = "Unsichtbarkeit aktiviert",
        invis_off = "Unsichtbarkeit deaktiviert",
        entity_deleted = "Goldschatz gelöscht",
        spawn_success = "Erstellte %s Goldschätze",
        menu_label = "VIP-Menü: ",
        success_msg = "Skript erfolgreich geladen",
        script_name = "Lufterlebnis Version V7.0",
        toggle_hud = "Heads-up-Display-Test - geladen!"
    },
}

local current_language = "简体中文"

local function getCurrentTime()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local function getPlayerID()
    local localPlayerIndex = native.player.player_id()
    return native.player.get_player_name(localPlayerIndex)
end

function startAnimation()
    start_animation = true
    thread.yield(display_duration) 
    start_animation = false 
end

thread.create(function()
    while true do
        if start_animation then
            local time_text = languages[current_language].time_text .. getCurrentTime()
            local player_id_text = languages[current_language].id_text .. getPlayerID()
            local full_text = time_text .. "\n" .. player_id_text
            
            local text_w, text_h = gui.get_text_size(full_text, scale)
            local wnd_w, wnd_h = gui.get_window_size()
            local wnd_x = (wnd_w / 2) - (text_w / 2)
            local wnd_y = (wnd_h / 2) - (text_h / 2)

            gui.draw_rect(wnd_x - 10, wnd_y - 10, text_w + 20, text_h + 20, 1.0, 0.0, 0.0, 0.6, 6.0, 3.0) 
            gui.draw_text(full_text, wnd_x, wnd_y, text_color.R, text_color.G, text_color.B, 1.0, scale) 
            
            thread.yield() 
        else
            thread.yield(1000)
        end
    end
end)

script.on_shutdown(function()
    for _, ent in ipairs(All_Chests) do
        delete_entity(ent)
    end
    native.hud.display_hud(true)  
end)

script.set_name(languages[current_language].script_name)
script.set_desc(languages[current_language].script_name)
toast.add_success(languages[current_language].success_msg, "Air已激活")

local localPlayerIndex = native.player.player_id()

local function delete_entity(ent)
    if native.entity.does_entity_exist(ent) then
        local mem = memory.alloc_mem(4)
        memory.write_s32(memory.get_address(mem), ent)
        native.entity.delete_entity(memory.get_address(mem))
        toast.add_info(languages[current_language].entity_deleted, languages[current_language].entity_deleted)
    end
end

local function setLocalPlayerInvisible(state)
    local playerPed = native.player.get_player_ped(localPlayerIndex)

    if playerPed and native.entity.does_entity_exist(playerPed) then
        native.entity.set_entity_visible(playerPed, not state)
        if state then
            toast.add_success(languages[current_language].invis_on, "玩家隐身")
        else
            toast.add_success(languages[current_language].invis_off, "玩家可见")
        end
    else
        toast.add_error("数据异常", "角色不存在")
    end
end

local menuRoot = menu.script_root()
menuRoot:add_toggle("隐身", {}, function(state)
    setLocalPlayerInvisible(state)
end)

Spawn_Gold = menu.player_root():add_list("刷新金条宝箱", {"1", "10", "50", "100"}, false, {}, function(pid)
    local player_ped = native.player.get_player_ped(pid)
    local pos1 = native.entity.get_offset_from_entity_in_world_coords(player_ped, 0, 1, 0)
    local rot = native.entity.get_entity_rotation(player_ped, 0)
    local chest = native.object.create_object(hash.joaat("s_footlocker03x"), pos1.x, pos1.y, pos1.z, true, false, true, false, false)
    native.entity.place_entity_on_ground_properly(chest, true)
    native.entity.set_entity_invincible(chest, true)
    native.entity.set_entity_rotation(chest, rot.x, rot.y, rot.z, 0, false)
    native.task._set_scenario_container_opening_state(chest, true)
    local pos2 = native.entity.get_entity_coords(chest, false, false)
    for i = 1, tonumber(Spawn_Gold:get_item()) do
        local gold = native.object.create_object(hash.joaat("mp001_s_mp_boxsm01x"), pos2.x, pos2.y, pos2.z + 0.15, true, false, true, false, false)
        native.entity.set_entity_invincible(gold, true)
        native.entity.set_entity_rotation(gold, rot.x, rot.y, rot.z, 0, false)
        All_Chests[#All_Chests + 1] = gold
        All_Chests[#All_Chests + 1] = chest
    end
    toast.add_success("刷新成功", string.format(languages[current_language].spawn_success, Spawn_Gold:get_item()))
end)

menu.player_root():add_button("删除所有金条宝箱", {}, function()
    for _, ent in ipairs(All_Chests) do
        delete_entity(ent)
    end
    All_Chests = {}
end)

toast.add_info(languages[current_language].toggle_hud, "平视显示切换选项")
local opt = menuRoot:add_toggle("平视", { "显示/隐藏" }, function(state)
    if state then
        native.hud.display_hud(false)
    else
        native.hud.display_hud(true)
    end
end)

opt:set_toggle(true)

local language_menu = menuRoot:add_list("语言切换", {"简体中文", "English", "Русский", "Deutsch"}, false, {}, function(selected)
    current_language = selected
    script.set_name(languages[current_language].script_name)
    script.set_desc(languages[current_language].script_name)
    toast.add_info("语言切换", "当前语言: " .. current_language)
end)

toast.add_success("Air系统", "脚本功能已开启")
startAnimation()

script.on_shutdown(function()
    toast.add_info("Air系统", "已关闭脚本")
end)

if menuRoot:is_valid() then
    toast.add_info("菜单有效", "菜单可以正常使用")
end

local label = menuRoot:get_label()
toast.add_info(languages[current_language].menu_label, languages[current_language].menu_label .. label)
