local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local EspPlayerT = false
local teamConnections = {}
local function UpdatePlayerESP(player)
    if not player or player == LocalPlayer or not player.Character then return end
    local highlight = player.Character:FindFirstChild("ESP_Highlight") or Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    local shouldHighlight = EspPlayerT and LocalPlayer.Team and player.Team and LocalPlayer.Team ~= player.Team
    highlight.Enabled = shouldHighlight
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.new(1, 0, 0)
    highlight.Parent = shouldHighlight and player.Character or nil
end
local function UpdateAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        UpdatePlayerESP(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if EspPlayerT then UpdatePlayerESP(player) end
    end)
    if EspPlayerT then UpdatePlayerESP(player) end
end)
local function createEspToggle()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EspToggleGui"
    ScreenGui.Parent = game:GetService("CoreGui")
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "EspToggleButton"
    ToggleButton.Text = "透视玩家(仅敌对) 关闭"
    ToggleButton.Size = UDim2.new(0, 200, 0, 50)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Parent = ScreenGui
    local isDragging = false
    local dragStartPosition
    local startButtonPosition
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPosition = input.Position
            startButtonPosition = ToggleButton.Position
        end
    end)
    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartPosition
            ToggleButton.Position = UDim2.new(startButtonPosition.X.Scale, startButtonPosition.X.Offset + delta.X, startButtonPosition.Y.Scale, startButtonPosition.Y.Offset + delta.Y)
        end
    end)
    ToggleButton.MouseButton1Click:Connect(function()
        EspPlayerT = not EspPlayerT
        ToggleButton.Text = EspPlayerT and "透视玩家(仅敌对) 开启" or "透视玩家(仅敌对) 关闭"
        if EspPlayerT then
            spawn(function()
                while EspPlayerT do
                    UpdateAllESP()
                    task.wait(0.3)
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local highlight = player.Character:FindFirstChild("ESP_Highlight")
                        if highlight then
                            highlight.Enabled = false
                        end
                    end
                end
            end)
        end
    end)
end
createEspToggle()    