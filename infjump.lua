-- Infinite Jump Script
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local InfiniteJumpEnabled = true
local JumpHeight = 50

-- Main function
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
        if InfiniteJumpEnabled then
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(0, JumpHeight, 0)
                end
            end
        end
    end
end)

-- Optional toggle notification
print("Infinite Jump Activated (Spacebar)")
