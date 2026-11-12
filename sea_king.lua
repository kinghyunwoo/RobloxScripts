
-- kinghyunwoo | 해왕 자동사냥
-- GUI ON/OFF 지원

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local running = false

local function getRoot(model)
    return model and (
        model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
    )
end

local function findSeaKing()
    local character = LocalPlayer.Character
    local root = getRoot(character)
    if not root then return nil end

    local nearest, nearestDistance

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= character then
            local name = string.lower(obj.Name)
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local targetRoot = getRoot(obj)

            if humanoid and humanoid.Health > 0
                and targetRoot
                and (string.find(name, "sea king")
                or string.find(name, "seaking")) then

                local distance =
                    (targetRoot.Position - root.Position).Magnitude

                if not nearestDistance or distance < nearestDistance then
                    nearest = obj
                    nearestDistance = distance
                end
            end
        end
    end

    return nearest
end

local gui = Instance.new("ScreenGui")
gui.Name = "kinghyunwoo"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(230, 125)
frame.Position = UDim2.new(0.5, -115, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 20, 42)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "kinghyunwoo"
title.TextColor3 = Color3.fromRGB(255, 100, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 0, 42)
button.Position = UDim2.fromOffset(10, 43)
button.BackgroundColor3 = Color3.fromRGB(130, 50, 160)
button.Text = "자동사냥 : OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.Parent = frame

Instance.new("UICorner", button).CornerRadius =
    UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 25)
status.Position = UDim2.fromOffset(5, 90)
status.BackgroundTransparency = 1
status.Text = "대기 중"
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = frame

button.MouseButton1Click:Connect(function()
    running = not running
    button.Text = running and "자동사냥 : ON"
        or "자동사냥 : OFF"

    status.Text = running and "해왕 탐색 중" or "정지됨"
end)

task.spawn(function()
    while gui.Parent do
        if running then
            local character = LocalPlayer.Character
            local root = getRoot(character)
            local target = findSeaKing()
            local targetRoot = target and getRoot(target)

            if root and targetRoot then
                root.CFrame =
                    CFrame.new(targetRoot.Position + Vector3.new(0, 22, 0))

                local humanoid =
                    character:FindFirstChildOfClass("Humanoid")

                local tool = character:FindFirstChildOfClass("Tool")

                if not tool then
                    local backpack =
                        LocalPlayer:FindFirstChildOfClass("Backpack")

                    tool = backpack and backpack:FindFirstChildOfClass("Tool")

                    if tool and humanoid then
                        humanoid:EquipTool(tool)
                    end
                end

                if tool then
                    pcall(function()
                        tool:Activate()
                    end)
                end

                status.Text = "대상: " .. target.Name
            else
                status.Text = "해왕 탐색 중..."
            end
        end

        task.wait(0.35)
    end
end)
