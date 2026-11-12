
--==================================================
-- kinghyunwoo LEVEL UP
-- QUEST REMOTE SCANNER V1
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- GUI 정리
local GUI_NAME = "KingHyunwooQuestScanner"

pcall(function()
    local old = CoreGui:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

pcall(function()
    local old = PlayerGui:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = gethui()
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = CoreGui
end

--==================================================
-- GUI
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 390)
Main.Position = UDim2.new(0.5, -170, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KINGHYUNWOO | QUEST SCANNER"
Title.TextColor3 = Color3.fromRGB(100, 255, 190)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 35, 0, 30)
Minimize.Position = UDim2.new(1, -75, 0, 5)
Minimize.Text = "-"
Minimize.TextSize = 20
Minimize.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 30)
Close.Position = UDim2.new(1, -38, 0, 5)
Close.Text = "X"
Close.TextSize = 16
Close.BackgroundColor3 = Color3.fromRGB(150, 55, 55)
Close.TextColor3 = Color3.new(1,1,1)
Close.Parent = Main

local LevelLabel = Instance.new("TextLabel")
LevelLabel.Size = UDim2.new(1, -20, 0, 30)
LevelLabel.Position = UDim2.new(0, 10, 0, 45)
LevelLabel.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
LevelLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
LevelLabel.Text = "LEVEL: 탐색 중..."
LevelLabel.TextSize = 15
LevelLabel.Font = Enum.Font.GothamBold
LevelLabel.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 0, 80)
Status.BackgroundTransparency = 1
Status.Text = "대기 중"
Status.TextColor3 = Color3.new(1,1,1)
Status.TextSize = 13
Status.Parent = Main

local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(1, -20, 0, 38)
ScanButton.Position = UDim2.new(0, 10, 0, 110)
ScanButton.BackgroundColor3 = Color3.fromRGB(35, 150, 110)
ScanButton.Text = "퀘스트 Remote 탐색"
ScanButton.TextColor3 = Color3.new(1,1,1)
ScanButton.TextSize = 14
ScanButton.Font = Enum.Font.GothamBold
ScanButton.Parent = Main

local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(1, -20, 0, 32)
CopyButton.Position = UDim2.new(0, 10, 0, 155)
CopyButton.BackgroundColor3 = Color3.fromRGB(65, 90, 150)
CopyButton.Text = "탐색 결과 복사"
CopyButton.TextColor3 = Color3.new(1,1,1)
CopyButton.TextSize = 13
CopyButton.Parent = Main

local Results = Instance.new("ScrollingFrame")
Results.Size = UDim2.new(1, -20, 1, -205)
Results.Position = UDim2.new(0, 10, 0, 195)
Results.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
Results.BorderSizePixel = 0
Results.ScrollBarThickness = 5
Results.CanvasSize = UDim2.new(0,0,0,0)
Results.Parent = Main

local ResultLayout = Instance.new("UIListLayout")
ResultLayout.Padding = UDim.new(0, 4)
ResultLayout.Parent = Results

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
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
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--==================================================
-- MINIMIZE / CLOSE
--==================================================

local minimized = false

Minimize.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        Main.Size = UDim2.new(0, 340, 0, 42)
        Minimize.Text = "+"
    else
        Main.Size = UDim2.new(0, 340, 0, 390)
        Minimize.Text = "-"
    end
end)

Close.Activated:Connect(function()
    ScreenGui:Destroy()
end)

--==================================================
-- LEVEL DETECTION
--==================================================

local function FindLevel()
    local candidates = {}

    local function inspect(root)
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local number = obj.Text:match("^%s*(%d+)%s*$")

                if number then
                    local color = obj.TextColor3
                    local pos = obj.AbsolutePosition
                    local size = obj.AbsoluteSize
                    local screenSize = workspace.CurrentCamera.ViewportSize

                    local yellow =
                        color.R > 0.65
                        and color.G > 0.55
                        and color.B < 0.55

                    local bottomCenter =
                        pos.Y > screenSize.Y * 0.45
                        and math.abs(
                            (pos.X + size.X / 2) - screenSize.X / 2
                        ) < screenSize.X * 0.3

                    if yellow and bottomCenter then
                        table.insert(candidates, tonumber(number))
                    end
                end
            end
        end
    end

    pcall(function() inspect(PlayerGui) end)
    pcall(function() inspect(CoreGui) end)

    table.sort(candidates, function(a,b)
        return a > b
    end)

    return candidates[1]
end

task.spawn(function()
    while ScreenGui.Parent do
        local level = FindLevel()

        if level then
            LevelLabel.Text = "LEVEL: " .. level
        else
            LevelLabel.Text = "LEVEL: 인식 대기 중..."
        end

        task.wait(1)
    end
end)

--==================================================
-- REMOTE SCANNER
--==================================================

local keywords = {
    "quest",
    "mission",
    "task",
    "npc",
    "reward",
    "objective",
    "accept",
    "complete"
}

local savedResults = {}

local function IsQuestRelated(name)
    local lower = string.lower(name)

    for _, keyword in ipairs(keywords) do
        if string.find(lower, keyword, 1, true) then
            return true
        end
    end

    return false
end

local function GetPath(obj)
    local parts = {}
    local current = obj

    while current and current ~= game do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end

    return table.concat(parts, ".")
end

local function ClearResults()
    for _, obj in ipairs(Results:GetChildren()) do
        if obj:IsA("TextLabel") then
            obj:Destroy()
        end
    end
end

local function AddResult(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 42)
    label.BackgroundColor3 = Color3.fromRGB(35, 42, 55)
    label.TextColor3 = color or Color3.new(1,1,1)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "  " .. text
    label.Parent = Results
end

local function ScanRemotes()
    ClearResults()
    table.clear(savedResults)

    Status.Text = "Remote 탐색 중..."
    ScanButton.Active = false

    local all = {}
    local questRelated = {}

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local path = GetPath(obj)
            local entry = obj.ClassName .. " | " .. path

            table.insert(all, entry)

            if IsQuestRelated(obj.Name) then
                table.insert(questRelated, entry)
            end
        end
    end

    table.sort(questRelated)
    table.sort(all)

    for _, entry in ipairs(questRelated) do
        table.insert(savedResults, entry)
    end

    for _, entry in ipairs(all) do
        if not table.find(savedResults, entry) then
            table.insert(savedResults, entry)
        end
    end

    AddResult("퀘스트 관련 객체: " .. #questRelated,
        Color3.fromRGB(100,255,170))

    AddResult("전체 Remote 객체: " .. #all,
        Color3.fromRGB(255,230,100))

    for index, entry in ipairs(savedResults) do
        if index > 100 then break end

        local color = index <= #questRelated
            and Color3.fromRGB(120,255,180)
            or Color3.fromRGB(210,210,210)

        AddResult(entry, color)
    end

    task.wait()

    Results.CanvasSize = UDim2.new(
        0, 0, 0, ResultLayout.AbsoluteContentSize.Y + 10
    )

    Status.Text = "탐색 완료 | " .. #all .. "개 발견"
    ScanButton.Active = true
end

ScanButton.Activated:Connect(function()
    task.spawn(ScanRemotes)
end)

CopyButton.Activated:Connect(function()
    if #savedResults == 0 then
        Status.Text = "먼저 탐색해 줘"
        return
    end

    local output = table.concat(savedResults, "\n")

    if setclipboard then
        local success = pcall(setclipboard, output)

        Status.Text = success
            and "탐색 결과 복사 성공"
            or "복사 실패"
    else
        Status.Text = "클립보드 기능을 지원하지 않음"
    end
end)

Status.Text = "준비 완료"
