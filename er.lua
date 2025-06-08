--!strict
-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Player & Character
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")

-- MaximGun seat location (adjust if needed)
local maximGunTP = Vector3.new(57, -5, -9000)

-- Path points to scan for unicorn
local pathPoints = {
    Vector3.new(13.66, 20, 29620.67),
    Vector3.new(-15.98, 20, 28227.97),
    Vector3.new(-63.54, 20, 26911.59),
    -- ... (rest of your points remain unchanged)
    Vector3.new(-452.39, 20, -49407.44),
}

local tpInterval = 0.5
local unicornScanInterval = 0.1
local retryDelay = 20

-- Destroy bookcases for seat logic
local function destroyBookcases()
    local castle = Workspace:FindFirstChild("VampireCastle")
    if castle then
        for _, descendant in ipairs(castle:GetDescendants()) do
            if descendant:IsA("Model") and descendant.Name == "Bookcase" then
                descendant:Destroy()
            end
        end
    end
end

-- Get MaximGun seat
local function getMaximGunSeat()
    destroyBookcases()
    local runtime = Workspace:FindFirstChild("RuntimeItems")
    if not runtime then return nil end
    for _, gun in ipairs(runtime:GetChildren()) do
        if gun.Name == "MaximGun" then
            local seat = gun:FindFirstChildWhichIsA("VehicleSeat")
            if seat then return seat end
        end
    end
    return nil
end

-- Sit and jump out logic
local function sitAndJumpOutSeat(seat)
    local jumped = false
    while true do
        if humanoid.SeatPart ~= seat then
            hrp.CFrame = seat.CFrame
            task.wait(0.1)
        else
            local weld = seat:FindFirstChild("SeatWeld")
            if weld and weld.Part1 and weld.Part1:IsDescendantOf(player.Character) then
                if not jumped then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    task.wait(0.15)
                    hrp.CFrame = seat.CFrame
                    jumped = true
                else
                    break
                end
            end
        end
    end
end

-- Find unicorn
local function findUnicorn()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Model_Unicorn" then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                return obj, part.Position
            end
        end
    end
    return nil, nil
end

-- === Hide Visuals Script ===
local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
local radius = 2000
local updateInterval = 1
local hideLoopStarted = false
local hideLoopShouldRun = true
local showLoopStarted = false

local function isInRuntimeItems(instance)
    if not runtimeItems then return false end
    return instance:IsDescendantOf(runtimeItems)
end

local function hideVisuals(instance)
    if isInRuntimeItems(instance) then return end
    if instance:IsA("BasePart") then
        instance.LocalTransparencyModifier = 1
        instance.CanCollide = false
    elseif instance:IsA("Decal") or instance:IsA("Texture") then
        instance.Transparency = 1
    elseif instance:IsA("Beam") or instance:IsA("Trail") then
        instance.Enabled = false
    end
end

local hideLoopThread = nil
local function startHideLoop()
    if hideLoopStarted then return end
    hideLoopStarted = true
    hideLoopShouldRun = true
    hideLoopThread = task.spawn(function()
        while hideLoopShouldRun do
            for _, instance in ipairs(Workspace:GetDescendants()) do
                hideVisuals(instance)
            end
            task.wait(updateInterval)
        end
    end)
end

local function stopHideLoop()
    hideLoopShouldRun = false
end

-- === Show Visuals Script ===
local function showVisuals()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local origin = character.HumanoidRootPart.Position
        for _, instance in ipairs(Workspace:GetDescendants()) do
            if instance:IsA("BasePart") and (instance.Position - origin).Magnitude <= radius then
                instance.LocalTransparencyModifier = 0
                instance.CanCollide = true
            elseif (instance:IsA("Decal") or instance:IsA("Texture")) and instance:IsDescendantOf(Workspace) then
                local parent = instance.Parent
                if parent and parent:IsA("BasePart") and (parent.Position - origin).Magnitude <= radius then
                    instance.Transparency = 0
                end
            elseif (instance:IsA("Beam") or instance:IsA("Trail")) and instance:IsDescendantOf(Workspace) then
                local parent = instance.Parent
                if parent and parent:IsA("BasePart") and (parent.Position - origin).Magnitude <= radius then
                    instance.Enabled = true
                end
            end
        end
    end
end

local function startShowLoop()
    if showLoopStarted then return end
    showLoopStarted = true
    task.spawn(function()
        while true do
            showVisuals()
            task.wait(updateInterval)
        end
    end)
end

-- ==========================

local function startRoutine()
    -- 1. Go to MaximGun and sit (retry until success)
    print("Teleporting to MaximGun area and attempting to sit...")
    local seat
    while true do
        hrp.CFrame = CFrame.new(maximGunTP)
        task.wait(0.5)
        seat = getMaximGunSeat()
        if seat then
            seat.Disabled = false
            sitAndJumpOutSeat(seat)
            print("Sat and jumped on MaximGun.")
            break
        else
            print("No MaximGun seat found, retrying...")
            task.wait(1)
        end
    end

    -- 2. Now do pathPoints unicorn search
    print("Starting path point loop and unicorn scan...")
    local unicornFound = false
    while not unicornFound do
        for i, pt in ipairs(pathPoints) do
            hrp.CFrame = CFrame.new(pt)
            -- === Start Hide Loop after 2nd local point ===
            if i == 2 then
                startHideLoop()
            end
            local t0 = tick()
            while tick() - t0 < tpInterval do
                local model, pos = findUnicorn()
                if model and pos then
                    print("Unicorn found, teleporting above it!")
                    hrp.CFrame = CFrame.new(pos.X, pos.Y + 40, pos.Z)
                    humanoid.Jump = true
                    unicornFound = true
                    -- === Stop hide loop and start show loop ===
                    stopHideLoop()
                    startShowLoop()
                    break
                end
                task.wait(unicornScanInterval)
            end
            if unicornFound then break end
        end
        if not unicornFound then
            print("Unicorn not found, retrying entire path after delay...")
            task.wait(retryDelay)
        end
    end
end

startRoutine()
