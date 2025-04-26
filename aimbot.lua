-- Aimbot Script for Custom Game
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aimbot Settings
local AIMBOT_SETTINGS = {
    Enabled = false,
    TeamCheck = true,
    FOV = 60, -- Degrees
    Smoothness = 0.4, -- 0 = instant, 1 = very smooth
    MaxDistance = 1000,
    AimKey = Enum.UserInputType.MouseButton2 -- Right click
}

-- Visual FOV Circle
local fovCircle = Instance.new("Part")
fovCircle.Shape = Enum.PartType.Cylinder
fovCircle.Size = Vector3.new(0.2, AIMBOT_SETTINGS.FOV * 2, AIMBOT_SETTINGS.FOV * 2)
fovCircle.Transparency = 0.7
fovCircle.Color = Color3.new(1, 0, 0)
fovCircle.Anchored = true
fovCircle.CanCollide = false
fovCircle.Parent = workspace

-- Function to find best target
local function findTarget()
    local bestTarget = nil
    local closestAngle = math.rad(AIMBOT_SETTINGS.FOV)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if AIMBOT_SETTINGS.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local direction = (rootPart.Position - Camera.CFrame.Position).Unit
                local lookVector = Camera.CFrame.LookVector
                local angle = math.acos(direction:Dot(lookVector))
                
                if angle < closestAngle and (rootPart.Position - Camera.CFrame.Position).Magnitude < AIMBOT_SETTINGS.MaxDistance then
                    closestAngle = angle
                    bestTarget = rootPart
                end
            end
        end
    end
    
    return bestTarget
end

-- Aim smoothing function
local function smoothLook(targetPosition)
    local currentCF = Camera.CFrame
    local targetCF = CFrame.lookAt(currentCF.Position, targetPosition)
    return currentCF:Lerp(targetCF, 1 - AIMBOT_SETTINGS.Smoothness)
end

-- Main aimbot loop
RunService.RenderStepped:Connect(function()
    if AIMBOT_SETTINGS.Enabled then
        fovCircle.Transparency = 0.7
        local target = findTarget()
        
        if target then
            Camera.CFrame = smoothLook(target.Position)
        end
    else
        fovCircle.Transparency = 1
    end
end)

-- Toggle aimbot
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AIMBOT_SETTINGS.AimKey then
        AIMBOT_SETTINGS.Enabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AIMBOT_SETTINGS.AimKey then
        AIMBOT_SETTINGS.Enabled = false
    end
end)

-- Update FOV visualization
RunService.Heartbeat:Connect(function()
    fovCircle.Size = Vector3.new(0.2, AIMBOT_SETTINGS.FOV * 2, AIMBOT_SETTINGS.FOV * 2)
    fovCircle.CFrame = Camera.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, math.rad(90))
end)

-- UI Notification
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer.PlayerGui

local label = Instance.new("TextLabel")
label.Text = "AIMBOT: HOLD RIGHT CLICK TO ACTIVATE"
label.Size = UDim2.new(0, 300, 0, 40)
label.Position = UDim2.new(0.5, -150, 0.95, -40)
label.BackgroundTransparency = 0.7
label.TextColor3 = Color3.new(1, 0, 0)
label.Font = Enum.Font.SciFi
label.TextSize = 18
label.Parent = gui
