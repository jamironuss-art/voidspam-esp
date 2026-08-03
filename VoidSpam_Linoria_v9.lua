-- ╔══════════════════════════════════════════════════════════╗
-- ║  VOID SPAM  —  LINORIA EDITION  v9   (UI + ESP)           ║
-- ║  Tabs: ESP | Movement | Settings                           ║
-- ║  • Real LinoriaLib loaded from GitHub                   ║
-- ║  • Draggable — built into LinoriaLib                    ║
-- ║  • Mobile: 60% wide / 50% tall  |  PC: fixed 560×520   ║
-- ║  • Mobile-only  Toggle UI / Lock UI  floating panel     ║
-- ║  • Client-sided — only YOU are affected                 ║
-- ╚══════════════════════════════════════════════════════════╝

-- ─────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────
--  MOBILE DETECTION
-- ─────────────────────────────────────────
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ─────────────────────────────────────────
--  LINORIALIB  (embedded - no HTTP at runtime)
-- ─────────────────────────────────────────
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

-- ─────────────────────────────────────────
--  WINDOW SIZE  (60 % wide / 50 % tall on mobile)
-- ─────────────────────────────────────────
local vp     = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local WIN_W  = isMobile and math.floor(vp.X * 0.60) or 660
local WIN_H  = isMobile and math.floor(vp.Y * 0.50) or 620
local WIN_X  = math.floor((vp.X - WIN_W) * 0.5)
local WIN_Y  = math.floor((vp.Y - WIN_H) * 0.5)

-- ─────────────────────────────────────────
--  CREATE WINDOW
-- ─────────────────────────────────────────
local Window = Library:CreateWindow({
    Title        = 'Void Spam  —  v9',
    AutoShow     = true,
    Center       = false,
    Position     = UDim2.fromOffset(WIN_X, WIN_Y),
    Size         = UDim2.fromOffset(WIN_W, WIN_H),
    TabPadding   = 8,
    MenuFadeTime = 0.2,
})

-- ─────────────────────────────────────────
--  TABS
-- ─────────────────────────────────────────
local Tabs = {
    ESP      = Window:AddTab('ESP'),
    Aimbot   = Window:AddTab('Aimbot'),
    Movement = Window:AddTab('Movement'),
    Settings = Window:AddTab('Settings'),
}

-- ══════════════════════════════════════════
--  TAB — ESP
-- ══════════════════════════════════════════
local GEspMain    = Tabs.ESP:AddLeftGroupbox('Main')
local GEspBox     = Tabs.ESP:AddLeftGroupbox('Box')
local GEspHealth  = Tabs.ESP:AddLeftGroupbox('Health')

local GTracer     = Tabs.ESP:AddRightGroupbox('Tracer / Snapline')
local GChams      = Tabs.ESP:AddRightGroupbox('Chams')
local GSkeleton   = Tabs.ESP:AddRightGroupbox('Skeleton')
local GColors     = Tabs.ESP:AddRightGroupbox('Colors')
local GRainbow    = Tabs.ESP:AddRightGroupbox('Rainbow')

-- ── Main ──
GEspMain:AddToggle('ESPEnabled', {
    Text    = 'Enable ESP',
    Default = false,
    Tooltip = 'Shows box / tracer / health / chams for other players',
})
GEspMain:AddToggle('TeamCheck', {
    Text    = 'Team Check',
    Default = false,
    Tooltip = 'Skips players on your team',
})
GEspMain:AddToggle('ShowTeam', {
    Text    = 'Show Team',
    Default = false,
    Tooltip = 'Show teammates anyway when team check is on',
})
GEspMain:AddSlider('MaxDistance', {
    Text     = 'Max Distance',
    Default  = 1000,
    Min      = 100,
    Max      = 5000,
    Rounding = 0,
    Suffix   = 'st',
})
GEspMain:AddSlider('TextSize', {
    Text     = 'Text Size',
    Default  = 14,
    Min      = 10,
    Max      = 24,
    Rounding = 0,
})

GEspMain:AddDivider()

GEspMain:AddToggle('ShowName', {
    Text    = 'Show Name',
    Default = true,
    Tooltip = 'Shows the player name above the box',
})
GEspMain:AddToggle('ShowDistance', {
    Text    = 'Show Distance',
    Default = true,
    Tooltip = 'Shows the distance to the player',
})
GEspMain:AddDropdown('DistanceSuffix', {
    Text    = 'Distance Suffix',
    Values  = { 'st', 'm', 'None' },
    Default = 'st',
    Multi   = false,
})
GEspMain:AddInput('DistancePrefix', {
    Text    = 'Distance Prefix',
    Default = 'D: ',
    Numeric = false,
    Finished = true,
    Tooltip = 'Text shown in front of the distance (leave empty for none)',
})
GEspMain:AddDropdown('NameMode', {
    Text    = 'Name Mode',
    Values  = { 'Display Name', 'Username' },
    Default = 'Display Name',
    Multi   = false,
    Tooltip = 'Which name to show above the box',
})
GEspMain:AddToggle('NameBG', {
    Text    = 'Name Background',
    Default = true,
    Tooltip = 'Draws a dark background behind the name and distance',
})
GEspMain:AddToggle('NameOutline', {
    Text    = 'Text Outline',
    Default = true,
    Tooltip = 'Adds a black outline to the ESP texts',
})
GEspMain:AddToggle('VisCheck', {
    Text    = 'Visibility Check',
    Default = false,
    Tooltip = 'ESP turns dark when the player is behind a wall',
})
GEspMain:AddToggle('VisText', {
    Text    = 'Visibility Text',
    Default = false,
    Tooltip = 'Shows "Visible" / "Not Visible" under the box',
})
GEspMain:AddToggle('WeaponESP', {
    Text    = 'Weapon ESP',
    Default = false,
    Tooltip = 'Shows the equipped weapon under the box',
})

-- ── Box ──
GEspBox:AddToggle('BoxESP', {
    Text    = 'Box ESP',
    Default = false,
    Tooltip = 'Draws a box around players',
})
GEspBox:AddDropdown('BoxStyle', {
    Text    = 'Box Style',
    Values  = { 'Corner', 'Full', 'ThreeD' },
    Default = 'Corner',
    Multi   = false,
})
GEspBox:AddSlider('BoxThickness', {
    Text     = 'Box Thickness',
    Default  = 1,
    Min      = 1,
    Max      = 5,
    Rounding = 1,
})
GEspBox:AddToggle('BoxOutline', {
    Text    = 'Box Outline',
    Default = true,
    Tooltip = 'Adds a dark outline around the box',
})
GEspBox:AddToggle('BoxFilled', {
    Text    = 'Box Filled',
    Default = false,
    Tooltip = 'Fills the box with a translucent colour',
})
GEspBox:AddSlider('BoxFillTransparency', {
    Text     = 'Fill Transparency',
    Default  = 0.5,
    Min      = 0,
    Max      = 1,
    Rounding = 2,
})

-- ── Health ──
GEspHealth:AddToggle('HealthESP', {
    Text    = 'Health Bar',
    Default = false,
    Tooltip = 'Draws a health bar next to players',
})
GEspHealth:AddDropdown('HealthStyle', {
    Text    = 'Health Style',
    Values  = { 'Bar', 'Text', 'Both' },
    Default = 'Bar',
    Multi   = false,
})
GEspHealth:AddSlider('HealthWidth', {
    Text     = 'Bar Width',
    Default  = 4,
    Min      = 2,
    Max      = 8,
    Rounding = 0,
})

