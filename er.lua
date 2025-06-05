local TweenService, UIS, rs = game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

-- Theme and Size
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Button = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(255, 255, 255)
}
local UI_WIDTH, UI_HEIGHT = 350, 230

-- Drag helper
local function makeDraggable(frame)
    local dragToggle, dragStart, startPos, dragInput
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragToggle and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main UI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "RingtaUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, UI_WIDTH, 0, UI_HEIGHT)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Theme.Background
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
makeDraggable(MainFrame)

local frameOutline = Instance.new("UIStroke", MainFrame)
frameOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameOutline.Thickness = 3
local hue = 0
rs.RenderStepped:Connect(function()
    hue = (hue + 0.005) % 1
    frameOutline.Color = Color3.fromHSV(hue, 1, 1)
end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "RINGTA SCRIPTS"
Title.Size = UDim2.new(1, -20, 0, 20)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Tabs Frame (tab selector)
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(0, 100, 1, -40)
TabsFrame.Position = UDim2.new(0, 10, 0, 30)
TabsFrame.BackgroundColor3 = Theme.Button
Instance.new("UICorner", TabsFrame).CornerRadius = UDim.new(0, 6)

-- TabContentFrame (content area)
local TabContentFrame = Instance.new("Frame", MainFrame)
TabContentFrame.Size = UDim2.new(1, -120, 1, -40)
TabContentFrame.Position = UDim2.new(0, 110, 0, 30)
TabContentFrame.BackgroundColor3 = Theme.Background
TabContentFrame.ClipsDescendants = true
Instance.new("UICorner", TabContentFrame).CornerRadius = UDim.new(0, 6)

-- Scrollable content for buttons
local ButtonScroll = Instance.new("ScrollingFrame", TabContentFrame)
ButtonScroll.Size = UDim2.new(1, 0, 1, 0)
ButtonScroll.Position = UDim2.new(0, 0, 0, 0)
ButtonScroll.BackgroundTransparency = 1
ButtonScroll.BorderSizePixel = 0
ButtonScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonScroll.ScrollBarThickness = 6
ButtonScroll.ClipsDescendants = true
ButtonScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", ButtonScroll)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local TAB_NAMES = {"Main", "Features", "Towns"}
local Tabs = {}

-- Tab Buttons
for i, tabName in ipairs(TAB_NAMES) do
    local TabButton = Instance.new("TextButton", TabsFrame)
    TabButton.Text = tabName
    TabButton.Size = UDim2.new(1, -10, 0, 30)
    TabButton.Position = UDim2.new(0, 5, 0, (i-1)*35)
    TabButton.BackgroundColor3 = Theme.Button
    TabButton.TextColor3 = Theme.Text
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    Tabs[tabName] = TabButton
end

-- Button Template
local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton", parent)
    Button.Text = text
    Button.Size = UDim2.new(1, -14, 0, 26)
    Button.BackgroundColor3 = Theme.Button
    Button.TextColor3 = Theme.Text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Theme.Button
    end)
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- STATE for Features
local noclipConnection, noclipOn
local function enableNoclip(feedbackButton, offButton)
    if noclipConnection then return end
    noclipOn = true
    feedbackButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    if offButton then offButton.BackgroundColor3 = Theme.Button end
    noclipConnection = rs.Stepped:Connect(function()
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end
local function disableNoclip(onButton, feedbackButton)
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    noclipOn = false
    if onButton then onButton.BackgroundColor3 = Theme.Button end
    feedbackButton.BackgroundColor3 = Color3.fromRGB(205, 50, 50)
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local antiVoidConnection, antiVoidActive
local function startAntiVoid(button)
    if antiVoidConnection then return end
    antiVoidActive = true
    button.Text = "Anti-Void: ON"
    button.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    antiVoidConnection = rs.Stepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            if rootPart.Position.Y < -1 then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWTPTRAIN.github.io/refs/heads/main/TRAIN.LUA"))()
            end
        end
    end)
end
local function stopAntiVoid(button)
    if antiVoidConnection then antiVoidConnection:Disconnect() antiVoidConnection = nil end
    antiVoidActive = false
    button.Text = "Anti-Void: OFF"
    button.BackgroundColor3 = Theme.Button
end

