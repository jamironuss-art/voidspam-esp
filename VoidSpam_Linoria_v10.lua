-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
-- â•‘  VOID SPAM  â€”  LINORIA EDITION  v10                     â•‘
-- â•‘  Tabs: ESP | Aimbot | Ragebot | Visuals | Movement | Settings     â•‘
-- â•‘  â€¢ Real LinoriaLib loaded from GitHub                   â•‘
-- â•‘  â€¢ Draggable â€” built into LinoriaLib                    â•‘
-- â•‘  â€¢ Mobile: 60% wide / 50% tall  |  PC: fixed 660Ã—620   â•‘
-- â•‘  â€¢ Mobile-only  Toggle UI / Lock UI  floating panel     â•‘
-- â•‘  â€¢ Client-sided â€” only YOU are affected                 â•‘
-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  SERVICES
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
warn('[VoidSpam:CHECK] A script start')
-- =====================================================
--  ANTICHEAT BYPASS  (AethSec challenge-response spoof)
--  Runs on its own thread; degrades silently if the
--  executor or the game's AC structure is unavailable.
-- =====================================================
task.spawn(function()
    local LPH_NO_VIRTUALIZE = nil
    if type(getgenv) == 'function' then
        local _g = getgenv()
        if type(_g.LPH_NO_VIRTUALIZE) == 'function' then LPH_NO_VIRTUALIZE = _g.LPH_NO_VIRTUALIZE end
    end
    if type(LPH_NO_VIRTUALIZE) ~= 'function' then LPH_NO_VIRTUALIZE = function(f) return f end end

pcall(LPH_NO_VIRTUALIZE(function()
    local bypassed = false

    local kKickNames = {
        "Kick",
        "kick"
    }

    local kProtectedProperties = {
        Enabled = true,
        Disabled = false
    }

    local kSlotMap = {
        [69]  = 2,
        [138] = 3,
        [207] = 4,
        [276] = 5,
        [345] = 6,
        [414] = 7,
    }

    local kFilledSub = {
        1,
        2,
        3,
        4,
        5
    }

    local Players = cloneref(game:GetService("Players"))
    local ReplicatedFirst = cloneref(game:GetService("ReplicatedFirst"))
    local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
    local ScriptContext = cloneref(game:GetService("ScriptContext"))

    local LocalPlayer = Players.LocalPlayer

    local ac_script = ReplicatedFirst:WaitForChild("LocalScript3")
    local ac_event = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvent")

    local last = nil
    local first_seen = false
    local hijack_ready = false
    local client_id
    local expected_interval = 0.6
    local min_interval = 0.25
    local ema_alpha = 0.5
    local samples = 0
    local hidden_fn = {}
    local max_stack_depth = 128
    setstackhidden = setstackhidden or function(fn_or_level, hidden)
        assert(typeof(hidden) == "boolean", "hidden must be boolean")

        local ok, fn = pcall(function()
            if typeof(fn_or_level) == "number" then
                return debug.info(fn_or_level + 2, "f")
            end
            return fn_or_level
        end)

        assert(ok and fn, "invalid argument #1 to 'setstackhidden'")
        hidden_fn[fn] = not hidden
    end

    local TrustedFunctions = setmetatable({}, {
        __mode = "k"
    })

    local function TrustFunction(fn)
        if type(fn) == "function" then
            TrustedFunctions[fn] = true
        end

        return fn
    end

    local function IsTrustedFunction(fn)
        return TrustedFunctions[fn] == true
    end

    local SafeHook = function(hookfn, ...)
        local args = {...}
        local func, inst, metamethod, detour

        if hookfn == hookmetamethod then
            inst = args[1]
            metamethod = args[2]
            detour = args[3]
        else
            func = args[1]
            detour = args[2]
        end

        local original_func

        if hookfn == hookfunction and iscclosure(func) then
            detour = newcclosure(detour)
        end

        if not iscclosure(detour) then
            detour = newcclosure(detour)
        end

        setstackhidden(detour, true)

        local ok, _ = pcall(function()
            TrustFunction(detour)
                    
            if hookfn == hookmetamethod then
                original_func = hookfn(inst, metamethod, detour)
            else
                original_func = hookfn(func, detour)
            end
        end)

        if not ok then
            LocalPlayer:Kick("[AethSec]: Bypass failed! n1")
        end

        return original_func
    end

    local SafeCall = function(func, ...)
        if checkcaller() then
            return func(...)
        end

        local old = getthreadidentity()
        if old ~= 2 then
            setthreadidentity(2)
        end

        local result = {func(...)}

        if old ~= 2 then
            setthreadidentity(old)
        end

        return table.unpack(result)
    end

    local monitor_conn = ScriptContext.Error:Connect(TrustFunction(function(message, stack, _)
        message = tostring(message)
        stack = tostring(stack)
        if stack:find("PlayerScripts.Controllers.MiscellaneousController") and message:find("attempt to index number with number") then
            LocalPlayer:Kick("[AethSec]: Bypass failed! n2")
        end
    end))

    local oldindex; oldindex = SafeHook(hookmetamethod, ac_script, "__index", function(t, k)
        local is_caller = not bypassed and checkcaller()
        if t == ac_script and not is_caller and kProtectedProperties[k] ~= nil then
            return kProtectedProperties[k]
        end
        if checkcaller() then
            return oldindex(t, k)
        end
        return SafeCall(oldindex, t, k)
    end)

    local oldnewindex; oldnewindex = SafeHook(hookmetamethod, ac_script, "__newindex", function(t, k, v)
        local is_caller = not bypassed and checkcaller()
        if t == ac_script and not is_caller and kProtectedProperties[k] ~= nil then
            kProtectedProperties[k] = v
            if k == "Enabled" then
                kProtectedProperties["Disabled"] = not v
            end

            if k == "Disabled" then
                kProtectedProperties["Enabled"] = not v
            end
            return
        end
        if checkcaller() then
            return oldnewindex(t, k, v)
        end
        return SafeCall(oldnewindex, t, k, v)
    end)

    client_id = ""
    last = tick()

    local oldfireserver; oldfireserver = SafeHook(hookfunction, ac_event.FireServer, function(self, ...)
        local now = tick()
        local args = {...}

        if not first_seen then
            first_seen = true
            local first_arg = args[1]

            if type(first_arg) == "table" and #first_arg >= 1 and (type(first_arg[1]) == "string" or type(first_arg[1]) == "number") then
                client_id = tostring(first_arg[1])
            else
                client_id = client_id or ""
            end

            last = tick()
            samples = 1
            hijack_ready = true

            local res = SafeCall(oldfireserver, self, ...)
            return res
        end

        local interval = now - (last or now)

        if interval > 0 then
            if samples == 0 then
                expected_interval = interval
            else
                expected_interval = ema_alpha * interval + (1 - ema_alpha) * expected_interval
            end

            samples = samples + 1

            if expected_interval < min_interval then
                expected_interval = min_interval
            end
        end

        local res = SafeCall(oldfireserver, self, ...)
        last = tick()

        return res
    end)

    local BuildSubTable = function()
        local num_empty = math.random(1, 5)
        local empty_map = {}
        local empty_slots = {7}
        empty_map[7] = true

        while #empty_slots < num_empty do
            local slot = math.random(1, 6)
            if not empty_map[slot] then
                empty_map[slot] = true
                table.insert(empty_slots, slot)
            end
        end

        table.sort(empty_slots)

        local result = {}
        for i = 1, 7 do
            if empty_map[i] then
                result[i] = {}
            else
                result[i] = kFilledSub
            end
        end

        return result, empty_slots
    end

    local ApplyTransforms = function(t, mask, empty_slots)
        local payload = t[1]
        local outer_index = #payload
        local inner_index = empty_slots[math.random(1, #empty_slots)]
        local derived
        local outer_val = payload[outer_index]

        if type(outer_val) == "table" and type(inner_index) == "number" then
            derived = outer_val[inner_index]
        else
            for i = outer_index, 1, -1 do
                if type(payload[i]) ~= "table" then
                    continue
                end

                local candidate = payload[i]

                if type(inner_index) == "number" and candidate[inner_index] ~= nil then
                    derived = candidate[inner_index]
                    break
                else
                    derived = candidate
                    break
                end
            end

            if derived == nil then
                derived = {}
            end
        end

        local written = {}
        local kSlotMapRef = kSlotMap

        for _, value in ipairs(mask) do
            local slot = kSlotMapRef[value]
            if slot and not written[slot] then
                t[slot] = derived
                written[slot] = true
            end
        end

        return t
    end

    local BuildPayload = function(challenge, mask)
        local sub_table, empty_slots = BuildSubTable()
        local total_idx = math.random(1, 8)
        local payload = {client_id, buffer.tostring(challenge)}
        local extra_strings = math.random(0, 2)

        for _ = 1, extra_strings do
            payload[#payload + 1] = ""
        end

        while #payload < (total_idx - 1) do
            payload[#payload + 1] = math.random(5, 100000)
        end

        payload[#payload + 1] = sub_table

        local t = {
            payload,
            {},
            nil,
            nil,
            nil,
            nil,
            nil
        }
        return ApplyTransforms(t, mask, empty_slots)
    end

    task.spawn(function()
        getfenv().script = ac_script
        while not hijack_ready do
            task.wait()
        end

        ac_script.Enabled = false

        ac_event.OnClientEvent:Connect(function(...)
            last = tick()

            local remote = Instance.new("RemoteEvent", nil)
            remote:FireServer()

            local t = {...}
            local challenge = t[1]
            local index = t[2]
            local mask = t[3]

            if typeof(challenge) ~= "buffer" or type(index) ~= "number" or type(mask) ~= "table" then
                LocalPlayer:Kick("[AethSec]: Bypass failed! n3")
            end

            local payload = BuildPayload(challenge, mask)
            task.defer(function()
                local since_last = tick() - (last or 0)
                local desired_wait = expected_interval - since_last
                
                if desired_wait > 0 then
                    task.wait(desired_wait)
                end
                ac_event:FireServer(table.unpack(payload, 1, 5))
                last = tick()
                remote:Destroy()
            end)
        end)
            
        bypassed = true
        monitor_conn:Disconnect()
    end)

    for _, name in ipairs(kKickNames) do
        local func = LocalPlayer[name]
        if type(func) ~= "function" then return end
            
        local oldfunc; oldfunc = SafeHook(hookfunction, func, function(self, ...)
            if self == LocalPlayer and not checkcaller() then
                return nil
            end
            return oldfunc(self, ...)
        end)
    end

    for _, conn in ipairs(getconnections(ScriptContext.Error)) do
        if not conn.Function then continue end
        if IsTrustedFunction(conn.Function) then continue end
        SafeHook(hookfunction, conn.Function, function(...)
            return nil
        end)
    end

    SafeHook(hookfunction, ScriptContext.Error.Connect, function(...)
        return nil
    end)

    while not bypassed do
        task.wait(0.5)
    end
    task.wait(1)
end))
end)


-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  MOBILE DETECTION
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- -----------------------------------------
--  LINORIALIB  (embedded - no HTTP at runtime)
-- -----------------------------------------
local LIBRARY_SRC = [====[

local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);

local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

local Library = {
    Registry = {};
    RegistryMap = {};

    HudRegistry = {};

    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(28, 28, 28);
    BackgroundColor = Color3.fromRGB(20, 20, 20);
    AccentColor = Color3.fromRGB(0, 85, 255);
    OutlineColor = Color3.fromRGB(50, 50, 50);
    RiskColor = Color3.fromRGB(255, 50, 50),

    Black = Color3.new(0, 0, 0);
    Font = Enum.Font.Code,

    OpenedFrames = {};
    DependencyBoxes = {};

    Signals = {};
    ScreenGui = ScreenGui;
};

local RainbowStep = 0
local Hue = 0

table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
    RainbowStep = RainbowStep + Delta

    if RainbowStep >= (1 / 60) then
        RainbowStep = 0

        Hue = Hue + (1 / 400);

        if Hue > 1 then
            Hue = 0;
        end;

        Library.CurrentRainbowHue = Hue;
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
    end
end))

local function GetPlayersString()
    local PlayerList = Players:GetPlayers();

    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name;
    end;

    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);

    return PlayerList;
end;

local function GetTeamsString()
    local TeamList = Teams:GetTeams();

    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name;
    end;

    table.sort(TeamList, function(str1, str2) return str1 < str2 end);
    
    return TeamList;
end;

function Library:SafeCallback(f, ...)
    if (not f) then
        return;
    end;

    if not Library.NotifyOnError then
        return f(...);
    end;

    local success, event = pcall(f, ...);

    if not success then
        local _, i = event:find(":%d+: ");

        if not i then
            return Library:Notify(event);
        end;

        return Library:Notify(event:sub(i + 1), 3);
    end;
end;

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save();
    end;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;

    if type(Class) == 'string' then
        _Instance = Instance.new(Class);
    end;

    for Property, Value in next, Properties do
        _Instance[Property] = Value;
    end;

    return _Instance;
end;

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1;

    Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0);
        Thickness = 1;
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = Inst;
    });
end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Library.Font;
        TextColor3 = Library.FontColor;
        TextSize = 16;
        TextStrokeTransparency = 0;
    });

    Library:ApplyTextStroke(_Instance);

    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud);

    return Library:Create(_Instance, Properties);
end;

function Library:MakeDraggable(Instance, Cutoff)
    Instance.Active = true;

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjPos = Vector2.new(
                Mouse.X - Instance.AbsolutePosition.X,
                Mouse.Y - Instance.AbsolutePosition.Y
            );

            if ObjPos.Y > (Cutoff or 40) then
                return;
            end;

            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                Instance.Position = UDim2.new(
                    0,
                    Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                    0,
                    Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                );

                RenderStepped:Wait();
            end;
        end;
    end)
end;

function Library:AddToolTip(InfoStr, HoverInstance)
    local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14);
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,

        Size = UDim2.fromOffset(X + 5, Y + 4),
        ZIndex = 100,
        Parent = Library.ScreenGui,

        Visible = false,
    })

    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(3, 1),
        Size = UDim2.fromOffset(X, Y);
        TextSize = 14;
        Text = InfoStr,
        TextColor3 = Library.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1,

        Parent = Tooltip;
    });

    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    });

    local IsHovering = false

    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            return
        end

        IsHovering = true

        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        Tooltip.Visible = true

        while IsHovering do
            RunService.Heartbeat:Wait()
            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        end
    end)

    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end)
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    HighlightInstance.MouseEnter:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)

    HighlightInstance.MouseLeave:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)
end;

function Library:MouseIsOverOpenedFrame()
    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
            and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

            return true;
        end;
    end;
end;

function Library:IsMouseOverFrame(Frame)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

        return true;
    end;
end;

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update();
    end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end;

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end;
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };

    table.insert(Library.Registry, Data);
    Library.RegistryMap[Instance] = Data;

    if IsHud then
        table.insert(Library.HudRegistry, Data);
    end;
end;

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance];

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx);
            end;
        end;

        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx);
            end;
        end;

        Library.RegistryMap[Instance] = nil;
    end;
end;

function Library:UpdateColorsUsingRegistry()
    -- TODO: Could have an 'active' list of objects
    -- where the active list only contains Visible objects.

    -- IMPL: Could setup .Changed events on the AddToRegistry function
    -- that listens for the 'Visible' propert being changed.
    -- Visible: true => Add to active list, and call UpdateColors function
    -- Visible: false => Remove from active list.

    -- The above would be especially efficient for a rainbow menu color or live color-changing.

    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if type(ColorIdx) == 'string' then
                Object.Instance[Property] = Library[ColorIdx];
            elseif type(ColorIdx) == 'function' then
                Object.Instance[Property] = ColorIdx()
            end
        end;
    end;
end;

function Library:GiveSignal(Signal)
    -- Only used for signals not attached to library instances, as those should be cleaned up on object destruction by Roblox
    table.insert(Library.Signals, Signal)
end

function Library:Unload()
    -- Unload all of the signals
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)
        Connection:Disconnect()
    end

     -- Call our unload callback, maybe to undo some hooks etc
    if Library.OnUnload then
        Library.OnUnload()
    end

    ScreenGui:Destroy()
end

function Library:OnUnload(Callback)
    Library.OnUnload = Callback
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance);
    end;
end))

local BaseAddons = {};

do
    local Funcs = {};

    function Funcs:AddColorPicker(Idx, Info)
        local ToggleLabel = self.TextLabel;
        -- local Container = self.Container;

        assert(Info.Default, 'AddColorPicker: Missing default value.');

        local ColorPicker = {
            Value = Info.Default;
            Transparency = Info.Transparency or 0;
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);

            ColorPicker.Hue = H;
            ColorPicker.Sat = S;
            ColorPicker.Vib = V;
        end;

        ColorPicker:SetHSVFromRGB(ColorPicker.Value);

        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 28, 0, 14);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        -- Transparency image taken from https://github.com/matas3535/SplixPrivateDrawingLibrary/blob/main/Library.lua cus i'm lazy
        local CheckerFrame = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(0, 27, 0, 13);
            ZIndex = 5;
            Image = 'http://www.roblox.com/asset/?id=12977615774';
            Visible = not not Info.Transparency;
            Parent = DisplayFrame;
        });

        -- 1/16/23
        -- Rewrote this to be placed inside the Library ScreenGui
        -- There was some issue which caused RelativeOffset to be way off
        -- Thus the color picker would never show

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        });

        DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
        end)

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });

        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 25);
            Size = UDim2.new(0, 200, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = SatVibMapOuter;
        });

        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapInner;
        });

        local CursorOuter = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6, 0, 6);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 19;
            Parent = SatVibMap;
        });

        local CursorInner = Library:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ZIndex = 20;
            Parent = CursorOuter;
        })

        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 208, 0, 25);
            Size = UDim2.new(0, 15, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorOuter;
        });

        local HueCursor = Library:Create('Frame', { 
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 18;
            Parent = HueSelectorInner;
        });

        local HueBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameInner;
        });

        local HueBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18,
            Parent = HueBoxOuter;
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxInner;
        });

        local HueBox = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxInner;
        });

        Library:ApplyTextStroke(HueBox);

        local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            Parent = PickerFrameInner
        });

        local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
            Text = '255, 255, 255',
            PlaceholderText = 'RGB color',
            TextColor3 = Library.FontColor
        });

        local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;
        
        if Info.Transparency then 
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4, 251);
                Size = UDim2.new(1, -8, 0, 15);
                ZIndex = 19;
                Parent = PickerFrameInner;
            });

            TransparencyBoxInner = Library:Create('Frame', {
                BackgroundColor3 = ColorPicker.Value;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 19;
                Parent = TransparencyBoxOuter;
            });

            Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });

            Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = 'http://www.roblox.com/asset/?id=12978095818';
                ZIndex = 20;
                Parent = TransparencyBoxInner;
            });

            TransparencyCursor = Library:Create('Frame', { 
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 21;
                Parent = TransparencyBoxInner;
            });
        end;

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            Text = ColorPicker.Title,--Info.Default;
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameInner;
        });


        local ContextMenu = {}
        do
            ContextMenu.Options = {}
            ContextMenu.Container = Library:Create('Frame', {
                BorderColor3 = Color3.new(),
                ZIndex = 14,

                Visible = false,
                Parent = ScreenGui
            })

            ContextMenu.Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });

            Library:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });

            Library:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            });

            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset(
                    (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                    DisplayFrame.AbsolutePosition.Y + 1
                )
            end

            local function updateMenuSize()
                local menuWidth = 60
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA('TextLabel') then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(
                    menuWidth + 8,
                    ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                )
            end

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)

            Library:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            function ContextMenu:Show()
                self.Container.Visible = true
            end

            function ContextMenu:Hide()
                self.Container.Visible = false
            end

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end
                end

                local Button = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    TextXAlignment = Enum.TextXAlignment.Left,
                });

                Library:OnHighlight(Button, Button, 
                    { TextColor3 = 'AccentColor' },
                    { TextColor3 = 'FontColor' }
                );

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                        return
                    end

                    Callback()
                end)
            end

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify('Copied color!', 2)
            end)

            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify('You have not copied a color!', 2)
                end
                ColorPicker:SetValueRGB(Library.ColorClipboard)
            end)


            ContextMenu:AddOption('Copy HEX', function()
                pcall(setclipboard, ColorPicker.Value:ToHex())
                Library:Notify('Copied hex code to clipboard!', 2)
            end)

            ContextMenu:AddOption('Copy RGB', function()
                pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
                Library:Notify('Copied RGB values to clipboard!', 2)
            end)

        end

        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
        Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });

        Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
        Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });

        local SequenceTable = {};

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;

        local HueSelectorGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorInner;
        });

        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BackgroundTransparency = ColorPicker.Transparency;
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            });

            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Func(ColorPicker.Value)
        end;

        function ColorPicker:Show()
            for Frame, Val in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;
        end;

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
            Library.OpenedFrames[PickerFrameOuter] = nil;
        end;

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinX = SatVibMap.AbsolutePosition.X;
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                    local MinY = SatVibMap.AbsolutePosition.Y;
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        HueSelectorInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinY = HueSelectorInner.AbsolutePosition.Y;
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        DisplayFrame.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end;
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ContextMenu:Show()
                ColorPicker:Hide()
            end
        end);

        if TransparencyBoxInner then
            TransparencyBoxInner.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local MinX = TransparencyBoxInner.AbsolutePosition.X;
                        local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X;
                        local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

                        ColorPicker:Display();

                        RenderStepped:Wait();
                    end;

                    Library:AttemptSave();
                end;
            end);
        end;

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    ColorPicker:Hide();
                end;

                if not Library:IsMouseOverFrame(ContextMenu.Container) then
                    ContextMenu:Hide()
                end
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                    ContextMenu:Hide()
                end
            end
        end))

        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame

        Options[Idx] = ColorPicker;

        return self;
    end;

    function Funcs:AddKeyPicker(Idx, Info)
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        assert(Info.Default, 'AddKeyPicker: Missing default value.');

        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Mode = Info.Mode or 'Toggle'; -- Always, Toggle, Hold
            Type = 'KeyPicker';
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;

            SyncToggleState = Info.SyncToggleState or false;
        };

        if KeyPicker.SyncToggleState then
            Info.Modes = { 'Toggle' }
            Info.Mode = 'Toggle'
        end

        local PickOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 7;
            Parent = PickOuter;
        });

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = Info.Default;
            TextWrapped = true;
            ZIndex = 8;
            Parent = PickInner;
        });

        local ModeSelectOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
            Size = UDim2.new(0, 60, 0, 45 + 2);
            Visible = false;
            ZIndex = 14;
            Parent = ScreenGui;
        });

        ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
        end);

        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        });

        Library:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        });

        local ContainerLabel = Library:CreateLabel({
            TextXAlignment = Enum.TextXAlignment.Left;
            Size = UDim2.new(1, 0, 0, 18);
            TextSize = 13;
            Visible = false;
            ZIndex = 110;
            Parent = Library.KeybindContainer;
        },  true);

        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
        local ModeButtons = {};

        for Idx, Mode in next, Modes do
            local ModeButton = {};

            local Label = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = Mode;
                ZIndex = 16;
                Parent = ModeSelectInner;
            });

            function ModeButton:Select()
                for _, Button in next, ModeButtons do
                    Button:Deselect();
                end;

                KeyPicker.Mode = Mode;

                Label.TextColor3 = Library.AccentColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

                ModeSelectOuter.Visible = false;
            end;

            function ModeButton:Deselect()
                KeyPicker.Mode = nil;

                Label.TextColor3 = Library.FontColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
            end;

            Label.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    ModeButton:Select();
                    Library:AttemptSave();
                end;
            end);

            if Mode == KeyPicker.Mode then
                ModeButton:Select();
            end;

            ModeButtons[Mode] = ModeButton;
        end;

        function KeyPicker:Update()
            if Info.NoUI then
                return;
            end;

            local State = KeyPicker:GetState();

            ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);

            ContainerLabel.Visible = true;
            ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;

            Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

            local YSize = 0
            local XSize = 0

            for _, Label in next, Library.KeybindContainer:GetChildren() do
                if Label:IsA('TextLabel') and Label.Visible then
                    YSize = YSize + 18;
                    if (Label.TextBounds.X > XSize) then
                        XSize = Label.TextBounds.X
                    end
                end;
            end;

            Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 210), 0, YSize + 23)
        end;

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true;
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Value == 'None' then
                    return false;
                end

                local Key = KeyPicker.Value;

                if Key == 'MB1' or Key == 'MB2' then
                    return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                        or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                else
                    return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                end;
            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode = Data[1], Data[2];
            DisplayLabel.Text = Key;
            KeyPicker.Value = Key;
            ModeButtons[Mode]:Select();
            KeyPicker:Update();
        end;

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback
        end

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback
            Callback(KeyPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        function KeyPicker:DoClick()
            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                ParentObj:SetValue(not ParentObj.Value)
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
        end

        local Picking = false;

        PickOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Picking = true;

                DisplayLabel.Text = '';

                local Break;
                local Text = '';

                task.spawn(function()
                    while (not Break) do
                        if Text == '...' then
                            Text = '';
                        end;

                        Text = Text .. '.';
                        DisplayLabel.Text = Text;

                        wait(0.4);
                    end;
                end);

                wait(0.2);

                local Event;
                Event = InputService.InputBegan:Connect(function(Input)
                    local Key;

                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name;
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = 'MB1';
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2';
                    end;

                    Break = true;
                    Picking = false;

                    DisplayLabel.Text = Key;
                    KeyPicker.Value = Key;

                    Library:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
                    Library:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)

                    Library:AttemptSave();

                    Event:Disconnect();
                end);
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ModeSelectOuter.Visible = true;
            end;
        end);

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Toggle' then
                    local Key = KeyPicker.Value;

                    if Key == 'MB1' or Key == 'MB2' then
                        if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1
                        or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeyPicker.Toggled = not KeyPicker.Toggled
                            KeyPicker:DoClick()
                        end;
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            KeyPicker.Toggled = not KeyPicker.Toggled;
                            KeyPicker:DoClick()
                        end;
                    end;
                end;

                KeyPicker:Update();
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    ModeSelectOuter.Visible = false;
                end;
            end;
        end))

        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if (not Picking) then
                KeyPicker:Update();
            end;
        end))

        KeyPicker:Update();

        Options[Idx] = KeyPicker;

        return self;
    end;

    BaseAddons.__index = Funcs;
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