-- ── Tracer ──
GTracer:AddToggle('TracerESP', {
    Text    = 'Tracer ESP',
    Default = false,
    Tooltip = 'Draws a line from a screen origin to each player',
})
GTracer:AddDropdown('TracerOrigin', {
    Text    = 'Tracer Origin',
    Values  = { 'Bottom', 'Top', 'Mouse', 'Center' },
    Default = 'Bottom',
    Multi   = false,
})
GTracer:AddToggle('Snaplines', {
    Text    = 'Snaplines',
    Default = false,
    Tooltip = 'Draws a line to the bottom center of the screen',
})
GTracer:AddSlider('TracerThickness', {
    Text     = 'Tracer Thickness',
    Default  = 1,
    Min      = 1,
    Max      = 5,
    Rounding = 1,
})
GTracer:AddSlider('SnaplineThickness', {
    Text     = 'Snapline Thickness',
    Default  = 1,
    Min      = 1,
    Max      = 5,
    Rounding = 1,
})

-- ── Chams ──
GChams:AddToggle('ChamsEnabled', {
    Text    = 'Enable Chams',
    Default = false,
    Tooltip = 'Highlights player bodies through walls',
})
GChams:AddLabel('Fill Color'):AddColorPicker('ChamsFillColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Title   = 'Fill Color',
})
GChams:AddLabel('Occluded Color'):AddColorPicker('ChamsOccludedColor', {
    Default = Color3.fromRGB(150, 0, 0),
    Title   = 'Occluded Color',
})
GChams:AddLabel('Outline Color'):AddColorPicker('ChamsOutlineColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'Outline Color',
})
GChams:AddSlider('ChamsTransparency', {
    Text     = 'Fill Transparency',
    Default  = 0.5,
    Min      = 0,
    Max      = 1,
    Rounding = 2,
})
GChams:AddSlider('ChamsOutlineTransparency', {
    Text     = 'Outline Transparency',
    Default  = 0,
    Min      = 0,
    Max      = 1,
    Rounding = 2,
})

-- ── Skeleton ──
GSkeleton:AddToggle('SkeletonESP', {
    Text    = 'Skeleton ESP',
    Default = false,
    Tooltip = 'Draws the player bones as lines',
})
GSkeleton:AddLabel('Skeleton Color'):AddColorPicker('SkeletonColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'Skeleton Color',
})
GSkeleton:AddSlider('SkeletonThickness', {
    Text     = 'Line Thickness',
    Default  = 1,
    Min      = 1,
    Max      = 3,
    Rounding = 1,
})
GSkeleton:AddSlider('SkeletonTransparency', {
    Text     = 'Transparency',
    Default  = 1,
    Min      = 0,
    Max      = 1,
    Rounding = 2,
})

-- ── Colors ──
GColors:AddLabel('Enemy Color'):AddColorPicker('EnemyColor', {
    Default = Color3.fromRGB(255, 25, 25),
    Title   = 'Enemy Color',
})
GColors:AddLabel('Ally Color'):AddColorPicker('AllyColor', {
    Default = Color3.fromRGB(25, 255, 25),
    Title   = 'Ally Color',
})
GColors:AddLabel('Health Color'):AddColorPicker('HealthColor', {
    Default = Color3.fromRGB(0, 255, 0),
    Title   = 'Health Color',
})
GColors:AddLabel('Occluded Color'):AddColorPicker('OccludedColor', {
    Default = Color3.fromRGB(120, 120, 120),
    Title   = 'Occluded Color',
})

GColors:AddDivider()

GColors:AddDropdown('ColorMode', {
    Text    = 'Individual Colors',
    Values  = { 'Custom', 'Team' },
    Default = 'Custom',
    Multi   = false,
    Tooltip = 'Custom = every ESP element uses its own color below; Team = enemy/ally colors for everything',
})

GColors:AddLabel('Box Color'):AddColorPicker('BoxColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'Box Color',
})
GColors:AddLabel('Tracer Color'):AddColorPicker('TracerColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'Tracer Color',
})
GColors:AddLabel('Snapline Color'):AddColorPicker('SnaplineColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'Snapline Color',
})
GColors:AddLabel('Name Color'):AddColorPicker('NameColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'Name Color',
})
GColors:AddLabel('Distance Color'):AddColorPicker('DistanceColor', {
    Default = Color3.fromRGB(200, 200, 200),
    Title   = 'Distance Color',
})
GColors:AddLabel('Visibility Text Color'):AddColorPicker('VisTextColor', {
    Default = Color3.fromRGB(0, 255, 150),
    Title   = 'Visibility Text Color',
})
GColors:AddLabel('Weapon Color'):AddColorPicker('WeaponColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'Weapon Color',
})

-- ── Rainbow ──
GRainbow:AddToggle('RainbowEnabled', {
    Text    = 'Rainbow Mode',
    Default = false,
    Tooltip = 'Cycles ESP colours through the rainbow',
})
GRainbow:AddSlider('RainbowSpeed', {
    Text     = 'Rainbow Speed',
    Default  = 1,
    Min      = 0.1,
    Max      = 5,
    Rounding = 1,
})
GRainbow:AddDropdown('RainbowParts', {
    Text    = 'Rainbow Parts',
    Values  = { 'All', 'Box Only', 'Tracers Only', 'Text Only' },
    Default = 'All',
    Multi   = false,
})

-- ══════════════════════════════════════════
--  TAB — AIMBOT
-- ══════════════════════════════════════════
local GAim    = Tabs.Aimbot:AddLeftGroupbox('Aimbot')
local GAimVis = Tabs.Aimbot:AddRightGroupbox('Visuals')

local aimUIOK, aimUIErr = pcall(function()
GAim:AddToggle('Aimbot', {
    Text    = 'Enable Aimbot',
    Default = false,
    Tooltip = 'Aims at the closest player while the key is held',
})
GAim:AddDropdown('AimKeyMode', {
    Text    = 'Aim Key',
    Values  = { 'Right Mouse', 'Left Mouse', 'Q', 'E', 'F', 'C', 'V', 'X' },
    Default = 'Right Mouse',
    Multi   = false,
})
GAim:AddDropdown('HitPart', {
    Text    = 'Hit Part',
    Values  = { 'Head', 'Torso', 'Random' },
    Default = 'Head',
    Multi   = false,
})
GAim:AddSlider('AimSmoothness', {
    Text     = 'Smoothness',
    Default  = 5,
    Min      = 0,
    Max      = 20,
    Rounding = 0,
    Tooltip  = 'Lower = snappier, higher = smoother',
})
GAim:AddSlider('AimFOV', {
    Text     = 'FOV',
    Default  = 45,
    Min      = 5,
    Max      = 180,
    Rounding = 0,
    Suffix   = 'deg',
    Tooltip  = 'Only aims at targets inside this circle around the crosshair',
})
GAim:AddSlider('AimDistance', {
    Text     = 'Max Distance',
    Default  = 500,
    Min      = 50,
    Max      = 5000,
    Rounding = 0,
    Suffix   = 'st',
})
GAim:AddToggle('AimTeamCheck', {
    Text    = 'Team Check',
    Default = true,
    Tooltip = 'Skips players on your team',
})
GAim:AddToggle('AimVisCheck', {
    Text    = 'Visibility Check',
    Default = true,
    Tooltip = 'Only aims if a raycast to the target is not blocked',
})
GAim:AddToggle('LeadTarget', {
    Text    = 'Velocity Lead',
    Default = true,
    Tooltip = 'Aims slightly ahead so shots hit a moving target',
})
GAim:AddSlider('LeadTime', {
    Text     = 'Lead Time',
    Default  = 0.1,
    Min      = 0,
    Max      = 0.25,
    Rounding = 3,
    Suffix   = 's',
})

GAimVis:AddToggle('ShowAimFov', {
    Text    = 'Show FOV Circle',
    Default = true,
})
GAimVis:AddLabel('FOV Color'):AddColorPicker('AimFovColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = 'FOV Circle Color',
})
end)
if not aimUIOK then
    warn('[VoidSpam] AIMBOT UI ERROR: ' .. tostring(aimUIErr))
