local TweenService, UIS, rs = game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

-- Theme Setup
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Button = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(255, 255, 255)
}

-- Main UI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 230)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Theme.Background

-- Draggable GUI for PC and Mobile
local dragToggle, dragStart, startPos, dragInput = false, nil, nil, nil
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragToggle and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Rainbow Outline for Main Frame
local frameOutline = Instance.new("UIStroke")
frameOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameOutline.Thickness = 3
frameOutline.Parent = MainFrame
local hue = 0
rs.RenderStepped:Connect(function()
    hue = (hue + 0.005) % 1
    frameOutline.Color = Color3.fromHSV(hue, 1, 1)
end)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Text, Title.Size, Title.Position = "RINGTA SCRIPTS", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency, Title.TextColor3, Title.Font, Title.TextSize = 1, Theme.Text, Enum.Font.GothamBold, 14

-- Tabs Frame
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(0, 100, 1, -40)
TabsFrame.Position = UDim2.new(0, 10, 0, 30)
TabsFrame.BackgroundColor3 = Theme.Button
Instance.new("UICorner", TabsFrame).CornerRadius = UDim.new(0, 6)

-- Tab Buttons
local Tabs = {}
local TabContentFrame = Instance.new("Frame", MainFrame)
TabContentFrame.Size = UDim2.new(1, -120, 1, -40)
TabContentFrame.Position = UDim2.new(0, 110, 0, 30)
TabContentFrame.BackgroundColor3 = Theme.Background
TabContentFrame.ClipsDescendants = true
Instance.new("UICorner", TabContentFrame).CornerRadius = UDim.new(0, 6)

-- SCROLLING TAB FUNCTION (COMPACT)
local function CreateTab(tabName)
    local TabButton = Instance.new("TextButton", TabsFrame)
    TabButton.Text, TabButton.Size, TabButton.Position = tabName, UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, (#Tabs * 35))
    TabButton.BackgroundColor3, TabButton.TextColor3 = Theme.Button, Theme.Text
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

    local TabFrame = Instance.new("ScrollingFrame", TabContentFrame)
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.Position = UDim2.new(0, 0, 0, 0)
    TabFrame.BackgroundColor3 = Theme.Background
    TabFrame.BackgroundTransparency = 0
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 6
    TabFrame.ClipsDescendants = true
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 300) -- fits about 8-9 compact buttons, increase if needed
    TabFrame.Visible = (#Tabs == 0)
    Instance.new("UICorner", TabFrame).CornerRadius = UDim.new(0, 6)
    table.insert(Tabs, TabFrame)

    TabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(Tabs) do frame.Visible = false end
        TabFrame.Visible = true
    end)
    return TabFrame
end

-- BUTTON TEMPLATE (COMPACT, 80% wide, 22px tall)
local function CreateButton(parent, text, callback, position)
    local Button = Instance.new("TextButton", parent)
    Button.Text = text
    Button.Size = UDim2.new(0.8, 0, 0, 22) -- 80% width, 22px tall (compact like your old UI)
    Button.Position = position
    Button.BackgroundColor3, Button.TextColor3 = Theme.Button, Theme.Text
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Theme.Button
    end)
    Button.MouseButton1Click:Connect(callback)
end

-- Main Tab for Teleports
local MainTab = CreateTab("Main")
CreateButton(MainTab, "AUTO HIT OP", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/AUTOHITNEW.github.io/refs/heads/main/NEWHIT.lua"))()
end, UDim2.new(0.1, 0, 0, 10))
CreateButton(MainTab, "TP to Train", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWTPTRAIN.github.io/refs/heads/main/TRAIN.LUA"))()
end, UDim2.new(0.1, 0, 0, 42))
CreateButton(MainTab, "TP to Sterling", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ringtaa/sterlingnotifcation.github.io/refs/heads/main/Sterling.lua'))()
end, UDim2.new(0.1, 0, 0, 74))
CreateButton(MainTab, "TP to TeslaLab", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ringtaa/tptotesla.github.io/refs/heads/main/Tptotesla.lua'))()
end, UDim2.new(0.1, 0, 0, 106))
CreateButton(MainTab, "TP to Castle", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/castletpfast.github.io/refs/heads/main/FASTCASTLE.lua"))()
end, UDim2.new(0.1, 0, 0, 138))
CreateButton(MainTab, "TP to Unicorn", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/erhjf.github.io/refs/heads/main/hew.lua"))()
end, UDim2.new(0.1, 0, 0, 170))