local BaseGroupbox = {};

do
    local Funcs = {};

    function Funcs:AddBlank(Size)
        local Groupbox = self;
        local Container = Groupbox.Container;

        Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = 1;
            Parent = Container;
        });
    end;

    function Funcs:AddLabel(Text, DoesWrap)
        local Label = {};

        local Groupbox = self;
        local Container = Groupbox.Container;

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = 14;
            Text = Text;
            TextWrapped = DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        if DoesWrap then
            local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TextLabel;
            });
        end

        Label.TextLabel = TextLabel;
        Label.Container = Container;

        function Label:SetText(Text)
            TextLabel.Text = Text

            if DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize();
        end

        if (not DoesWrap) then
            setmetatable(Label, BaseAddons);
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Label;
    end;

    function Funcs:AddButton(...)
        -- TODO: Eventually redo this
        local Button = {};
        local function ProcessButtonParams(Class, Obj, ...)
            local Props = select(1, ...)
            if type(Props) == 'table' then
                Obj.Text = Props.Text
                Obj.Func = Props.Func
                Obj.DoubleClick = Props.DoubleClick
                Obj.Tooltip = Props.Tooltip
            else
                Obj.Text = select(1, ...)
                Obj.Func = select(2, ...)
            end

            assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
        end

        ProcessButtonParams('Button', Button, ...)

        local Groupbox = self;
        local Container = Groupbox.Container;

        local function CreateBaseButton(Button)
            local Outer = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20);
                ZIndex = 5;
            });

            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = Outer;
            });

            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 14;
                Text = Button.Text;
                ZIndex = 6;
                Parent = Inner;
            });

            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = Inner;
            });

            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black';
            });

            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            Library:OnHighlight(Outer, Outer,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            return Outer, Inner, Label
        end

        local function InitEvents(Button)
            local function WaitForEvent(event, timeout, validator)
                local bindable = Instance.new('BindableEvent')
                local connection = event:Once(function(...)

                    if type(validator) == 'function' and validator(...) then
                        bindable:Fire(true)
                    else
                        bindable:Fire(false)
                    end
                end)
                task.delay(timeout, function()
                    connection:disconnect()
                    bindable:Fire(false)
                end)
                return bindable.Event:Wait()
            end

            local function ValidateClick(Input)
                if Library:MouseIsOverOpenedFrame() then
                    return false
                end

                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                    return false
                end

                return true
            end

            Button.Outer.InputBegan:Connect(function(Input)
                if not ValidateClick(Input) then return end
                if Button.Locked then return end

                if Button.DoubleClick then
                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'AccentColor' })

                    Button.Label.TextColor3 = Library.AccentColor
                    Button.Label.Text = 'Are you sure?'
                    Button.Locked = true

                    local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })

                    Button.Label.TextColor3 = Library.FontColor
                    Button.Label.Text = Button.Text
                    task.defer(rawset, Button, 'Locked', false)

                    if clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    return
                end

                Library:SafeCallback(Button.Func);
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container

        InitEvents(Button)

        function Button:AddTooltip(tooltip)
            if type(tooltip) == 'string' then
                Library:AddToolTip(tooltip, self.Outer)
            end
            return self
        end


        function Button:AddButton(...)
            local SubButton = {}

            ProcessButtonParams('SubButton', SubButton, ...)

            self.Outer.Size = UDim2.new(0.5, -2, 0, 20)

            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

            SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
            SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y)
            SubButton.Outer.Parent = self.Outer

            function SubButton:AddTooltip(tooltip)
                if type(tooltip) == 'string' then
                    Library:AddToolTip(tooltip, self.Outer)
                end
                return SubButton
            end

            if type(SubButton.Tooltip) == 'string' then
                SubButton:AddTooltip(SubButton.Tooltip)
            end

            InitEvents(SubButton)
            return SubButton
        end

        if type(Button.Tooltip) == 'string' then
            Button:AddTooltip(Button.Tooltip)
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Button;
    end;

    function Funcs:AddDivider()
        local Groupbox = self;
        local Container = self.Container

        local Divider = {
            Type = 'Divider',
        }

        Groupbox:AddBlank(2);
        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 5);
            ZIndex = 5;
            Parent = Container;
        });

        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DividerOuter;
        });

        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black';
        });

        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Groupbox:AddBlank(9);
        Groupbox:Resize();
    end

    function Funcs:AddInput(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Textbox = {
            Value = Info.Default or '';
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Type = 'Input';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local InputLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        Groupbox:AddBlank(1);

        local TextBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = TextBoxOuter;
        });

        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:OnHighlight(TextBoxOuter, TextBoxOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, TextBoxOuter)
        end

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = TextBoxInner;
        });

        local Container = Library:Create('Frame', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;

            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);

            ZIndex = 7;
            Parent = TextBoxInner;
        })

        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1;

            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),

            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = Info.Placeholder or '';

            Text = Info.Default or '';
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;

            ZIndex = 7;
            Parent = Container;
        });

        Library:ApplyTextStroke(Box);

        function Textbox:SetValue(Text)
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text;
            Box.Text = Text;

            Library:SafeCallback(Textbox.Callback, Textbox.Value);
            Library:SafeCallback(Textbox.Changed, Textbox.Value);
        end;

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if not enter then return end

                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end)
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end);
        end

        -- https://devforum.roblox.com/t/how-to-make-textboxes-follow-current-cursor-position/1368429/6
        -- thank you nicemike40 :)

        local function Update()
            local PADDING = 2
            local reveal = Container.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                -- we aren't focused, or we fit so be normal
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                -- we are focused and don't fit, so adjust position
                local cursor = Box.CursorPosition
                if cursor ~= -1 then
                    -- calculate pixel width of text from start to cursor
                    local subtext = string.sub(Box.Text, 1, cursor-1)
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X

                    -- check if we're inside the box with the cursor
                    local currentCursorPos = Box.Position.X.Offset + width

                    -- adjust if necessary
                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING-width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                    end
                end
            end
        end

        task.spawn(Update)

        Box:GetPropertyChangedSignal('Text'):Connect(Update)
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)

        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor';
        });

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func;
            Func(Textbox.Value);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Options[Idx] = Textbox;

        return Textbox;
    end;

    function Funcs:AddToggle(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';

            Callback = Info.Callback or function(Value) end;
            Addons = {},
            Risky = Info.Risky,
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local ToggleOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 13, 0, 13);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black';
        });

        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ToggleOuter;
        });

        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local ToggleLabel = Library:CreateLabel({
            Size = UDim2.new(0, 216, 1, 0);
            Position = UDim2.new(1, 6, 0, 0);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = ToggleInner;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        });

        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 170, 1, 0);
            ZIndex = 8;
            Parent = ToggleOuter;
        });

        Library:OnHighlight(ToggleRegion, ToggleOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        function Toggle:UpdateColors()
            Toggle:Display();
        end;

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion)
        end

        function Toggle:Display()
            ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
            ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Func(Toggle.Value);
        end;

        function Toggle:SetValue(Bool)
            Bool = (not not Bool);

            Toggle.Value = Bool;
            Toggle:Display();

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool
                    Addon:Update()
                end
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value);
            Library:SafeCallback(Toggle.Changed, Toggle.Value);
            Library:UpdateDependencyBoxes();
        end;

        ToggleRegion.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Toggle:SetValue(not Toggle.Value) -- Why was it not like this from the start?
                Library:AttemptSave();
            end;
        end);

        if Toggle.Risky then
            Library:RemoveFromRegistry(ToggleLabel)
            ToggleLabel.TextColor3 = Library.RiskColor
            Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
        end

        Toggle:Display();
        Groupbox:AddBlank(Info.BlankSize or 5 + 2);
        Groupbox:Resize();

        Toggle.TextLabel = ToggleLabel;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);

        Toggles[Idx] = Toggle;

        Library:UpdateDependencyBoxes();

        return Toggle;
    end;

    function Funcs:AddSlider(Idx, Info)
        assert(Info.Default, 'AddSlider: Missing default value.');
        assert(Info.Text, 'AddSlider: Missing slider text.');
        assert(Info.Min, 'AddSlider: Missing minimum value.');
        assert(Info.Max, 'AddSlider: Missing maximum value.');
        assert(Info.Rounding, 'AddSlider: Missing rounding value.');

        local Slider = {
            Value = Info.Default;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = Info.Rounding;
            MaxSize = 232;
            Type = 'Slider';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end

        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 13);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black';
        });

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = SliderOuter;
        });

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderColor3 = Library.AccentColorDark;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderInner;
        });

        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'AccentColorDark';
        });

        local HideBorderRight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(1, 0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 8;
            Parent = Fill;
        });

        Library:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = 'AccentColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = 'Infinite';
            ZIndex = 9;
            Parent = SliderInner;
        });

        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, SliderOuter)
        end

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
            Fill.BorderColor3 = Library.AccentColorDark;
        end;

        function Slider:Display()
            local Suffix = Info.Suffix or '';

            if Info.Compact then
                DisplayLabel.Text = Info.Text .. ': ' .. Slider.Value .. Suffix
            elseif Info.HideMax then
                DisplayLabel.Text = string.format('%s', Slider.Value .. Suffix)
            else
                DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix);
            end

            local X = math.ceil(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
            Fill.Size = UDim2.new(0, X, 1, 0);

            HideBorderRight.Visible = not (X == Slider.MaxSize or X == 0);
        end;

        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Func(Slider.Value);
        end;

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value);
            end;


            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
        end;

        function Slider:GetValueFromXOffset(X)
            return Round(Library:MapValue(X, 0, Slider.MaxSize, Slider.Min, Slider.Max));
        end;

        function Slider:SetValue(Str)
            local Num = tonumber(Str);

            if (not Num) then
                return;
            end;

            Num = math.clamp(Num, Slider.Min, Slider.Max);

            Slider.Value = Num;
            Slider:Display();

            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
        end;

        SliderInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                local mPos = Mouse.X;
                local gPos = Fill.Size.X.Offset;
                local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local nMPos = Mouse.X;
                    local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize);

                    local nValue = Slider:GetValueFromXOffset(nX);
                    local OldValue = Slider.Value;
                    Slider.Value = nValue;

                    Slider:Display();

                    if nValue ~= OldValue then
                        Library:SafeCallback(Slider.Callback, Slider.Value);
                        Library:SafeCallback(Slider.Changed, Slider.Value);
                    end;

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        Slider:Display();
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();

        Options[Idx] = Slider;

        return Slider;
    end;

    function Funcs:AddDropdown(Idx, Info)
        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString();
            Info.AllowNull = true;
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString();
            Info.AllowNull = true;
        end;

        assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
        assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

        if (not Info.Text) then
            Info.Compact = true;
        end;

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType; -- can be either 'Player' or 'Team'
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local RelativeOffset = 0;

        if not Info.Compact then
            local DropdownLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA('UIListLayout') then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
            end;
        end;

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(DropdownOuter, {
            BorderColor3 = 'Black';
        });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        });

        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = DropdownInner;
        });

        local DropdownArrow = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -16, 0.5, 0);
            Size = UDim2.new(0, 12, 0, 12);
            Image = 'http://www.roblox.com/asset/?id=6282522798';
            ZIndex = 8;
            Parent = DropdownInner;
        });

        local ItemList = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            TextSize = 14;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 7;
            Parent = DropdownInner;
        });

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter)
        end

        local MAX_DROPDOWN_ITEMS = 8;

        local ListOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });

        local function RecalculateListPosition()
            ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1);
        end;

        local function RecalculateListSize(YSize)
            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, YSize or (MAX_DROPDOWN_ITEMS * 20 + 2))
        end;

        RecalculateListPosition();
        RecalculateListSize();

        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
        });

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListInner;

            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.AccentColor,
        });

        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor'
        })

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        function Dropdown:Display()
            local Values = Dropdown.Values;
            local Str = '';

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', ';
                    end;
                end;

                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value or '';
            end;

            ItemList.Text = (Str == '' and '--' or Str);
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value);
                end;

                return T;
            else
                return Dropdown.Value and 1 or 0;
            end;
        end;

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values;
            local Buttons = {};

            for _, Element in next, Scrolling:GetChildren() do
                if not Element:IsA('UIListLayout') then
                    Element:Destroy();
                end;
            end;

            local Count = 0;

            for Idx, Value in next, Values do
                local Table = {};

                Count = Count + 1;

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Middle;
                    Size = UDim2.new(1, -1, 0, 20);
                    ZIndex = 23;
                    Active = true,
                    Parent = Scrolling;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                    BorderColor3 = 'OutlineColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, -6, 1, 0);
                    Position = UDim2.new(0, 6, 0, 0);
                    TextSize = 14;
                    Text = Value;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 25;
                    Parent = Button;
                });

                Library:OnHighlight(Button, Button,
                    { BorderColor3 = 'AccentColor', ZIndex = 24 },
                    { BorderColor3 = 'OutlineColor', ZIndex = 23 }
                );

                local Selected;

                if Info.Multi then
                    Selected = Dropdown.Value[Value];
                else
                    Selected = Dropdown.Value == Value;
                end;

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value];
                    else
                        Selected = Dropdown.Value == Value;
                    end;

                    ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';
                end;

                ButtonLabel.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local Try = not Selected;

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value[Value] = true;
                                else
                                    Dropdown.Value[Value] = nil;
                                end;
                            else
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value = Value;
                                else
                                    Dropdown.Value = nil;
                                end;

                                for _, OtherButton in next, Buttons do
                                    OtherButton:UpdateButton();
                                end;
                            end;

                            Table:UpdateButton();
                            Dropdown:Display();

                            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);

                            Library:AttemptSave();
                        end;
                    end;
                end);

                Table:UpdateButton();
                Dropdown:Display();

                Buttons[Button] = Table;
            end;

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1);

            local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1;
            RecalculateListSize(Y);
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then
                Dropdown.Values = NewValues;
            end;

            Dropdown:BuildDropdownList();
        end;

        function Dropdown:OpenDropdown()
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;
            DropdownArrow.Rotation = 180;
        end;

        function Dropdown:CloseDropdown()
            ListOuter.Visible = false;
            Library.OpenedFrames[ListOuter] = nil;
            DropdownArrow.Rotation = 0;
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func(Dropdown.Value);
        end;

        function Dropdown:SetValue(Val)
            if Dropdown.Multi then
                local nTable = {};

                for Value, Bool in next, Val do
                    if table.find(Dropdown.Values, Value) then
                        nTable[Value] = true
                    end;
                end;

                Dropdown.Value = nTable;
            else
                if (not Val) then
                    Dropdown.Value = nil;
                elseif table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val;
                end;
            end;

            Dropdown:BuildDropdownList();

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
        end;

        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown();
                else
                    Dropdown:OpenDropdown();
                end;
            end;
        end);

        InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    Dropdown:CloseDropdown();
                end;
            end;
        end);

        Dropdown:BuildDropdownList();
        Dropdown:Display();

        local Defaults = {}

        if type(Info.Default) == 'string' then
            local Idx = table.find(Dropdown.Values, Info.Default)
            if Idx then
                table.insert(Defaults, Idx)
            end
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Idx = table.find(Dropdown.Values, Value)
                if Idx then
                    table.insert(Defaults, Idx)
                end
            end
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end

        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true
                else
                    Dropdown.Value = Dropdown.Values[Index];
                end

                if (not Info.Multi) then break end
            end

            Dropdown:BuildDropdownList();
            Dropdown:Display();
        end

        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        Options[Idx] = Dropdown;

        return Dropdown;
    end;

    function Funcs:AddDependencyBox()
        local Depbox = {
            Dependencies = {};
        };
        
        local Groupbox = self;
        local Container = Groupbox.Container;

        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, 0);
            Visible = false;
            Parent = Container;
        });

        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Visible = true;
            Parent = Holder;
        });

        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Frame;
        });

        function Depbox:Resize()
            Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y);
            Groupbox:Resize();
        end;

        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Depbox:Resize();
        end);

        Holder:GetPropertyChangedSignal('Visible'):Connect(function()
            Depbox:Resize();
        end);

        function Depbox:Update()
            for _, Dependency in next, Depbox.Dependencies do
                local Elem = Dependency[1];
                local Value = Dependency[2];

                if Elem.Type == 'Toggle' and Elem.Value ~= Value then
                    Holder.Visible = false;
                    Depbox:Resize();
                    return;
                end;
            end;

            Holder.Visible = true;
            Depbox:Resize();
        end;

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in next, Dependencies do
                assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
                assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
                assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');
            end;

            Depbox.Dependencies = Dependencies;
            Depbox:Update();
        end;

        Depbox.Container = Frame;

        setmetatable(Depbox, BaseGroupbox);

        table.insert(Library.DependencyBoxes, Depbox);

        return Depbox;
    end;

    BaseGroupbox.__index = Funcs;
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

