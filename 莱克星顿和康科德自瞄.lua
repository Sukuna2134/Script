local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Aiming = false
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGui"
ScreenGui.Parent = game:GetService("CoreGui")
local AimButton = Instance.new("TextButton")
AimButton.Name = "AimButton"
AimButton.Text = "自瞄开"
AimButton.Size = UDim2.new(0, 100, 0, 50)
AimButton.Position = UDim2.new(0.8, 0, 0.7, 0)
AimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.Parent = ScreenGui
local isDragging = false
local dragStartPosition
local startButtonPosition
AimButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStartPosition = input.Position
        startButtonPosition = AimButton.Position
    end
end)
AimButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPosition
        AimButton.Position = UDim2.new(startButtonPosition.X.Scale, startButtonPosition.X.Offset + delta.X, startButtonPosition.Y.Scale, startButtonPosition.Y.Offset + delta.Y)
    end
end)
AimButton.MouseButton1Click:Connect(function()
    Aiming = not Aiming
    AimButton.Text = Aiming and "自瞄关" or "自瞄开"
end)
local function FindClosestEnemy()
    local closestPlayer = nil
    local closestDistance = math.huge
    local camera = workspace.CurrentCamera
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (not LocalPlayer.Team or player.Team ~= LocalPlayer.Team) then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPoint = camera:WorldToScreenPoint(head.Position)
                if screenPoint.Z > 0 then
                    local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (screenPos - center).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end
RunService.Heartbeat:Connect(function()
    if Aiming then
        local target = FindClosestEnemy()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position)
            end
        end
    end
end)    