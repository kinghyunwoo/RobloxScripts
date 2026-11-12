-- kinghyunwoo LevelUp GUI TEST

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local old = game:GetService("CoreGui"):FindFirstChild("kinghyunwoo_LevelUp")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "kinghyunwoo_LevelUp"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent = player:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.5, -130, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 35)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "kinghyunwoo LevelUp"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 17
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -70, 0, 5)
minimize.Text = "ㅡ"
minimize.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 220, 0, 45)
toggle.Position = UDim2.new(0, 20, 0, 75)
toggle.Text = "자동 레벨업 : OFF"
toggle.TextSize = 16
toggle.Parent = frame

local enabled = false
toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "자동 레벨업 : ON" or "자동 레벨업 : OFF"
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    toggle.Visible = not minimized
    frame.Size = minimized and UDim2.new(0, 260, 0, 40)
        or UDim2.new(0, 260, 0, 160)
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("kinghyunwoo GUI TEST loaded")