-- ESP Script for your custom Arsenal-style game
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ESP Settings
local ESP_SETTINGS = {
    Enabled = true,
    TeamCheck = true, -- Only show enemies
    Boxes = true,
    Names = true,
    Health = true,
    Distance = true,
    TeamColor = true,
    TextSize = 14,
    TextFont = Enum.Font.SciFi,
    TextOffset = Vector2.new(0, -30),
    BoxThickness = 1,
    MaxDistance = 1000 -- Max render distance in studs
}

-- ESP Objects storage
local ESPObjects = {}

-- Function to create ESP for a player
local function createESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    
    local espObject = {
        Player = player,
        Box = nil,
        NameLabel = nil,
        HealthLabel = nil,
        DistanceLabel = nil
    }
    
    -- Create ESP parts
    if ESP_SETTINGS.Boxes then
        espObject.Box = Instance.new("BoxHandleAdornment")
        espObject.Box.Name = "ESPBox"
        espObject.Box.Adornee = character:WaitForChild("HumanoidRootPart")
        espObject.Box.AlwaysOnTop = true
        espObject.Box.ZIndex = 5
        espObject.Box.Size = Vector3.new(2, 3.5, 1)
        espObject.Box.Transparency = 0.5
        espObject.Box.Color3 = ESP_SETTINGS.TeamColor and player.TeamColor.Color or Color3.new(1, 0, 0)
        espObject.Box.Parent = character.HumanoidRootPart
    end
    
    if ESP_SETTINGS.Names or ESP_SETTINGS.Health or ESP_SETTINGS.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Adornee = character:WaitForChild("Head")
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.Parent = character.Head
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ESPText"
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Font = ESP_SETTINGS.TextFont
        textLabel.TextSize = ESP_SETTINGS.TextSize
        textLabel.TextColor3 = ESP_SETTINGS.TeamColor and player.TeamColor.Color or Color3.new(1, 1, 1)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.Parent = billboard
        
        espObject.TextLabel = textLabel
    end
    
    ESPObjects[player] = espObject
    
    -- Handle character removal
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if ESPObjects[player] then
                if ESPObjects[player].Box then ESPObjects[player].Box:Destroy() end
                if ESPObjects[player].TextLabel then ESPObjects[player].TextLabel.Parent:Destroy() end
                ESPObjects[player] = nil
            end
        end
    end)
end

-- Function to update ESP
local function updateESP()
    for player, espObject in pairs(ESPObjects) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            continue
        end
        
        if ESP_SETTINGS.TeamCheck and player.Team == LocalPlayer.Team then
            if espObject.Box then espObject.Box.Visible = false end
            if espObject.TextLabel then espObject.TextLabel.Visible = false end
            continue
        end
        
        local character = player.Character
        local rootPart = character.HumanoidRootPart
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        
        if distance > ESP_SETTINGS.MaxDistance then
            if espObject.Box then espObject.Box.Visible = false end
            if espObject.TextLabel then espObject.TextLabel.Visible = false end
            continue
        end
        
        -- Update box
        if espObject.Box then
            espObject.Box.Visible = ESP_SETTINGS.Boxes
            espObject.Box.Color3 = ESP_SETTINGS.TeamColor and player.TeamColor.Color or Color3.new(1, 0, 0)
            espObject.Box.Adornee = rootPart
        end
        
        -- Update text
        if espObject.TextLabel then
            local text = ""
            
            if ESP_SETTINGS.Names then
                text = text .. player.Name .. "\n"
            end
            
            if ESP_SETTINGS.Health and humanoid then
                text = text .. string.format("HP: %d/%d\n", humanoid.Health, humanoid.MaxHealth)
            end
            
            if ESP_SETTINGS.Distance then
                text = text .. string.format("%.1f studs", distance)
            end
            
            espObject.TextLabel.Visible = true
            espObject.TextLabel.Text = text
            espObject.TextLabel.TextColor3 = ESP_SETTINGS.TeamColor and player.TeamColor.Color or Color3.new(1, 1, 1)
        end
    end
end

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        createESP(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end)

-- Handle player removal
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        if ESPObjects[player].Box then ESPObjects[player].Box:Destroy() end
        if ESPObjects[player].TextLabel then ESPObjects[player].TextLabel.Parent:Destroy() end
        ESPObjects[player] = nil
    end
end)

-- Update ESP every frame
RunService.RenderStepped:Connect(updateESP)

-- Toggle ESP with a keybind (optional)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
        ESP_SETTINGS.Enabled = not ESP_SETTINGS.Enabled
        for _, espObject in pairs(ESPObjects) do
            if espObject.Box then espObject.Box.Visible = ESP_SETTINGS.Enabled end
            if espObject.TextLabel then espObject.TextLabel.Visible = ESP_SETTINGS.Enabled end
        end
    end
end)

-- Notification
local notification = Instance.new("ScreenGui")
notification.Name = "ESPNotification"
notification.Parent = LocalPlayer.PlayerGui

local textLabel = Instance.new("TextLabel")
textLabel.Text = "HACKER MODE: ESP ACTIVE (F1 to toggle)"
textLabel.Size = UDim2.new(0, 300, 0, 50)
textLabel.Position = UDim2.new(0.5, -150, 0.05, 0)
textLabel.AnchorPoint = Vector2.new(0.5, 0)
textLabel.BackgroundTransparency = 0.7
textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
textLabel.TextColor3 = Color3.new(1, 0, 0)
textLabel.Font = Enum.Font.SciFi
textLabel.TextSize = 18
textLabel.TextStrokeTransparency = 0
textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
textLabel.Parent = notification
