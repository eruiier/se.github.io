-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local HUM = Character:FindFirstChildOfClass("Humanoid")

-- Noclip (persistent)
task.spawn(function()
    while true do
        for _, part in ipairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        task.wait(0.1)
    end
end)
Player.CharacterAdded:Connect(function()
    task.wait(0.2)
    while true do
        for _, part in ipairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        task.wait(0.1)
    end
end)

if not Character.PrimaryPart then
    Character.PrimaryPart = HRP
end

-- Store original WalkSpeed and temporarily disable movement
local originalWalkSpeed = HUM.WalkSpeed
HUM.WalkSpeed = 0

-- Step 1: Teleport above Generator and anchor
local Generator = Workspace:WaitForChild("TeslaLab"):WaitForChild("Generator")
local generatorCFrame = Generator:GetPivot()
local modelPosition = generatorCFrame.Position
HRP.CFrame = CFrame.new(modelPosition + Vector3.new(0, 5, 0))
HRP.Anchored = true
task.wait(2)

-- Step 2: Find and sit on closest available Chair.Seat
local RuntimeItems = Workspace:WaitForChild("RuntimeItems")
local function findClosestSeat()
    local closestSeat, minDist = nil, math.huge
    local pos = HRP.Position
    for _, chairModel in ipairs(RuntimeItems:GetChildren()) do
        if chairModel:IsA("Model") and chairModel.Name == "Chair" then
            local seat = chairModel:FindFirstChildOfClass("Seat")
            if seat and seat.Occupant == nil then
                local d = (seat.Position - pos).Magnitude
                if d < minDist then
                    minDist = d
                    closestSeat = seat
                end
            end
        end
    end
    return closestSeat
end