-- Other Tab for Additional Features
local OtherTab = CreateTab("Other")
CreateButton(OtherTab, "TP to End", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/NEWNEWtpend.github.io/refs/heads/main/en.lua"))()
end, UDim2.new(0.1, 0, 0, 10))
CreateButton(OtherTab, "TP to Bank", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Tptobank.github.io/refs/heads/main/Banktp.lua"))()
end, UDim2.new(0.1, 0, 0, 42))

-- Gun Kill Aura Toggle with Shading
local gunKillAuraActive = false
local GunKillAuraButton = Instance.new("TextButton", OtherTab)
GunKillAuraButton.Text, GunKillAuraButton.Size, GunKillAuraButton.Position = "Gun Aura (Kill Mobs): OFF", UDim2.new(0.8, 0, 0, 22), UDim2.new(0.1, 0, 0, 74)
GunKillAuraButton.BackgroundColor3, GunKillAuraButton.TextColor3 = Color3.fromRGB(30, 30, 30), Theme.Text
Instance.new("UICorner", GunKillAuraButton).CornerRadius = UDim.new(0, 6)
GunKillAuraButton.MouseEnter:Connect(function()
    GunKillAuraButton.BackgroundColor3 = gunKillAuraActive and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(40, 40, 40)
end)
GunKillAuraButton.MouseLeave:Connect(function()
    GunKillAuraButton.BackgroundColor3 = gunKillAuraActive and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(30, 30, 30)
end)
GunKillAuraButton.MouseButton1Click:Connect(function()
    gunKillAuraActive = not gunKillAuraActive
    if gunKillAuraActive then
        GunKillAuraButton.Text = "Gun Aura (Kill Mobs): ON"
        GunKillAuraButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWKILLAURA.github.io/refs/heads/main/NEWkill.lua"))()
    else
        GunKillAuraButton.Text = "Gun Aura (Kill Mobs): OFF"
        GunKillAuraButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

local NoclipOnButton = Instance.new("TextButton", OtherTab)
NoclipOnButton.Text, NoclipOnButton.Size, NoclipOnButton.Position = "Noclip: ON", UDim2.new(0.8, 0, 0, 22), UDim2.new(0.1, 0, 0, 106)
NoclipOnButton.BackgroundColor3, NoclipOnButton.TextColor3 = Color3.fromRGB(30, 30, 30), Theme.Text
Instance.new("UICorner", NoclipOnButton).CornerRadius = UDim.new(0, 6)

local NoclipOffButton = Instance.new("TextButton", OtherTab)
NoclipOffButton.Text, NoclipOffButton.Size, NoclipOffButton.Position = "Noclip: OFF", UDim2.new(0.8, 0, 0, 22), UDim2.new(0.1, 0, 0, 138)
NoclipOffButton.BackgroundColor3, NoclipOffButton.TextColor3 = Color3.fromRGB(30, 30, 30), Theme.Text
Instance.new("UICorner", NoclipOffButton).CornerRadius = UDim.new(0, 6)

local noclipConnection
local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end
local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end
NoclipOnButton.MouseButton1Click:Connect(function()
    enableNoclip()
    NoclipOnButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    NoclipOffButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
end)
NoclipOffButton.MouseButton1Click:Connect(function()
    disableNoclip()
    NoclipOnButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NoclipOffButton.BackgroundColor3 = Color3.fromRGB(205, 50, 50)
end)

local antiVoidActive = false
local antiVoidConnection
local AntiVoidButton = Instance.new("TextButton", OtherTab)
AntiVoidButton.Text, AntiVoidButton.Size, AntiVoidButton.Position = "Anti-Void: OFF", UDim2.new(0.8, 0, 0, 22), UDim2.new(0.1, 0, 0, 170)
AntiVoidButton.BackgroundColor3, AntiVoidButton.TextColor3 = Color3.fromRGB(30, 30, 30), Theme.Text
Instance.new("UICorner", AntiVoidButton).CornerRadius = UDim.new(0, 6)
AntiVoidButton.MouseEnter:Connect(function()
    AntiVoidButton.BackgroundColor3 = antiVoidActive and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(40, 40, 40)
end)
AntiVoidButton.MouseLeave:Connect(function()
    AntiVoidButton.BackgroundColor3 = antiVoidActive and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(30, 30, 30)
end)
local function startAntiVoid()
    antiVoidConnection = game:GetService("RunService").Stepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            if rootPart.Position.Y < -1 then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWTPTRAIN.github.io/refs/heads/main/TRAIN.LUA"))()
            end
        end
    end)