-- < Create other UI elements >
do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 100;
        Parent = ScreenGui;
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.NotificationArea;
    });

    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, -25);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    });

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });

    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor';
    });

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    });

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });

    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    });

    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = WatermarkLabel;
    Library:MakeDraggable(Library.Watermark);



    local KeybindOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0.5);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 10, 0.5, 0);
        Size = UDim2.new(0, 210, 0, 20);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui;
    });

    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = KeybindOuter;
    });

    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local ColorFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 102;
        Parent = KeybindInner;
    });

    Library:AddToRegistry(ColorFrame, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    local KeybindLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 20);
        Position = UDim2.fromOffset(5, 2),
        TextXAlignment = Enum.TextXAlignment.Left,

        Text = 'Keybinds';
        ZIndex = 104;
        Parent = KeybindInner;
    });

    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, -20);
        Position = UDim2.new(0, 0, 0, 20);
        ZIndex = 1;
        Parent = KeybindInner;
    });

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    });

    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    })

    Library.KeybindFrame = KeybindOuter;
    Library.KeybindContainer = KeybindContainer;
    Library:MakeDraggable(KeybindOuter);
end;

function Library:SetWatermarkVisibility(Bool)
    Library.Watermark.Visible = Bool;
end;

function Library:SetWatermark(Text)
    local X, Y = Library:GetTextBounds(Text, Library.Font, 14);
    Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3);
    Library:SetWatermarkVisibility(true)

    Library.WatermarkText.Text = Text;
end;

function Library:Notify(Text, Time)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14);

    YSize = YSize + 7

    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, 0, 0, YSize);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });

    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 102;
        Parent = NotifyInner;
    });

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });

    local NotifyLabel = Library:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14;
        ZIndex = 103;
        Parent = InnerFrame;
    });

    local LeftColor = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, -1, 0, -1);
        Size = UDim2.new(0, 3, 1, 2);
        ZIndex = 104;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(LeftColor, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true);

    task.spawn(function()
        wait(Time or 5);

        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);

        wait(0.4);

        NotifyOuter:Destroy();
    end);
end;

function Library:CreateWindow(...)
    local Arguments = { ... }
    local Config = { AnchorPoint = Vector2.zero }

    if type(...) == 'table' then
        Config = ...;
    else
        Config.Title = Arguments[1]
        Config.AutoShow = Arguments[2] or false;
    end

    if type(Config.Title) ~= 'string' then Config.Title = 'No title' end
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 0 end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end

    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 600) end

    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end

    local Window = {
        Tabs = {};
    };

    local Outer = Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = Config.Position,
        Size = Config.Size,
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
    });

    Library:MakeDraggable(Outer, 25);

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 1;
        Parent = Outer;
    });

    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    });

    local WindowLabel = Library:CreateLabel({
        Position = UDim2.new(0, 7, 0, 0);
        Size = UDim2.new(0, 0, 0, 25);
        Text = Config.Title or '';
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 1;
        Parent = Inner;
    });

    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 25);
        Size = UDim2.new(1, -16, 1, -33);
        ZIndex = 1;
        Parent = Inner;
    });

    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = MainSectionOuter;
    });

    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor';
    });

    local TabArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 8, 0, 8);
        Size = UDim2.new(1, -16, 0, 21);
        ZIndex = 1;
        Parent = MainSectionInner;
    });

    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, Config.TabPadding);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabArea;
    });

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 30);
        Size = UDim2.new(1, -16, 1, -38);
        ZIndex = 2;
        Parent = MainSectionInner;
    });
    

    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    function Window:SetWindowTitle(Title)
        WindowLabel.Text = Title;
    end;

    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
        };

        local TabButtonWidth = Library:GetTextBounds(Name, Library.Font, 16);

        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0);
            ZIndex = 1;
            Parent = TabArea;
        });

        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, -1);
            Text = Name;
            ZIndex = 1;
            Parent = TabButton;
        });

        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, 0);
            Size = UDim2.new(1, 0, 0, 1);
            BackgroundTransparency = 1;
            ZIndex = 3;
            Parent = TabButton;
        });

        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor';
        });

        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 2;
            Parent = TabContainer;
        });

        local LeftSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 8 - 1, 0, 8 - 1);
            Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });

        local RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 4 + 1, 0, 8 - 1);
            Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        });

        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
            end);
        end;

        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do
                Tab:HideTab();
            end;

            Blocker.BackgroundTransparency = 0;
            TabButton.BackgroundColor3 = Library.MainColor;
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            TabFrame.Visible = true;
        end;

        function Tab:HideTab()
            Blocker.BackgroundTransparency = 1;
            TabButton.BackgroundColor3 = Library.BackgroundColor;
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
            TabFrame.Visible = false;
        end;

        function Tab:SetLayoutOrder(Position)
            TabButton.LayoutOrder = Position;
            TabListLayout:ApplyLayout();
        end;

        function Tab:AddGroupbox(Info)
            local Groupbox = {};

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 507 + 2);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                -- BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 5;
                Parent = BoxInner;
            });

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });

            local GroupboxLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18);
                Position = UDim2.new(0, 4, 0, 2);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = BoxInner;
            });

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 4, 0, 20);
                Size = UDim2.new(1, -4, 1, -20);
                ZIndex = 1;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            });

            function Groupbox:Resize()
                local Size = 0;

                for _, Element in next, Groupbox.Container:GetChildren() do
                    if (not Element:IsA('UIListLayout')) and Element.Visible then
                        Size = Size + Element.Size.Y.Offset;
                    end;
                end;

                BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
            end;

            Groupbox.Container = Container;
            setmetatable(Groupbox, BaseGroupbox);

            Groupbox:AddBlank(3);
            Groupbox:Resize();

            Tab.Groupboxes[Info.Name] = Groupbox;

            return Groupbox;
        end;

        function Tab:AddLeftGroupbox(Name)
            return Tab:AddGroupbox({ Side = 1; Name = Name; });
        end;

        function Tab:AddRightGroupbox(Name)
            return Tab:AddGroupbox({ Side = 2; Name = Name; });
        end;

        function Tab:AddTabbox(Info)
            local Tabbox = {
                Tabs = {};
            };

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                -- BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 10;
                Parent = BoxInner;
            });

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });

            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 1);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 5;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabboxButtons;
            });

            function Tabbox:AddTab(Name)
                local Tab = {};

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = 14;
                    Text = Name;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    ZIndex = 7;
                    Parent = Button;
                });

                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 1);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });

                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor';
                });

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 4, 0, 20);
                    Size = UDim2.new(1, -4, 1, -20);
                    ZIndex = 1;
                    Visible = false;
                    Parent = BoxInner;
                });

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                });

                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide();
                    end;

                    Container.Visible = true;
                    Block.Visible = true;

                    Button.BackgroundColor3 = Library.BackgroundColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

                    Tab:Resize();
                end;

                function Tab:Hide()
                    Container.Visible = false;
                    Block.Visible = false;

                    Button.BackgroundColor3 = Library.MainColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                end;

                function Tab:Resize()
                    local TabCount = 0;

                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount + 1;
                    end;

                    for _, Button in next, TabboxButtons:GetChildren() do
                        if not Button:IsA('UIListLayout') then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                        end;
                    end;

                    if (not Container.Visible) then
                        return;
                    end;

                    local Size = 0;

                    for _, Element in next, Tab.Container:GetChildren() do
                        if (not Element:IsA('UIListLayout')) and Element.Visible then
                            Size = Size + Element.Size.Y.Offset;
                        end;
                    end;

                    BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
                end;

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                        Tab:Show();
                        Tab:Resize();
                    end;
                end);

                Tab.Container = Container;
                Tabbox.Tabs[Name] = Tab;

                setmetatable(Tab, BaseGroupbox);

                Tab:AddBlank(3);
                Tab:Resize();

                -- Show first tab (number is 2 cus of the UIListLayout that also sits in that instance)
                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show();
                end;

                return Tab;
            end;

            Tab.Tabboxes[Info.Name or ''] = Tabbox;

            return Tabbox;
        end;

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 1; });
        end;

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 2; });
        end;

        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Tab:ShowTab();
            end;
        end);

        -- This was the first tab added, so we show it by default.
        if #TabContainer:GetChildren() == 1 then
            Tab:ShowTab();
        end;

        Window.Tabs[Name] = Tab;
        return Tab;
    end;

    local ModalElement = Library:Create('TextButton', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 0);
        Visible = true;
        Text = '';
        Modal = false;
        Parent = ScreenGui;
    });

    local TransparencyCache = {};
    local Toggled = false;
    local Fading = false;

    function Library:Toggle()
        if Fading then
            return;
        end;

        local FadeTime = Config.MenuFadeTime;
        Fading = true;
        Toggled = (not Toggled);
        ModalElement.Modal = Toggled;

        if Toggled then
            -- A bit scuffed, but if we're going from not toggled -> toggled we want to show the frame immediately so that the fade is visible.
            Outer.Visible = true;

            task.spawn(function()
                -- TODO: add cursor fade?
                local State = InputService.MouseIconEnabled;

                local Cursor = Drawing.new('Triangle');
                Cursor.Thickness = 1;
                Cursor.Filled = true;
                Cursor.Visible = true;

                local CursorOutline = Drawing.new('Triangle');
                CursorOutline.Thickness = 1;
                CursorOutline.Filled = false;
                CursorOutline.Color = Color3.new(0, 0, 0);
                CursorOutline.Visible = true;

                while Toggled and ScreenGui.Parent do
                    InputService.MouseIconEnabled = false;

                    local mPos = InputService:GetMouseLocation();

                    Cursor.Color = Library.AccentColor;

                    Cursor.PointA = Vector2.new(mPos.X, mPos.Y);
                    Cursor.PointB = Vector2.new(mPos.X + 16, mPos.Y + 6);
                    Cursor.PointC = Vector2.new(mPos.X + 6, mPos.Y + 16);

                    CursorOutline.PointA = Cursor.PointA;
                    CursorOutline.PointB = Cursor.PointB;
                    CursorOutline.PointC = Cursor.PointC;

                    RenderStepped:Wait();
                end;

                InputService.MouseIconEnabled = State;

                Cursor:Remove();
                CursorOutline:Remove();
            end);
        end;

        for _, Desc in next, Outer:GetDescendants() do
            local Properties = {};

            if Desc:IsA('ImageLabel') then
                table.insert(Properties, 'ImageTransparency');
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
                table.insert(Properties, 'TextTransparency');
            elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('UIStroke') then
                table.insert(Properties, 'Transparency');
            end;

            local Cache = TransparencyCache[Desc];

            if (not Cache) then
                Cache = {};
                TransparencyCache[Desc] = Cache;
            end;

            for _, Prop in next, Properties do
                if not Cache[Prop] then
                    Cache[Prop] = Desc[Prop];
                end;

                if Cache[Prop] == 1 then
                    continue;
                end;

                TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { [Prop] = Toggled and Cache[Prop] or 1 }):Play();
            end;
        end;

        task.wait(FadeTime);

        Outer.Visible = Toggled;

        Fading = false;
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end
        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(Library.Toggle)
        end
    end))

    if Config.AutoShow then task.spawn(Library.Toggle) end

    Window.Holder = Outer;

    return Window;
end;

local function OnPlayerChange()
    local PlayerList = GetPlayersString();

    for _, Value in next, Options do
        if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(PlayerList);
        end;
    end;
end;

Players.PlayerAdded:Connect(OnPlayerChange);
Players.PlayerRemoving:Connect(OnPlayerChange);

getgenv().Library = Library
return Library
]====]

local THEME_SRC = [====[

local httpService = game:GetService('HttpService')
local ThemeManager = {} do
	ThemeManager.Folder = 'LinoriaLibSettings'
	-- if not isfolder(ThemeManager.Folder) then makefolder(ThemeManager.Folder) end

	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		['Default'] 		= { 1, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}') },
		['BBot'] 			= { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
		['Fatality']		= { 3, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
		['Jester'] 			= { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Mint'] 			= { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Tokyo Night'] 	= { 6, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
		['Ubuntu'] 			= { 7, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
		['Quartz'] 			= { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
	}

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		-- custom themes are just regular dictionaries instead of an array with { index, dictionary }

		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			self.Library[idx] = Color3.fromHex(col)
			
			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		-- This allows us to force apply themes without loading the themes tab :)
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, options do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()		
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
		 	theme = self.DefaultTheme
		end

		if isDefault then
			Options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

		groupbox:AddButton('Set as default', function()
			self:SaveDefault(Options.ThemeManager_ThemeList.Value)
			self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
		end)

		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddDivider()
		
		groupbox:AddButton('Save theme', function() 
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)

			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end):AddButton('Load theme', function() 
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value) 
		end)

		groupbox:AddButton('Refresh list', function()
			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddButton('Set as default', function()
			if Options.ThemeManager_CustomThemeList.Value ~= nil and Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_CustomThemeList.Value))
			end
		end)

		ThemeManager:LoadDefault()

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.MainColor:OnChanged(UpdateTheme)
		Options.AccentColor:OnChanged(UpdateTheme)
		Options.OutlineColor:OnChanged(UpdateTheme)
		Options.FontColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)
		
		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

		for _, field in next, fields do
			theme[field] = Options[field].Value:ToHex()
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				-- i hate this but it has to be done ...

				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		-- build the entire tree if a path is like some-hub/phantom-forces
		-- makefolder builds the entire tree on Synapse X but not other exploits

		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

return ThemeManager
]====]

local SAVE_SRC = [====[

local httpService = game:GetService('HttpService')

local SaveManager = {} do
	SaveManager.Folder = 'LinoriaLibSettings'
	SaveManager.Ignore = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if Toggles[idx] then 
					Toggles[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] and type(data.text) == 'string' then
					Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function SaveManager:Save(name)
		if (not name) then
			return false, 'no config file is selected'
		end

		local fullPath = self.Folder .. '/settings/' .. name .. '.json'

		local data = {
			objects = {}
		}

		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		if (not name) then
			return false, 'no config file is selected'
		end
		
		local file = self.Folder .. '/settings/' .. name .. '.json'
		if not isfile(file) then return false, 'invalid file' end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, 'decode error' end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(function() self.Parser[option.type].Load(option.idx, option) end) -- task.spawn() so the config loading wont get stuck.
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", -- themes
			"ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', -- themes
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. '/settings')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				-- i hate this but it has to be done ...

				local pos = file:find('.json', 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end
		
		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load autoload config: ' .. err)
			end

			self.Library:Notify(string.format('Auto loaded config %q', name))
		end
	end


	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')

		local section = tab:AddRightGroupbox('Configuration')

		section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })
		section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true })

		section:AddDivider()

		section:AddButton('Create config', function()
			local name = Options.SaveManager_ConfigName.Value

			if name:gsub(' ', '') == '' then 
				return self.Library:Notify('Invalid config name (empty)', 2)
			end

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to save config: ' .. err)
			end

			self.Library:Notify(string.format('Created config %q', name))

			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end):AddButton('Load config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load config: ' .. err)
			end

			self.Library:Notify(string.format('Loaded config %q', name))
		end)

		section:AddButton('Overwrite config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to overwrite config: ' .. err)
			end

			self.Library:Notify(string.format('Overwrote config %q', name))
		end)

		section:AddButton('Refresh list', function()
			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end)

		section:AddButton('Set as autoload', function()
			local name = Options.SaveManager_ConfigList.Value
			writefile(self.Folder .. '/settings/autoload.txt', name)
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
			self.Library:Notify(string.format('Set %q to auto load', name))
		end)

		SaveManager.AutoloadLabel = section:AddLabel('Current autoload config: none', true)

		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
		end

		SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
	end

	SaveManager:BuildFolderTree()
end

return SaveManager

]====]

local Library      = assert(loadstring(LIBRARY_SRC))()
local ThemeManager = assert(loadstring(THEME_SRC))()
local SaveManager  = assert(loadstring(SAVE_SRC))()
print('[VoidSpam] LinoriaLib loaded (embedded)')

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  WINDOW SIZE
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local vp    = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local WIN_W = isMobile and math.floor(vp.X * 0.60) or 660
local WIN_H = isMobile and math.floor(vp.Y * 0.50) or 620
local WIN_X = math.floor((vp.X - WIN_W) * 0.5)
local WIN_Y = math.floor((vp.Y - WIN_H) * 0.5)

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  CREATE WINDOW
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Window = Library:CreateWindow({
    Title        = 'Void Spam  â€”  v10',
    AutoShow     = true,
    Center       = false,
    Position     = UDim2.fromOffset(WIN_X, WIN_Y),
    Size         = UDim2.fromOffset(WIN_W, WIN_H),
    TabPadding   = 8,
    MenuFadeTime = 0.2,
})

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  TABS
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Tabs = {
    ESP      = Window:AddTab('ESP'),
    Aimbot   = Window:AddTab('Aimbot'),
    Ragebot  = Window:AddTab('Ragebot'),
    Weapon   = Window:AddTab('Weapon'),
    Visuals  = Window:AddTab('Visuals'),
    Movement = Window:AddTab('Movement'),
    Settings = Window:AddTab('Settings'),
}

-- =====================================================
--  RIVALS CORE  (ported from Aetherea)
--  Combat state + module infra for Silent Aim /
--  Triggerbot / Targeting / Rage Bot / Anti Aim /
--  Weapon Mods.  UI lives on the Aimbot / Ragebot tabs.
-- =====================================================

local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")

local LPH_NO_VIRTUALIZE = nil
if type(getgenv) == 'function' then LPH_NO_VIRTUALIZE = getgenv().LPH_NO_VIRTUALIZE end
if type(LPH_NO_VIRTUALIZE) ~= 'function' then LPH_NO_VIRTUALIZE = function(f) return f end end
local LPH_JIT_MAX = nil
if type(getgenv) == 'function' then LPH_JIT_MAX = getgenv().LPH_JIT_MAX end
if type(LPH_JIT_MAX) ~= 'function' then LPH_JIT_MAX = function(f) return f end end

local LocalChar = player.Character
player.CharacterAdded:Connect(function(char)
    LocalChar = char
    pcall(function() char:WaitForChild("Humanoid", 5) end)
    pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
end)

local kTargetList    = { "FOV", "Visible" }
local kCheckScoped   = { "None", "Sniper", "Crossbow" }
local kGunIgnoreList = { "None", "Katana", "Riot Shield" }
local kBodyParts = {
    "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso",
    "LeftFoot", "LeftLowerLeg", "LeftUpperLeg",
    "RightFoot", "RightLowerLeg", "RightUpperLeg",
    "LeftHand", "LeftLowerArm", "LeftUpperArm",
    "RightHand", "RightLowerArm", "RightUpperArm",
}
local kPitchOptions = { "None", "Offset", "Custom", "Random", "Look Up", "Look Down" }
local kYawOptions   = { "None", "Offset", "Custom", "Random", "Spin", "Jitter", "Backwards" }

local states = {
    target = nil,
    target_part = nil,
    server_cf = nil,
    is_reloading = false,
    screen_gui = Instance.new("ScreenGui"),
    targeting_state = {
        target_group = "Visible",
        ignore = { "None" },
        radius = 100,
        max_distance = 150,
        weight_ratio = 0.7,
        reaction_time = 0,
        forget_time = 1,
        target = "Closest Part",
        include_parts = { "Head", "UpperTorso" },

        wallcheck = true,
        show_fov = false,

        fov_outline = false,
        fov_fill = false,
        fov_lerp = 1,

        fov_rotation = 0,
        fov_rotation_speed = 1,

        fov_start_color = Color3.fromRGB(255, 255, 255),
        fov_mid_color = Color3.fromRGB(255, 255, 255),
        fov_end_color = Color3.fromRGB(255, 255, 255),

        fov_outline_start_color = Color3.fromRGB(0, 0, 0),
        fov_outline_mid_color = Color3.fromRGB(0, 0, 0),
        fov_outline_end_color = Color3.fromRGB(0, 0, 0),

        fov_transparency = 0,
        fov_outline_transparency = 0,

        fov_position = { ["None"] = true },

        blocking = {},
    },
    legit_state = {
        silent_aim = {
            enabled = false,
            hit_chance = 100,
            manipulation = false,
            visualize = false,
        },
        triggerbot = {
            enabled = false,
            shoot_delay = 0,
            check_scoped = { "Sniper", "Crossbow" },

            triggerbot_shot_started = Instance.new("BindableEvent"),
            triggerbot_shot_finished = Instance.new("BindableEvent"),
            triggerbot_active = false,
        }
    },
    rage_state = {
        weapons = {
            no_recoil = false,
            no_spread = false,
            full_auto = false,
            firerate = 100,
        },
        pluggwalk = {
            enabled = false,
        },
        rage_bot = {
            enabled = false,
            void_spam = false,
            hide = 0.25,
            attack = 0.1,
            shoot_attempts = 1,
            attack_mode = "Gun",
            preferred = "Primary",
            hit_notifications = true,
            rage_hud = true,

            sync_void_state = Instance.new("BindableEvent"),
        },
        anti_aim = {
            enabled = false,
            pitch = "None",
            pitch_angle = 0,
            yaw = "None",
            yaw_angle = 0,
            jitter_angle = 20,
            speed = 10,
            underground = false,
        },
    },
    visuals_state = {
        colors = {
            trail_color = Color3.fromRGB(255, 0, 255),
        },
    },
}