local seat = findClosestSeat()
local chosenSeat, seatWeld
if seat then
    HRP.Anchored = true
    HRP.CFrame = seat.CFrame + Vector3.new(0, 3, 0)
    task.delay(0.1, function()
        if HRP and HRP.Anchored then HRP.Anchored = false end
    end)
    task.delay(0.15, function()
        if HRP and HRP.Anchored then HRP.Anchored = false end
    end)
    task.wait(0.5)
    seat:Sit(HUM)

    -- Weld HRP to seat to remain seated during actions
    local weld = Instance.new("WeldConstraint")
    weld.Name = "PersistentSeatWeld"
    weld.Part0 = HRP
    weld.Part1 = seat
    weld.Parent = HRP
    chosenSeat = seat
    seatWeld = weld

    -- Disable collisions on entire chair model
    local chairModel = seat.Parent
    for _, part in ipairs(chairModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
else
    HRP.Anchored = false
    return
end

-- Step 3: Enable scripted flying via BodyVelocity, BodyGyro
local v3inf = Vector3.new(9e9, 9e9, 9e9)
local BV = Instance.new("BodyVelocity")
BV.Name = "FlyBV"
BV.Parent = HRP
BV.MaxForce = v3inf
BV.Velocity = Vector3.new()

local BG = Instance.new("BodyGyro")
BG.Name = "FlyBG"
BG.Parent = HRP
BG.MaxTorque = v3inf
BG.P = 1000
BG.D = 50

local function flyTo(targetPos)
    while (HRP.Position - targetPos).Magnitude > 2 do
        local dir = (targetPos - HRP.Position).Unit
        BV.Velocity = dir * 50
        BG.CFrame = CFrame.new(HRP.Position, targetPos)
        RunService.Heartbeat:Wait()
    end
    BV.Velocity = Vector3.new()
end

-- Restore movement speed
task.wait(1)
HUM.WalkSpeed = originalWalkSpeed

-- Step 4: Equip Sack tool
local sackTool = Player.Backpack:FindFirstChild("Sack")
if sackTool then
    HUM:EquipTool(sackTool)
    task.wait(0.5)
end

-- Step 5: Collect Werewolf parts by flying to each
local itemsToCollect = {
    Workspace.RuntimeItems:FindFirstChild("LeftWerewolfArm"),
    Workspace.RuntimeItems:FindFirstChild("LeftWerewolfLeg"),
    Workspace.RuntimeItems:FindFirstChild("RightWerewolfArm"),
    Workspace.RuntimeItems:FindFirstChild("RightWerewolfLeg"),
    Workspace.RuntimeItems:FindFirstChild("WerewolfTorso"),
    Workspace.RuntimeItems:FindFirstChild("BrainJar"),
    Workspace.RuntimeItems.BrainJar and Workspace.RuntimeItems.BrainJar:FindFirstChild("Brain")
}

local storeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")
for _, item in ipairs(itemsToCollect) do
    if item and item:IsDescendantOf(Workspace.RuntimeItems) then
        local targetCFrame
        if item:IsA("BasePart") then
            targetCFrame = item.CFrame
        elseif item.PrimaryPart then
            targetCFrame = item.PrimaryPart.CFrame
        else
            for _, d in ipairs(item:GetDescendants()) do
                if d:IsA("BasePart") then
                    targetCFrame = d.CFrame
                    break
                end
            end
        end
        if targetCFrame then
            local flyTarget = targetCFrame.Position + Vector3.new(0, 2, 0)
            flyTo(flyTarget)
            task.wait(0.2)
            storeRemote:FireServer(item)
            task.wait(0.2)
        end
    end
end

-- Step 6: Fly to front of ExperimentTable to drop parts
local experimentTable = Workspace.TeslaLab:FindFirstChild("ExperimentTable")
local placedPartsFolder = experimentTable and experimentTable:FindFirstChild("PlacedParts")
if experimentTable and placedPartsFolder then
    local dropTarget = experimentTable.PrimaryPart
    if not dropTarget then
        for _, p in ipairs(experimentTable:GetDescendants()) do
            if p:IsA("BasePart") then
                dropTarget = p
                break
            end
        end
    end
    if dropTarget then
        local frontPos = dropTarget.Position + (dropTarget.CFrame.LookVector * 2) + Vector3.new(0, 5, 0)
        flyTo(frontPos)
        task.wait(0.5)
        local dropRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DropItem")
        local initialCount = #placedPartsFolder:GetChildren()
        for i = 1, #itemsToCollect do
            local success = false
            local attempts = 0
            while not success and attempts < 5 do
                dropRemote:FireServer()
                task.wait(0.2)
                local currentCount = #placedPartsFolder:GetChildren()
                if currentCount > initialCount then
                    success = true
                    initialCount = currentCount
                else
                    flyTo(frontPos)
                    task.wait(0.2)
                    attempts = attempts + 1
                end
            end
        end
    end
end

-- Step 7: Teleport back to generator and do ProximityPrompt
task.wait(1)
HRP.CFrame = generatorCFrame * CFrame.new(0, 4, 0)
task.wait(2)
local POSITION = HRP.Position
local nearestPrompt, nearestDist = nil, math.huge
for _, part in ipairs(workspace:GetDescendants()) do
    if part:IsA("ProximityPrompt") and part.Enabled then
        local parent = part.Parent
        if parent and parent:IsA("BasePart") then
            local dist = (parent.Position - POSITION).Magnitude
            if dist < nearestDist then
                nearestPrompt = part
                nearestDist = dist
            end
        end
    end
end
if nearestPrompt then
    for i = 1, 3 do
        fireproximityprompt(nearestPrompt)
        task.wait(0.2)
    end
    print("Fired prompt '" .. nearestPrompt.Name .. "' 3 times.")
else
    warn("No enabled ProximityPrompt found near the teleport location.")
end

task.wait(3) -- Wait 3 seconds after firing prompt

-- Step 8: TP 12 blocks above experiment table
if experimentTable then
    local tpTarget = experimentTable.PrimaryPart or experimentTable:FindFirstChildWhichIsA("BasePart")
    if tpTarget then
        HRP.CFrame = tpTarget.CFrame * CFrame.new(0, 12, 0)
    end
end

while true do task.wait() end

-- Other scripts (as in your original)
task.spawn(function()
    task.wait(1)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/fly.github.io/refs/heads/main/fly.lua"))()
end)

task.spawn(function()
    task.wait(2)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hbjrev/newhit.github.io/refs/heads/main/hithit.lua"))()
end)

task.spawn(function()
    local Backpack = Player:WaitForChild("Backpack")
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local shovel = Backpack:FindFirstChild("shovel")
    if shovel then
        Humanoid:EquipTool(shovel)
        print("Equipped the shovel!")
    else
        warn("No shovel found in your inventory!")
    end
end)
