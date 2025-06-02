local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

if not character.PrimaryPart then
    character.PrimaryPart = hrp
end

local storeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")
local dropRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DropItem")

local targetCFrame = Workspace.TeslaLab.Generator.Generator.CFrame
for i = 1, 2 do
    hrp.CFrame = targetCFrame
    wait(1.1)
end

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
                if dist <= 300 and dist < shortest then
                    closestSeat = seat
                    shortest = dist
                end
            end
        end
    end

    return closestSeat
end

local function sitAndWeldToSeat(seat)
    assert(seat and seat:IsA("Seat"), "Invalid seat")

    hrp.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
    wait(0.2)
    seat:Sit(hum)

    for i = 1, 30 do
        if hum.SeatPart == seat then break end
        wait(0.1)
    end

local weld = Instance.new("WeldConstraint")
    weld.Name = "PersistentSeatWeld"
    weld.Part0 = hrp
    weld.Part1 = seat
    weld.Parent = hrp

    return seat, weld
end

task.spawn(function()
    local chosenSeat, seatWeld
    while not chosenSeat do
        local seat = findNearestValidChair()
        if seat then
            local s, w = sitAndWeldToSeat(seat)
            if s then
                chosenSeat = s
                seatWeld = w
            end
        end
        wait(0.25)
    end

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

            if cframeTarget then
                chosenSeat.CFrame = cframeTarget * CFrame.new(0, 2, 0)
                wait(0.3)
                storeRemote:FireServer(item)
                wait(0.2)
            end
        end
    end

local experimentTable = Workspace.TeslaLab:FindFirstChild("ExperimentTable")
    if experimentTable then
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

    if seatWeld and seatWeld.Parent then
        seatWeld:Destroy()
    end

    hum.Jump = true
end)


task.spawn(function()
    wait(1)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/fly.github.io/refs/heads/main/fly.lua"))()
end)
