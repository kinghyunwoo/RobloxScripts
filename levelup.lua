
--==================================================
-- kinghyunwoo LEVEL UP
-- GUI ONLY V3
-- MOBILE MINIMIZE / EXPAND FIX
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-- 기존 GUI 제거
pcall(function()
    CoreGui:FindFirstChild("kinghyunwoo_LEVELUP"):Destroy()
end)

pcall(function()
    Player.PlayerGui:FindFirstChild("kinghyunwoo_LEVELUP"):Destroy()
end)

-- GUI 생성
local Gui = Instance.new("ScreenGui")
Gui.Name = "kinghyunwoo_LEVELUP"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function()
    Gui.Parent = CoreGui
end)

if not success or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

-- 메인 창
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(300, 300)
Main.Position = UDim2.new(0.5, -150, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70, 190, 150)
Stroke.Thickness = 1.5
Stroke.Parent = Main

-- 상단 표시줄
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(35, 42, 55)
Header.BorderSizePixel = 0
Header.ZIndex = 2
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

-- 제목 / 드래그 영역
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "kinghyunwoo LEVEL UP"
Title.TextColor3 = Color3.fromRGB(110, 255, 195)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Active = true
Title.ZIndex = 3
Title.Parent = Header

-- 축소 버튼
local Minimize = Instance.new("TextButton")
Minimize.Name = "Minimize"
Minimize.Size = UDim2.fromOffset(30, 28)
Minimize.Position = UDim2.new(1, -68, 0, 7)
Minimize.BackgroundColor3 = Color3.fromRGB(65, 80, 95)
Minimize.Text = "-"
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = true
Minimize.Active = true
Minimize.ZIndex = 5
Minimize.Parent = Header

Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 6)

-- 닫기 버튼
local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Size = UDim2.fromOffset(30, 28)
Close.Position = UDim2.new(1, -34, 0, 7)
Close.BackgroundColor3 = Color3.fromRGB(170, 65, 65)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 16
Close.Font = Enum.Font.GothamBold
Close.Active = true
Close.ZIndex = 5
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

-- 레벨 표시
local Level = Instance.new("TextLabel")
Level.Size = UDim2.new(1, -24, 0, 35)
Level.Position = UDim2.fromOffset(12, 52)
Level.BackgroundColor3 = Color3.fromRGB(38, 48, 60)
Level.Text = "현재 레벨: 인식 대기 중"
Level.TextColor3 = Color3.fromRGB(110, 255, 195)
Level.TextSize = 17
Level.Font = Enum.Font.GothamBold
Level.Parent = Main

Instance.new("UICorner", Level).CornerRadius = UDim.new(0, 8)

-- 상태 표시
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -24, 0, 28)
Status.Position = UDim2.fromOffset(12, 95)
Status.BackgroundTransparency = 1
Status.Text = "상태: OFF"
Status.TextColor3 = Color3.fromRGB(255, 180, 100)
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.Parent = Main

-- 정보 라벨
local function MakeInfo(text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 25)
    label.Position = UDim2.fromOffset(12, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 225, 235)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = Main
    return label
end

local Quest = MakeInfo("퀘스트: 대기 중", 130)
local Monster = MakeInfo("몬스터: 대기 중", 160)
local Attack = MakeInfo("공격: 대기 중", 190)

-- ON/OFF 버튼
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -24, 0, 42)
Toggle.Position = UDim2.fromOffset(12, 235)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 130, 90)
Toggle.Text = "자동 레벨업 : OFF"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 16
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

local Enabled = false

Toggle.Activated:Connect(function()
    Enabled = not Enabled

    Toggle.Text = Enabled
        and "자동 레벨업 : ON"
        or "자동 레벨업 : OFF"

    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(35, 170, 110)
        or Color3.fromRGB(45, 130, 90)

    Status.Text = Enabled
        and "상태: 작동 ON"
        or "상태: OFF"
end)

--==================================================
-- MINIMIZE / EXPAND
--==================================================

local minimized = false

local ContentObjects = {
    Level,
    Status,
    Quest,
    Monster,
    Attack,
    Toggle
}

local function SetMinimized(state)
    minimized = state

    for _, object in ipairs(ContentObjects) do
        object.Visible = not minimized
    end

    if minimized then
        Main.Size = UDim2.fromOffset(300, 42)
        Minimize.Text = "+"
    else
        Main.Size = UDim2.fromOffset(300, 300)
        Minimize.Text = "-"
    end
end

Minimize.Activated:Connect(function()
    SetMinimized(not minimized)
end)

--==================================================
-- CLOSE
--==================================================

Close.Activated:Connect(function()
    Enabled = false
    Gui:Destroy()
end)

--==================================================
-- MOBILE / PC DRAG
-- 제목 부분만 드래그 가능
--==================================================

do
    local dragging = false
    local dragStart
    local startPos
    local activeInput

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            activeInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == activeInput
            or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = false
            activeInput = nil
        end
    end)
end

print("kinghyunwoo LEVEL UP GUI V3 loaded")
