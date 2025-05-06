local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Using your provided values
local x = 57
local y = 3
local startZ = 30000
local endZ = -49032.99
local stepZ = -2000
local duration = 0.5
local stopTweening = false

local part = Instance.new("Part") -- The moving object
part.Position = Vector3.new(x, y, startZ)
part.Anchored = true
part.Parent = game.Workspace

local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")

local bondCounter = Instance.new("TextLabel") -- GUI counter
bondCounter.Size = UDim2.new(0, 200, 0, 50)
bondCounter.Position = UDim2.new(0.5, -100, 0, 50)
bondCounter.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bondCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
bondCounter.TextSize = 20
bondCounter.Text = "Bonds Found: 0"
bondCounter.Parent = screenGui

local bondCount = 0
local currentZ = startZ

function checkForBonds()
    for _, bond in pairs(workspace.RuntimeItems:GetChildren()) do
        if bond:IsA("Part") and (bond.Position.Z > currentZ + stepZ and bond.Position.Z <= currentZ) then
            bondCount += 1
        end
    end
    bondCounter.Text = "Bonds Found: " .. bondCount
end

while currentZ > endZ and not stopTweening do
    local newPosition = Vector3.new(x, y, currentZ + stepZ)
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(part, tweenInfo, {Position = newPosition})
    
    tween:Play()
    tween.Completed:Wait()
    
    currentZ += stepZ
    checkForBonds()
end

print("Tweening complete. Total Bonds Found: " .. bondCount)
