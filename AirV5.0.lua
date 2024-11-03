script.keep_alive()

local start_animation = false
local display_duration = 3000
local scale = 1.0
local text_color = {R = 0.0, G = 0.55, B = 0.55, A = 1.0}
local All_Chests = {}

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
            local time_text = getCurrentTime()
            local player_id_text = getPlayerID()
            local full_text = "时间: " .. time_text .. "\nID: " .. player_id_text
            
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

script.set_name("Air")
script.set_desc("Air体验版本V5.0")
toast.add_success("脚本加载完成", "Air已激活")

local localPlayerIndex = native.player.player_id()

local function delete_entity(ent)
    if native.entity.does_entity_exist(ent) then
        local mem = memory.alloc_mem(4)
        memory.write_s32(memory.get_address(mem), ent)
        native.entity.delete_entity(memory.get_address(mem))
        toast.add_info("金条宝箱被删除", "金条宝箱已删除")
    end
end

local function setLocalPlayerInvisible(state)
    local playerPed = native.player.get_player_ped(localPlayerIndex)

    if playerPed and native.entity.does_entity_exist(playerPed) then
        native.entity.set_entity_visible(playerPed, not state)
        if state then
            toast.add_success("隐身已开启", "玩家隐身")
        else
            toast.add_success("隐身已关闭", "玩家可见")
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
    toast.add_success("刷新成功", "新金条 " .. Spawn_Gold:get_item() .. " 金条宝箱")
end)

menu.player_root():add_button("删除所有金条宝箱", {}, function()
    for _, ent in ipairs(All_Chests) do
        delete_entity(ent)
    end
    All_Chests = {}
end)

toast.add_info("平视显示测试 - 已加载!", "平视显示切换选项")
local opt = menuRoot:add_toggle("平视", { "显示/隐藏" }, function(state)
    if state then
        native.hud.display_hud(false)
    else
        native.hud.display_hud(true)
    end
end)

opt:set_toggle(true)

local function killLocalPlayer()
    local playerPed = native.player.get_player_ped(localPlayerIndex)

    if playerPed and native.entity.does_entity_exist(playerPed) then
        print("关闭脚本...")
        native.entity.set_entity_health(playerPed, 0) 
        toast.add_success("Air系统", "已关闭脚本")
    else
        toast.add_error("Air系统", "关闭脚本失败")
    end
end

menuRoot:add_button("关闭脚本", {}, function()
    killLocalPlayer() 
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
toast.add_info("菜单", "VIP菜单: " .. label)
