local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Disable collisions for all character parts
RunService.Stepped:Connect(function()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end)

local foundSeat = false

for z = 30000, -49032.99, -2000 do
    if foundSeat then break end
    print("Tweening to Z:", z)
    local tween = TweenService:Create(rootPart, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(57, 3, z)})

    if tween then
        tween:Play()
        tween.Completed:Wait()
    else
        warn("Tween failed to create. Check TweenService parameters.")
        break
    end

    local stillwater = workspace:FindFirstChild("StillwaterPrison")
    if stillwater then
        local ballista = stillwater:FindFirstChild("Ballista")
        if ballista then
            local vehicleSeat = ballista:FindFirstChild("VehicleSeat")
            if vehicleSeat and vehicleSeat:IsA("Seat") then
                -- Found the seat! Teleport and try to sit up to 100 times (0.1s apart), stopping if successful
                for i = 1, 100 do
                    rootPart.CFrame = vehicleSeat.CFrame
                    vehicleSeat:Sit(character:WaitForChild("Humanoid"))
                    task.wait(0.1)
                    if character.Humanoid.SeatPart == vehicleSeat then
                        print("Sat on the VehicleSeat after " .. i .. " attempts.")
                        foundSeat = true
                        break
                    end
                end
                if not foundSeat then
                    print("Could not sit after 100 attempts.")
                end
                break
            end
        end
    end
end

if not foundSeat then
    warn("No VehicleSeat found in StillwaterPrison's Ballista or sitting failed.")
end