end

-- ══════════════════════════════════════════
--  TAB — MOVEMENT
-- ══════════════════════════════════════════
local GMove    = Tabs.Movement:AddLeftGroupbox('Movement')
local GCustom  = Tabs.Movement:AddRightGroupbox('Customization')

-- ── Movement (Left) ──
GMove:AddToggle('Fly', {
    Text    = 'Fly',
    Default = false,
    Tooltip = 'Fly with WASD + Space/Left Shift',
})
GMove:AddSlider('FlySpeed', {
    Text     = 'Fly Speed',
    Default  = 30,
    Min      = 5,
    Max      = 120,
    Rounding = 1,
})
GMove:AddToggle('Noclip', {
    Text    = 'Noclip',
    Default = false,
    Tooltip = 'Walk through walls',
})
GMove:AddToggle('SpeedHack', {
    Text    = 'Speed Hack',
    Default = false,
    Tooltip = 'Sets your WalkSpeed',
})
GMove:AddSlider('WalkSpeed', {
    Text     = 'WalkSpeed',
    Default  = 32,
    Min      = 16,
    Max      = 200,
    Rounding = 1,
})
GMove:AddToggle('JumpPower', {
    Text    = 'Jump Power',
    Default = false,
    Tooltip = 'Sets your jump height',
})
GMove:AddSlider('JumpPowerVal', {
    Text     = 'Jump Height',
    Default  = 50,
    Min      = 0,
    Max      = 300,
    Rounding = 1,
})

-- ── Customization (Right) ──
GCustom:AddSlider('FlyVertSpeed', {
    Text     = 'Vertical Fly Speed',
    Default  = 20,
    Min      = 5,
    Max      = 80,
    Rounding = 1,
})
GCustom:AddSlider('FlySmoothness', {
    Text     = 'Fly Smoothness',
    Default  = 6,
    Min      = 1,
    Max      = 20,
    Rounding = 1,
    Suffix   = 'x',
})
GCustom:AddToggle('Spinbot', {
    Text    = 'Spinbot',
    Default = false,
    Tooltip = 'Spins your character in place',
})
GCustom:AddSlider('SpinSpeed', {
    Text     = 'Spin Speed',
    Default  = 90,
    Min      = 10,
    Max      = 720,
    Rounding = 0,
    Suffix   = 'deg/s',
})

-- ══════════════════════════════════════════
--  TAB — SETTINGS  (menu + configs + theme)
-- ══════════════════════════════════════════
local GMenu = Tabs.Settings:AddLeftGroupbox('Menu')

GMenu:AddButton({
    Text      = 'Unload script',
    Func      = function() Library:Unload() end,
    Tooltip   = 'Completely removes the GUI and stops all logic',
})

GMenu:AddLabel('Menu keybind')
    :AddKeyPicker('MenuKeybind', {
        Default = 'End',
        NoUI    = false,
        Text    = 'Toggle menu',
        Mode    = 'Toggle',
    })

Library.ToggleKeybind = Options.MenuKeybind

-- Hand off to managers (must happen before BuildConfigSection)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('VoidSpam')
SaveManager:SetFolder('VoidSpam/configs')

-- Builds the full save/load config UI on the RIGHT side of Settings
SaveManager:BuildConfigSection(Tabs.Settings)

-- Builds the theme picker on the LEFT side of Settings
ThemeManager:ApplyToTab(Tabs.Settings)

-- Auto-load disabled: the script ALWAYS starts with defaults (all OFF) so
-- nothing (ESP, toggles, bypass, etc.) turns on by itself at execute.
-- SaveManager:LoadAutoloadConfig()

-- ─────────────────────────────────────────
--  WATERMARK
-- ─────────────────────────────────────────
Library:SetWatermarkVisibility(true)
Library:SetWatermark('Void Spam v9  |  client-sided only')

-- ══════════════════════════════════════════
--  MOBILE-ONLY  Toggle UI / Lock UI panel
-- ══════════════════════════════════════════
if isMobile then
    local mobileSG              = Instance.new("ScreenGui")
    mobileSG.Name               = "VoidSpamMobilePanel"
    mobileSG.ResetOnSpawn       = false
    mobileSG.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
    mobileSG.DisplayOrder       = 1000   -- above LinoriaLib (999)
    mobileSG.IgnoreGuiInset     = true
    mobileSG.Parent             = playerGui

    local panel                 = Instance.new("Frame")
    panel.Size                  = UDim2.fromOffset(114, 58)
    panel.Position              = UDim2.fromOffset(6, 110)
    panel.BackgroundColor3      = Color3.fromRGB(10, 10, 15)
    panel.BorderSizePixel       = 0
    panel.Parent                = mobileSG

    local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,4) pc.Parent = panel
    local ps = Instance.new("UIStroke") ps.Color = Color3.fromRGB(45,55,90) ps.Thickness = 1 ps.Parent = panel

    local function mobileBtn(txt, y)
        local b                 = Instance.new("TextButton")
        b.Size                  = UDim2.new(1, 0, 0, 26)
        b.Position              = UDim2.fromOffset(0, y)
        b.BackgroundColor3      = Color3.fromRGB(10, 10, 15)
        b.TextColor3            = Color3.fromRGB(210, 210, 220)
        b.Text                  = txt
        b.Font                  = Enum.Font.Code
        b.TextSize              = 13
        b.BorderSizePixel       = 0
        b.AutoButtonColor       = false
        b.Parent                = panel
        b.MouseButton1Down:Connect(function() b.BackgroundColor3 = Color3.fromRGB(22,22,35) end)
        b.MouseButton1Up:Connect(function()   b.BackgroundColor3 = Color3.fromRGB(10,10,15) end)
        return b
    end

    local btnToggle = mobileBtn("Toggle UI", 0)
    local btnLock   = mobileBtn("Lock UI",  28)

    btnToggle.MouseButton1Click:Connect(function()
        if Library.GUI then
            Library.GUI.Enabled = not Library.GUI.Enabled
        end
    end)

    local locked = false
    btnLock.MouseButton1Click:Connect(function()
        locked = not locked
        btnLock.TextColor3 = locked
            and Color3.fromRGB(75, 130, 255)
            or  Color3.fromRGB(210, 210, 220)
        btnLock.Text = locked and "Locked" or "Lock UI"
    end)