-- Minimal ESP interface shim.  The full Aetherea Sense isn't ported,
-- so the target highlight is a no-op and the manipulation visualizer
-- simply parents a neon part into the workspace.
local EspInterface = {
    GlobalChamRenderer = { Viewport = Workspace },
    SetTarget = function() end,
}

local function SetSilentAimEnabled(state)
    if state == states.legit_state.silent_aim.enabled then return end
    states.legit_state.silent_aim.enabled = state
end

local function SetTriggerbotEnabled(state)
    if state == states.legit_state.triggerbot.enabled then return end
    states.legit_state.triggerbot.enabled = state
end

local function SetRageBotEnabled(state)
    if state == states.rage_state.rage_bot.enabled then return end
    states.rage_state.rage_bot.enabled = state
    states.rage_state.rage_bot.sync_void_state:Fire()
end

local function SetVoidSpamEnabled(state)
    if state == states.rage_state.rage_bot.void_spam then return end
    states.rage_state.rage_bot.void_spam = state
    states.rage_state.rage_bot.sync_void_state:Fire()
end

local function SetAntiAimEnabled(state)
    if state == states.rage_state.anti_aim.enabled then return end
    states.rage_state.anti_aim.enabled = state
end

local function multiToList(tbl)
    local out = {}
    for k, v in pairs(tbl or {}) do
        if v then table.insert(out, k) end
    end
    return out
end

pcall(function()
    states.screen_gui.Name = ""
    states.screen_gui.DisplayOrder = 999
    states.screen_gui.ResetOnSpawn = false
    states.screen_gui.IgnoreGuiInset = true
    if gethui and type(gethui) == 'function' then
        states.screen_gui.Parent = gethui()
    else
        states.screen_gui.Parent = playerGui
    end
end)

