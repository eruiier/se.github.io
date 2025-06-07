local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")

local x = 57
local y = 3
local startZ = 30000
local endZ = -49000
local stepZ = -1000
local duration = 1

local function getPrisonPos(stillwater)
    if stillwater:IsA("Model") then
        if stillwater.PrimaryPart then
            return stillwater.PrimaryPart.Position
        elseif stillwater.GetModelCFrame then
            return stillwater:GetModelCFrame().Position
        elseif #stillwater:GetChildren() > 0 then
            return stillwater:GetChildren()[1].Position
        end
    elseif stillwater.Position then
        return stillwater.Position
    end
    return nil
end

local stopped = false
for z = startZ, endZ, stepZ do
    if stopped then break end

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
        local prisonPos = getPrisonPos(stillwater)
        if prisonPos then
            -- Find Ballista inside StillwaterPrison ONLY
            local ballista = stillwater:FindFirstChild("Ballista", true)
            if ballista then
                local seat = ballista:FindFirstChild("VehicleSeat", true)
                if seat then
                    for i = 1, 100 do
                        humanoidRootPart.CFrame = CFrame.new(prisonPos)
                        seat:Sit(humanoid)
                        task.wait(0.1)
                        if humanoid.SeatPart == seat then
                            print("Sat on the Ballista seat inside StillwaterPrison after " .. i .. " attempts. Script stopping.")
                            stopped = true
                            break
                        end
                    end
                    if not stopped then
                        print("Tried 100 times, but could not sit.")
                        stopped = true
                        break
                    end
                else
                    print("Ballista inside StillwaterPrison has no VehicleSeat.")
                    stopped = true
                    break
                end
            else
                print("No Ballista found inside StillwaterPrison.")
                stopped = true
                break
            end
        end
    end
end

if not stopped then
    warn("No StillwaterPrison found along the specified Z range.")
end