end

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local function getRoot()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Short-hand value accessors (safe — returns false/0 if not ready)
local function TG(idx)  return Toggles[idx] and Toggles[idx].Value   or false end
local function SL(idx)  return Options[idx]  and Options[idx].Value   or 0     end
local function COL(idx, dflt)
    local o = Options[idx]
    return (o and o.Value) or dflt
end

-- ══════════════════════════════════════════
--  ESP  (Drawing-based)
-- ══════════════════════════════════════════
local hueColor = Color3.fromRGB(255, 255, 255)
local ESP = {}

local Camera = workspace.CurrentCamera

local function GetCam()
    return workspace.CurrentCamera or Camera
end

local function CreateESP(p)
    if p == player then return end
    if ESP[p] then return end
    if not TG('ESPEnabled') then return end

    local ok, err = pcall(function()
        -- outline box lines are created BEFORE the box lines so they render underneath
        local boxO = {}
        for i = 1, 12 do
            boxO[i] = Drawing.new("Line")
            boxO[i].Visible = false
            boxO[i].Thickness = 1
            boxO[i].Color = Color3.new()
        end

        local box = {}
        for i = 1, 12 do
            box[i] = Drawing.new("Line")
            box[i].Visible = false
            box[i].Thickness = 1
        end

        local fill = Drawing.new("Quad")
        fill.Visible = false
        fill.Filled = true
        fill.Color = Color3.fromRGB(255, 255, 255)

        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1

        local healthBar = {
            Outline = Drawing.new("Square"),
            Fill    = Drawing.new("Square"),
            Text    = Drawing.new("Text"),
        }
        healthBar.Outline.Visible = false
        healthBar.Outline.Color = Color3.new()
        healthBar.Outline.Thickness = 1
        healthBar.Outline.Filled = false

        healthBar.Fill.Visible = false
        healthBar.Fill.Filled = true

        healthBar.Text.Visible = false
        healthBar.Text.Center = true
        healthBar.Text.Outline = true
        healthBar.Text.Font = 2

        local name = Drawing.new("Text")
        name.Visible = false
        name.Center = true
        name.Outline = true
        name.Font = 2

        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Center = true
        distance.Outline = true
        distance.Font = 2

        local visText = Drawing.new("Text")
        visText.Visible = false
        visText.Center = true
        visText.Outline = true
        visText.Font = 2

        local weapon = Drawing.new("Text")
        weapon.Visible = false
        weapon.Center = true
        weapon.Outline = true
        weapon.Font = 2

        local weaponBG = Drawing.new("Quad")
        weaponBG.Visible = false
        weaponBG.Filled = true
        weaponBG.Color = Color3.new()
        weaponBG.Transparency = 0.55

        local nameBG = Drawing.new("Quad")
        nameBG.Visible = false
        nameBG.Filled = true
        nameBG.Color = Color3.new()
        nameBG.Transparency = 0.55

        local distBG = Drawing.new("Quad")
        distBG.Visible = false
        distBG.Filled = true
        distBG.Color = Color3.new()
        distBG.Transparency = 0.55

        local snapline = Drawing.new("Line")
        snapline.Visible = false
        snapline.Thickness = 1

        local skeleton = {}
        for i = 1, 19 do
            skeleton[i] = Drawing.new("Line")
            skeleton[i].Visible = false
        end

        ESP[p] = {
            Box = box, BoxO = boxO, Fill = fill, Tracer = tracer,
            HealthBar = healthBar, Name = name, Distance = distance,
            VisText = visText,
            NameBG = nameBG, DistBG = distBG,
            Weapon = weapon, WeaponBG = weaponBG,
            Snapline = snapline, Skeleton = skeleton,
            Highlights = nil,
        }
    end)

    if not ok then
        warn('[VoidSpam] CreateESP failed for ' .. tostring(p and p.Name) .. ': ' .. tostring(err))
    end
end

local function RemoveESP(p)
    local esp = ESP[p]
    if not esp then return end
    for i = 1, 12 do esp.Box[i]:Remove() end
    for i = 1, 12 do esp.BoxO[i]:Remove() end
    esp.Fill:Remove()
    esp.Tracer:Remove()
    esp.HealthBar.Outline:Remove()
    esp.HealthBar.Fill:Remove()
    esp.HealthBar.Text:Remove()
    esp.Name:Remove()
    esp.Distance:Remove()
    esp.VisText:Remove()
    esp.Weapon:Remove()
    esp.WeaponBG:Remove()
    esp.NameBG:Remove()
    esp.DistBG:Remove()
    esp.Snapline:Remove()
    for i = 1, 19 do esp.Skeleton[i]:Remove() end
    if esp.Highlights then
        for _, hl in ipairs(esp.Highlights) do
            pcall(function() hl:Destroy() end)
        end
    end
    ESP[p] = nil
end

local function GetPlayerColor(p, occluded, customKey, customDflt)
    if occluded then
        return COL('OccludedColor', Color3.fromRGB(120, 120, 120))
    end

    if TG('RainbowEnabled') then
        local parts = SL('RainbowParts')
        if parts == 'All' then return hueColor end
        if parts == 'Box Only' and TG('BoxESP') then return hueColor end
        if parts == 'Tracers Only' and TG('TracerESP') then return hueColor end
        if parts == 'Text Only' and (TG('HealthESP') or TG('SkeletonESP')) then return hueColor end
    end

    if SL('ColorMode') == 'Custom' then
        return COL(customKey, customDflt)
    end

    local pTeam  = p.Team  or p.TeamColor
    local myTeam = player.Team or player.TeamColor
    if pTeam and myTeam and pTeam == myTeam then
        return COL('AllyColor', Color3.fromRGB(25, 255, 25))
    end
    return COL('EnemyColor', Color3.fromRGB(255, 25, 25))
end

local function GetTracerOrigin()
    local cam = GetCam()
    local origin = SL('TracerOrigin')
    if origin == 'Bottom' then
        return Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
    elseif origin == 'Top' then
        return Vector2.new(cam.ViewportSize.X / 2, 0)
    elseif origin == 'Mouse' then
        return UIS:GetMouseLocation()
    else
        return Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    end
end

local function hideAll(esp)
    for i = 1, 12 do esp.Box[i].Visible = false end
    for i = 1, 12 do esp.BoxO[i].Visible = false end
    esp.Fill.Visible = false
    esp.Tracer.Visible = false
    esp.HealthBar.Outline.Visible = false
    esp.HealthBar.Fill.Visible = false
    esp.HealthBar.Text.Visible = false
    esp.Name.Visible = false
    esp.Distance.Visible = false
    esp.VisText.Visible = false
    esp.Weapon.Visible = false
    esp.WeaponBG.Visible = false
    esp.NameBG.Visible = false
    esp.DistBG.Visible = false
    esp.Snapline.Visible = false
    for i = 1, 19 do esp.Skeleton[i].Visible = false end
end

-- tries to find the weapon the player is holding (Rivals keeps the weapon as a
-- Tool in the character while equipped, or in the Backpack otherwise)
local function getWeaponName(p, char)
    if char then
        local t = char:FindFirstChildOfType('Tool') or char:FindFirstChildWhichIsA('Tool', true)
        if t then return t.Name end
        local w = char:FindFirstChild('Weapon')
        if w then return w.Name end
    end
    local bp = p and p:FindFirstChild('Backpack')
    if bp then
        local t = bp:FindFirstChildOfType('Tool')
        if t then return t.Name end
    end
    return nil