--  RIVALS module hooks + combat loops  (installed once modules are ready)
task.spawn(function()
    warn('[VoidSpam:CHECK] C rivals spawn start')
    local modules = {}

    local function requireMod(path)
        local ok, res = pcall(function() return require(path) end)
        return ok and res or nil
    end

    local rs_modules = ReplicatedStorage:FindFirstChild("Modules")
    local ps         = player:FindFirstChild("PlayerScripts")
    local psm        = ps and ps:FindFirstChild("Modules")
    local psc        = ps and ps:FindFirstChild("Controllers")

    if rs_modules and psm and psc then
        modules.Utility             = requireMod(rs_modules:WaitForChild("Utility"))
        modules.OutOfBoundsMachine  = requireMod(rs_modules:WaitForChild("OutOfBoundsMachine"))
        modules.GameplayUtility     = requireMod(rs_modules:WaitForChild("GameplayUtility"))

        modules.Gun                 = requireMod(psm.ItemTypes:WaitForChild("Gun"))
        modules.Melee               = requireMod(psm.ItemTypes:WaitForChild("Melee"))
        modules.Knife               = requireMod(psm.Items:WaitForChild("Knife"))

        modules.CameraController    = requireMod(psc:WaitForChild("CameraController"))
        modules.MechanicsController = requireMod(psc:WaitForChild("MechanicsController"))
        modules.FighterController   = requireMod(psc:WaitForChild("FighterController"))

        local crep = psm:FindFirstChild("ClientReplicatedClasses")
        if crep then
            modules.ClientEntity = requireMod(crep:FindFirstChild("ClientEntity"))
        end
    end

    local ready = 0
    while (not modules.FighterController or not modules.Gun or not modules.Utility or not modules.MechanicsController) do
        ready = ready + 1
        if ready > 200 then break end
        task.wait(0.5)
    end
    warn('[VoidSpam:CHECK] D modules loaded')
    if not modules.FighterController or not modules.Gun or not modules.Utility or not modules.MechanicsController then
        warn('[VoidSpam] RIVALS combat modules unavailable - combat features disabled.')
        return
    end

    -- Camera freeze (used by manipulation / throwables)
    local frozen = false
    local org_cam = modules.CameraController.Update
    modules.CameraController.Update = LPH_NO_VIRTUALIZE(function(self, ...)
        if frozen then return end
        return org_cam(self, ...)
    end)

    local function FreezeCamera() frozen = true end
    local function UnfreezeCamera() frozen = false end

    -- Reload tracker
    local orig_startrl = modules.Gun.StartReloading
    modules.Gun.StartReloading = LPH_NO_VIRTUALIZE(function(u21, p22, p23, p24, p25)
        states.is_reloading = true
        task.delay((u21.Info and u21.Info.ReloadLength or 1.5) + 0.1, function()
            states.is_reloading = false
        end)
        return orig_startrl(u21, p22, p23, p24, p25)
    end)

    -- Server CF sync / desync (void spam + manipulation)
    local server_cf_sync = true

    pcall(LPH_JIT_MAX(function()
        local real
        local real_lin_vel
        local real_ang_vel

        RunService:BindToRenderStep(tostring(math.random(100000, 999999)), 0, LPH_NO_VIRTUALIZE(function()
            if server_cf_sync then return end
            local root = LocalChar and LocalChar.PrimaryPart
            if not root or not root.Parent or not real then return end
            root.AssemblyLinearVelocity = real_lin_vel or Vector3.zero
            root.AssemblyAngularVelocity = real_ang_vel or Vector3.zero
            root.CFrame = real
        end))

        RunService.PostSimulation:Connect(LPH_NO_VIRTUALIZE(function()
            local root = LocalChar and LocalChar.PrimaryPart
            if not root or not root.Parent then return end
            real = root.CFrame
            real_lin_vel = root.AssemblyLinearVelocity
            real_ang_vel = root.AssemblyAngularVelocity
            if server_cf_sync then
                states.server_cf = real
                return
            end
            root.CFrame = states.server_cf
        end))
    end))

    local function ServerCFDesync() server_cf_sync = false end
    local function ServerCFSync() server_cf_sync = true end

    -- OOB exploit (keeps void spam from triggering the out-of-bounds kill).
    -- Targeted hook on just the OOB remote's FireServer - avoids hooking the
    -- shared Instance __namecall metatable (which would route every method
    -- call in the whole game through Lua and can hang weaker executors).
    local oob_remote = nil
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local repl = remotes:FindFirstChild("Replication")
            if repl then
                local fighter = repl:FindFirstChild("Fighter")
                if fighter then
                    oob_remote = fighter:FindFirstChild("OutOfBounds")
                end
            end
        end
    end)
    local oob_original = nil
    if oob_remote then
        pcall(function()
            oob_original = hookfunction(oob_remote.FireServer, LPH_NO_VIRTUALIZE(function(self, ...)
                return nil
            end))
        end)
    end

    pcall(function()
        modules.OutOfBoundsMachine.IsOutOfBounds = function() return false end
        modules.OutOfBoundsMachine.Update = LPH_NO_VIRTUALIZE(function() return end)
        modules.GameplayUtility.GetOOBWarnDelay = function() return 9999 end
        modules.GameplayUtility.GetOOBKillDelay = function() return 9999 end
        modules.GameplayUtility.IsWithinOOBPart = function() return end
    end)
    warn('[VoidSpam:CHECK] E hooks installed')

    -- Muzzle / screen helpers
    local GetMuzzlePos = LPH_JIT_MAX(function()
        local vms = Workspace:FindFirstChild("ViewModels")
        if not vms then return nil end
        local first_person = vms:FindFirstChild("FirstPerson")
        if not first_person then return nil end
        local player_name = player.Name
        for _, model in pairs(first_person:GetChildren()) do
            if not model:IsA("Model") or not model.Name:find("^" .. player_name) then continue end
            local item_visual = model:FindFirstChild("ItemVisual")
            if not item_visual then continue end
            local body = item_visual:FindFirstChild("Body")
            if not body then continue end
            local body_primary = body:FindFirstChild("BodyPrimary")
            if not body_primary then continue end
            local muzzle = body_primary:FindFirstChild("_muzzle")
            if muzzle and muzzle:IsA("Attachment") then return muzzle.WorldPosition end
        end
        return nil
    end)

    local WorldToScreen = LPH_NO_VIRTUALIZE(function(world_position)
        local screen_point, on_screen = Workspace.CurrentCamera:WorldToViewportPoint(world_position)
        return Vector2.new(screen_point.X, screen_point.Y), on_screen, screen_point.Z
    end)

    local SetTarget = LPH_NO_VIRTUALIZE(function(plr, part)
        states.target = plr
        states.target_part = part
        EspInterface.SetTarget(plr)
    end)

    -- Valid-position search (manipulation)
    local candidates = {
        Vector3.new(5, 3, 5),
        Vector3.new(-5, 3, 5),
        Vector3.new(5, 3, -5),
        Vector3.new(-5, 3, -5),
        Vector3.new(0, 5, 8),
        Vector3.new(0, 5, -8),
    }

    local overlap_params = OverlapParams.new()
    overlap_params.FilterType = Enum.RaycastFilterType.Exclude

    local ray_params = RaycastParams.new()
    ray_params.FilterType = Enum.RaycastFilterType.Exclude

    local valid_position_cache = {}
    local valid_position_cache_ttl = 0.5

    local FindValidPosition = LPH_NO_VIRTUALIZE(function(target)
        if not LocalChar then return nil end
        overlap_params.FilterDescendantsInstances = { LocalChar }
        ray_params.FilterDescendantsInstances = { LocalChar }

        local target_pos = target.Position
        local target_model = target.Parent

        for i = 1, #candidates do
            local offset = candidates[i]
            local pos = target_pos + offset

            local result = Workspace:Raycast(pos, target_pos - pos, ray_params)
            if not result or result.Instance:IsDescendantOf(target_model) then
                local parts = Workspace:GetPartBoundsInBox(CFrame.new(pos), Vector3.new(3, 6, 3), overlap_params)
                local blocked = false
                for j = 1, #parts do
                    if parts[j].CanCollide then
                        blocked = true
                        break
                    end
                end
                if not blocked then return offset end
            end
        end

        return nil
    end)

    local GetCachedValidPosition = LPH_NO_VIRTUALIZE(function(target)
        if not target or not target.Parent then return nil end
        local now = os.clock()
        local entry = valid_position_cache[target]
        if entry and now - entry.time < valid_position_cache_ttl then
            return entry.value
        end
        local value = FindValidPosition(target)
        valid_position_cache[target] = { value = value, time = now }
        return value
    end)

    -- Katana / Riot Shield "ignore" support
    pcall(function()
        task.wait(3)
        task.spawn(function()
            local katana_path = player.PlayerScripts.Modules.Items:FindFirstChild("Katana", true)
            local riot_path = player.PlayerScripts.Modules.Items:FindFirstChild("Riot Shield", true)
            local katana = katana_path and require(katana_path)
            local riot = riot_path and require(riot_path)

            if katana and type(katana) == "table" and katana.StartAiming then
                local old = katana.StartAiming
                katana.StartAiming = function(self, force)
                    if not table.find(states.targeting_state.ignore, "Katana") then return old(self, force) end
                    local fighter = self.ClientFighter
                    local plr = fighter and fighter.Player
                    if plr then
                        states.targeting_state.blocking[plr.Name] = true
                        local dur = self.Info and self.Info.DeflectDuration or 0.6
                        task.delay(dur, function() states.targeting_state.blocking[plr.Name] = nil end)
                    end
                    return old(self, force)
                end
            end

            if riot and type(riot) == "table" and riot._UpdateUnequippedViewModel then
                local old = riot._UpdateUnequippedViewModel
                riot._UpdateUnequippedViewModel = function(self, ...)
                    if not table.find(states.targeting_state.ignore, "Riot Shield") then return old(self, ...) end
                    local was_on_back = self._shieldOnBack
                    local fighter = self.ClientFighter
                    local plr = fighter and fighter.Player
                    local on_back = not (self.IsEquipped or fighter:IsActuallyFirstPerson()) and not fighter:Get("IsHiddenByEmotes")
                    if was_on_back ~= on_back then
                        self._shieldOnBack = on_back
                        if on_back then
                            states.targeting_state.blocking[plr.Name] = true
                        else
                            states.targeting_state.blocking[plr.Name] = nil
                        end
                    end
                    return old(self, ...)
                end
            end
        end)
    end)

    -- FOV circle UI + target acquisition
    pcall(function()
        local fov_frame = Instance.new("Frame")
        fov_frame.Name = ""
        fov_frame.Parent = states.screen_gui
        fov_frame.AnchorPoint = Vector2.new(0.5, 0.5)
        fov_frame.Position = UDim2.fromScale(0.5, 0.5)
        fov_frame.Size = UDim2.fromScale(1, 1)
        fov_frame.BackgroundTransparency = 1
        fov_frame.BorderSizePixel = 0
        fov_frame.ZIndex = 1

        local fov_circle_inline = Instance.new("Frame")
        fov_circle_inline.Name = ""
        fov_circle_inline.Parent = fov_frame
        fov_circle_inline.AnchorPoint = Vector2.new(0.5, 0.5)
        fov_circle_inline.BackgroundTransparency = 1
        fov_circle_inline.ZIndex = 1

        local fov_circle_inline_stroke = Instance.new("UIStroke")
        fov_circle_inline_stroke.Name = ""
        fov_circle_inline_stroke.Parent = fov_circle_inline
        fov_circle_inline_stroke.Color = Color3.new(1, 1, 1)
        fov_circle_inline_stroke.Thickness = 1

        local fov_circle_inline_grad = Instance.new("UIGradient")
        fov_circle_inline_grad.Name = ""
        fov_circle_inline_grad.Parent = fov_circle_inline_stroke

        local fov_circle = Instance.new("Frame")
        fov_circle.Name = ""
        fov_circle.Parent = fov_frame
        fov_circle.AnchorPoint = Vector2.new(0.5, 0.5)
        fov_circle.ZIndex = 2

        local fov_circle_stroke = Instance.new("UIStroke")
        fov_circle_stroke.Name = ""
        fov_circle_stroke.Parent = fov_circle
        fov_circle_stroke.Color = Color3.new(1, 1, 1)
        fov_circle_stroke.Thickness = 1

        local fov_circle_grad = Instance.new("UIGradient")
        fov_circle_grad.Name = ""
        fov_circle_grad.Parent = fov_circle_stroke

        local fov_circle_fill = Instance.new("UIGradient")
        fov_circle_fill.Name = ""
        fov_circle_fill.Parent = fov_circle

        local fov_circle_outline = Instance.new("Frame")
        fov_circle_outline.Name = ""
        fov_circle_outline.Parent = fov_frame
        fov_circle_outline.AnchorPoint = Vector2.new(0.5, 0.5)
        fov_circle_outline.BackgroundTransparency = 1
        fov_circle_outline.ZIndex = 3

        local fov_circle_outline_stroke = Instance.new("UIStroke")
        fov_circle_outline_stroke.Name = ""
        fov_circle_outline_stroke.Parent = fov_circle_outline
        fov_circle_outline_stroke.Color = Color3.new(1, 1, 1)
        fov_circle_outline_stroke.Thickness = 1

        local fov_circle_outline_grad = Instance.new("UIGradient")
        fov_circle_outline_grad.Name = ""
        fov_circle_outline_grad.Parent = fov_circle_outline_stroke

        local circle_mod = Instance.new("UICorner")
        circle_mod.Name = ""
        circle_mod.Parent = fov_circle_inline
        circle_mod.CornerRadius = UDim.new(1, 0)
        circle_mod:Clone().Parent = fov_circle
        circle_mod:Clone().Parent = fov_circle_outline

        local camera = Workspace.CurrentCamera or Workspace.Camera
        local raycast_params = RaycastParams.new()
        raycast_params.FilterType = Enum.RaycastFilterType.Exclude
        raycast_params.IgnoreWater = true
        raycast_params.FilterDescendantsInstances = { player.Character }
        player.CharacterAdded:Connect(function(char)
            raycast_params.FilterDescendantsInstances = { char }
        end)

        local wallcheck_cache = {}
        local wallcheck_cache_ttl = 0.15

        local WallCheck = LPH_NO_VIRTUALIZE(function(character, part)
            if not states.targeting_state.wallcheck then return true end
            local char_cache = wallcheck_cache[character]
            if not char_cache then
                char_cache = {}
                wallcheck_cache[character] = char_cache
            end
            local now = os.clock()
            local cached = char_cache[part]
            if cached and (now - cached.time) < wallcheck_cache_ttl then
                return cached.value
            end
            local origin = camera.CFrame.Position
            local result = Workspace:Raycast(origin, part.Position - origin, raycast_params)
            local passed = not result or result.Instance:IsDescendantOf(character)
            char_cache[part] = { time = now, value = passed }
            return passed
        end)

        local FindBestTarget = LPH_JIT_MAX(function()
            local origin = camera.CFrame.Position

            local best_part
            local best_player
            local best_distance = math.huge

            for _, plr in Players:GetPlayers() do
                if plr == player then continue end
                local character = plr.Character
                if not character then continue end
                local root = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not root or not humanoid or humanoid.Health <= 0 then continue end

                local their_team = plr:GetAttribute("TeamID")
                if their_team and their_team == player:GetAttribute("TeamID") then continue end

                if states.targeting_state.blocking[plr.Name] then continue end

                local root_dist = (root.Position - origin).Magnitude
                if root_dist > (states.targeting_state.max_distance + 6) then continue end

                local closest_part = nil
                local closest = math.huge

                if states.targeting_state.target == "Closest Part" then
                    for _, part_name in states.targeting_state.include_parts do
                        if type(part_name) ~= "string" then continue end
                        local part = character:FindFirstChild(part_name)
                        if not part or not part:IsA("BasePart") then continue end
                        local world_dist = (part.Position - origin).Magnitude
                        if world_dist > states.targeting_state.max_distance then continue end
                        local screen, visible = camera:WorldToViewportPoint(part.Position)
                        if not visible and screen.Z <= 0 then continue end
                        local dx = screen.X - fov_circle.Position.X.Offset
                        local dy = screen.Y - fov_circle.Position.Y.Offset
                        local screen_dist = dx * dx + dy * dy
                        local radius_sq = states.targeting_state.radius * states.targeting_state.radius
                        if states.targeting_state.target_group == "FOV" and screen_dist > radius_sq then continue end
                        local score = (screen_dist * states.targeting_state.weight_ratio) + (world_dist * (1 - states.targeting_state.weight_ratio))
                        if score < closest then
                            closest = score
                            closest_part = part
                        end
                    end
                else
                    local part = character:FindFirstChild(states.targeting_state.target)
                    if part and part:IsA("BasePart") then
                        local world_dist = (part.Position - origin).Magnitude
                        if world_dist <= states.targeting_state.max_distance then
                            local screen, visible = camera:WorldToViewportPoint(part.Position)
                            if visible or screen.Z > 0 then
                                local dx = screen.X - fov_circle.Position.X.Offset
                                local dy = screen.Y - fov_circle.Position.Y.Offset
                                local screen_dist = dx * dx + dy * dy
                                local radius_sq = states.targeting_state.radius * states.targeting_state.radius
                                if states.targeting_state.target_group ~= "FOV" or screen_dist <= radius_sq then
                                    closest = (screen_dist * states.targeting_state.weight_ratio) + (world_dist * (1 - states.targeting_state.weight_ratio))
                                    closest_part = part
                                end
                            end
                        end
                    end
                end

                if not closest_part or closest >= best_distance then continue end
                if not WallCheck(character, closest_part) then continue end

                best_distance = closest
                best_player = plr
                best_part = closest_part
            end

            return best_player, best_part
        end)

        local pending_player
        local pending_part
        local pending_time = 0

        local current_player
        local current_part
        local current_lost_time = 0

        local next_search = 0
        local current_pos = UDim2.fromOffset((camera.ViewportSize / 2).X, (camera.ViewportSize / 2).Y)
        local target_scan_interval = 0.03

        RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            local now = os.clock()
            local state = states.targeting_state

            if not (states.legit_state.silent_aim.enabled or states.rage_state.rage_bot.enabled or states.legit_state.triggerbot.enabled or state.show_fov) then
                if current_player then
                    current_player = nil
                    current_part = nil
                    current_lost_time = 0
                    SetTarget(nil, nil)
                end
                fov_frame.Visible = false
                return
            end

            fov_frame.Visible = state.show_fov

            local target_pos = UDim2.fromOffset((camera.ViewportSize / 2).X, (camera.ViewportSize / 2).Y)
            if state.fov_position["Barrel"] and not states.target_part then
                local muzzle_pos = GetMuzzlePos()
                if muzzle_pos then
                    local screenPos, on_screen = WorldToScreen(muzzle_pos)
                    if on_screen then
                        target_pos = UDim2.fromOffset(screenPos.X, screenPos.Y)
                    else
                        target_pos = UDim2.fromOffset((camera.ViewportSize / 2).X, (camera.ViewportSize / 2).Y)
                    end
                end
            end

            if state.fov_position["Target"] and states.target_part then
                local hitbox_pos = states.target_part.Position
                if hitbox_pos then
                    local screenPos, on_screen = WorldToScreen(hitbox_pos)
                    if on_screen then
                        target_pos = UDim2.fromOffset(screenPos.X, screenPos.Y)
                    else
                        target_pos = UDim2.fromOffset((camera.ViewportSize / 2).X, (camera.ViewportSize / 2).Y)
                    end
                end
            end

            if state.fov_lerp and state.fov_lerp > 0 then
                current_pos = current_pos:Lerp(target_pos, state.fov_lerp)
            else
                current_pos = target_pos
            end

            local radius = state.radius
            local transparency = state.fov_transparency
            local rotation = state.fov_rotation
            local rot_speed = state.fov_rotation_speed * 0.5
            if state.fov_rotation_speed > 0 then
                rotation = (state.fov_rotation + now * rot_speed * 360) % 360
            end

            local color_start = state.fov_start_color
            local color_mid = state.fov_mid_color
            local color_end = state.fov_end_color

            local outline_transparency = state.fov_outline_transparency
            local outline_color_start = state.fov_outline_start_color
            local outline_color_mid = state.fov_outline_mid_color
            local outline_color_end = state.fov_outline_end_color

            fov_circle_inline.Position = current_pos
            fov_circle_inline.Size = UDim2.fromOffset((radius * 2) - 2, (radius * 2) - 2)
            fov_circle_inline.Visible = state.fov_outline
            fov_circle_inline_stroke.Transparency = outline_transparency
            fov_circle_inline_grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, outline_color_start), ColorSequenceKeypoint.new(0.5, outline_color_mid), ColorSequenceKeypoint.new(1, outline_color_end)}
            fov_circle_inline_grad.Rotation = rotation

            fov_circle.Position = current_pos
            fov_circle.Size = UDim2.fromOffset(radius * 2, radius * 2)
            fov_circle.Visible = state.show_fov
            fov_circle.BackgroundTransparency = state.fov_fill and math.clamp(0.35 + (transparency * 0.65), 0, 1) or 1
            fov_circle_stroke.Transparency = transparency
            fov_circle_grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, color_start), ColorSequenceKeypoint.new(0.5, color_mid), ColorSequenceKeypoint.new(1, color_end)}
            fov_circle_grad.Rotation = rotation
            fov_circle_fill.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, color_start), ColorSequenceKeypoint.new(0.5, color_mid), ColorSequenceKeypoint.new(1, color_end)}
            fov_circle_fill.Rotation = rotation

            fov_circle_outline.Position = current_pos
            fov_circle_outline.Size = UDim2.fromOffset((radius * 2) + 2, (radius * 2) + 2)
            fov_circle_outline.Visible = state.fov_outline
            fov_circle_outline_stroke.Transparency = outline_transparency
            fov_circle_outline_grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, outline_color_start), ColorSequenceKeypoint.new(0.5, outline_color_mid), ColorSequenceKeypoint.new(1, outline_color_end)}
            fov_circle_outline_grad.Rotation = rotation

            if now < next_search then return end
            next_search = now + math.max(state.reaction_time / 1000, target_scan_interval)

            local best_player, best_part = FindBestTarget()

            if best_player ~= pending_player or best_part ~= pending_part then
                pending_player = best_player
                pending_part = best_part
                pending_time = now
                return
            end

            if best_player then
                current_lost_time = 0
                if current_player ~= best_player or current_part ~= best_part then
                    if now - pending_time >= state.reaction_time / 1000 then
                        current_player = best_player
                        current_part = best_part
                        SetTarget(best_player, best_part)
                    end
                end
                return
            end

            if not current_player then
                current_lost_time = 0
                return
            end

            if state.forget_time <= 0 then
                current_player = nil
                current_part = nil
                SetTarget(nil, nil)
                return
            end

            if current_lost_time == 0 then
                current_lost_time = now
                return
            end

            if now - current_lost_time >= state.forget_time then
                current_player = nil
                current_part = nil
                current_lost_time = 0
                SetTarget(nil, nil)
            end
        end))
    end)

    -- Triggerbot
    states.legit_state.triggerbot.triggerbot_shot_started.Parent = nil
    states.legit_state.triggerbot.triggerbot_shot_finished.Parent = nil

    pcall(function()
        local last_shot = 0
        RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
            pcall(setthreadidentity, 2)
            local state = states.legit_state.triggerbot
            if not state.enabled then
                if state.triggerbot_active then state.triggerbot_shot_finished:Fire() end
                pcall(setthreadidentity, 8)
                return
            end

            local target = states.target_part
            if not target then
                if state.triggerbot_active then state.triggerbot_shot_finished:Fire() end
                pcall(setthreadidentity, 8)
                return
            end

            if states.is_reloading then
                if state.triggerbot_active then state.triggerbot_shot_finished:Fire() end
                pcall(setthreadidentity, 8)
                return
            end

            local fighter = modules.FighterController:GetFighter(player)
            if not fighter then pcall(setthreadidentity, 8) return end

            local equipped_item = fighter.EquippedItem
            if not equipped_item then pcall(setthreadidentity, 8) return end

            if table.find(state.check_scoped, equipped_item.Name) then
                if not equipped_item:IsFullyAiming() then
                    if state.triggerbot_active then state.triggerbot_shot_finished:Fire() end
                    pcall(setthreadidentity, 8)
                    return
                end
            end

            local now = os.clock()
            local shoot_delay_ms = state.shoot_delay or 100
            local shoot_delay = shoot_delay_ms / 1000

            if now - last_shot < shoot_delay then pcall(setthreadidentity, 8) return end

            if not state.triggerbot_active then state.triggerbot_shot_started:Fire() end

            last_shot = now
            modules.MechanicsController:EquippedItemInput("StartShooting")
            pcall(setthreadidentity, 8)
        end))
    end)

    -- Weapon mods (no recoil / no spread / full auto / firerate)
    pcall(function()
        local old = {}
        local weapon_state = states.rage_state.weapons
        local weapon_last_update = 0
        local weapon_update_interval = 0.03

        local function RestoreWeaponInfo(info, original)
            if not info or not original then return end
            info.ShootRecoil = original.ShootRecoil
            info.ShootAccuracy = original.ShootAccuracy
            info.ShootSpread = original.ShootSpread
            info.QuickShotSpread = original.QuickShotSpread
            info.ShootSpreadConsistent = original.ShootSpreadConsistent
            info.AimSpreadMultiplier = original.AimSpreadMultiplier
            if info.InputSpammingEnabled then info.InputSpammingEnabled.StartShooting = original.StartShooting end
            info.ShootCooldown = original.ShootCooldown
        end

        RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
            if not (weapon_state.no_recoil or weapon_state.no_spread or weapon_state.full_auto or weapon_state.firerate ~= 100) then
                return
            end
            local fighter = modules.FighterController:GetFighter(player)
            if not fighter then return end
            local equipped_item = fighter.EquippedItem
            if not equipped_item then return end
            local info = equipped_item.Info
            if not info then return end

            if not old[equipped_item] then
                old[equipped_item] = {
                    ShootRecoil = info.ShootRecoil,
                    ShootAccuracy = info.ShootAccuracy,
                    ShootSpread = info.ShootSpread,
                    QuickShotSpread = info.QuickShotSpread,
                    ShootSpreadConsistent = info.ShootSpreadConsistent,
                    AimSpreadMultiplier = info.AimSpreadMultiplier,
                    StartShooting = info.InputSpammingEnabled and info.InputSpammingEnabled.StartShooting,
                    ShootCooldown = info.ShootCooldown,
                }
            end

            local original = old[equipped_item]
            local should_apply = weapon_state.no_recoil
                or weapon_state.no_spread
                or weapon_state.full_auto
                or weapon_state.firerate ~= 100

            if not should_apply then
                RestoreWeaponInfo(info, original)
                return
            end

            local now = os.clock()
            if now - weapon_last_update < weapon_update_interval then return end
            weapon_last_update = now

            if weapon_state.no_recoil then
                info.ShootRecoil = 0
            else
                info.ShootRecoil = original.ShootRecoil
            end

            if weapon_state.no_spread then
                info.ShootAccuracy = 0
                info.ShootSpread = 0
                info.QuickShotSpread = 0
                info.ShootSpreadConsistent = true
                info.AimSpreadMultiplier = 0
            else
                info.ShootAccuracy = original.ShootAccuracy
                info.ShootSpread = original.ShootSpread
                info.QuickShotSpread = original.QuickShotSpread
                info.ShootSpreadConsistent = original.ShootSpreadConsistent
                info.AimSpreadMultiplier = original.AimSpreadMultiplier
            end

            if weapon_state.full_auto and info.InputSpammingEnabled then
                info.InputSpammingEnabled.StartShooting = 0
            elseif info.InputSpammingEnabled then
                info.InputSpammingEnabled.StartShooting = original.StartShooting
            end

            if weapon_state.firerate ~= 100 then
                info.ShootCooldown = original.ShootCooldown and original.ShootCooldown * (weapon_state.firerate / 100) or nil
            else
                info.ShootCooldown = original.ShootCooldown
            end
        end))
    end)

    -- Silent aim (gun / melee / knife) + manipulation
    pcall(function()
        local manip_cf
        local manip_conn
        local manipulation = false
        local manip_visualizer = nil
        local manip_visualizer_conns = {}
        local last_manip_update = 0
        local manip_update_interval = 0.02

        local function DestroyManipVisualizer()
            if manip_visualizer then
                pcall(function() manip_visualizer:Destroy() end)
                manip_visualizer = nil
            end
            for _, conn in ipairs(manip_visualizer_conns) do
                conn:Disconnect()
            end
            table.clear(manip_visualizer_conns)
        end

        local function CreateManipVisualizer()
            if manip_visualizer then return end
            local root = LocalChar and LocalChar.PrimaryPart
            if not root then return end

            manip_visualizer = Instance.new("Part")
            manip_visualizer.Name = ""
            manip_visualizer.Material = Enum.Material.Neon
            manip_visualizer.Size = root.Size
            manip_visualizer.Color = states.visuals_state.colors.trail_color
            manip_visualizer.CanCollide = false
            manip_visualizer.CanQuery = false
            manip_visualizer.CanTouch = false
            manip_visualizer.CFrame = manip_cf or root.CFrame
            manip_visualizer.Anchored = true
            manip_visualizer.Parent = EspInterface.GlobalChamRenderer.Viewport

            table.insert(manip_visualizer_conns, root.Destroying:Connect(function()
                if manip_visualizer then
                    pcall(function() manip_visualizer:Destroy() end)
                    manip_visualizer = nil
                end
            end))

            table.insert(manip_visualizer_conns, root.AncestryChanged:Connect(function(_, parent)
                if not parent and manip_visualizer then
                    pcall(function() manip_visualizer:Destroy() end)
                    manip_visualizer = nil
                end
            end))
        end

        local function EnsureManipVisualizer()
            if not states.legit_state.silent_aim.visualize then
                DestroyManipVisualizer()
                return
            end
            if not manip_visualizer then
                CreateManipVisualizer()
            elseif manip_cf then
                manip_visualizer.CFrame = manip_cf
            end
        end

        local ApplyManipulation = LPH_NO_VIRTUALIZE(function()
            if not manipulation or not manip_cf then return end
            local root = LocalChar and LocalChar.PrimaryPart
            if root and root.Parent then
                root.CFrame = manip_cf
            end
            states.server_cf = manip_cf
        end)

        local StartManipulation = Instance.new("BindableEvent")
        StartManipulation.Parent = nil

        StartManipulation.Event:Connect(function(cf)
            ServerCFDesync()
            manip_cf = cf
            manipulation = true
            last_manip_update = 0
            ApplyManipulation()

            if not manip_conn then
                manip_conn = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
                    if not manipulation or not manip_cf then return end
                    local now = os.clock()
                    if now - last_manip_update < manip_update_interval then return end
                    last_manip_update = now
                    ApplyManipulation()
                    if states.legit_state.silent_aim.visualize then
                        if manip_visualizer then
                            manip_visualizer.CFrame = manip_cf
                        else
                            CreateManipVisualizer()
                        end
                    elseif manip_visualizer then
                        DestroyManipVisualizer()
                    end
                end))
            end

            EnsureManipVisualizer()
        end)

        local function StopManipulation()
            manipulation = false
            manip_cf = nil
            last_manip_update = 0
            if manip_conn then
                manip_conn:Disconnect()
                manip_conn = nil
            end
            DestroyManipVisualizer()
            ServerCFSync()
        end

        UserInputService.InputEnded:Connect(function(input)
            if manipulation and input.UserInputType == Enum.UserInputType.MouseButton1 then
                StopManipulation()
            end
        end)

        states.legit_state.triggerbot.triggerbot_shot_started.Event:Connect(function()
            states.legit_state.triggerbot.triggerbot_active = true
        end)

        states.legit_state.triggerbot.triggerbot_shot_finished.Event:Connect(function()
            states.legit_state.triggerbot.triggerbot_active = false
            StopManipulation()
            modules.MechanicsController:EquippedItemInput("FinishShooting")
        end)

        local shot_offset_cf = modules.Utility:EncodeCFrame(CFrame.new(0.43, 0.25, 0.42))
        local shot_key_0 = utf8.char(0)
        local shot_key_1 = utf8.char(1)
        local shot_key_2 = utf8.char(2)
        local shot_key_3 = utf8.char(3)

        local BuildShotPayload = LPH_NO_VIRTUALIZE(function(origin, target, part)
            local aim_cf = modules.Utility:EncodeCFrame(CFrame.new(origin, target))
            return {
                [shot_key_0] = aim_cf,
                [shot_key_1] = aim_cf,
                [shot_key_2] = part,
                [shot_key_3] = shot_offset_cf,
            }
        end)

        local old_gun = modules.Gun.StartShooting
        modules.Gun.StartShooting = LPH_NO_VIRTUALIZE(function(self, ...)
            local legit_state = states.legit_state.silent_aim
            local rage_state = states.rage_state.rage_bot
            local part = states.target_part

            if not self.ClientFighter.IsLocalPlayer or not part then
                return old_gun(self, ...)
            end

            local results = { old_gun(self, ...) }

            if results[1] ~= true or results[2] ~= "StartShooting" then
                return unpack(results)
            end

            if not legit_state.enabled and not rage_state.enabled then
                return unpack(results)
            end

            local root = LocalChar and LocalChar.PrimaryPart
            if not root then return unpack(results) end

            if rage_state.enabled then
                results[3] = BuildShotPayload(states.server_cf.Position, part.Position, part)
                return unpack(results)
            end

            if math.random(1, 100) > legit_state.hit_chance then
                return unpack(results)
            end

            local origin = root.Position
            local target = part.Position

            if legit_state.manipulation then
                local offset = GetCachedValidPosition(part) or Vector3.new(0, 5, 5)
                local fake_cf = part.CFrame * CFrame.new(offset)
                StartManipulation:Fire(fake_cf)
                origin = fake_cf.Position
            end

            results[3] = BuildShotPayload(origin, target, part)
            return unpack(results)
        end)

        local old_melee = modules.Melee.StartShooting
        modules.Melee.StartShooting = LPH_JIT_MAX(function(self, ...)
            local rage_state = states.rage_state.rage_bot
            local part = states.target_part

            if not self.ClientFighter.IsLocalPlayer or not part then
                return old_melee(self, ...)
            end

            local results = { old_melee(self, ...) }

            if results[1] ~= true or results[2] ~= "StartShooting" then
                return unpack(results)
            end

            if not rage_state.enabled then return unpack(results) end

            local root = LocalChar and LocalChar.PrimaryPart
            if not root then return unpack(results) end

            if rage_state.enabled then
                results[3] = BuildShotPayload(states.server_cf.Position, part.Position, part)
                return unpack(results)
            end

            return unpack(results)
        end)

        local old_knife = modules.Knife.StartAiming
        modules.Knife.StartAiming = LPH_JIT_MAX(function(self, ...)
            local rage_state = states.rage_state.rage_bot
            local part = states.target_part

            if not self.ClientFighter.IsLocalPlayer or not part then
                return old_knife(self, ...)
            end

            local results = { old_knife(self, ...) }

            if results[1] ~= true or results[2] ~= "StartAiming" then
                return unpack(results)
            end

            if not rage_state.enabled then return unpack(results) end

            local root = LocalChar and LocalChar.PrimaryPart
            if not root then return unpack(results) end

            if rage_state.enabled then
                results[3] = BuildShotPayload(states.server_cf.Position, part.Position, part)
                return unpack(results)
            end

            return unpack(results)
        end)
    end)

    -- Rage bot
    states.rage_state.rage_bot.sync_void_state.Parent = nil

    pcall(function()
        local void_phase = false
        local last_switch = 0
        local rage_active = false
        local last_action_time = 0
        local entity = modules.ClientEntity
        local orig_rplfromserv = entity and entity.ReplicateFromServer
        local orig_hurteffect = entity and entity._HurtEffect
        local prev = {}

        local rage_hud_frame = Instance.new("Frame")
        rage_hud_frame.Name = ""
        rage_hud_frame.Parent = states.screen_gui
        rage_hud_frame.AnchorPoint = Vector2.new(0.5, 0)
        rage_hud_frame.BackgroundTransparency = 1
        rage_hud_frame.ZIndex = 5
        rage_hud_frame.Size = UDim2.fromOffset(250, 120)
        rage_hud_frame.Visible = false

        local hud_layout = Instance.new("UIListLayout")
        hud_layout.Parent = rage_hud_frame
        hud_layout.SortOrder = Enum.SortOrder.LayoutOrder
        hud_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        hud_layout.VerticalAlignment = Enum.VerticalAlignment.Top
        hud_layout.Padding = UDim.new(0, 2)

        local function CreateHUDText(text, order)
            local label = Instance.new("TextLabel")
            label.Name = ""
            label.Parent = rage_hud_frame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 14)
            label.Font = Enum.Font.Arial
            label.TextSize = 14
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0
            label.Text = text
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.LayoutOrder = order
            label.ZIndex = 6
            return label
        end

        local function ResetVoidState()
            void_phase = false
            last_switch = 0
        end

        local function GetShootCooldown()
            local fighter = modules.FighterController:GetFighter(player)
            local equipped_item = fighter and fighter.EquippedItem
            local info = equipped_item and equipped_item.Info
            if info and info.ShootCooldown then
                return math.max(0.02, info.ShootCooldown)
            end
            return 0.05
        end

        local shoot_ready_at = 0
        local shoot_pending = false

        states.rage_state.rage_bot.sync_void_state.Event:Connect(function()
            local state = states.rage_state.rage_bot
            if not state.enabled then
                ResetVoidState()
                ServerCFSync()
            else
                ResetVoidState()
                if state.void_spam then
                    last_switch = tick()
                end
            end
        end)

        local EditServerCF = LPH_JIT_MAX(function(force_hide)
            local state = states.rage_state.rage_bot
            if not state.enabled or states.rage_state.pluggwalk.enabled then return end

            local root = LocalChar and LocalChar.PrimaryPart
            if not root or not root.Parent then return end

            local target = states.target_part
            if not target then return end

            local target_cf = target.CFrame * CFrame.new(0, 0, 2)

            if not state.void_spam then
                states.server_cf = target_cf
                return
            end

            if force_hide then
                void_phase = true
            else
                local now = tick()
                local duration = void_phase and state.hide or state.attack
                if now - last_switch >= duration then
                    void_phase = not void_phase
                    last_switch = now
                end
            end

            if void_phase then
                local pos = target_cf.Position
                local far_pos = Vector3.new(math.random(-10000, 10000), -999999999, math.random(-10000, 10000))
                states.server_cf = CFrame.new(far_pos) * (target_cf - pos)
            else
                states.server_cf = target_cf
            end
        end)

        local function HasAmmo(item)
            if not item then return false end
            return (item:Get("Ammo") or 0) > 0 or (item:Get("AmmoReserve") or 0) > 0
        end

        local EquipBestWeapon = LPH_JIT_MAX(function()
            local state = states.rage_state.rage_bot
            local fighter = modules.FighterController:GetFighter(player)
            if not fighter then return end

            local desired_slot

            if state.attack_mode == "Knife" or state.attack_mode == "Melee" then
                desired_slot = 3
            else
                local primary = fighter.Items and fighter.Items[1]
                local secondary = fighter.Items and fighter.Items[2]
                if not primary and not secondary then return end

                if state.preferred == "Secondary" then
                    if HasAmmo(secondary) then
                        desired_slot = 2
                    elseif HasAmmo(primary) then
                        desired_slot = 1
                    end
                else
                    if HasAmmo(primary) then
                        desired_slot = 1
                    elseif HasAmmo(secondary) then
                        desired_slot = 2
                    end
                end
            end

            if not desired_slot then return end

            if fighter.Items[desired_slot] and not fighter.Items[desired_slot].IsEquipped then
                fighter:EquipItem(desired_slot)
            end
        end)

        local function StartRage()
            rage_active = true
        end

        local function FinishRage()
            rage_active = false
            last_action_time = 0
            shoot_pending = false
            shoot_ready_at = 0
            modules.MechanicsController:EquippedItemInput("FinishShooting")
            ResetVoidState()
            ServerCFSync()
        end

        local rage_status = CreateHUDText("rage bot: idle", 1)
        local rage_target = CreateHUDText("target: none", 2)

        local UpdateRageHUD = LPH_NO_VIRTUALIZE(function()
            local state = states.rage_state.rage_bot
            local center_screen = Workspace.CurrentCamera.ViewportSize / 2
            rage_hud_frame.Visible = state.enabled and state.rage_hud
            rage_hud_frame.Position = UDim2.fromOffset(center_screen.X, center_screen.Y + 25)

            if states.is_reloading then
                rage_status.Text = "rage bot: reloading"
            elseif void_phase then
                rage_status.Text = "rage bot: void"
            elseif shoot_pending or (state.attack_mode == "Knife" and modules.MechanicsController:IsAiming()) then
                rage_status.Text = "rage bot: shoot"
            else
                rage_status.Text = "rage bot: idle"
            end

            local target = states.target
            if target == nil then
                rage_target.Text = "target: none"
            else
                rage_target.Text = "target: " .. target.Name
            end
        end)

        RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            UpdateRageHUD()
            pcall(setthreadidentity, 2)
            local state = states.rage_state.rage_bot
            if not state.enabled then
                if rage_active then FinishRage() end
                pcall(setthreadidentity, 8)
                return
            end

            if states.rage_state.pluggwalk.enabled then
                if rage_active then FinishRage() end
                pcall(setthreadidentity, 8)
                return
            end

            local root = LocalChar and LocalChar.PrimaryPart
            if not root then
                if rage_active then FinishRage() end
                pcall(setthreadidentity, 8)
                return
            end

            local can_attack = states.target_part and not states.is_reloading
            if not can_attack then
                shoot_pending = false
                shoot_ready_at = 0
                modules.MechanicsController:EquippedItemInput("FinishShooting")
                if state.void_spam then
                    ServerCFDesync()
                    EditServerCF(true)
                else
                    ServerCFSync()
                end
                pcall(setthreadidentity, 8)
                return
            else
                ServerCFDesync()
                EquipBestWeapon()
                EditServerCF()
            end

            if not rage_active then StartRage() end

            local now = os.clock()
            if not void_phase then
                if not shoot_pending then
                    if now - last_action_time >= GetShootCooldown() then
                        local ping_delay = player:GetNetworkPing()
                        shoot_ready_at = now + math.max(0.03, ping_delay)
                        shoot_pending = true
                    end
                else
                    if now >= shoot_ready_at then
                        last_action_time = now
                        shoot_pending = false
                        for _ = 1, state.shoot_attempts do
                            local action = (state.attack_mode == "Knife") and "StartAiming" or "StartShooting"
                            modules.MechanicsController:EquippedItemInput(action)
                        end
                    end
                end
            end

            pcall(setthreadidentity, 8)
        end))

        local notify_bindable = Instance.new("BindableEvent")
        notify_bindable.Parent = nil

        notify_bindable.Event:Connect(function(name, dmg)
            Library:Notify(("Hit %s for %.1f"):format(name, dmg), 5)
        end)

        local FireHitNotification = LPH_JIT_MAX(function(obj)
            if not obj or not obj.Model then return end
            local hum = obj.Model:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            local previous = prev[obj]
            if previous == nil then
                prev[obj] = hum.Health
                return
            end

            task.defer(function()
                if not hum.Parent then return end
                local new_health = hum.Health
                local damage = previous - new_health
                prev[obj] = new_health
                if damage <= 0 then return end
                if not (states.rage_state.rage_bot.enabled and states.rage_state.rage_bot.hit_notifications and states.target and states.target.Name == obj.Model.Name) then
                    return
                end
                notify_bindable:Fire(obj.Model.Name, damage)
            end)
        end)

        if entity then
            entity._HurtEffect = function(self, ...)
                FireHitNotification(self)
                return orig_hurteffect and orig_hurteffect(self, ...) or nil
            end
            entity.ReplicateFromServer = function(self, enum, ...)
                if enum == "Died" then prev[self] = nil end
                return orig_rplfromserv and orig_rplfromserv(self, enum, ...) or nil
            end
        end
    end)

    -- Anti aim
    pcall(function()
        local StrongRandom = LPH_JIT_MAX(function(min, max, entropy)
            local seed = (os.clock() * 1e9 + tick() * 1e6 + math.random(1, 1e9) + (entropy or 0) * 1337)
            seed = math.abs(math.sin(seed) * 1e14)
            local rng = Random.new(seed % 2^31)
            return rng:NextNumber(min, max)
        end)

        local RandomAngle = LPH_JIT_MAX(function(min, max, entropy)
            return math.rad(StrongRandom(min, max, entropy))
        end)

        local spin_angle = 0
        local jitter_angle = 0
        local last_jitter = 0

        local pitch_handlers = {
            Offset = function(state)
                return math.rad(state.pitch_angle)
            end,
            Custom = function(state)
                return math.rad(state.pitch_angle)
            end,
            Random = function(state)
                return RandomAngle(-89, 89, state.pitch_angle)
            end,
            ["Look Up"] = function()
                return math.rad(-89)
            end,
            ["Look Down"] = function()
                return math.rad(89)
            end,
        }

        local yaw_handlers = {
            Offset = function(state)
                return math.rad(state.yaw_angle)
            end,
            Custom = function(state)
                return math.rad(state.yaw_angle)
            end,
            Random = function(state)
                return RandomAngle(-180, 180, state.yaw_angle)
            end,
            Spin = function(state)
                spin_angle += math.rad(state.speed)
                if spin_angle >= math.pi * 2 then
                    spin_angle -= math.pi * 2
                end
                return spin_angle
            end,
            Jitter = function(state)
                local now = tick()
                local interval = 1 / math.max(state.speed, 1)
                if now - last_jitter >= interval then
                    last_jitter = now
                    jitter_angle = math.rad(StrongRandom(-state.jitter_angle, state.jitter_angle, jitter_angle))
                end
                return jitter_angle
            end,
            Backwards = function()
                return math.pi
            end,
        }

        local rayparams = RaycastParams.new()
        rayparams.FilterType = Enum.RaycastFilterType.Exclude

        local floor_cache_pos
        local floor_cache_cf
        local floor_cache_time = 0
        local floor_cache_ttl = 0.2

        local GetFloorBelow = LPH_NO_VIRTUALIZE(function(pos)
            local now = os.clock()
            if floor_cache_cf and floor_cache_pos and (floor_cache_pos - pos).Magnitude < 3 and (now - floor_cache_time) < floor_cache_ttl then
                return floor_cache_cf
            end
            local ray_origin = pos
            local ray_dir = Vector3.new(0, -500, 0)
            rayparams.FilterDescendantsInstances = { LocalChar }
            local result = Workspace:Raycast(ray_origin, ray_dir, rayparams)
            local cf = nil
            if result then
                cf = CFrame.new(Vector3.new(pos.X, result.Position.Y - 2, pos.Z))
            end
            floor_cache_pos = pos
            floor_cache_cf = cf
            floor_cache_time = now
            return cf
        end)

        local GetFakeRot = LPH_JIT_MAX(function(vec)
            local state = states.rage_state.anti_aim
            if not state.enabled then return vec end

            local pitch_func = pitch_handlers[state.pitch]
            local yaw_func = yaw_handlers[state.yaw]

            if pitch_func then
                vec = Vector2.new(pitch_func(state), vec.Y)
            end
            if yaw_func then
                vec = Vector2.new(vec.X, vec.Y + yaw_func(state))
            end

            return vec
        end)

        local orig = modules.Utility.EncodeCameraRotation
        modules.Utility.EncodeCameraRotation = LPH_JIT_MAX(function(self, vec)
            local fake_rot = GetFakeRot(vec)
            local state = states.rage_state.anti_aim
            if state.enabled or states.rage_state.pluggwalk.enabled then
                local root = LocalChar and LocalChar.PrimaryPart
                if root and root.Parent then
                    root.CFrame = root.CFrame * CFrame.Angles(fake_rot.X, fake_rot.Y, math.rad(root.CFrame.Rotation.Z))
                end
            end
            return orig(self, fake_rot)
        end)

        RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
            if not states.rage_state.anti_aim.enabled or states.rage_state.pluggwalk.enabled or states.rage_state.rage_bot.void_spam then
                return
            end
            if not states.rage_state.anti_aim.underground then return end

            local root = LocalChar and LocalChar.PrimaryPart
            if not root or not root.Parent then return end

            local cf = root.CFrame
            if not cf then return end

            local pos = cf.Position
            local floor_cf = GetFloorBelow(pos)
            if not floor_cf then return end

            root.CFrame = floor_cf
        end))
    end)