end
local function stopAntiVoid()
    if antiVoidConnection then
        antiVoidConnection:Disconnect()
        antiVoidConnection = nil
    end
end
AntiVoidButton.MouseButton1Click:Connect(function()
    antiVoidActive = not antiVoidActive
    if antiVoidActive then
        AntiVoidButton.Text = "Anti-Void: ON"
        AntiVoidButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        startAntiVoid()
    else
        AntiVoidButton.Text = "Anti-Void: OFF"
        AntiVoidButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        stopAntiVoid()
    end
end)

CreateButton(OtherTab, "Train Kill Aura", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/trainkillaura.github.io/refs/heads/main/trainkill.lua"))()
end, UDim2.new(0.1, 0, 0, 202))

-- Towns Tab for Town Teleports
local TownsTab = CreateTab("Towns")
CreateButton(TownsTab, "Town 1", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown1.github.io/refs/heads/main/town1.lua"))()
end, UDim2.new(0.1, 0, 0, 10))
CreateButton(TownsTab, "Town 2", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown2.github.io/refs/heads/main/town2.lua"))()
end, UDim2.new(0.1, 0, 0, 42))
CreateButton(TownsTab, "Town 3", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown3.github.io/refs/heads/main/town3.lua"))()
end, UDim2.new(0.1, 0, 0, 74))
CreateButton(TownsTab, "Town 4", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown4.github.io/refs/heads/main/town4.lua"))()
end, UDim2.new(0.1, 0, 0, 106))
CreateButton(TownsTab, "Town 5", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown5.github.io/refs/heads/main/town5.lua"))()
end, UDim2.new(0.1, 0, 0, 138))
CreateButton(TownsTab, "Town 6", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown6.github.io/refs/heads/main/town6.lua"))()
end, UDim2.new(0.1, 0, 0, 170))

local BypassTab = CreateTab("OTHER TP")
CreateButton(BypassTab, "Tp To Fort", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Tpfort.github.io/refs/heads/main/Tpfort.lua"))()
end, UDim2.new(0.1, 0, 0, 10))
CreateButton(BypassTab, "TP StillWater Prision", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/StillwaterPrisontp.github.io/refs/heads/main/ringta.lua"))()
end, UDim2.new(0.1, 0, 0, 42))
CreateButton(BypassTab, "Jade Sword", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fjruie/tpjadesword.github.io/refs/heads/main/ringta.lua"))()
end, UDim2.new(0.1, 0, 0, 74))
CreateButton(BypassTab, "Jade Mask", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/jademask.github.io/refs/heads/main/ringta.lua"))()
end, UDim2.new(0.1, 0, 0, 106))
CreateButton(BypassTab, "Tp To End", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/newtpend.github.io/refs/heads/main/ringta.lua"))()
end, UDim2.new(0.1, 0, 0, 138))
CreateButton(BypassTab, "Tp Trading Post", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/trading.github.io/refs/heads/main/ringta.lua"))()
end, UDim2.new(0.1, 0, 0, 170))