end

local function UpdateESP(p)
    local esp = ESP[p]
    if not esp then return end
    if not TG('ESPEnabled') then
        hideAll(esp)
        return
    end

    local cam = GetCam()
    local character = p.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not (character and rootPart and humanoid) or humanoid.Health <= 0 then
        hideAll(esp)
        return
    end

    local pos, onScreen = cam:WorldToViewportPoint(rootPart.Position)
    local distanceStuds = (rootPart.Position - cam.CFrame.Position).Magnitude

    if not onScreen or distanceStuds > SL('MaxDistance') then
        hideAll(esp)
        return
    end

    local pTeam  = p.Team or p.TeamColor
    local myTeam = player.Team or player.TeamColor
    if TG('TeamCheck') and pTeam and myTeam and pTeam == myTeam and not TG('ShowTeam') then
        hideAll(esp)
        return
    end

    local occluded = false
    if TG('VisCheck') or TG('VisText') then
        local origin = cam.CFrame.Position
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = { player.Character }
        local res = workspace:Raycast(origin, (rootPart.Position - origin).Unit * 1000, rayParams)
        occluded = not (res and res.Instance and res.Instance:IsDescendantOf(character))
    end

    local function ElemColor(key, dflt)
        return GetPlayerColor(p, TG('VisCheck') and occluded, key, dflt)
    end

    local color   = ElemColor('BoxColor', Color3.fromRGB(255, 255, 255))
    local textSize = SL('TextSize')
    local size
    local okSize = pcall(function()
        size = character:GetExtentsSize()
    end)
    if not okSize or not size or size.Y <= 0 or size.X <= 0 then
        size = Vector3.new(5, 7, 3)
    end
    -- clamp ridiculous sizes so boxes stay on screen
    size = Vector3.new(
        math.clamp(size.X, 2, 20),
        math.clamp(size.Y, 4, 25),
        math.clamp(size.Z, 2, 20)
    )
    local cf      = rootPart.CFrame

    local top,    topOnScreen    = cam:WorldToViewportPoint((cf * CFrame.new(0, size.Y / 2, 0)).Position)
    local bottom, bottomOnScreen = cam:WorldToViewportPoint((cf * CFrame.new(0, -size.Y / 2, 0)).Position)

    if not (topOnScreen and bottomOnScreen) then
        hideAll(esp)
        return
    end

    local screenSize = bottom.Y - top.Y
    local boxWidth   = screenSize * 0.65
    local boxPos     = Vector2.new(top.X - boxWidth / 2, top.Y)
    local boxSize    = Vector2.new(boxWidth, screenSize)

    local function toV2(v) return Vector2.new(v.X, v.Y) end

    -- ── BOX ──
    for i = 1, 12 do esp.Box[i].Visible = false end
    esp.Fill.Visible = false

    if TG('BoxESP') then
        local style = SL('BoxStyle')

        if style == 'ThreeD' then
            local front = {
                TL = cam:WorldToViewportPoint((cf * CFrame.new(-size.X/2,  size.Y/2, -size.Z/2)).Position),
                TR = cam:WorldToViewportPoint((cf * CFrame.new( size.X/2,  size.Y/2, -size.Z/2)).Position),
                BL = cam:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position),
                BR = cam:WorldToViewportPoint((cf * CFrame.new( size.X/2, -size.Y/2, -size.Z/2)).Position),
            }
            local back = {
                TL = cam:WorldToViewportPoint((cf * CFrame.new(-size.X/2,  size.Y/2,  size.Z/2)).Position),
                TR = cam:WorldToViewportPoint((cf * CFrame.new( size.X/2,  size.Y/2,  size.Z/2)).Position),
                BL = cam:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2,  size.Z/2)).Position),
                BR = cam:WorldToViewportPoint((cf * CFrame.new( size.X/2, -size.Y/2,  size.Z/2)).Position),
            }

            local allVisible = front.TL.Z > 0 and front.TR.Z > 0 and front.BL.Z > 0 and front.BR.Z > 0
                and back.TL.Z > 0 and back.TR.Z > 0 and back.BL.Z > 0 and back.BR.Z > 0
            if not allVisible then
                for i = 1, 12 do esp.Box[i].Visible = false end
                for i = 1, 12 do esp.BoxO[i].Visible = false end
                return
            end

            local B = esp.Box
            B[1].From, B[1].To, B[1].Visible = toV2(front.TL), toV2(front.TR), true
            B[2].From, B[2].To, B[2].Visible = toV2(front.TR), toV2(front.BR), true
            B[3].From, B[3].To, B[3].Visible = toV2(front.BR), toV2(front.BL), true
            B[4].From, B[4].To, B[4].Visible = toV2(front.BL), toV2(front.TL), true
            B[5].From, B[5].To, B[5].Visible = toV2(back.TL), toV2(back.TR), true
            B[6].From, B[6].To, B[6].Visible = toV2(back.TR), toV2(back.BR), true
            B[7].From, B[7].To, B[7].Visible = toV2(back.BR), toV2(back.BL), true
            B[8].From, B[8].To, B[8].Visible = toV2(back.BL), toV2(back.TL), true
            B[9].From,  B[9].To,  B[9].Visible  = toV2(front.TL), toV2(back.TL), true
            B[10].From, B[10].To, B[10].Visible = toV2(front.TR), toV2(back.TR), true
            B[11].From, B[11].To, B[11].Visible = toV2(front.BL), toV2(back.BL), true
            B[12].From, B[12].To, B[12].Visible = toV2(front.BR), toV2(back.BR), true
        elseif style == 'Corner' then
            local cs = boxWidth * 0.2
            local B = esp.Box
            -- top left
            B[1].From, B[1].To, B[1].Visible = boxPos, boxPos + Vector2.new(cs, 0), true
            B[2].From, B[2].To, B[2].Visible = boxPos, boxPos + Vector2.new(0, cs), true
            -- top right
            B[3].From, B[3].To, B[3].Visible = boxPos + Vector2.new(boxSize.X, 0), boxPos + Vector2.new(boxSize.X - cs, 0), true
            B[4].From, B[4].To, B[4].Visible = boxPos + Vector2.new(boxSize.X, 0), boxPos + Vector2.new(boxSize.X, cs), true
            -- bottom left
            B[5].From, B[5].To, B[5].Visible = boxPos + Vector2.new(0, boxSize.Y), boxPos + Vector2.new(cs, boxSize.Y), true
            B[6].From, B[6].To, B[6].Visible = boxPos + Vector2.new(0, boxSize.Y), boxPos + Vector2.new(0, boxSize.Y - cs), true
            -- bottom right
            B[7].From, B[7].To, B[7].Visible = boxPos + Vector2.new(boxSize.X, boxSize.Y), boxPos + Vector2.new(boxSize.X - cs, boxSize.Y), true
            B[8].From, B[8].To, B[8].Visible = boxPos + Vector2.new(boxSize.X, boxSize.Y), boxPos + Vector2.new(boxSize.X, boxSize.Y - cs), true
        else -- Full
            local B = esp.Box
            B[1].From, B[1].To, B[1].Visible = boxPos, boxPos + Vector2.new(0, boxSize.Y), true
            B[2].From, B[2].To, B[2].Visible = boxPos + Vector2.new(boxSize.X, 0), boxPos + Vector2.new(boxSize.X, boxSize.Y), true
            B[3].From, B[3].To, B[3].Visible = boxPos, boxPos + Vector2.new(boxSize.X, 0), true
            B[4].From, B[4].To, B[4].Visible = boxPos + Vector2.new(0, boxSize.Y), boxPos + Vector2.new(boxSize.X, boxSize.Y), true
        end

        for i = 1, 12 do
            if esp.Box[i].Visible then
                esp.Box[i].Color = color
                esp.Box[i].Thickness = SL('BoxThickness')
            end
        end

        -- dark outline around the box (copies the drawn box lines, thicker + black)
        if TG('BoxOutline') then
            for i = 1, 12 do
                local bl = esp.Box[i]
                local ol = esp.BoxO[i]
                if bl.Visible then
                    ol.From = bl.From
                    ol.To = bl.To
                    ol.Thickness = bl.Thickness + 2
                    ol.Color = Color3.new()
                    ol.Visible = true
                else
                    ol.Visible = false
                end
            end
        else
            for i = 1, 12 do esp.BoxO[i].Visible = false end
        end

        if TG('BoxFilled') and style ~= 'ThreeD' then
            esp.Fill.PointA = boxPos
            esp.Fill.PointB = boxPos + Vector2.new(boxSize.X, 0)
            esp.Fill.PointC = boxPos + Vector2.new(boxSize.X, boxSize.Y)
            esp.Fill.PointD = boxPos + Vector2.new(0, boxSize.Y)
            esp.Fill.Color = Color3.fromRGB(color.R * 255, color.G * 255, color.B * 255)
            esp.Fill.Transparency = SL('BoxFillTransparency')
            esp.Fill.Visible = true
        end
    end

    -- ── TRACER ──
    if TG('TracerESP') then
        esp.Tracer.From = GetTracerOrigin()
        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
        esp.Tracer.Color = ElemColor('TracerColor', Color3.fromRGB(255, 255, 255))
        esp.Tracer.Thickness = SL('TracerThickness')
        if esp.Tracer.Thickness <= 0 then esp.Tracer.Thickness = 1 end
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end

    -- ── HEALTH ──
    if TG('HealthESP') then
        local hp = humanoid.Health
        local maxHp = math.max(humanoid.MaxHealth, 1)
        local pct = math.clamp(hp / maxHp, 0, 1)

        local barHeight = screenSize * 0.8
        local barWidth  = SL('HealthWidth')
        if barWidth <= 0 then barWidth = 4 end
        local barPos    = Vector2.new(boxPos.X - barWidth - 2, boxPos.Y + (screenSize - barHeight) / 2)

        esp.HealthBar.Outline.Size = Vector2.new(barWidth, barHeight)
        esp.HealthBar.Outline.Position = barPos
        esp.HealthBar.Outline.Visible = true

        esp.HealthBar.Fill.Size = Vector2.new(barWidth - 2, barHeight * pct)
        esp.HealthBar.Fill.Position = Vector2.new(barPos.X + 1, barPos.Y + barHeight * (1 - pct))
        esp.HealthBar.Fill.Color = Color3.fromRGB(255 - (255 * pct), 255 * pct, 0)
        esp.HealthBar.Fill.Visible = true

        local style = SL('HealthStyle')
        if style == 'Text' or style == 'Both' then
            esp.HealthBar.Text.Text = math.floor(hp)
            esp.HealthBar.Text.Position = Vector2.new(barPos.X + barWidth + 8, barPos.Y + barHeight / 2)
            esp.HealthBar.Text.Size = textSize
            esp.HealthBar.Text.Color = COL('HealthColor', Color3.fromRGB(0, 255, 0))
            esp.HealthBar.Text.Outline = TG('NameOutline')
            esp.HealthBar.Text.Visible = true
        else
            esp.HealthBar.Text.Visible = false
        end
    else
        esp.HealthBar.Outline.Visible = false
        esp.HealthBar.Fill.Visible = false
        esp.HealthBar.Text.Visible = false
    end

    -- ── NAME + DISTANCE (with optional dark backgrounds) ──
    local textOutline = TG('NameOutline')
    local textBG      = TG('NameBG')

    local function drawTextBG(quad, txt, sz, pos)
        local w = #txt * sz * 0.55
        local h = sz * 1.25
        quad.PointA = pos + Vector2.new(-w / 2 - 3, -h / 2)
        quad.PointB = pos + Vector2.new( w / 2 + 3, -h / 2)
        quad.PointC = pos + Vector2.new( w / 2 + 3,  h / 2)
        quad.PointD = pos + Vector2.new(-w / 2 - 3,  h / 2)
        quad.Visible = true
    end

    if TG('ShowName') then
        local nMode = SL('NameMode')
        esp.Name.Text = nMode == 'Username' and p.Name or (p.DisplayName or p.Name)
        esp.Name.Position = Vector2.new(boxPos.X + boxWidth / 2, boxPos.Y - 18)
        esp.Name.Size = textSize
        esp.Name.Color = ElemColor('NameColor', Color3.fromRGB(255, 255, 255))
        esp.Name.Outline = textOutline
        esp.Name.Visible = true
        if textBG then
            drawTextBG(esp.NameBG, esp.Name.Text, textSize, esp.Name.Position)
        else
            esp.NameBG.Visible = false
        end
    else
        esp.Name.Visible = false
        esp.NameBG.Visible = false
    end

    if TG('ShowDistance') then
        local dText = string.format('%.0f', distanceStuds)
        local prefix = SL('DistancePrefix')
        if type(prefix) == 'string' and prefix ~= '' then
            dText = prefix .. dText
        end
        local suffix = SL('DistanceSuffix')
        if suffix == 'st' then dText = dText .. 'st'
        elseif suffix == 'm' then dText = dText .. 'm' end
        esp.Distance.Text = dText
        esp.Distance.Position = Vector2.new(boxPos.X + boxWidth / 2, boxPos.Y - 2)
        esp.Distance.Size = textSize - 2
        esp.Distance.Outline = textOutline
        esp.Distance.Color = ElemColor('DistanceColor', Color3.fromRGB(200, 200, 200))
        esp.Distance.Visible = true
        if textBG then
            drawTextBG(esp.DistBG, dText, textSize - 2, esp.Distance.Position)
        else
            esp.DistBG.Visible = false
        end
    else
        esp.Distance.Visible = false
        esp.DistBG.Visible = false
    end

    -- ── SNAPLINE ──
    if TG('Snaplines') then
        esp.Snapline.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
        esp.Snapline.To = Vector2.new(pos.X, pos.Y)
        esp.Snapline.Color = ElemColor('SnaplineColor', Color3.fromRGB(255, 255, 255))
        esp.Snapline.Thickness = SL('SnaplineThickness')
        if esp.Snapline.Thickness <= 0 then esp.Snapline.Thickness = 1 end
        esp.Snapline.Visible = true
    else
        esp.Snapline.Visible = false
    end

    -- ── VISIBILITY TEXT ──
    if TG('VisText') then
        esp.VisText.Text = occluded and 'Not Visible' or 'Visible'
        esp.VisText.Position = Vector2.new(boxPos.X + boxWidth / 2, boxPos.Y + boxSize.Y + 4)
        esp.VisText.Size = textSize - 2
        esp.VisText.Color = COL('VisTextColor', Color3.fromRGB(0, 255, 150))
        esp.VisText.Outline = textOutline
        esp.VisText.Visible = true
    else
        esp.VisText.Visible = false
    end

    -- ── WEAPON ESP ──
    if TG('WeaponESP') then
        local wName = getWeaponName(p, character)
        if wName then
            esp.Weapon.Text = wName
            esp.Weapon.Position = Vector2.new(boxPos.X + boxWidth / 2, boxPos.Y + boxSize.Y + 18)
            esp.Weapon.Size = textSize - 2
            esp.Weapon.Color = ElemColor('WeaponColor', Color3.fromRGB(255, 255, 255))
            esp.Weapon.Outline = textOutline
            esp.Weapon.Visible = true
            if textBG then
                drawTextBG(esp.WeaponBG, wName, textSize - 2, esp.Weapon.Position)
            else
                esp.WeaponBG.Visible = false
            end
        else
            esp.Weapon.Visible = false
            esp.WeaponBG.Visible = false
        end
    else
        esp.Weapon.Visible = false
        esp.WeaponBG.Visible = false
    end

    -- ── CHAMS ──
    if TG('ChamsEnabled') then
        local fillC  = COL('ChamsFillColor', Color3.fromRGB(255, 0, 0))
        local occlC  = COL('ChamsOccludedColor', Color3.fromRGB(150, 0, 0))
        local outC   = COL('ChamsOutlineColor', Color3.fromRGB(255, 255, 255))
        local fillT  = SL('ChamsTransparency')
        local outT   = SL('ChamsOutlineTransparency')

        if not esp.Highlights then
            local hlV = Instance.new("Highlight")
            hlV.Name = "_ESPVisible"
            hlV.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hlV.Enabled = false
            local hlO = Instance.new("Highlight")
            hlO.Name = "_ESPOccluded"
            hlO.DepthMode = Enum.HighlightDepthMode.Occluded
            hlO.Enabled = false
            esp.Highlights = { hlV, hlO }
        end

        esp.Highlights[1].Parent = character
        esp.Highlights[1].Adornee = character
        esp.Highlights[1].FillColor = fillC
        esp.Highlights[1].FillTransparency = fillT
        esp.Highlights[1].OutlineColor = outC
        esp.Highlights[1].OutlineTransparency = outT
        esp.Highlights[1].Enabled = true

        esp.Highlights[2].Parent = character
        esp.Highlights[2].Adornee = character
        esp.Highlights[2].FillColor = occlC
        esp.Highlights[2].FillTransparency = fillT
        esp.Highlights[2].OutlineColor = outC
        esp.Highlights[2].OutlineTransparency = outT
        esp.Highlights[2].Enabled = true
    elseif esp.Highlights then
        esp.Highlights[1].Enabled = false
        esp.Highlights[2].Enabled = false
    end

    -- ── SKELETON ──
    if TG('SkeletonESP') then
        local bones = {
            head = character:FindFirstChild("Head"),
            upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
            lower = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"),
            la = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
            ll = character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Arm"),
            lh = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"),
            ra = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
            rl = character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Arm"),
            rh = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"),
            lu = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
            ll2 = character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg"),
            lf = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg"),
            ru = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
            rl2 = character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg"),
            rf = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg"),
        }

        local function drawBone(a, b, line)
            if not (a and b) then
                line.Visible = false
                return
            end
            local ap = a.Position
            local bp = b.Position
            local as_, av = cam:WorldToViewportPoint(ap)
            local bs_, bv = cam:WorldToViewportPoint(bp)
            if not (av and bv) or as_.Z < 0 or bs_.Z < 0 then
                line.Visible = false
                return
            end
            line.From = Vector2.new(as_.X, as_.Y)
            line.To = Vector2.new(bs_.X, bs_.Y)
            line.Color = COL('SkeletonColor', Color3.fromRGB(255, 255, 255))
            line.Thickness = SL('SkeletonThickness')
            line.Transparency = SL('SkeletonTransparency')
            line.Visible = true
        end

        local S = esp.Skeleton
        drawBone(bones.head, bones.upper, S[1])
        drawBone(bones.upper, bones.lower, S[2])
        drawBone(bones.upper, bones.la, S[3])
        drawBone(bones.la, bones.ll, S[4])
        drawBone(bones.ll, bones.lh, S[5])
        drawBone(bones.upper, bones.ra, S[6])
        drawBone(bones.ra, bones.rl, S[7])
        drawBone(bones.rl, bones.rh, S[8])
        drawBone(bones.lower, bones.lu, S[9])
        drawBone(bones.lu, bones.ll2, S[10])
        drawBone(bones.ll2, bones.lf, S[11])
        drawBone(bones.lower, bones.ru, S[12])
        drawBone(bones.ru, bones.rl2, S[13])
        drawBone(bones.rl2, bones.rf, S[14])
    else
        for i = 1, 19 do esp.Skeleton[i].Visible = false end
    end
