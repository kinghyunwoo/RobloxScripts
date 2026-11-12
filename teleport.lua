
-- kinghyunwoo Player Teleport GUI
-- Local testing in your own Roblox experience

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "kinghyunwoo"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(270, 330)
frame.Position = UDim2.new(0.5, -135, 0.5, -165)
frame.BackgroundColor3 = Color3.fromRGB(35, 20, 55)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "kinghyunwoo | TELEPORT"
title.TextColor3 = Color3.fromRGB(255, 100, 220)
title.BackgroundColor3 = Color3.fromRGB(65, 25, 90)
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 35)
close.Position = UDim2.new(1, -35, 0, 0)
close.Text = "X"
close.Parent = frame

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(10, 50)
list.Size = UDim2.new(1, -20, 1, -105)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 5
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

local selected = nil

local function refresh()
    for _, v in ipairs(list:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -5, 0, 35)
            button.Text = player.Name
            button.BackgroundColor3 = Color3.fromRGB(100, 45, 130)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Parent = list

            button.MouseButton1Click:Connect(function()
                selected = player
                title.Text = "선택: " .. player.Name
            end)
        end
    end

    task.wait()
    list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
end

local teleport = Instance.new("TextButton")
teleport.Size = UDim2.new(1, -20, 0, 40)
teleport.Position = UDim2.new(0, 10, 1, -45)
teleport.Text = "순간이동"
teleport.BackgroundColor3 = Color3.fromRGB(190, 55, 180)
teleport.TextColor3 = Color3.new(1, 1, 1)
teleport.Parent = frame

teleport.MouseButton1Click:Connect(function()
    if not selected then return end

    local target = selected.Character
    local character = LocalPlayer.Character

    if target and character then
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            character:PivotTo(targetRoot.CFrame * CFrame.new(0, 0, 3))
        end
    end
end)

Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)

refresh()