end)

--  TAB - ESP
local GEspMain   = Tabs.ESP:AddLeftGroupbox('Main')
local GEspBox    = Tabs.ESP:AddLeftGroupbox('Box')
local GEspHealth = Tabs.ESP:AddLeftGroupbox('Health')
local GTracer    = Tabs.ESP:AddRightGroupbox('Tracer / Snapline')
local GChams     = Tabs.ESP:AddRightGroupbox('Chams')
local GSkeleton  = Tabs.ESP:AddRightGroupbox('Skeleton')
local GColors    = Tabs.ESP:AddRightGroupbox('Colors')
local GRainbow   = Tabs.ESP:AddRightGroupbox('Rainbow')

GEspMain:AddToggle('ESPEnabled',  { Text = 'Enable ESP',   Default = false, Tooltip = 'Shows box/tracer/health/chams for other players' })
GEspMain:AddToggle('TeamCheck',   { Text = 'Team Check',   Default = false, Tooltip = 'Skips players on your team' })
GEspMain:AddToggle('ShowTeam',    { Text = 'Show Team',    Default = false, Tooltip = 'Show teammates anyway when team check is on' })
GEspMain:AddSlider('MaxDistance', { Text = 'Max Distance', Default = 1000, Min = 100,  Max = 5000, Rounding = 0, Suffix = 'st' })
GEspMain:AddSlider('TextSize',    { Text = 'Text Size',    Default = 14,   Min = 10,   Max = 24,   Rounding = 0 })

GEspBox:AddToggle('BoxESP',     { Text = 'Box ESP',          Default = false, Tooltip = 'Draws a box around players' })
GEspBox:AddDropdown('BoxStyle', { Text = 'Box Style', Values = {'Corner','Full','ThreeD'}, Default = 'Corner', Multi = false })
GEspBox:AddSlider('BoxThickness',       { Text = 'Box Thickness',    Default = 1,   Min = 1,  Max = 5,  Rounding = 1 })
GEspBox:AddToggle('BoxFilled',          { Text = 'Box Filled',        Default = false })
GEspBox:AddSlider('BoxFillTransparency',{ Text = 'Fill Transparency', Default = 0.5, Min = 0,  Max = 1,  Rounding = 2 })

GEspHealth:AddToggle('HealthESP',  { Text = 'Health Bar',   Default = false })
GEspHealth:AddDropdown('HealthStyle', { Text = 'Health Style', Values = {'Bar','Text','Both'}, Default = 'Bar', Multi = false })

GTracer:AddToggle('TracerESP',     { Text = 'Tracer ESP',  Default = false })
GTracer:AddDropdown('TracerOrigin',{ Text = 'Tracer Origin', Values = {'Bottom','Top','Mouse','Center'}, Default = 'Bottom', Multi = false })
GTracer:AddToggle('Snaplines',     { Text = 'Snaplines',   Default = false })

GChams:AddToggle('ChamsEnabled', { Text = 'Enable Chams', Default = false })
GChams:AddLabel('Fill Color'):AddColorPicker('ChamsFillColor',    { Default = Color3.fromRGB(255,0,0),   Title = 'Fill Color' })
GChams:AddLabel('Occluded'):AddColorPicker('ChamsOccludedColor',  { Default = Color3.fromRGB(150,0,0),   Title = 'Occluded Color' })
GChams:AddLabel('Outline'):AddColorPicker('ChamsOutlineColor',    { Default = Color3.fromRGB(255,255,255),Title = 'Outline Color' })
GChams:AddSlider('ChamsTransparency',       { Text = 'Fill Transparency',    Default = 0.5, Min = 0, Max = 1, Rounding = 2 })
GChams:AddSlider('ChamsOutlineTransparency',{ Text = 'Outline Transparency', Default = 0,   Min = 0, Max = 1, Rounding = 2 })

GSkeleton:AddToggle('SkeletonESP', { Text = 'Skeleton ESP', Default = false })
GSkeleton:AddLabel('Color'):AddColorPicker('SkeletonColor', { Default = Color3.fromRGB(255,255,255), Title = 'Skeleton Color' })
GSkeleton:AddSlider('SkeletonThickness',   { Text = 'Line Thickness', Default = 1,   Min = 1, Max = 3,  Rounding = 1 })
GSkeleton:AddSlider('SkeletonTransparency',{ Text = 'Transparency',   Default = 1,   Min = 0, Max = 1,  Rounding = 2 })

GColors:AddLabel('Enemy Color'):AddColorPicker('EnemyColor',  { Default = Color3.fromRGB(255,25,25),  Title = 'Enemy Color' })
GColors:AddLabel('Ally Color'):AddColorPicker('AllyColor',    { Default = Color3.fromRGB(25,255,25),  Title = 'Ally Color' })
GColors:AddLabel('Health Color'):AddColorPicker('HealthColor',{ Default = Color3.fromRGB(0,255,0),    Title = 'Health Color' })

GRainbow:AddToggle('RainbowEnabled', { Text = 'Rainbow Mode', Default = false })
GRainbow:AddSlider('RainbowSpeed',   { Text = 'Rainbow Speed', Default = 1, Min = 0.1, Max = 5, Rounding = 1 })
GRainbow:AddDropdown('RainbowParts', { Text = 'Rainbow Parts', Values = {'All','Box Only','Tracers Only','Text Only'}, Default = 'All', Multi = false })

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  TAB â€” AIMBOT
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local SilentGroup  = Tabs.Aimbot:AddLeftGroupbox('Silent Aim')
local TriggerGroup = Tabs.Aimbot:AddRightGroupbox('Triggerbot')
local TargetGroup  = Tabs.Aimbot:AddLeftGroupbox('Targeting')

-- Silent Aim (Left)
SilentGroup:AddToggle('SilentAimEnabled', {
    Text    = 'Enable Silent Aim',
    Default = false,
    Tooltip = 'Redirects the shot direction to the acquired target',
})
    :AddKeyPicker('SilentAimKey', {
        Default = 'X',
        NoUI    = false,
        Text    = 'Silent Aim',
        Mode    = 'Toggle',
        SyncToggleState = true,
        Callback = function()
            Library:Notify(Toggles.SilentAimEnabled.Value and 'Silent Aim Enabled' or 'Silent Aim Disabled', 5)
        end,
    })

SilentGroup:AddSlider('SilentHitChance', {
    Text     = 'Hit Chance',
    Default  = 100,
    Min      = 0,
    Max      = 100,
    Rounding = 0,
    Suffix   = '%',
    Tooltip  = 'Chance each shot gets redirected',
})

SilentGroup:AddToggle('SilentManipulation', {
    Text    = 'Manipulation',
    Default = false,
    Tooltip = 'Puts you in a valid spot behind the target while shooting',
})
SilentGroup:AddToggle('SilentVisualize', {
    Text    = 'Visualize',
    Default = false,
    Tooltip = 'Shows a neon marker where manipulation puts you',
})

-- Triggerbot (Right)
TriggerGroup:AddToggle('TriggerbotEnabled', {
    Text    = 'Enable Triggerbot',
    Default = false,
    Tooltip = 'Automatically fires once a target is locked',
})
    :AddKeyPicker('TriggerbotKey', {
        Default = 'Q',
        NoUI    = false,
        Text    = 'Triggerbot',
        Mode    = 'Toggle',
        SyncToggleState = true,
        Callback = function()
            Library:Notify(Toggles.TriggerbotEnabled.Value and 'Triggerbot Enabled' or 'Triggerbot Disabled', 5)
        end,
    })

TriggerGroup:AddSlider('TriggerbotDelay', {
    Text     = 'Shoot Delay',
    Default  = 0,
    Min      = 0,
    Max      = 300,
    Rounding = 0,
    Suffix   = 'ms',
    Tooltip  = 'Delay between locking a target and firing',
})

TriggerGroup:AddDropdown('TriggerbotScoped', {
    Text    = 'Check Scoped',
    Values  = kCheckScoped,
    Default = { 'Sniper', 'Crossbow' },
    Multi   = true,
    Tooltip = 'Weapons that must be fully scoped before the triggerbot fires',
})

-- Targeting (Left)
TargetGroup:AddDropdown('TargetGroup', {
    Text    = 'Target Group',
    Values  = kTargetList,
    Default = 'Visible',
    Multi   = false,
    Tooltip = 'Visible = any on-screen target, FOV = must be inside the FOV circle',
})

TargetGroup:AddDropdown('TargetIgnore', {
    Text    = 'Ignore',
    Values  = kGunIgnoreList,
    Default = { 'None' },
    Multi   = true,
    Tooltip = 'Defences / weapons to skip while acquiring targets',
})

TargetGroup:AddSlider('TargetRadius', {
    Text     = 'Radius',
    Default  = 100,
    Min      = 0,
    Max      = 500,
    Rounding = 0,
    Tooltip  = 'FOV circle radius in screen pixels',
})

TargetGroup:AddSlider('TargetMaxDistance', {
    Text     = 'Max Distance',
    Default  = 150,
    Min      = 50,
    Max      = 1000,
    Rounding = 0,
})

TargetGroup:AddSlider('TargetWeightRatio', {
    Text     = 'Weight Ratio',
    Default  = 0.7,
    Min      = 0,
    Max      = 1,
    Rounding = 1,
    Tooltip  = '0 = distance only, 1 = on-screen distance only',
})

TargetGroup:AddSlider('TargetReactionTime', {
    Text     = 'Reaction Time',
    Default  = 0,
    Min      = 0,
    Max      = 300,
    Rounding = 0,
    Suffix   = 'ms',
})

TargetGroup:AddSlider('TargetForgetTime', {
    Text     = 'Forget Time',
    Default  = 1,
    Min      = 0,
    Max      = 10,
    Rounding = 1,
    Suffix   = 's',
    Tooltip  = 'How long before a lost target is dropped',
})

TargetGroup:AddDropdown('TargetPart', {
    Text    = 'Target',
    Values  = { 'Closest Part', 'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso', 'LeftFoot', 'LeftLowerLeg', 'LeftUpperLeg', 'RightFoot', 'RightLowerLeg', 'RightUpperLeg', 'LeftHand', 'LeftLowerArm', 'LeftUpperArm', 'RightHand', 'RightLowerArm', 'RightUpperArm' },
    Default = 'Closest Part',
    Multi   = false,
})

TargetGroup:AddDropdown('TargetIncludeParts', {
    Text    = 'Include Parts',
    Values  = kBodyParts,
    Default = { 'Head', 'UpperTorso' },
    Multi   = true,
    Tooltip = 'Parts considered when targeting the closest part',
})

TargetGroup:AddToggle('TargetWallcheck', {
    Text    = 'Wallcheck',
    Default = true,
    Tooltip = 'Skips targets blocked by walls',
})
TargetGroup:AddToggle('TargetShowFOV', {
    Text    = 'Show FOV',
    Default = false,
    Tooltip = 'Draws the FOV circle on screen',
})
TargetGroup:AddToggle('FovOutline', {
    Text    = 'FOV Outline',
    Default = false,
})
TargetGroup:AddToggle('FovFill', {
    Text    = 'FOV Fill',
    Default = false,
})
TargetGroup:AddSlider('FovLerp', {
    Text     = 'FOV Lerp',
    Default  = 1,
    Min      = 0.1,
    Max      = 1,
    Rounding = 2,
})

-- =====================================================
--  TAB - RAGEBOT  (Rage Bot / Weapon Mods / Anti Aim)
-- =====================================================
local RageBotGroup = Tabs.Ragebot:AddLeftGroupbox('Rage Bot')
local WeaponMods   = Tabs.Ragebot:AddRightGroupbox('Weapon Mods')
local AntiAimGroup = Tabs.Ragebot:AddLeftGroupbox('Anti Aim')

-- Rage Bot (Left)
RageBotGroup:AddToggle('RageBotEnabled', {
    Text    = 'Enable Rage Bot',
    Default = false,
    Tooltip = 'Auto-locks and fires at the acquired target',
})
    :AddKeyPicker('RageBotKey', {
        Default = 'F',
        NoUI    = false,
        Text    = 'Rage Bot',
        Mode    = 'Toggle',
        SyncToggleState = true,
        Callback = function()
            Library:Notify(Toggles.RageBotEnabled.Value and 'Rage Bot Enabled' or 'Rage Bot Disabled', 5)
        end,
    })

RageBotGroup:AddToggle('RageVoidSpam', {
    Text    = 'Void Spam',
    Default = false,
    Tooltip = 'Drops you far below the map while hiding (OOB exploit)',
})

RageBotGroup:AddSlider('RageHide', {
    Text     = 'Hide',
    Default  = 0.25,
    Min      = 0.01,
    Max      = 1,
    Rounding = 2,
    Tooltip  = 'How long you stay hidden (void) per cycle',
})

RageBotGroup:AddSlider('RageAttack', {
    Text     = 'Attack',
    Default  = 0.1,
    Min      = 0.01,
    Max      = 1,
    Rounding = 2,
    Tooltip  = 'How long you are visible (shooting) per cycle',
})

RageBotGroup:AddSlider('RageShootAttempts', {
    Text     = 'Shoot Attempts',
    Default  = 1,
    Min      = 1,
    Max      = 2,
    Rounding = 0,
})

