-- Skidder's Dream GUI by NotImportant
local Gui = Instance.new("ScreenGui")
local Toggle = Instance.new("TextButton")
local Main = Instance.new("Frame")
local UIStroke = Instance.new("UIStroke")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local LinkBox = Instance.new("TextBox")
local FileBox = Instance.new("TextBox")
local IB2Btn = Instance.new("TextButton")
local MoonsecBtn = Instance.new("TextButton")
local Credit = Instance.new("TextLabel")

Gui.Name = "SkidderDream"
Gui.Parent = game.CoreGui
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Toggle Button
Toggle.Parent = Gui
Toggle.AnchorPoint = Vector2.new(1, 0.5)
Toggle.Position = UDim2.new(1, -10, 0.5, 0)
Toggle.Size = UDim2.new(0, 40, 0, 40)
Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Toggle.Text = "+"
Toggle.TextColor3 = Color3.fromRGB(255, 102, 0)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextScaled = true
Toggle.BorderSizePixel = 0

-- Main Frame
Main.Parent = Gui
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 300, 0, 240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Visible = true

UICorner.Parent = Main

UIStroke.Parent = Main
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 102, 0)

-- Animation: Pulsing Orange-Black Outline
task.spawn(function()
	while true do
		for i = 0, 1, 0.05 do
			UIStroke.Color = Color3.new(1, 0.4 + (0.2 * math.sin(tick()*3)), 0)
			wait(0.03)
		end
	end
end)

-- Title
Title.Parent = Main
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Skidder's Dream"
Title.TextColor3 = Color3.fromRGB(255, 102, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22

-- Link / Loadstring Box
LinkBox.Parent = Main
LinkBox.PlaceholderText = "Put loadstring or link here"
LinkBox.Size = UDim2.new(0.9, 0, 0, 30)
LinkBox.Position = UDim2.new(0.05, 0, 0.25, 0)
LinkBox.Text = ""
LinkBox.TextColor3 = Color3.fromRGB(255, 255, 255)
LinkBox.PlaceholderColor3 = Color3.fromRGB(180, 90, 0)
LinkBox.Font = Enum.Font.Code
LinkBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LinkBox.BorderSizePixel = 0
UICorner:Clone().Parent = LinkBox

-- Filename Box
FileBox.Parent = Main
FileBox.PlaceholderText = "Enter filename (optional)"
FileBox.Size = UDim2.new(0.9, 0, 0, 30)
FileBox.Position = UDim2.new(0.05, 0, 0.45, 0)
FileBox.Text = ""
FileBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FileBox.PlaceholderColor3 = Color3.fromRGB(180, 90, 0)
FileBox.Font = Enum.Font.Code
FileBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FileBox.BorderSizePixel = 0
UICorner:Clone().Parent = FileBox

-- IB2 Button
IB2Btn.Parent = Main
IB2Btn.Text = "IronBrew2"
IB2Btn.Size = UDim2.new(0.42, 0, 0, 30)
IB2Btn.Position = UDim2.new(0.05, 0, 0.65, 0)
IB2Btn.Font = Enum.Font.GothamBold
IB2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
IB2Btn.BackgroundColor3 = Color3.fromRGB(255, 102, 0)
IB2Btn.BorderSizePixel = 0
UICorner:Clone().Parent = IB2Btn

-- Moonsec Button
MoonsecBtn.Parent = Main
MoonsecBtn.Text = "MoonsecV3"
MoonsecBtn.Size = UDim2.new(0.42, 0, 0, 30)
MoonsecBtn.Position = UDim2.new(0.53, 0, 0.65, 0)
MoonsecBtn.Font = Enum.Font.GothamBold
MoonsecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MoonsecBtn.BackgroundColor3 = Color3.fromRGB(255, 102, 0)
MoonsecBtn.BorderSizePixel = 0
UICorner:Clone().Parent = MoonsecBtn

-- Credit
Credit.Parent = Main
Credit.Text = "Made by NotImportant btw"
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -25)
Credit.BackgroundTransparency = 1
Credit.TextColor3 = Color3.fromRGB(100, 100, 100)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 12

-- Toggle Logic
local open = true
Toggle.MouseButton1Click:Connect(function()
	open = not open
	Main.Visible = open
	Toggle.Text = open and "-" or "+"
end)

-- Dump Functions
local function notify(msg)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Skidder's Dream",
		Text = msg,
		Duration = 4
	})
end

local function dumpIronBrew2(link)
	if not link:match("^https?://") then
		notify("Invalid link!")
		return
	end
	local file = FileBox.Text ~= "" and FileBox.Text or "ironbrew2_dump.lua"
	local scriptContent = game:HttpGet(link)
	writefile(file, "-- Dumped with IronBrew2\n\n" .. scriptContent)
	notify("IronBrew2 dump saved to " .. file)
end

local function dumpMoonsecV3(link)
	if not link:match("^https?://") then
		notify("Invalid link!")
		return
	end
	local file = FileBox.Text ~= "" and FileBox.Text or "moonsecv3_dump.lua"
	local scriptContent = game:HttpGet(link)
	writefile(file, "-- MoonsecV3 Dump\n\n" .. scriptContent)
	notify("MoonsecV3 dump saved to " .. file)
end

-- Button Listeners
IB2Btn.MouseButton1Click:Connect(function()
	local link = LinkBox.Text
	if link ~= "" then
		dumpIronBrew2(link)
	else
		notify("Please enter a valid link!")
	end
end)

MoonsecBtn.MouseButton1Click:Connect(function()
	local link = LinkBox.Text
	if link ~= "" then
		dumpMoonsecV3(link)
	else
		notify("Please enter a valid link!")
	end
end)
