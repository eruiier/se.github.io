local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")

local x, y = 57, 3
local startZ, endZ, stepZ = 30000, -49000, -1250
local duration = 0.5

-- Variables to store the prison position when found
local savedPrisonPos = nil
local savedBallistaSeat = nil

-- Step 1: Move along path, find StillwaterPrison and Ballista/VehicleSeat
for z = startZ, endZ, stepZ do
    if savedPrisonPos then break end  -- Stop after finding prison

    local pos = Vector3.new(x, y, z)
    local tween = TweenService:Create(
        humanoidRootPart,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(pos)}
    )
    tween:Play()
    tween.Completed:Wait()

    local stillwater = workspace:FindFirstChild("StillwaterPrison")
    if stillwater then
        -- Prison found! Save its position
        if stillwater.PrimaryPart then
            savedPrisonPos = stillwater.PrimaryPart.Position
        else
            savedPrisonPos = stillwater:GetChildren()[1].Position
        end

        -- Find Ballista inside StillwaterPrison only
        local ballista = stillwater:FindFirstChild("Ballista", true)
        if ballista then
            local seat = ballista:FindFirstChild("VehicleSeat", true)
            if seat then
                savedBallistaSeat = seat
            end
        end
        break
    end
end

-- Step 2: If found, repeatedly TP and try to sit (stop if successful)
local sat = false
if savedPrisonPos and savedBallistaSeat then
    for i = 1, 100 do
        humanoidRootPart.CFrame = CFrame.new(savedPrisonPos)
        savedBallistaSeat:Sit(humanoid)
        task.wait(0.1)
        if humanoid.SeatPart == savedBallistaSeat then
            print("Sat on the Ballista seat inside StillwaterPrison after " .. i .. " attempts. Script stopping.")
            sat = true
            break
        end
    end
    if not sat then
        warn("Could not sit after 100 attempts.")
    end
elseif not savedPrisonPos then
    warn("No StillwaterPrison found along the specified Z range.")
elseif not savedBallistaSeat then
    warn("No Ballista VehicleSeat found in StillwaterPrison.")
end