-- Features Tab for Features
local FeaturesTab = CreateTab("Features")
CreateButton(FeaturesTab, "Collect All", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/collectall.github.io/refs/heads/main/ringta.lua"))()
end, UDim2.new(0.1, 0, 0, 10))
CreateButton(FeaturesTab, "Auto Electrocutioner", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Electrocutioner.github.io/refs/heads/main/tesla.lua"))()
end, UDim2.new(0.1, 0, 0, 42))
-- Fly Button and Slider (special vertical spacing)
CreateButton(FeaturesTab, "Fly", function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local flySpeed = 50
    local velocityHandlerName = "VelocityHandler"
    local gyroHandlerName = "GyroHandler"
    local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local root = HumanoidRootPart
    local camera = Workspace.CurrentCamera
    local v3inf = Vector3.new(9e9, 9e9, 9e9)
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3inf
    bv.Velocity = Vector3.new()
    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50
    RunService.RenderStepped:Connect(function()
        local VelocityHandler = root:FindFirstChild(velocityHandlerName)
        local GyroHandler = root:FindFirstChild(gyroHandlerName)
        if VelocityHandler and GyroHandler then
            GyroHandler.CFrame = camera.CFrame
            local direction = controlModule:GetMoveVector()
            VelocityHandler.Velocity =
                (camera.CFrame.RightVector * direction.X * flySpeed) +
                (-camera.CFrame.LookVector * direction.Z * flySpeed)
        end
    end)
    local slider = Instance.new("Frame", FeaturesTab)
    slider.Size = UDim2.new(0.8, 0, 0, 16)
    slider.Position = UDim2.new(0.1, 0, 0, 106)
    slider.BackgroundColor3 = Theme.Button
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 6)
    local sliderButton = Instance.new("TextButton", slider)
    sliderButton.Size = UDim2.new(0.1, 0, 1, 0)
    sliderButton.Position = UDim2.new(0, 0, 0.5, 0)
    sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderButton.Text = ""
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(0, 6)
    local speedText = Instance.new("TextLabel", FeaturesTab)
    speedText.Size = UDim2.new(0.8, 0, 0, 16)
    speedText.Position = UDim2.new(0.1, 0, 0, 130)
    speedText.Text = "Fly Speed: " .. flySpeed
    speedText.BackgroundTransparency = 1
    speedText.TextColor3 = Theme.Text
    speedText.Font = Enum.Font.GothamBold
    speedText.TextSize = 16
    local dragging = false
    sliderButton.MouseButton1Down:Connect(function(input)
        dragging = true
        local dragConn
        local endConn
        dragConn = UserInputService.InputChanged:Connect(function(inputChanged)
            if dragging and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
                local pos = inputChanged.Position.X - slider.AbsolutePosition.X
                local scale = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                flySpeed = math.floor(scale * 990) + 10
                speedText.Text = "Fly Speed: " .. flySpeed
                sliderButton.Position = UDim2.new(scale, 0, 0.5, 0)
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(inputEnded)
            if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if dragConn then dragConn:Disconnect() end
                if endConn then endConn:Disconnect() end
            end
        end)
    end)
end, UDim2.new(0.1, 0, 0, 74)) -- fly button
CreateButton(FeaturesTab, "Fly Off", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/un.github.io/refs/heads/main/ufly.lua"))()
end, UDim2.new(0.1, 0, 0, 162))

-- Minimize Button
local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Text, MinimizeButton.Size, MinimizeButton.Position = "-", UDim2.new(0, 20, 0, 20), UDim2.new(1, -25, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
MinimizeButton.TextColor3 = Theme.Text
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)
local ReopenButton = Instance.new("TextButton", ScreenGui)
ReopenButton.Text, ReopenButton.Size, ReopenButton.Position = "Open RINGTA SCRIPTS", UDim2.new(0, 150, 0, 30), UDim2.new(0.5, 0, 0, -22)
ReopenButton.AnchorPoint, ReopenButton.Visible = Vector2.new(0.5, 0), false
ReopenButton.BackgroundColor3, ReopenButton.TextColor3 = Theme.Button, Theme.Text
Instance.new("UICorner", ReopenButton).CornerRadius = UDim.new(0, 6)
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    if not isMinimized then
        isMinimized = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, -0.7, 0),
            Size = UDim2.new(0, 250, 0, 50)
        }):Play()
        wait(0.3)
        MainFrame.Visible = false
        ReopenButton.Visible = true
    end
end)
ReopenButton.MouseButton1Click:Connect(function()
    if isMinimized then
        isMinimized = false
        ReopenButton.Visible = false
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 350, 0, 230)
        }):Play()
    end
end)
