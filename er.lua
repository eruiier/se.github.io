local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

-- Function to enable noclip
local noclipConnection
local function enableNoclip()
    if noclipConnection then return end -- Prevent multiple connections
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false -- Disable collisions
                end
            end
        end
    end)
end
enableNoclip()
LocalPlayer.CharacterAdded:Connect(function()
    enableNoclip()
end)

if not character.PrimaryPart then
    character.PrimaryPart = hrp
end

local storeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")
local dropRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DropItem")

local targetCFrame = Workspace.TeslaLab.Generator.Generator.CFrame

local function isUnanchored(model)
    for _, p in pairs(model:GetDescendants()) do
        if p:IsA("BasePart") and not p.Anchored then
            return true
        end
    end
    return false
end

local function findNearestValidChair()
    local runtimeFolder = Workspace:FindFirstChild("RuntimeItems")
    if not runtimeFolder then return nil end

    local origin = targetCFrame.Position
    local closestSeat, shortest = nil, math.huge

    for _, item in pairs(runtimeFolder:GetChildren()) do
        if item:IsA("Model") and item.Name == "Chair" and isUnanchored(item) then
            local seat = item:FindFirstChildWhichIsA("Seat", true)
            if seat and not seat.Occupant then
                local dist = (origin - seat.Position).Magnitude
                if dist <= 100 and dist < shortest then -- Only chairs really close to the generator!
                    closestSeat = seat
                    shortest = dist
                end
            end
        end
    end

    return closestSeat
end

local function sitOnSeat(seat)
    hrp.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
    wait(0.2)
    seat:Sit(hum)
    for i = 1, 30 do
        if hum.SeatPart == seat then break end
        wait(0.1)
    end
    return seat
end

task.spawn(function()
    local alreadySat = false
    local chosenSeat = nil

    -- PRE-TP and sit phase
    for i = 1, 2 do
        hrp.CFrame = targetCFrame
        wait(1.1)
    end

    -- Sit-once logic, only if not already seated or unseated
    if not alreadySat or hum.SeatPart == nil then
        chosenSeat = nil
        while not chosenSeat do
            hrp.CFrame = targetCFrame
            wait(0.2)
            local seat = findNearestValidChair()
            if seat then
                local s = sitOnSeat(seat)
                if s then
                    chosenSeat = s
                    alreadySat = true
                end
            end
            wait(0.25)
        end
    end

    -- Do item collect/drop logic ONCE (not a loop)
    local sackTool = LocalPlayer.Backpack:FindFirstChild("Sack")
    if sackTool then
        hum:EquipTool(sackTool)
        wait(0.5)
    end

    local itemsToCollect = {
        Workspace.RuntimeItems:FindFirstChild("LeftWerewolfArm"),
        Workspace.RuntimeItems:FindFirstChild("LeftWerewolfLeg"),
        Workspace.RuntimeItems:FindFirstChild("RightWerewolfArm"),
        Workspace.RuntimeItems:FindFirstChild("RightWerewolfLeg"),
        Workspace.RuntimeItems:FindFirstChild("WerewolfTorso"),
        Workspace.RuntimeItems:FindFirstChild("BrainJar"),
        Workspace.RuntimeItems:FindFirstChild("BrainJar") and Workspace.RuntimeItems.BrainJar:FindFirstChild("Brain")
    }

    for _, item in ipairs(itemsToCollect) do
        if item and item:IsA("Instance") and item:IsDescendantOf(Workspace.RuntimeItems) then
            local cframeTarget = item:IsA("BasePart") and item.CFrame or (item.PrimaryPart and item.PrimaryPart.CFrame)
            if not cframeTarget then
                for _, d in ipairs(item:GetDescendants()) do
                    if d:IsA("BasePart") then
                        cframeTarget = d.CFrame
                        break
                    end
                end
            end
            if cframeTarget and chosenSeat then
                chosenSeat.CFrame = cframeTarget * CFrame.new(0, 2, 0)
                wait(0.3)
                storeRemote:FireServer(item)
                wait(0.2)
            end
        end
    end

    local experimentTable = Workspace.TeslaLab:FindFirstChild("ExperimentTable")
    if experimentTable and chosenSeat then
        local dropTarget = experimentTable.PrimaryPart
        if not dropTarget then
            for _, p in pairs(experimentTable:GetDescendants()) do
                if p:IsA("BasePart") then
                    dropTarget = p
                    break
                end
            end
        end
        if dropTarget then
            chosenSeat.CFrame = dropTarget.CFrame * CFrame.new(0, 5, 0)
            wait(0.75)
        end
    end

    for _ = 1, #itemsToCollect do
        dropRemote:FireServer()
        wait(0.2)
    end

    wait(3)

    -- TP to generator ONCE, then idle
    hrp.CFrame = targetCFrame

    -- Idle forever, do nothing else
    while true do wait() end
end)

task.spawn(function()
    wait(1)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/fly.github.io/refs/heads/main/fly.lua"))()
end)