-- Features
local tabDefinitions = {
    ["Main"] = {
        {label = "AUTO HIT OP", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/newhit.github.io/refs/heads/main/hithit.lua"))()
        end},
        {label = "TP to Train", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWTPTRAIN.github.io/refs/heads/main/TRAIN.LUA"))()
        end},
        {label = "TP to End", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/newtpend.github.io/refs/heads/main/ringta.lua"))()
        end},
        {label = "TP to Sterling", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/sterlingnotifcation.github.io/refs/heads/main/Sterling.lua"))()
        end},
        {label = "TP to TeslaLab", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/tptotesla.github.io/refs/heads/main/Tptotesla.lua"))()
        end},
        {label = "TP to Castle", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/castletpfast.github.io/refs/heads/main/FASTCASTLE.lua"))()
        end},
        {label = "TP to Unicorn", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/erhjf.github.io/refs/heads/main/hew.lua"))()
        end},
        {label = "TP to Bank", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Tptobank.github.io/refs/heads/main/Banktp.lua"))()
        end},
        {label = "TP to Fort", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Tpfort.github.io/refs/heads/main/Tpfort.lua"))()
        end},
    },
    ["Features"] = function(parent)
        CreateButton(parent, "GunKill Aura", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWKILLAURA.github.io/refs/heads/main/NEWkill.lua"))()
        end)
        local noclipOnBtn = CreateButton(parent, "Noclip: ON", function()
            enableNoclip(noclipOnBtn, nil)
        end)
        local noclipOffBtn = CreateButton(parent, "Noclip: OFF", function()
            disableNoclip(noclipOnBtn, noclipOffBtn)
        end)
        local antiVoidBtn = CreateButton(parent, "Anti-Void: OFF", function()
            if antiVoidActive then stopAntiVoid(antiVoidBtn)
            else startAntiVoid(antiVoidBtn) end
        end)
        -- FLY BUTTON with slider and speed text
        CreateButton(parent, "Fly", function()
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
            local rsConn
            rsConn = RunService.RenderStepped:Connect(function()
                if not bv.Parent or not bg.Parent then
                    if rsConn then rsConn:Disconnect() end
                    return
                end
                bg.CFrame = camera.CFrame
                local direction = controlModule:GetMoveVector()
                bv.Velocity =
                    (camera.CFrame.RightVector * direction.X * flySpeed) +
                    (-camera.CFrame.LookVector * direction.Z * flySpeed)
            end)
            -- slider UI
            local slider = Instance.new("Frame", parent)
            slider.Size = UDim2.new(0.8, 0, 0.13, 0)
            slider.Position = UDim2.new(0.1, 0, 0.29, 0)
            slider.BackgroundColor3 = Theme.Button
            Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 6)
            local sliderButton = Instance.new("TextButton", slider)
            sliderButton.Size = UDim2.new(0.1, 0, 1, 0)
            sliderButton.Position = UDim2.new(0, 0, 0.5, 0)
            sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
            sliderButton.Text = ""
            sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(0, 6)
            -- Text label
            local speedText = Instance.new("TextLabel", parent)
            speedText.Size = UDim2.new(0.8, 0, 0.13, 0)
            speedText.Position = UDim2.new(0.1, 0, 0.42, 0)
            speedText.Text = "Fly Speed: " .. flySpeed
            speedText.BackgroundTransparency = 1
            speedText.TextColor3 = Theme.Text
            speedText.Font = Enum.Font.GothamBold
            speedText.TextSize = 13
            -- Drag logic
            local dragging = false
            sliderButton.MouseButton1Down:Connect(function(input)
                dragging = true
                local dragConn, endConn
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
        end)
        CreateButton(parent, "Fly Off", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/un.github.io/refs/heads/main/ufly.lua"))()
        end)
        CreateButton(parent, "Collect All", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/collectall.github.io/refs/heads/main/ringta.lua"))()
        end)
        CreateButton(parent, "Auto Electrocutioner", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Electrocutioner.github.io/refs/heads/main/tesla.lua"))()
        end)
        CreateButton(parent, "TP to Trading Post", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/trading.github.io/refs/heads/main/ringta.lua"))()
        end)
    end,
    ["Towns"] = {
        {label = "Town 1", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown1.github.io/refs/heads/main/town1.lua"))()
        end},
        {label = "Town 2", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown2.github.io/refs/heads/main/town2.lua"))()
        end},
        {label = "Town 3", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown3.github.io/refs/heads/main/town3.lua"))()
        end},
        {label = "Town 4", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown4.github.io/refs/heads/main/town4.lua"))()
        end},
        {label = "Town 5", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown5.github.io/refs/heads/main/town5.lua"))()
        end},
        {label = "Town 6", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown6.github.io/refs/heads/main/town6.lua"))()
        end},
    }
}

local function loadTab(tabName)
    for _, child in pairs(ButtonScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    local def = tabDefinitions[tabName]
    if typeof(def) == "function" then
        def(ButtonScroll)
    else
        for _, buttonDef in ipairs(def) do
            CreateButton(ButtonScroll, buttonDef.label, buttonDef.callback)
        end
    end
end

-- Set up tab switching
for name, button in pairs(Tabs) do
    button.MouseButton1Click:Connect(function()
        for _, b in pairs(Tabs) do
            b.BackgroundColor3 = Theme.Button
        end
        button.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        loadTab(name)
    end)
end
Tabs.Main.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
loadTab("Main")

-- Minimize Button
local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Text = "-"
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -25, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
MinimizeButton.TextColor3 = Theme.Text
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

-- Reopen Button
local ReopenButton = Instance.new("TextButton", ScreenGui)
ReopenButton.Text = "Open RINGTA SCRIPTS"
ReopenButton.Size = UDim2.new(0, 150, 0, 30)
ReopenButton.Position = UDim2.new(0.5, 0, 0, -22)
ReopenButton.AnchorPoint = Vector2.new(0.5, 0)
ReopenButton.Visible = false
ReopenButton.BackgroundColor3 = Theme.Button
ReopenButton.TextColor3 = Theme.Text
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