RageBotGroup:AddDropdown('RageAttackMode', {
    Text    = 'Attack Mode',
    Values  = { 'Gun', 'Knife', 'Melee' },
    Default = 'Gun',
    Multi   = false,
})

RageBotGroup:AddDropdown('RagePreferred', {
    Text    = 'Preferred',
    Values  = { 'Primary', 'Secondary' },
    Default = 'Primary',
    Multi   = false,
})

RageBotGroup:AddToggle('RageHitNotifications', {
    Text    = 'Hit Notifications',
    Default = true,
})
RageBotGroup:AddToggle('RageHUD', {
    Text    = 'Rage HUD',
    Default = true,
    Tooltip = 'Shows rage status and the current target',
})

-- Weapon Mods (Right)
WeaponMods:AddToggle('RageNoRecoil', {
    Text    = 'No Recoil',
    Default = false,
})
WeaponMods:AddToggle('RageNoSpread', {
    Text    = 'No Spread',
    Default = false,
})
WeaponMods:AddToggle('RageFullAuto', {
    Text    = 'Full Auto',
    Default = false,
    Tooltip = 'Removes the semi-auto fire delay',
})
WeaponMods:AddSlider('RageFirerate', {
    Text     = 'Firerate',
    Default  = 100,
    Min      = 10,
    Max      = 100,
    Rounding = 0,
    Suffix   = '%',
})

-- Anti Aim (Left)
AntiAimGroup:AddToggle('AntiAimEnabled', {
    Text    = 'Enable Anti Aim',
    Default = false,
    Tooltip = 'Fakes your camera rotation to other players',
})
    :AddKeyPicker('AntiAimKey', {
        Default = 'G',
        NoUI    = false,
        Text    = 'Anti Aim',
        Mode    = 'Toggle',
        SyncToggleState = true,
        Callback = function()
            Library:Notify(Toggles.AntiAimEnabled.Value and 'Anti Aim Enabled' or 'Anti Aim Disabled', 5)
        end,
    })

AntiAimGroup:AddDropdown('AntiAimPitch', {
    Text    = 'Pitch',
    Values  = kPitchOptions,
    Default = 'None',
    Multi   = false,
})
AntiAimGroup:AddSlider('AntiAimPitchAngle', {
    Text     = 'Pitch Angle',
    Default  = 0,
    Min      = -180,
    Max      = 180,
    Rounding = 0,
})
AntiAimGroup:AddDropdown('AntiAimYaw', {
    Text    = 'Yaw',
    Values  = kYawOptions,
    Default = 'None',
    Multi   = false,
})
AntiAimGroup:AddSlider('AntiAimYawAngle', {
    Text     = 'Yaw Angle',
    Default  = 0,
    Min      = -180,
    Max      = 180,
    Rounding = 0,
})
AntiAimGroup:AddSlider('AntiAimJitterAngle', {
    Text     = 'Jitter Angle',
    Default  = 20,
    Min      = -180,
    Max      = 180,
    Rounding = 0,
})
AntiAimGroup:AddSlider('AntiAimSpeed', {
    Text     = 'Spin/Jitter Speed',
    Default  = 10,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
})
AntiAimGroup:AddToggle('AntiAimUnderground', {
    Text    = 'Underground',
    Default = false,
    Tooltip = 'Snaps you below the floor while anti-aim is on',
})

-- ---- Aimbot wiring ----
Toggles.SilentAimEnabled:OnChanged(function(v) SetSilentAimEnabled(v) end)
Toggles.SilentManipulation:OnChanged(function(v) states.legit_state.silent_aim.manipulation = v end)
Toggles.SilentVisualize:OnChanged(function(v) states.legit_state.silent_aim.visualize = v end)
Options.SilentHitChance:OnChanged(function(v) states.legit_state.silent_aim.hit_chance = v end)

Toggles.TriggerbotEnabled:OnChanged(function(v) SetTriggerbotEnabled(v) end)
Options.TriggerbotDelay:OnChanged(function(v) states.legit_state.triggerbot.shoot_delay = v end)
Options.TriggerbotScoped:OnChanged(function(v) states.legit_state.triggerbot.check_scoped = multiToList(v) end)

Options.TargetGroup:OnChanged(function(v) states.targeting_state.target_group = v end)
Options.TargetIgnore:OnChanged(function(v) states.targeting_state.ignore = multiToList(v) end)
Options.TargetRadius:OnChanged(function(v) states.targeting_state.radius = v end)
Options.TargetMaxDistance:OnChanged(function(v) states.targeting_state.max_distance = v end)
Options.TargetWeightRatio:OnChanged(function(v) states.targeting_state.weight_ratio = v end)
Options.TargetReactionTime:OnChanged(function(v) states.targeting_state.reaction_time = v end)
Options.TargetForgetTime:OnChanged(function(v) states.targeting_state.forget_time = v end)
Options.TargetPart:OnChanged(function(v) states.targeting_state.target = v end)
Options.TargetIncludeParts:OnChanged(function(v) states.targeting_state.include_parts = multiToList(v) end)
Toggles.TargetWallcheck:OnChanged(function(v) states.targeting_state.wallcheck = v end)
Toggles.TargetShowFOV:OnChanged(function(v) states.targeting_state.show_fov = v end)
Toggles.FovOutline:OnChanged(function(v) states.targeting_state.fov_outline = v end)
Toggles.FovFill:OnChanged(function(v) states.targeting_state.fov_fill = v end)
Options.FovLerp:OnChanged(function(v) states.targeting_state.fov_lerp = v end)

-- ---- Ragebot wiring ----
Toggles.RageBotEnabled:OnChanged(function(v) SetRageBotEnabled(v) end)
Toggles.RageVoidSpam:OnChanged(function(v) SetVoidSpamEnabled(v) end)
Options.RageHide:OnChanged(function(v) states.rage_state.rage_bot.hide = v end)
Options.RageAttack:OnChanged(function(v) states.rage_state.rage_bot.attack = v end)
Options.RageShootAttempts:OnChanged(function(v) states.rage_state.rage_bot.shoot_attempts = v end)
Options.RageAttackMode:OnChanged(function(v) states.rage_state.rage_bot.attack_mode = v end)
Options.RagePreferred:OnChanged(function(v) states.rage_state.rage_bot.preferred = v end)
Toggles.RageHitNotifications:OnChanged(function(v) states.rage_state.rage_bot.hit_notifications = v end)
Toggles.RageHUD:OnChanged(function(v) states.rage_state.rage_bot.rage_hud = v end)

Toggles.RageNoRecoil:OnChanged(function(v) states.rage_state.weapons.no_recoil = v end)
Toggles.RageNoSpread:OnChanged(function(v) states.rage_state.weapons.no_spread = v end)
Toggles.RageFullAuto:OnChanged(function(v) states.rage_state.weapons.full_auto = v end)
Options.RageFirerate:OnChanged(function(v) states.rage_state.weapons.firerate = v end)

Toggles.AntiAimEnabled:OnChanged(function(v) SetAntiAimEnabled(v) end)
Options.AntiAimPitch:OnChanged(function(v) states.rage_state.anti_aim.pitch = v end)
Options.AntiAimPitchAngle:OnChanged(function(v) states.rage_state.anti_aim.pitch_angle = v end)
Options.AntiAimYaw:OnChanged(function(v) states.rage_state.anti_aim.yaw = v end)
Options.AntiAimYawAngle:OnChanged(function(v) states.rage_state.anti_aim.yaw_angle = v end)
Options.AntiAimJitterAngle:OnChanged(function(v) states.rage_state.anti_aim.jitter_angle = v end)
Options.AntiAimSpeed:OnChanged(function(v) states.rage_state.anti_aim.speed = v end)
Toggles.AntiAimUnderground:OnChanged(function(v) states.rage_state.anti_aim.underground = v end)
-- ══════════════════════════════════════════
--  TAB — WEAPON  (gun mods)
-- ══════════════════════════════════════════
local setupWeaponHook = nil
local hookStatus = nil

local GWeapon = Tabs.Weapon:AddLeftGroupbox('Gun Mods')
local GInfo   = Tabs.Weapon:AddRightGroupbox('Status')

GWeapon:AddToggle('NoRecoil', {
    Text    = 'No Recoil',
    Default = false,
    Tooltip = 'Zeroes ShootRecoil while the Input hook is active',
})

GWeapon:AddToggle('NoSpread', {
    Text    = 'No Spread',
    Default = false,
    Tooltip = 'Zeroes ShootSpread — bullets go perfectly straight',
})

GWeapon:AddToggle('FireSpeed', {
    Text    = 'Fire Speed Changer',
    Default = false,
    Tooltip = 'Scales the weapon cooldown so it fires faster',
})

GWeapon:AddSlider('FireSpeedMult', {
    Text     = 'Fire Speed',
    Default  = 2,
    Min      = 1,
    Max      = 10,
    Rounding = 1,
    Suffix   = 'x',
    Tooltip  = 'Multiplier on the fire rate (higher = faster)',
})

hookStatus = GInfo:AddLabel('Hook status: not installed yet')
GInfo:AddButton({
    Text = 'Retry weapon hook',
    Func = function()
        local ok = setupWeaponHook()
        if hookStatus then hookStatus:SetText('Hook status: ' .. (ok and 'ACTIVE' or 'FAILED')) end
    end,
})

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  TAB â€” VISUALS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local GSelf  = Tabs.Visuals:AddLeftGroupbox('Character')
local GWorld = Tabs.Visuals:AddRightGroupbox('World')

GSelf:AddToggle('CharRGB',     { Text = 'RGB Character', Default = false })
GSelf:AddSlider('CharRGBSpeed',{ Text = 'RGB Speed',     Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = 'x' })
GSelf:AddToggle('RainbowName', { Text = 'RGB Nametag',   Default = false })
GSelf:AddDivider()
GSelf:AddLabel('Camera')
GSelf:AddToggle('FovEnabled', { Text = 'Custom FOV', Default = false })
GSelf:AddSlider('FovValue',   { Text = 'Field of View', Default = 90, Min = 20, Max = 160, Rounding = 0, Suffix = 'deg' })

GWorld:AddToggle('Fullbright', { Text = 'Fullbright', Default = false })

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  TAB â€” MOVEMENT
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local GMove   = Tabs.Movement:AddLeftGroupbox('Movement')
local GCustom = Tabs.Movement:AddRightGroupbox('Customization')

GMove:AddToggle('Fly',        { Text = 'Fly',        Default = false })
GMove:AddSlider('FlySpeed',   { Text = 'Fly Speed',  Default = 30, Min = 5, Max = 120, Rounding = 1 })
GMove:AddToggle('Noclip',     { Text = 'Noclip',     Default = false })
GMove:AddToggle('SpeedHack',  { Text = 'Speed Hack', Default = false })
GMove:AddSlider('WalkSpeed',  { Text = 'WalkSpeed',  Default = 32, Min = 16, Max = 200, Rounding = 1 })
GMove:AddToggle('JumpPower',  { Text = 'Jump Power', Default = false })
GMove:AddSlider('JumpPowerVal',{ Text = 'Jump Height',Default = 50, Min = 0, Max = 300, Rounding = 1 })

GCustom:AddSlider('FlyVertSpeed', { Text = 'Vertical Fly Speed', Default = 20,  Min = 5, Max = 80,  Rounding = 1 })
GCustom:AddSlider('FlySmoothness',{ Text = 'Fly Smoothness',     Default = 6,   Min = 1, Max = 20,  Rounding = 1, Suffix = 'x' })
GCustom:AddToggle('Spinbot',      { Text = 'Spinbot',            Default = false })
GCustom:AddSlider('SpinSpeed',    { Text = 'Spin Speed',         Default = 90,  Min = 10, Max = 720, Rounding = 0, Suffix = 'deg/s' })

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  TAB â€” SETTINGS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local GMenu = Tabs.Settings:AddLeftGroupbox('Menu')

GMenu:AddButton({ Text = 'Unload script', Func = function() Library:Unload() end })
GMenu:AddLabel('Menu keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'End', NoUI = false, Text = 'Toggle menu', Mode = 'Toggle',
})
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('VoidSpam')
SaveManager:SetFolder('VoidSpam/configs')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

Library:SetWatermarkVisibility(true)
Library:SetWatermark('Void Spam v10  |  client-sided only')

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  MOBILE PANEL
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
if isMobile then
    local mobileSG            = Instance.new("ScreenGui")
    mobileSG.Name             = "VoidSpamMobilePanel"
    mobileSG.ResetOnSpawn     = false
    mobileSG.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    mobileSG.DisplayOrder     = 1000
    mobileSG.IgnoreGuiInset   = true
    mobileSG.Parent           = playerGui

    local panel               = Instance.new("Frame")
    panel.Size                = UDim2.fromOffset(114, 58)
    panel.Position            = UDim2.fromOffset(6, 110)
    panel.BackgroundColor3    = Color3.fromRGB(10, 10, 15)
    panel.BorderSizePixel     = 0
    panel.Parent              = mobileSG
    local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,4) pc.Parent = panel
    local ps = Instance.new("UIStroke") ps.Color = Color3.fromRGB(45,55,90) ps.Thickness = 1 ps.Parent = panel

    local function mobileBtn(txt, y)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 26) b.Position = UDim2.fromOffset(0, y)
        b.BackgroundColor3 = Color3.fromRGB(10, 10, 15) b.TextColor3 = Color3.fromRGB(210, 210, 220)
        b.Text = txt b.Font = Enum.Font.Code b.TextSize = 13
        b.BorderSizePixel = 0 b.AutoButtonColor = false b.Parent = panel
        b.MouseButton1Down:Connect(function() b.BackgroundColor3 = Color3.fromRGB(22,22,35) end)
        b.MouseButton1Up:Connect(function()   b.BackgroundColor3 = Color3.fromRGB(10,10,15) end)
        return b
    end

    local btnToggle = mobileBtn("Toggle UI", 0)
    local btnLock   = mobileBtn("Lock UI",  28)

    btnToggle.MouseButton1Click:Connect(function()
        if Library.GUI then Library.GUI.Enabled = not Library.GUI.Enabled end
    end)
    local locked = false
    btnLock.MouseButton1Click:Connect(function()
        locked = not locked
        btnLock.TextColor3 = locked and Color3.fromRGB(75,130,255) or Color3.fromRGB(210,210,220)
        btnLock.Text = locked and "Locked" or "Lock UI"
    end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  HELPERS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function getRoot()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function TG(idx)  return Toggles[idx] and Toggles[idx].Value  or false end
local function SL(idx)  return Options[idx]  and Options[idx].Value  or 0     end
local function COL(idx, dflt)
    local o = Options[idx]
    return (o and o.Value) or dflt
end

local hue      = 0
local hueColor = Color3.fromRGB(255, 255, 255)

-- ══════════════════════════════════════════
--  WEAPON HOOK  (Rivals ClientItem.Input)
--  Hooks the local client item module so we can zero
--  recoil / spread and scale the fire cooldown each shot.
-- ══════════════════════════════════════════
local gunItemModule = nil
local gunHook = nil
local gunFallback = false
local gunFallbackConn = nil

local function findItemModule()
    local ok, mod = pcall(function()
        local ps = player:FindFirstChild('PlayerScripts')
        local m  = ps and ps:FindFirstChild('Modules')
        m = m and m:FindFirstChild('ClientReplicatedClasses')
        m = m and m:FindFirstChild('ClientFighter')
        m = m and m:FindFirstChild('ClientItem')
        return require(m)
    end)
    if ok and mod then return mod end
    return nil
end

-- GC-sweep fallback: sets recoil/spread/cooldown on any table that
-- carries the Rivals weapon-attribute keys (works without hookfunction)
local function applyGunSweep()
    if not getgc then return end
    for _, val in pairs(getgc(true)) do
        if type(val) == 'table' then
            if TG('NoRecoil') then
                if rawget(val, 'ShootRecoil') ~= nil then val.ShootRecoil = 0 end
                if rawget(val, 'Recoil') ~= nil then val.Recoil = 0 end
            end
            if TG('NoSpread') then
                if rawget(val, 'ShootSpread') ~= nil then val.ShootSpread = 0 end
                if rawget(val, 'Spread') ~= nil then val.Spread = 0 end
            end
            if TG('FireSpeed') then
                local mult = math.max(SL('FireSpeedMult'), 0.1)
                if rawget(val, 'ShootCooldown') ~= nil then val.ShootCooldown = val.ShootCooldown / mult end
                if rawget(val, 'FireRate') ~= nil then val.FireRate = val.FireRate * mult end
            end
        end
    end
end

setupWeaponHook = function()
    local ok = false
    pcall(function()
        local mod = findItemModule()
        if not mod then return end
        local input = mod.Input
        if type(input) ~= 'function' then return end
        local old = input
        gunHook = hookfunction(input, function(...)
            local args = { ... }
            local state = args[1]
            if type(state) == 'table' then
                local info = state.Info
                if type(info) == 'table' then
                    if TG('NoRecoil') then
                        if info.ShootRecoil ~= nil then info.ShootRecoil = 0 end
                        if info.Recoil ~= nil then info.Recoil = 0 end
                    end
                    if TG('NoSpread') then
                        if info.ShootSpread ~= nil then info.ShootSpread = 0 end
                        if info.Spread ~= nil then info.Spread = 0 end
                    end
                    if TG('FireSpeed') then
                        local mult = math.max(SL('FireSpeedMult'), 0.1)
                        if info.ShootCooldown ~= nil then info.ShootCooldown = info.ShootCooldown / mult end
                        if info.FireRate ~= nil then info.FireRate = info.FireRate * mult end
                    end
                end
            end
            return old(...)
        end)
        gunItemModule = mod
        ok = true
    end)
    if not ok then
        gunHook = nil
        if getgc then
            gunFallback = true
            if not gunFallbackConn then
                gunFallbackConn = RunService.Heartbeat:Connect(function()
                    if not (TG('NoRecoil') or TG('NoSpread') or TG('FireSpeed')) then return end
                    pcall(applyGunSweep)
                end)
            end
            ok = true
        end
    end
    if hookStatus then
        pcall(function() hookStatus:SetText('Hook status: ' .. (ok and 'ACTIVE' or 'FAILED')) end)
    end
    return ok
end

-- auto-install once the modules exist, and re-try on respawn
task.spawn(function()
    while not setupWeaponHook() do task.wait(2) end
end)
player.CharacterAdded:Connect(function()
    task.wait(3)
    setupWeaponHook()
end)


-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  FULLBRIGHT
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local LightSnapshot = {
    Brightness     = Lighting.Brightness,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows  = Lighting.GlobalShadows,
    ClockTime      = Lighting.ClockTime,
}
local function applyFullbright(on)
    if on then
        Lighting.Brightness     = 1
        Lighting.Ambient        = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.GlobalShadows  = false
        Lighting.ClockTime      = 12
    else
        Lighting.Brightness     = LightSnapshot.Brightness
        Lighting.Ambient        = LightSnapshot.Ambient
        Lighting.OutdoorAmbient = LightSnapshot.OutdoorAmbient
        Lighting.GlobalShadows  = LightSnapshot.GlobalShadows
        Lighting.ClockTime      = LightSnapshot.ClockTime
    end
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  FOV OVERRIDE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local fovApplied = false
local origFOV    = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70
local function applyFov(on, value)
    local cam = workspace.CurrentCamera
    if not cam then return end
    if on then
        cam.FieldOfView = value
        fovApplied = true
    elseif fovApplied then
        cam.FieldOfView = origFOV
        fovApplied = false
    end
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  RGB CHARACTER / NAMETAG
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function paintCharacter(color)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.Color = color end
    end
end
local function paintNametag(color)
    local nt = playerGui:FindFirstChild("Nametag") or playerGui:FindFirstChild("NameTag")
    if not nt then return end
    for _, lbl in ipairs(nt:GetDescendants()) do
        if lbl:IsA("TextLabel") then lbl.TextColor3 = color end
    end
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  ESP  (Drawing-based)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local ESP = {}
local Camera = workspace.CurrentCamera
local function GetCam() return workspace.CurrentCamera or Camera end

local function CreateESP(p)
    if p == player or ESP[p] then return end
    local ok, err = pcall(function()
        local box = {}
        for i = 1, 12 do
            box[i] = Drawing.new("Line")
            box[i].Visible   = false
            box[i].Thickness = 1
        end
        local fill = Drawing.new("Quad")
        fill.Visible = false fill.Filled = true fill.Color = Color3.new(1,1,1)
        local tracer = Drawing.new("Line")
        tracer.Visible = false tracer.Thickness = 1
        local hbOut = Drawing.new("Square") hbOut.Visible = false hbOut.Color = Color3.new() hbOut.Thickness = 1 hbOut.Filled = false
        local hbFill= Drawing.new("Square") hbFill.Visible = false hbFill.Filled = true
        local hbTxt = Drawing.new("Text")   hbTxt.Visible = false hbTxt.Center = true hbTxt.Outline = true hbTxt.Font = 2
        local name  = Drawing.new("Text")   name.Visible = false  name.Center = true  name.Outline = true  name.Font = 2
        local dist  = Drawing.new("Text")   dist.Visible = false  dist.Center = true  dist.Outline = true  dist.Font = 2
        local snap  = Drawing.new("Line")   snap.Visible = false  snap.Thickness = 1
        local skel  = {}
        for i = 1, 19 do
            skel[i] = Drawing.new("Line")
            skel[i].Visible = false
        end
        ESP[p] = {
            Box = box, Fill = fill, Tracer = tracer,
            HealthBar = { Outline = hbOut, Fill = hbFill, Text = hbTxt },
            Name = name, Distance = dist, Snapline = snap, Skeleton = skel,
            Highlights = nil,
        }
    end)
    if not ok then warn('[VoidSpam] CreateESP error: ' .. tostring(err)) end
end

local function RemoveESP(p)
    local esp = ESP[p]
    if not esp then return end
    for i = 1,12 do esp.Box[i]:Remove() end
    esp.Fill:Remove() esp.Tracer:Remove()
    esp.HealthBar.Outline:Remove() esp.HealthBar.Fill:Remove() esp.HealthBar.Text:Remove()
    esp.Name:Remove() esp.Distance:Remove() esp.Snapline:Remove()
    for i = 1,19 do esp.Skeleton[i]:Remove() end
    if esp.Highlights then
        for _, hl in ipairs(esp.Highlights) do pcall(function() hl:Destroy() end) end
    end
    ESP[p] = nil
end

local function CleanupESP()
    for p in pairs(ESP) do RemoveESP(p) end
end

local function GetPlayerColor(p)
    if TG('RainbowEnabled') then
        local parts = SL('RainbowParts')
        if parts == 'All'
        or (parts == 'Box Only'     and TG('BoxESP'))
        or (parts == 'Tracers Only' and TG('TracerESP'))
        or (parts == 'Text Only'    and (TG('HealthESP') or TG('SkeletonESP')))
        then return hueColor end
    end
    local pTeam  = p.Team  or p.TeamColor
    local myTeam = player.Team or player.TeamColor
    if pTeam and myTeam and pTeam == myTeam then
        return COL('AllyColor', Color3.fromRGB(25,255,25))
    end
    return COL('EnemyColor', Color3.fromRGB(255,25,25))
end

local function GetTracerOrigin()
    local cam = GetCam()
    local o = SL('TracerOrigin')
    if o == 'Bottom' then return Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
    elseif o == 'Top' then return Vector2.new(cam.ViewportSize.X/2, 0)
    elseif o == 'Mouse' then return UIS:GetMouseLocation()
    else return Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2) end
