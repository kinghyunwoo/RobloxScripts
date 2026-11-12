
--========================================
-- kinghyunwoo LevelUp
-- GUI + 자동 레벨 인식 테스트
--========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- 기존 GUI 제거
pcall(function()
    local old = CoreGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)

pcall(function()
    local old = player.PlayerGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)

-- GUI 생성
local gui = Instance.new("ScreenGui")
gui.Name = "kinghyunwoo_LevelUp"
gui.ResetOnSpawn = false

local ok = pcall(function()
    gui.Parent = CoreGui
end)

if not ok or not gui.Parent then
    gui.Parent = player:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 270, 0, 185)
frame.Position = UDim2.new(0.5, -135, 0.5, -92)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 35)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "kinghyunwoo LevelUp"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16
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

local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(1, -20, 0, 35)
levelLabel.Position = UDim2.new(0, 10, 0, 45)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "레벨: 탐색 중..."
levelLabel.TextColor3 = Color3.fromRGB(100, 255, 190)
levelLabel.TextSize = 20
levelLabel.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.new(0, 10, 0, 80)
status.BackgroundTransparency = 1
status.Text = "레벨 인식 대기 중"
status.TextColor3 = Color3.fromRGB(220,220,220)
status.TextSize = 13
status.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 230, 0, 45)
toggle.Position = UDim2.new(0, 20, 0, 120)
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
    levelLabel.Visible = not minimized
    status.Visible = not minimized
    toggle.Visible = not minimized

    frame.Size = minimized
        and UDim2.new(0, 270, 0, 40)
        or UDim2.new(0, 270, 0, 185)
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--========================================
-- 레벨 인식
--========================================

local function parseLevel(value)
    if not value then return nil end

    local number = tostring(value):gsub(",", "")
    local result = number:match("%d+")

    if result then
        result = tonumber(result)
        if result and result >= 1 and result <= 1000000 then
            return result
        end
    end

    return nil
end

local function findLevel()
    -- 1. leaderstats 탐색
    local leaderstats = player:FindFirstChild("leaderstats")

    if leaderstats then
        for _, obj in ipairs(leaderstats:GetDescendants()) do
            local name = obj.Name:lower()

            if name == "level" or name == "lv" or name == "렙" then
                local number = parseLevel(obj.Value)
                if number then return number, "leaderstats" end
            end
        end
    end

    -- 2. 화면 GUI 탐색
    local containers = {player:FindFirstChildOfClass("PlayerGui")}

    local success, coreObjects = pcall(function()
        return CoreGui:GetDescendants()
    end)

    if success then
        table.insert(containers, CoreGui)
    end

    for _, container in ipairs(containers) do
        if container then
            local descendants = {}

            pcall(function()
                descendants = container:GetDescendants()
            end)

            for _, obj in ipairs(descendants) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local text = tostring(obj.Text or "")
                    local lower = text:lower()

                    -- Level 또는 Lv가 포함된 텍스트
                    if lower:find("level") or lower:find("lv") then
                        local number = parseLevel(text)
                        if number then
                            return number, "화면 텍스트"
                        end
                    end

                    -- 민트색 숫자 텍스트 탐색
                    local number = text:match("^%s*([%d,]+)%s*$")
                    local color = obj.TextColor3

                    if number and color then
                        local r, g, b = color.R, color.G, color.B

                        if g > 0.60 and g > r * 1.15 and b > r * 1.05 then
                            local level = parseLevel(number)
                            if level then
                                return level, "민트색 숫자"
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

--========================================
-- 실시간 레벨 갱신
--========================================

task.spawn(function()
    while gui.Parent do
        local level, source = findLevel()

        if level then
            levelLabel.Text = "현재 레벨: " .. tostring(level)
            status.Text = "인식 성공 (" .. source .. ")"
            status.TextColor3 = Color3.fromRGB(100,255,150)
        else
            levelLabel.Text = "레벨: 인식 실패"
            status.Text = "레벨 탐색 중..."
            status.TextColor3 = Color3.fromRGB(255,190,100)
        end

        task.wait(1)
    end
end)

print("kinghyunwoo LevelUp - Level Detector Loaded")