end

local function CleanupESP()
    for p in pairs(ESP) do RemoveESP(p) end
    ESP = {}
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.1); CreateESP(p) end)
end)

Players.PlayerRemoving:Connect(RemoveESP)

local espConn = nil
local lastUpdate = 0
espConn = RunService.RenderStepped:Connect(function()
    local ok, err = pcall(function()
        hueColor = Color3.fromHSV((tick() * SL('RainbowSpeed')) % 1, 1, 1)

        if not TG('ESPEnabled') then
            for p in pairs(ESP) do hideAll(ESP[p]) end
            lastUpdate = 0
            return
        end

        local now = tick()
        if now - lastUpdate >= 1 / 144 then
            -- create at most ONE esp per frame so the game never freezes on join
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and not ESP[plr] then
                    CreateESP(plr)
                    break
                end
            end
            for p in pairs(ESP) do
                local ok2, err2 = pcall(UpdateESP, p)
                if not ok2 and err2 then
                    warn('[VoidSpam] ESP update error for ' .. tostring(p and p.Name) .. ': ' .. tostring(err2))
                end
            end
            lastUpdate = now
        end
    end)
    if not ok and err then
        warn('[VoidSpam] ESP error: ' .. tostring(err))
    end
end)

-- ══════════════════════════════════════════
--  AIMBOT  (camera only, no character rotation,
--  no hooks - safe for Rivals anticheat)
-- ══════════════════════════════════════════
local aimCircle = Drawing.new('Circle')
aimCircle.Visible = false
aimCircle.Filled = false
aimCircle.Thickness = 1
aimCircle.Color = Color3.fromRGB(255, 255, 255)
aimCircle.Transparency = 0.8
aimCircle.Radius = 100

