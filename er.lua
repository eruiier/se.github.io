local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local TweenService = game:GetService("TweenService")
local x = 57
local y = 3
local startZ = 30000
local endZ = -49000
local stepZ = -1000 -- Increased step size to cover more ground per iteration
local duration = 1 -- Reduced duration for faster movement

local maxDistance = 300 -- Only consider Ballista seats within this distance from StillwaterPrison

-- Find StillwaterPrison's position
local stillwater = workspace:FindFirstChild("StillwaterPrison")
local prisonPos = nil
if stillwater then
    if stillwater:IsA("Model") then
        if stillwater.PrimaryPart then
            prisonPos = stillwater.PrimaryPart.Position
        elseif stillwater.GetModelCFrame then
            prisonPos = stillwater:GetModelCFrame().Position
        elseif #stillwater:GetChildren() > 0 then
            prisonPos = stillwater:GetChildren()[1].Position
        end
    elseif stillwater.Position then
        prisonPos = stillwater.Position
    end
end

local stopTweening = false
local closestSeat = nil
local minDist = math.huge

for z = startZ, endZ, stepZ do
    if stopTweening then break end

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {CFrame = CFrame.new(Vector3.new(x, y, z))}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)

    tween:Play()
    tween.Completed:Wait()

    -- If we have a prison position, look for the closest Ballista seat within maxDistance
    if prisonPos then
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("Model") and item.Name == "Ballista" then
                local vehicleSeat = item:FindFirstChild("VehicleSeat")
                if vehicleSeat and vehicleSeat:IsA("Seat") then
                    local dist = (vehicleSeat.Position - prisonPos).Magnitude
                    if dist < minDist and dist <= maxDistance then
                        minDist = dist
                        closestSeat = vehicleSeat
                    end
                end
            end
        end
    end

    if closestSeat then
        -- Move to the seat and sit
        character:PivotTo(closestSeat.CFrame)
        closestSeat:Sit(humanoid)
        stopTweening = true
        break
    end
end

if not stopTweening then
    warn("No Ballista with a seat found within 300 studs of StillwaterPrison along the specified Z range.")
else
    print("Stopped after finding and sitting on the Ballista seat.")
end
