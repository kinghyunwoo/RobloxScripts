
--========================================
-- kinghyunwoo LEVEL UP
-- 독립 자동레벨업 GUI
--========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then return end

-- 이전 GUI 정리
pcall(function()
    CoreGui:FindFirstChild("kinghyunwoo_LevelUp"):Destroy()
end)

pcall(function()
    Player.PlayerGui:FindFirstChild("kinghyunwoo_LevelUp"):Destroy()
end)

local Enabled = false
local Running = true

-- GUI 생성부터 실행
local GUI = Instance.new("ScreenGui")
GUI.Name = "kinghyunwoo_LevelUp"
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999

local parentSuccess = pcall(function()
    GUI.Parent = CoreGui
end)

if not parentSuccess then
    GUI.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Name = "Main"
Frame.Size = UDim2.fromOffset(270, 205)
Frame.Position = UDim2.new(0.5, -135, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 0, 38)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "kinghyunwoo"
Title.TextColor3 = Color3.fromRGB(230, 120, 255)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30, 30)
Close.Position = UDim2.new(1, -35, 0, 4)
Close.BackgroundTransparency = 1
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 16
Close.Parent = Frame

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(30, 30)
Minimize.Position = UDim2.new(1, -70, 0, 4)
Minimize.BackgroundTransparency = 1
Minimize.Text = "−"
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.TextSize = 22
Minimize.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(12, 48)
Status.Size = UDim2.new(1, -24, 0, 48)
Status.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
Status.Text = "준비 완료"
Status.TextColor3 = Color3.new(1,1,1)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.TextWrapped = true
Status.Parent = Frame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 7)
StatusCorner.Parent = Status

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(12, 108)
Toggle.Size = UDim2.new(1, -24, 0, 38)
Toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 65)
Toggle.Text = "자동레벨업 : OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 7)
ToggleCorner.Parent = Toggle

local Info = Instance.new("TextLabel")
Info.Position = UDim2.fromOffset(12, 153)
Info.Size = UDim2.new(1, -24, 0, 38)
Info.BackgroundTransparency = 1
Info.Text = "지원 예정: 1해 / 2해 / 3해"
Info.TextColor3 = Color3.fromRGB(190, 170, 210)
Info.TextSize = 11
Info.Parent = Frame

-- ON/OFF
Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    if Enabled then
        Toggle.Text = "자동레벨업 : ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(30, 150, 85)
        Status.Text = "퀘스트 정보 확인 중..."
    else
        Toggle.Text = "자동레벨업 : OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 65)
        Status.Text = "자동레벨업 중지"
    end
end)

-- 최소화
local minimized = false

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    Status.Visible = not minimized
    Toggle.Visible = not minimized
    Info.Visible = not minimized
    Frame.Size = minimized
        and UDim2.fromOffset(270, 40)
        or UDim2.fromOffset(270, 205)
end)

-- 종료
Close.MouseButton1Click:Connect(function()
    Running = false
    Enabled = false
    GUI:Destroy()
end)

-- 현재 퀘스트 UI 읽기
local function ReadQuest()
    local pg = Player:FindFirstChild("PlayerGui")
    if not pg then return nil end

    local target, current, required

    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local txt = obj.Text or ""

            local name = txt:match(
                "^%s*(.-)%s*%[Lv%.%s*%d+%]"
            )

            if name then
                target = name
            end

            local a, b = txt:match(
                "%((%d+)%s*/%s*(%d+)%)"
            )

            if a then
                current = tonumber(a)
                required = tonumber(b)
            end
        end
    end

    if target and current and required then
        return target, current, required
    end
end

-- 상태 확인 루프
task.spawn(function()
    while Running and GUI.Parent do
        task.wait(1)

        if Enabled then
            local target, current, required = ReadQuest()

            if target then
                Status.Text = "퀘스트: " .. target ..
                    "\n진행도: " .. current .. "/" .. required
            else
                Status.Text = "활성 퀘스트를 찾지 못했습니다."
            end
        end
    end
end)
