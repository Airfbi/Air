script.keep_alive()

local main_menu = menu.script_root():add_submenu("菜单", { "*Air*Lua开发人员" }, nil, nil)

main_menu:add_button("个人信息", { "查看显示个人玩家信息" }, function()
    local player_index = player.get_rockstar_id(0)
    local player_name = player.get_name(0)
    local player_health = player.get_health(0)

    toast.add_info("玩家信息", string.format("名字: %s\nRockstar ID: %d\n生命值: %.2f", player_name, player_index, player_health))
end)

local add_function_menu = main_menu:add_submenu("个人功能", { "所有的功能" })

local new_submenu = add_function_menu:add_submenu("代理菜单", { "未开放" })

toast.add_success("代理菜单加载完成", "代理菜单加载成功")

local toggle_option = main_menu:add_toggle("测试中", { "测试中" }, function(state)
    if state then
        toast.add_success("测试中")
    else
        toast.add_warning("测试中")
    end
end)

local slider_value = 5
main_menu:add_slider_int("测试中", slider_value, 1, 10, 1, false, { "测试中" }, nil, function(value)
    slider_value = value
    toast.add_info("当前值", string.format("设置测试中: %d", slider_value))
end)

main_menu:add_separator("分隔符示例")

local sub_menu = main_menu:add_submenu("辅助菜单", { "测试中" }, function()
    toast.add_info("测试中", "测试中")
end, function()
    toast.add_info("退出测试中", "您已退出测试中")
end)

sub_menu:add_button("测试中", { "测试中" }, function()
    local current_time = time.unix_seconds()
    toast.add_info("动态文本", string.format("当前时间戳: %d", current_time))
end)

local items = { "选项 1", "选项 2", "选项 3" }
sub_menu:add_list("测试中", items, false, { "测试中" }, function(item)
    toast.add_info("测试中", string.format("测试中: %s", item))
end)

local player_count = 0

local function getLeaveReason(playerIdx)
    return "未知"
end

local function displayPlayerInfo(index, is_joining)
    local name = player.get_name(index)
    local b1, b2, b3, b4 = player.get_ip(index)

    local status_message = string.format("玩家信息: %s\nIP: %d.%d.%d.%d", name, b1, b2, b3, b4)

    if is_joining then
        player_count = player_count + 1
        toast.add_info(status_message, "陌生玩家加入了战局")
        toast.add_info(string.format("战局玩家数量: %d", player_count), "数量已更新")
    else
        local leave_reason = getLeaveReason(index)
        player_count = player_count - 1
        toast.add_info(status_message .. string.format("\n离开原因: %s", leave_reason), "陌生玩家离开战局")
        toast.add_info(string.format("战局玩家数量: %d", player_count), "玩家数量更新")
    end
end

local function isPlayerActive(playerIdx)
    local playerPed = native.player.get_player_ped(playerIdx)
    return playerPed and native.entity.does_entity_exist(playerPed)
end

local function monitorPlayers()
    local players = {}
    while true do
        for i = 0, 31 do
            if isPlayerActive(i) and not players[i] then
                players[i] = true
                displayPlayerInfo(i, true)
            elseif players[i] and not isPlayerActive(i) then
                players[i] = nil
                displayPlayerInfo(i, false)
            end
        end
        thread.yield(1000) 
    end
end

local thread_status = thread.create(monitorPlayers)
if not thread_status then
    toast.add_warning("玩家监控线程启动失败", "请检查线程创建代码")
else
    toast.add_success("玩家监控线程已启动", "监控功能正常运行")
end

script.on_shutdown(function()
    toast.add_info("检测到您", "脚本关闭")
end)

toast.add_success("脚本加载完成", "*Air*Lua开发人员")

if exodus and exodus.is_available() then
    toast.add_info("Exodus API检查", "API检查正常")
end