local function isTargetBlocked(point)
    local cam = GetCam()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { player.Character }
    local res = workspace:Raycast(cam.CFrame.Position, (point - cam.CFrame.Position).Unit * 1000, params)
    return res ~= nil
end

local function aimHitPart(char)
    local mode = SL('HitPart')
    if mode == 'Head' then return char:FindFirstChild('Head') end
    if mode == 'Torso' then return char:FindFirstChild('HumanoidRootPart') end
    local head = char:FindFirstChild('Head')
    local root = char:FindFirstChild('HumanoidRootPart')
    if not root then return head end
    if not head then return root end
    return (tick() % 2 < 1) and head or root
end

local function findAimTarget()
    local cam = GetCam()
    local center = cam.ViewportSize / 2
    local maxScore = SL('AimFOV')
    local best, bestScore = nil, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char then
                local hum = char:FindFirstChildOfClass('Humanoid')
                if hum and hum.Health > 0 then
                    local myTeam = player.Team or player.TeamColor
                    local tTeam = p.Team or p.TeamColor
                    if not (TG('AimTeamCheck') and myTeam and tTeam and myTeam == tTeam) then
                        local part = aimHitPart(char)
                        if part then
                            local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist = (part.Position - cam.CFrame.Position).Magnitude
                                if dist <= SL('AimDistance') then
                                    local score = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                                    if score <= maxScore and (not bestScore or score < bestScore) then
                                        local ok = not TG('AimVisCheck')
                                        if not ok then ok = not isTargetBlocked(part.Position) end
                                        if ok then
                                            best, bestScore = p, score
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- yaw+pitch-only camera rotation (keeps the camera upright, never rotates
-- the character, settles exactly when close so it never overshoots)
local function rotateCamToward(cam, target, alpha)
    local pos = cam.CFrame.Position
    local curLook = cam.CFrame.LookVector
    local delta = target - pos
    local dist = delta.Magnitude
    if dist < 0.001 then return end
    local desired = delta / dist
    local angle = math.acos(math.clamp(curLook:Dot(desired), -1, 1))
    if angle < 0.03 then
        cam.CFrame = CFrame.lookAt(pos, target)
        return
    end
    local axis = curLook:Cross(desired)
    if axis.Magnitude < 1e-4 then
        cam.CFrame = CFrame.lookAt(pos, target)
        return
    end
    local newLook = CFrame.fromAxisAngle(axis.Unit, angle * alpha) * curLook
    cam.CFrame = CFrame.lookAt(pos, pos + newLook)
