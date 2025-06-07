local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local TweenService = game:GetService("TweenService")
local x = 57
local y = 3
local startZ = 30000
local endZ = 10000
local stepZ = -1000 -- Covers more ground per iteration
local duration = 1 -- Faster movement

local foundExcalibur = false
local excaliburInstance = nil

-- Tween along Z-axis
for z = startZ, endZ, stepZ do
    if foundExcalibur then break end

    -- Tween to the next point
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {CFrame = CFrame.new(Vector3.new(x, y, z))}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()

    -- Search for Excalibur in workspace.RuntimeItems
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        local excalibur = runtimeItems:FindFirstChild("Excalibur")
        if excalibur then
            foundExcalibur = true
            excaliburInstance = excalibur
            break
        end
    end
end

if foundExcalibur and excaliburInstance then
    -- Find the closest Cannon (with VehicleSeat) to Excalibur
    local closestCannon = nil
    local closestSeat = nil
    local minDist = math.huge

    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item.Name == "Cannon" then
            local vehicleSeat = item:FindFirstChild("VehicleSeat")
            if vehicleSeat and vehicleSeat:IsA("Seat") then
                local dist = (vehicleSeat.Position - excaliburInstance.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closestCannon = item
                    closestSeat = vehicleSeat
                end
            end
        end
    end

    if closestCannon and closestSeat then
        -- Tween to a position next to the closest cannon's seat
        local seatCFrame = closestSeat.CFrame
        local offset = seatCFrame.LookVector * -3 -- 3 studs behind the seat
        local targetCFrame = seatCFrame + offset

        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local goal = {CFrame = targetCFrame}
        local finalTween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
        finalTween:Play()
        finalTween.Completed:Wait()

        -- Sit next to the seat (or on the seat if you want)
        -- closestSeat:Sit(humanoid) -- Uncomment to actually sit

        print("Arrived next to the closest cannon to Excalibur!")
    else
        warn("Excalibur found, but no cannon with a seat nearby.")
    end
else
    warn("Excalibur not found along the specified Z range.")
end