end

local function hideAll(esp)
    for i=1,12 do esp.Box[i].Visible=false end
    esp.Fill.Visible=false esp.Tracer.Visible=false
    esp.HealthBar.Outline.Visible=false esp.HealthBar.Fill.Visible=false esp.HealthBar.Text.Visible=false
    esp.Name.Visible=false esp.Distance.Visible=false esp.Snapline.Visible=false
    for i=1,19 do esp.Skeleton[i].Visible=false end
end

local function toV2(v) return Vector2.new(v.X, v.Y) end

local function UpdateESP(p)
    local esp = ESP[p]
    if not esp then return end
    if not TG('ESPEnabled') then hideAll(esp) return end

    local cam       = GetCam()
    local character = p.Character
    local rootPart  = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid  = character and character:FindFirstChild("Humanoid")

    if not (character and rootPart and humanoid) or humanoid.Health <= 0 then hideAll(esp) return end

    local pos, onScreen = cam:WorldToViewportPoint(rootPart.Position)
    local distStuds     = (rootPart.Position - cam.CFrame.Position).Magnitude

    if not onScreen or distStuds > SL('MaxDistance') then hideAll(esp) return end

    local pTeam  = p.Team or p.TeamColor
    local myTeam = player.Team or player.TeamColor
    if TG('TeamCheck') and pTeam and myTeam and pTeam == myTeam and not TG('ShowTeam') then
        hideAll(esp) return
    end

    local color    = GetPlayerColor(p)
    local textSize = SL('TextSize')

    local size = Vector3.new(5, 7, 3)
    pcall(function() size = character:GetExtentsSize() end)
    size = Vector3.new(math.clamp(size.X,2,20), math.clamp(size.Y,4,25), math.clamp(size.Z,2,20))

    local cf     = rootPart.CFrame
    local topV,  topOn    = cam:WorldToViewportPoint((cf * CFrame.new(0,  size.Y/2, 0)).Position)
    local botV,  botOn    = cam:WorldToViewportPoint((cf * CFrame.new(0, -size.Y/2, 0)).Position)
    if not (topOn and botOn) then hideAll(esp) return end

    local screenH = botV.Y - topV.Y
    local boxW    = screenH * 0.65
    local boxPos  = Vector2.new(topV.X - boxW/2, topV.Y)
    local boxSize = Vector2.new(boxW, screenH)

    -- BOX
    for i=1,12 do esp.Box[i].Visible=false end
    esp.Fill.Visible = false

    if TG('BoxESP') then
        local style = SL('BoxStyle')
        if style == 'ThreeD' then
            local corners = {
                FF = {cf*CFrame.new(-size.X/2, size.Y/2,-size.Z/2)},
                FR = {cf*CFrame.new( size.X/2, size.Y/2,-size.Z/2)},
                FB = {cf*CFrame.new(-size.X/2,-size.Y/2,-size.Z/2)},
                FBR= {cf*CFrame.new( size.X/2,-size.Y/2,-size.Z/2)},
                BF = {cf*CFrame.new(-size.X/2, size.Y/2, size.Z/2)},
                BR = {cf*CFrame.new( size.X/2, size.Y/2, size.Z/2)},
                BB = {cf*CFrame.new(-size.X/2,-size.Y/2, size.Z/2)},
                BBR= {cf*CFrame.new( size.X/2,-size.Y/2, size.Z/2)},
            }
            local function sp(c)
                local p2,v = cam:WorldToViewportPoint(c[1].Position)
                return v, Vector2.new(p2.X,p2.Y)
            end
            local fTLv,fTL = sp(corners.FF) local fTRv,fTR = sp(corners.FR)
            local fBLv,fBL = sp(corners.FB) local fBRv,fBR = sp(corners.FBR)
            local bTLv,bTL = sp(corners.BF) local bTRv,bTR = sp(corners.BR)
            local bBLv,bBL = sp(corners.BB) local bBRv,bBR = sp(corners.BBR)
            if (fTLv and fTRv and fBLv and fBRv and bTLv and bTRv and bBLv and bBRv) then
                local B = esp.Box
                B[1].From,B[1].To,B[1].Visible=fTL,fTR,true B[2].From,B[2].To,B[2].Visible=fTR,fBR,true
                B[3].From,B[3].To,B[3].Visible=fBR,fBL,true B[4].From,B[4].To,B[4].Visible=fBL,fTL,true
                B[5].From,B[5].To,B[5].Visible=bTL,bTR,true B[6].From,B[6].To,B[6].Visible=bTR,bBR,true
                B[7].From,B[7].To,B[7].Visible=bBR,bBL,true B[8].From,B[8].To,B[8].Visible=bBL,bTL,true
                B[9].From,B[9].To,B[9].Visible=fTL,bTL,true B[10].From,B[10].To,B[10].Visible=fTR,bTR,true
                B[11].From,B[11].To,B[11].Visible=fBL,bBL,true B[12].From,B[12].To,B[12].Visible=fBR,bBR,true
            end
        elseif style == 'Corner' then
            local cs = boxW * 0.2
            local B = esp.Box
            B[1].From,B[1].To,B[1].Visible = boxPos, boxPos+Vector2.new(cs,0), true
            B[2].From,B[2].To,B[2].Visible = boxPos, boxPos+Vector2.new(0,cs), true
            B[3].From,B[3].To,B[3].Visible = boxPos+Vector2.new(boxSize.X,0), boxPos+Vector2.new(boxSize.X-cs,0), true
            B[4].From,B[4].To,B[4].Visible = boxPos+Vector2.new(boxSize.X,0), boxPos+Vector2.new(boxSize.X,cs), true
            B[5].From,B[5].To,B[5].Visible = boxPos+Vector2.new(0,boxSize.Y), boxPos+Vector2.new(cs,boxSize.Y), true
            B[6].From,B[6].To,B[6].Visible = boxPos+Vector2.new(0,boxSize.Y), boxPos+Vector2.new(0,boxSize.Y-cs), true
            B[7].From,B[7].To,B[7].Visible = boxPos+Vector2.new(boxSize.X,boxSize.Y), boxPos+Vector2.new(boxSize.X-cs,boxSize.Y), true
            B[8].From,B[8].To,B[8].Visible = boxPos+Vector2.new(boxSize.X,boxSize.Y), boxPos+Vector2.new(boxSize.X,boxSize.Y-cs), true
        else -- Full
            local B = esp.Box
            B[1].From,B[1].To,B[1].Visible = boxPos, boxPos+Vector2.new(0,boxSize.Y), true
            B[2].From,B[2].To,B[2].Visible = boxPos+Vector2.new(boxSize.X,0), boxPos+Vector2.new(boxSize.X,boxSize.Y), true
            B[3].From,B[3].To,B[3].Visible = boxPos, boxPos+Vector2.new(boxSize.X,0), true
            B[4].From,B[4].To,B[4].Visible = boxPos+Vector2.new(0,boxSize.Y), boxPos+Vector2.new(boxSize.X,boxSize.Y), true
        end
        for i=1,12 do
            if esp.Box[i].Visible then
                esp.Box[i].Color = color
                esp.Box[i].Thickness = SL('BoxThickness')
            end
        end
        if TG('BoxFilled') and SL('BoxStyle') ~= 'ThreeD' then
            esp.Fill.PointA,esp.Fill.PointB = boxPos, boxPos+Vector2.new(boxSize.X,0)
            esp.Fill.PointC,esp.Fill.PointD = boxPos+Vector2.new(boxSize.X,boxSize.Y), boxPos+Vector2.new(0,boxSize.Y)
            esp.Fill.Color        = color
            esp.Fill.Transparency = SL('BoxFillTransparency')
            esp.Fill.Visible      = true
        end
    end

    -- TRACER
    if TG('TracerESP') then
        esp.Tracer.From = GetTracerOrigin() esp.Tracer.To = toV2(pos)
        esp.Tracer.Color = color esp.Tracer.Visible = true
    else esp.Tracer.Visible = false end

    -- HEALTH BAR
    if TG('HealthESP') then
        local hp  = humanoid.Health
        local mhp = math.max(humanoid.MaxHealth, 1)
        local pct = math.clamp(hp/mhp, 0, 1)
        local barH = screenH * 0.8
        local barW = 4
        local barPos = Vector2.new(boxPos.X - barW - 2, boxPos.Y + (screenH - barH)/2)
        esp.HealthBar.Outline.Size = Vector2.new(barW, barH) esp.HealthBar.Outline.Position = barPos esp.HealthBar.Outline.Visible = true
        esp.HealthBar.Fill.Size = Vector2.new(barW-2, barH*pct)
        esp.HealthBar.Fill.Position = Vector2.new(barPos.X+1, barPos.Y+barH*(1-pct))
        esp.HealthBar.Fill.Color = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 0)
        esp.HealthBar.Fill.Visible = true
        local hs = SL('HealthStyle')
        if hs == 'Text' or hs == 'Both' then
            esp.HealthBar.Text.Text = math.floor(hp)
            esp.HealthBar.Text.Position = Vector2.new(barPos.X+barW+8, barPos.Y+barH/2)
            esp.HealthBar.Text.Size = textSize esp.HealthBar.Text.Color = COL('HealthColor', Color3.new(0,1,0))
            esp.HealthBar.Text.Visible = true
        else esp.HealthBar.Text.Visible = false end
    else
        esp.HealthBar.Outline.Visible=false esp.HealthBar.Fill.Visible=false esp.HealthBar.Text.Visible=false
    end

    -- NAME + DISTANCE
    esp.Name.Text = p.DisplayName or p.Name
    esp.Name.Position = Vector2.new(boxPos.X+boxW/2, boxPos.Y-18)
    esp.Name.Size = textSize esp.Name.Color = color esp.Name.Visible = true

    esp.Distance.Text = string.format('%.0f st', distStuds)
    esp.Distance.Position = Vector2.new(boxPos.X+boxW/2, boxPos.Y-4)
    esp.Distance.Size = textSize-2 esp.Distance.Color = Color3.fromRGB(200,200,200)
    esp.Distance.Visible = true

    -- SNAPLINE
    if TG('Snaplines') then
        esp.Snapline.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
        esp.Snapline.To = toV2(pos) esp.Snapline.Color = color esp.Snapline.Visible = true
    else esp.Snapline.Visible = false end

    -- CHAMS
    if TG('ChamsEnabled') then
        local fillC = COL('ChamsFillColor', Color3.fromRGB(255,0,0))
        local occlC = COL('ChamsOccludedColor', Color3.fromRGB(150,0,0))
        local outC  = COL('ChamsOutlineColor',  Color3.fromRGB(255,255,255))
        local fillT = SL('ChamsTransparency') local outT = SL('ChamsOutlineTransparency')
        if not esp.Highlights then
            local hlV = Instance.new("Highlight") hlV.Name="_ESPVisible"   hlV.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hlV.Enabled=false
            local hlO = Instance.new("Highlight") hlO.Name="_ESPOccluded"  hlO.DepthMode=Enum.HighlightDepthMode.Occluded    hlO.Enabled=false
            esp.Highlights = {hlV, hlO}
        end
        for i, hl in ipairs(esp.Highlights) do
            hl.Parent=character hl.Adornee=character hl.Enabled=true
            hl.FillColor=i==1 and fillC or occlC hl.FillTransparency=fillT
            hl.OutlineColor=outC hl.OutlineTransparency=outT
        end
    elseif esp.Highlights then
        for _, hl in ipairs(esp.Highlights) do hl.Enabled=false end
    end

    -- SKELETON
    if TG('SkeletonESP') then
        local b = character
        local bones = {
            head  = b:FindFirstChild("Head"),
            upper = b:FindFirstChild("UpperTorso") or b:FindFirstChild("Torso"),
            lower = b:FindFirstChild("LowerTorso") or b:FindFirstChild("Torso"),
            la    = b:FindFirstChild("LeftUpperArm")  or b:FindFirstChild("Left Arm"),
            ll    = b:FindFirstChild("LeftLowerArm")  or b:FindFirstChild("Left Arm"),
            lh    = b:FindFirstChild("LeftHand")      or b:FindFirstChild("Left Arm"),
            ra    = b:FindFirstChild("RightUpperArm") or b:FindFirstChild("Right Arm"),
            rl    = b:FindFirstChild("RightLowerArm") or b:FindFirstChild("Right Arm"),
            rh    = b:FindFirstChild("RightHand")     or b:FindFirstChild("Right Arm"),
            lu    = b:FindFirstChild("LeftUpperLeg")  or b:FindFirstChild("Left Leg"),
            ll2   = b:FindFirstChild("LeftLowerLeg")  or b:FindFirstChild("Left Leg"),
            lf    = b:FindFirstChild("LeftFoot")      or b:FindFirstChild("Left Leg"),
            ru    = b:FindFirstChild("RightUpperLeg") or b:FindFirstChild("Right Leg"),
            rl2   = b:FindFirstChild("RightLowerLeg") or b:FindFirstChild("Right Leg"),
            rf    = b:FindFirstChild("RightFoot")     or b:FindFirstChild("Right Leg"),
        }
        local function drawBone(a, bPart, line)
            if not (a and bPart) then line.Visible=false return end
            local ap, av = cam:WorldToViewportPoint(a.Position)
            local bp, bv = cam:WorldToViewportPoint(bPart.Position)
            if not (av and bv) or ap.Z<0 or bp.Z<0 then line.Visible=false return end
            line.From=Vector2.new(ap.X,ap.Y) line.To=Vector2.new(bp.X,bp.Y)
            line.Color=COL('SkeletonColor',Color3.new(1,1,1))
            line.Thickness=SL('SkeletonThickness')
            line.Transparency=SL('SkeletonTransparency')
            line.Visible=true
        end
        local S = esp.Skeleton
        drawBone(bones.head,bones.upper,S[1]) drawBone(bones.upper,bones.lower,S[2])
        drawBone(bones.upper,bones.la,S[3])   drawBone(bones.la,bones.ll,S[4])   drawBone(bones.ll,bones.lh,S[5])
        drawBone(bones.upper,bones.ra,S[6])   drawBone(bones.ra,bones.rl,S[7])   drawBone(bones.rl,bones.rh,S[8])
        drawBone(bones.lower,bones.lu,S[9])   drawBone(bones.lu,bones.ll2,S[10]) drawBone(bones.ll2,bones.lf,S[11])
        drawBone(bones.lower,bones.ru,S[12])  drawBone(bones.ru,bones.rl2,S[13]) drawBone(bones.rl2,bones.rf,S[14])
    else
        for i=1,19 do esp.Skeleton[i].Visible=false end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.1); CreateESP(p) end)
end)
Players.PlayerRemoving:Connect(RemoveESP)

local espConn  = nil
local lastESP  = 0
espConn = RunService.RenderStepped:Connect(function()
    pcall(function()
        hueColor = Color3.fromHSV((tick() * SL('RainbowSpeed')) % 1, 1, 1)
        if not TG('ESPEnabled') then
            for p in pairs(ESP) do hideAll(ESP[p]) end
            return
        end
        local now = tick()
        if now - lastESP < 1/144 then return end
        lastESP = now
        -- create at most ONE esp per frame so the game never freezes on join
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and not ESP[plr] then
                CreateESP(plr)
                break
            end
        end
        for p in pairs(ESP) do
            pcall(UpdateESP, p)
        end
    end)
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  MOVEMENT
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local collideSaved = {}
local flyVel       = Vector3.zero
local origWalk, origJump = nil, nil
local flyBV = nil

local function ensureFlyBV(hrp)
    if flyBV and flyBV.Parent == hrp then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent   = hrp
end
local function stopFlyBV()
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
end

local function applyNoclip(on)
    local char = player.Character
    if not char then return end
    if on then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA('BasePart') then
                if collideSaved[part] == nil then collideSaved[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    else
        for part, val in pairs(collideSaved) do
            if part.Parent then pcall(function() part.CanCollide = val end) end
        end
        collideSaved = {}
    end
end

local moveConn = RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local char     = player.Character
        local hrp      = char and char:FindFirstChild('HumanoidRootPart')
        local humanoid = char and char:FindFirstChildOfClass('Humanoid')

        applyNoclip(TG('Noclip'))

        if humanoid then
            if origWalk == nil then origWalk = humanoid.WalkSpeed end
            if origJump == nil then origJump = humanoid.JumpPower end
            humanoid.WalkSpeed = TG('SpeedHack') and SL('WalkSpeed') or origWalk
            humanoid.JumpPower = TG('JumpPower')  and SL('JumpPowerVal') or origJump
        end

        if TG('Fly') and hrp then
            if hrp.Anchored then hrp.Anchored = false end
            ensureFlyBV(hrp)
            local cam = workspace.CurrentCamera
            local hor = Vector3.zero
            if cam then
                if UIS:IsKeyDown(Enum.KeyCode.W) then hor = hor + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then hor = hor - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then hor = hor - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then hor = hor + cam.CFrame.RightVector end
            end
            if hor.Magnitude > 0 then hor = hor.Unit * SL('FlySpeed') end
            local vert = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space)     then vert = vert + SL('FlyVertSpeed') end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vert = vert - SL('FlyVertSpeed') end
            local tgt = hor + Vector3.new(0, vert, 0)
            flyVel = flyVel:Lerp(tgt, math.clamp(dt * SL('FlySmoothness'), 0, 1))
            flyBV.Velocity = flyVel
            if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Flying) end) end
        else
            stopFlyBV()
            flyVel = Vector3.zero
        end

        if TG('Spinbot') and hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SL('SpinSpeed') * dt), 0)
        end
    end)
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  MAIN HEARTBEAT (RGB / FOV / Fullbright)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        hue = (hue + dt * SL('CharRGBSpeed') * 0.1) % 1
        if TG('CharRGB') then paintCharacter(Color3.fromHSV(hue, 1, 1)) end
        if TG('RainbowName') then paintNametag(Color3.fromHSV(hue, 1, 1)) end
        applyFov(TG('FovEnabled'), SL('FovValue'))
        applyFullbright(TG('Fullbright'))
    end)
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  UNLOAD
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
Library:OnUnload(function()
    Library.Unloaded = true
    pcall(applyFullbright, false)
    pcall(applyFov, false, 70)
    if espConn  then espConn:Disconnect()  end
    if moveConn then moveConn:Disconnect() end
    pcall(applyNoclip, false)
    stopFlyBV()
    if states and states.screen_gui then
        pcall(function() states.screen_gui:Destroy() end)
    end
    if gunFallbackConn then gunFallbackConn:Disconnect() gunFallbackConn = nil end
    local uc   = player.Character
    local uhrp = uc and uc:FindFirstChild('HumanoidRootPart')
    if uhrp and uhrp.Anchored then uhrp.Anchored = false end
    local uhum = uc and uc:FindFirstChildOfClass('Humanoid')
    if uhum then
        if origWalk then pcall(function() uhum.WalkSpeed = origWalk end) end
        if origJump then pcall(function() uhum.JumpPower = origJump end) end
    end
    CleanupESP()
    print('[VoidSpam v10] unloaded.')
end)

print('[VoidSpam v10] loaded  |  End = toggle  |  client-side only')
warn('[VoidSpam:CHECK] Z script end reached')