end

local aimConn = nil
local function aimKeyDown()
    local k = SL('AimKeyMode')
    if k == 'Right Mouse' then
        return InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif k == 'Left Mouse' then
        return InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    end
    local kc = Enum.KeyCode[k]
    return kc and InputService:IsKeyDown(kc) or false
end

aimConn = RunService.RenderStepped:Connect(function()
    pcall(function()
        local cam = GetCam()
        local view = cam.ViewportSize

        if TG('Aimbot') and TG('ShowAimFov') then
            aimCircle.Visible = true
            aimCircle.Position = view / 2
            local fovRad = math.rad(math.clamp(SL('AimFOV'), 1, 179) / 2)
            local camFovRad = math.rad(math.clamp(cam.FieldOfView or 70, 1, 179) / 2)
            aimCircle.Radius = (view.Y / 2) * (math.tan(fovRad) / math.tan(camFovRad))
            aimCircle.Color = COL('AimFovColor', Color3.fromRGB(255, 255, 255))
        else
            aimCircle.Visible = false
        end

        if TG('Aimbot') and aimKeyDown() then
            local target = findAimTarget()
            if target and target.Character then
                local part = aimHitPart(target.Character)
                if part then
                    local aimPoint = part.Position
                    if TG('LeadTarget') then
                        local vel = part.AssemblyLinearVelocity
                        local lead = vel * SL('LeadTime')
                        if lead.Magnitude > 2.5 then lead = lead.Unit * 2.5 end
                        aimPoint = aimPoint + lead
                    end
                    local alpha = (21 - math.clamp(SL('AimSmoothness'), 0, 20)) / 21
                    rotateCamToward(cam, aimPoint, alpha)
                end
            end
        end
    end)
end)

-- ══════════════════════════════════════════
--  MOVEMENT  (fly / noclip / speed / jump)
-- ══════════════════════════════════════════
local collideSaved = {}
local flyVel = Vector3.zero
local origWalk, origJump = nil, nil

local flyBV = nil
local function ensureFlyBV(hrp)
    if flyBV and flyBV.Parent == hrp then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp
end
local function stopFlyBV()
    if flyBV then
        pcall(function() flyBV:Destroy() end)
        flyBV = nil
    end
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
            if part.Parent then
                pcall(function() part.CanCollide = val end)
            end
        end
        collideSaved = {}
    end
end

local moveConn = nil
moveConn = RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild('HumanoidRootPart')
        local humanoid = char and char:FindFirstChildOfClass('Humanoid')

        -- Noclip
        applyNoclip(TG('Noclip'))

        -- Speed / Jump
        if humanoid then
            if origWalk == nil then origWalk = humanoid.WalkSpeed end
            if origJump == nil then origJump = humanoid.JumpPower end
            if TG('SpeedHack') then
                humanoid.WalkSpeed = SL('WalkSpeed')
            else
                humanoid.WalkSpeed = origWalk
            end
            if TG('JumpPower') then
                humanoid.JumpPower = SL('JumpPowerVal')
            else
                humanoid.JumpPower = origJump
            end
        end

        -- Fly (BodyVelocity = replicated, so other players see you fly)
        if TG('Fly') and hrp then
            if hrp.Anchored then hrp.Anchored = false end
            ensureFlyBV(hrp)
            local cam = workspace.CurrentCamera
            local hor = Vector3.new()
            if cam then
                if UIS:IsKeyDown(Enum.KeyCode.W) then hor = hor + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then hor = hor - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then hor = hor - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then hor = hor + cam.CFrame.RightVector end
            end
            if hor.Magnitude > 0 then hor = hor.Unit * SL('FlySpeed') end
            local vert = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) then vert = vert + SL('FlyVertSpeed') end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vert = vert - SL('FlyVertSpeed') end
            local targetVel = hor + Vector3.new(0, vert, 0)
            flyVel = flyVel:Lerp(targetVel, math.clamp(dt * SL('FlySmoothness'), 0, 1))
            flyBV.Velocity = flyVel
            if humanoid then
                pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Flying) end)
            end
        else
            stopFlyBV()
            flyVel = Vector3.zero
        end

        -- Spinbot
        if TG('Spinbot') and hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SL('SpinSpeed')) * dt, 0)
        end
    end)
end)

-- ─────────────────────────────────────────
--  UNLOAD HANDLER
-- ─────────────────────────────────────────
Library:OnUnload(function()
    Library.Unloaded = true
    if espConn then espConn:Disconnect() end
    if aimConn then aimConn:Disconnect() end
    aimCircle:Remove()
    if moveConn then moveConn:Disconnect() end
    pcall(applyNoclip, false)
    stopFlyBV()
    local uc = player.Character
    local uhrp = uc and uc:FindFirstChild('HumanoidRootPart')
    if uhrp and uhrp.Anchored then uhrp.Anchored = false end
    local uhum = uc and uc:FindFirstChildOfClass('Humanoid')
    if uhum then
        if origWalk then pcall(function() uhum.WalkSpeed = origWalk end) end
        if origJump then pcall(function() uhum.JumpPower = origJump end) end
    end
    CleanupESP()
    print('[VoidSpam v9] unloaded.')
end)

print('[VoidSpam v9] loaded  |  End = toggle menu  |  client-side only')
