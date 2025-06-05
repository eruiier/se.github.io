local TweenService, UIS, rs = game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

-- Theme
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Button = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(255, 255, 255)
}

local function makeDraggable(frame)
    local dragToggle, dragStart, startPos, dragInput
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
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
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main UI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "RingtaUI"

-- MainFrame (for rainbow outline & minimize, but now not the parent of other frames)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.AnchorPoint = Vector2.new(0, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Rainbow border
local frameOutline = Instance.new("UIStroke", MainFrame)
frameOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameOutline.Thickness = 3
local hue = 0
rs.RenderStepped:Connect(function()
    hue = (hue + 0.005) % 1
    frameOutline.Color = Color3.fromHSV(hue, 1, 1)
end)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "RINGTA SCRIPTS"
Title.Size = UDim2.new(1, 0, 0, 32)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

-- TabsFrame (tab selector, DRAGGABLE)
local TabsFrame = Instance.new("Frame", ScreenGui)
TabsFrame.Size = UDim2.new(0, 110, 0, 220)
TabsFrame.Position = UDim2.new(0.5, -250, 0.5, -110)
TabsFrame.BackgroundColor3 = Theme.Button
Instance.new("UICorner", TabsFrame).CornerRadius = UDim.new(0, 8)
makeDraggable(TabsFrame)

-- TabContentFrame (content area, DRAGGABLE, contains a ScrollingFrame)
local TabContentFrame = Instance.new("Frame", ScreenGui)
TabContentFrame.Size = UDim2.new(0, 340, 0, 220)
TabContentFrame.Position = UDim2.new(0.5, -120, 0.5, -110)
TabContentFrame.BackgroundColor3 = Theme.Background
Instance.new("UICorner", TabContentFrame).CornerRadius = UDim.new(0, 8)
makeDraggable(TabContentFrame)

-- ScrollingFrame for buttons
local ButtonScroll = Instance.new("ScrollingFrame", TabContentFrame)
ButtonScroll.Size = UDim2.new(1, 0, 1, 0)
ButtonScroll.Position = UDim2.new(0, 0, 0, 0)
ButtonScroll.BackgroundTransparency = 1
ButtonScroll.BorderSizePixel = 0
ButtonScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonScroll.ScrollBarThickness = 6
ButtonScroll.ClipsDescendants = true
ButtonScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Tabs
local TAB_NAMES = {"Main", "Features", "Other"}
local currentTab = "Main"
local Tabs = {}

-- Tab Buttons
for i, tabName in ipairs(TAB_NAMES) do
    local TabButton = Instance.new("TextButton", TabsFrame)
    TabButton.Text = tabName
    TabButton.Size = UDim2.new(1, -10, 0, 40)
    TabButton.Position = UDim2.new(0, 5, 0, (i-1)*50 + 10)
    TabButton.BackgroundColor3 = Theme.Button
    TabButton.TextColor3 = Theme.Text
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 16
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)

    TabButton.MouseButton1Click:Connect(function()
        currentTab = tabName
        for _, btn in pairs(TabsFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Theme.Button
            end
        end
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        -- Refresh Buttons
        for _, child in pairs(ButtonScroll:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end
        loadTab(tabName)
    end)

    Tabs[tabName] = TabButton
end

Tabs["Main"].BackgroundColor3 = Color3.fromRGB(50, 205, 50)

local layout = Instance.new("UIListLayout", ButtonScroll)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Button Template
local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton", parent)
    Button.Text = text
    Button.Size = UDim2.new(1, -16, 0, 40)
    Button.BackgroundColor3 = Theme.Button
    Button.TextColor3 = Theme.Text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 15
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Theme.Button
    end)
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- Tab Contents: Define per tab
local tabDefinitions = {
    Main = {
        {label = "Teleport 1", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/newhit.github.io/refs/heads/main/hithit.lua"))()
        end},
        {label = "Teleport 2", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWTPTRAIN.github.io/refs/heads/main/TRAIN.LUA"))()
        end},
        {label = "Teleport 3", callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/ringtaa/sterlingnotifcation.github.io/refs/heads/main/Sterling.lua'))()
        end},
        {label = "Teleport 4", callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/ringtaa/tptotesla.github.io/refs/heads/main/Tptotesla.lua'))()
        end},
        {label = "Teleport 5", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/castletpfast.github.io/refs/heads/main/FASTCASTLE.lua"))()
        end},
        {label = "Teleport 6", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/erhjf.github.io/refs/heads/main/hew.lua"))()
        end},
        {label = "TP to End", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/NEWNEWtpend.github.io/refs/heads/main/en.lua"))()
        end},
        {label = "TP to Bank", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Tptobank.github.io/refs/heads/main/Banktp.lua"))()
        end},
        {label = "Town 1", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringta9321/tptown1.github.io/refs/heads/main/town1.lua"))()
        end},
        -- Add more as needed...
    },
    Features = {
        {label = "Gun Aura (Kill Mobs)", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWKILLAURA.github.io/refs/heads/main/NEWkill.lua"))()
        end},
        {label = "Noclip: ON", callback = function()
            -- Noclip logic (as in your original script)
            if _G.noclipConn then return end
            _G.noclipConn = rs.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end},
        {label = "Noclip: OFF", callback = function()
            if _G.noclipConn then
                _G.noclipConn:Disconnect()
                _G.noclipConn = nil
            end
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end},
        {label = "Anti-Void: ON", callback = function()
            if _G.antiVoidConn then return end
            _G.antiVoidConn = rs.Stepped:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = player.Character.HumanoidRootPart
                    if rootPart.Position.Y < -1 then
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/NEWTPTRAIN.github.io/refs/heads/main/TRAIN.LUA"))()
                    end
                end
            end)
        end},
        {label = "Anti-Void: OFF", callback = function()
            if _G.antiVoidConn then
                _G.antiVoidConn:Disconnect()
                _G.antiVoidConn = nil
            end
        end},
        {label = "Fly", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/unflyslider.github.io/refs/heads/main/flyslider.lua"))()
        end},
        {label = "Fly Off", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/un.github.io/refs/heads/main/ufly.lua"))()
        end},
    },
    Other = {
        {label = "Collect All", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/collectall.github.io/refs/heads/main/ringta.lua"))()
        end},
        {label = "Auto Electrocutioner", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Electrocutioner.github.io/refs/heads/main/tesla.lua"))()
        end},
        {label = "Tp To Fort", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Tpfort.github.io/refs/heads/main/Tpfort.lua"))()
        end},
        {label = "Sterling Town", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/fjruie/newsterlingtp.github.io/refs/heads/main/RINGTA.lua"))()
        end},
        {label = "Jade Sword", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/fjruie/tpjadesword.github.io/refs/heads/main/ringta.lua"))()
        end},
        {label = "Jade Mask", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/jademask.github.io/refs/heads/main/ringta.lua"))()
        end},
        {label = "Tp To End", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/newtpend.github.io/refs/heads/main/ringta.lua"))()
        end},
        {label = "Tp Trading Post", callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/trading.github.io/refs/heads/main/ringta.lua"))()
        end},
    }
}

