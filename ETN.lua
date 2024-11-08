script.keep_alive()
script.set_name("Air")
script.set_desc("Plus")

local _m1 = menu.script_root():add_submenu("菜单", { "*Air*Lua开发人员" }, nil, nil)
local _m2 = _m1:add_submenu("个人功能", { "所有的功能" })
local _m3 = _m2:add_submenu("代理菜单", { "ETN" })

local _p1 = native.player.player_id()

local function _f1()
    local _m4 = _m3:add_submenu("玩家列表", { "临时玩家" })
    for _i = 0, 31 do
        if player.is_connected(_i) then
            _m4:add_button("玩家 " .. player.get_name(_i), { "查看玩家信息" }, function()
                toast.add_info("玩家信息", "玩家 " .. player.get_name(_i) .. " 在线")
            end)
        end
    end
end

_f1()

_m1:add_button("个人信息", { "查看显示个人玩家信息" }, function()
    local _id = player.get_rockstar_id(0)
    local _name = player.get_name(0)
    local _health = player.get_health(0)
    toast.add_info("玩家信息", string.format("名字: %s\nRockstar ID: %d\n生命值: %.2f", _name, _id, _health))
end)

local _v1 = false
local function _f2(_p2, _state)
    local _ped = native.player.get_player_ped(_p2)
    if _state then
        native.entity.set_entity_visible(_ped, false, false)
        toast.add_success("隐身模式开启", "可使用")
    else
        native.entity.set_entity_visible(_ped, true, false)
        toast.add_info("隐身模式关闭", "您已退出隐身模式")
    end
end

_m3:add_toggle("隐身模式", { "开启或关闭隐身模式" }, function(_state)
    _f2(0, _state)
end)

local _w1 = {}
_w1.__index = _w1

function _w1.new()
    local _self = setmetatable({}, _w1)
    _self.ped = nil
    _self.weapon_hash = nil
    _self.ammo_count = 0
    return _self
end

function _w1:set_character(_ped)
    self.ped = _ped
end

function _w1:set_weapon(_hash)
    self.weapon_hash = _hash
end

function _w1:toggle_visibility(_state)
    local _ped = native.player.get_player_ped(0)
    native.weapon._set_ped_all_weapons_visibility(_ped, _state)
    if _state then
        toast.add_info("武器可见", "您的武器现在可见")
    else
        toast.add_info("武器已隐藏", "您的武器现在隐藏")
    end
end

local _m5 = _w1.new()
local _m6 = _m3:add_submenu("武器管理", { "所有武器" })

_m6:add_toggle("隐藏武器", { "隐藏或显示所有武器" }, function(_state)
    _m5:toggle_visibility(not _state)
end)

toast.add_success("武器检查完成", "所有武器")

local _p2 = 0
local _players = {}

local function _f3(_p3)
    return "未知"
end

local function _f4(_p3, _joining)
    local _name = player.get_name(_p3)
    local _b1, _b2, _b3, _b4 = player.get_ip(_p3)

    local _status = string.format("玩家信息: %s\nIP: %d.%d.%d.%d", _name, _b1, _b2, _b3, _b4)

    if _joining then
        _p2 = _p2 + 1
        toast.add_info(_status, "玩家加入了战局")
    else
        local _reason = _f3(_p3)
        _p2 = _p2 - 1
        toast.add_info(_status .. string.format("\n离开原因: %s", _reason), "玩家离开战局")
    end
end

local function _f5(_p3)
    local _ped = native.player.get_player_ped(_p3)
    return _ped and native.entity.does_entity_exist(_ped)
end

local function _f6()
    while true do
        for _i = 0, 31 do
            if _f5(_i) and not _players[_i] then
                _players[_i] = true
                _f4(_i, true)
            elseif _players[_i] and not _f5(_i) then
                _players[_i] = nil
                _f4(_i, false)
            end
        end
        thread.yield(1000)
    end
end

local function _f7()
    local _delay = math.random(60, 120)
    thread.yield(_delay * 1000)

    toast.add_info(string.format("战局玩家数量: %d", _p2), "玩家数量已更新")
end

local _t1 = thread.create(_f6)
if not _t1 then
    toast.add_warning("玩家监控线程启动失败", "请检查线程创建代码")
else
    toast.add_success("玩家监控线程可使用", "监控功能正常运行")
end

local _t2 = thread.create(_f7)
if not _t2 then
    toast.add_warning("人数显示延迟线程失败", "请检查延迟线程代码")
else
    toast.add_success("人数显示延迟线程可使用", "玩家人数将在延迟后显示")
end

local function _f8()
    toast.add_info("脚本", "请稍等...")
    thread.yield(0000)

    toast.add_success("脚本", "可使用")
end

local _t3 = thread.create(_f8)

script.on_shutdown(function()
    events.remove_listener("on_player_join", "UniqueListenerName")
    toast.add_info("Shutdown", "Object Spawner for Players has been stopped.")
end)

toast.add_success("代理菜单", "可使用")