function loadTab(tabName)
    for _, buttonDef in ipairs(tabDefinitions[tabName]) do
        CreateButton(ButtonScroll, buttonDef.label, buttonDef.callback)
    end
end

-- Initialize with main tab
loadTab("Main")

-- Minimize Button
local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Text = "-"
MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
MinimizeButton.Position = UDim2.new(1, -36, 0, 4)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
MinimizeButton.TextColor3 = Theme.Text
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 22
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 8)

local ReopenButton = Instance.new("TextButton", ScreenGui)
ReopenButton.Text = "Open RINGTA SCRIPTS"
ReopenButton.Size = UDim2.new(0, 180, 0, 36)
ReopenButton.Position = UDim2.new(0.5, -90, 0, 8)
ReopenButton.AnchorPoint = Vector2.new(0,0)
ReopenButton.BackgroundColor3, ReopenButton.TextColor3 = Theme.Button, Theme.Text
ReopenButton.Font = Enum.Font.GothamBold
ReopenButton.TextSize = 16
Instance.new("UICorner", ReopenButton).CornerRadius = UDim.new(0, 8)
ReopenButton.Visible = false

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    if not isMinimized then
        isMinimized = true
        MainFrame.Visible = false
        TabsFrame.Visible = false
        TabContentFrame.Visible = false
        ReopenButton.Visible = true
    end
end)

ReopenButton.MouseButton1Click:Connect(function()
    if isMinimized then
        isMinimized = false
        MainFrame.Visible = true
        TabsFrame.Visible = true
        TabContentFrame.Visible = true
        ReopenButton.Visible = false
    end
end)
