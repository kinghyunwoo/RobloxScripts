
--==================================================
-- KINGHYUNWOO QUEST REMOTE LOGGER V3
-- Observe only: no RemoteFunction calls are sent
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GUI_NAME = "KingHyunwooQuestLogger"

-- Shared state: prevent installing the hook repeatedly
local env = (getgenv and getgenv()) or _G
local State = env.KHQuestLoggerState or {
    hooked = false,
    enabled = false,
    logs = {},
    onLog = nil
}
env.KHQuestLoggerState = State

-- Remove old GUI
pcall(function()
    local h = gethui and gethui()
    if h and h:FindFirstChild(GUI_NAME) then
        h[GUI_NAME]:Destroy()
    end
end)

pcall(function()
    if CoreGui:FindFirstChild(GUI_NAME) then
        CoreGui[GUI_NAME]:Destroy()
    end
end)

pcall(function()
    if PlayerGui:FindFirstChild(GUI_NAME) then
        PlayerGui[GUI_NAME]:Destroy()
    end
end)

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = gethui()
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = CoreGui
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 350, 0, 440)
Main.Position = UDim2.new(0.5, -175, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KINGHYUNWOO | QUEST LOGGER"
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
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 30)
Close.Position = UDim2.new(1, -38, 0, 5)
Close.Text = "X"
Close.TextSize = 16
Close.BackgroundColor3 = Color3.fromRGB(150, 55, 55)
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Parent = Main

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.new(0, 0, 0, 40)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local LevelLabel = Instance.new("TextLabel")
LevelLabel.Size = UDim2.new(1, -20, 0, 30)
LevelLabel.Position = UDim2.new(0, 10, 0, 5)
LevelLabel.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
LevelLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
LevelLabel.Text = "LEVEL: 탐색 중..."
LevelLabel.TextSize = 15
LevelLabel.Font = Enum.Font.GothamBold
LevelLabel.Parent = Content

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 28)
Status.Position = UDim2.new(0, 10, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "기록 대기 중"
Status.TextColor3 = Color3.new(1, 1, 1)
Status.TextSize = 13
Status.Parent = Content

local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(1, -20, 0, 38)
StartButton.Position = UDim2.new(0, 10, 0, 72)
StartButton.BackgroundColor3 = Color3.fromRGB(35, 150, 110)
StartButton.Text = "기록 시작"
StartButton.TextColor3 = Color3.new(1, 1, 1)
StartButton.TextSize = 14
StartButton.Font = Enum.Font.GothamBold
StartButton.Parent = Content

local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.5, -15, 0, 32)
StopButton.Position = UDim2.new(0, 10, 0, 117)
StopButton.BackgroundColor3 = Color3.fromRGB(150, 65, 65)
StopButton.Text = "기록 중지"
StopButton.TextColor3 = Color3.new(1, 1, 1)
StopButton.TextSize = 13
StopButton.Parent = Content

local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(0.5, -15, 0, 32)
CopyButton.Position = UDim2.new(0.5, 5, 0, 117)
CopyButton.BackgroundColor3 = Color3.fromRGB(65, 90, 150)
CopyButton.Text = "기록 복사"
CopyButton.TextColor3 = Color3.new(1, 1, 1)
CopyButton.TextSize = 13
CopyButton.Parent = Content

local LogBox = Instance.new("TextBox")
LogBox.Size = UDim2.new(1, -20, 1, -165)
LogBox.Position = UDim2.new(0, 10, 0, 155)
LogBox.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
LogBox.TextColor3 = Color3.fromRGB(170, 255, 190)
LogBox.TextSize = 11
LogBox.Font = Enum.Font.Code
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.TextWrapped = true
LogBox.MultiLine = true
LogBox.ClearTextOnFocus = false
LogBox.TextEditable = false
LogBox.Text = "기록된 호출이 여기에 표시됩니다."
LogBox.Parent = Content

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

    Content.Visible = not minimized
    Main.Size = minimized
        and UDim2.new(0, 350, 0, 42)
        or UDim2.new(0, 350, 0, 440)

    Minimize.Text = minimized and "+" or "-"
end)

Close.Activated:Connect(function()
    State.enabled = false
    State.onLog = nil
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
                    local camera = workspace.CurrentCamera

                    if camera then
                        local screenSize = camera.ViewportSize

                        local yellow =
                            color.R > 0.65
                            and color.G > 0.55
                            and color.B < 0.55

                        local bottomCenter =
                            pos.Y > screenSize.Y * 0.45
                            and math.abs(
                                (pos.X + size.X / 2)
                                - screenSize.X / 2
                            ) < screenSize.X * 0.3

                        if yellow and bottomCenter then
                            table.insert(candidates, tonumber(number))
                        end
                    end
                end
            end
        end
    end

    pcall(function() inspect(PlayerGui) end)
    pcall(function() inspect(CoreGui) end)

    table.sort(candidates, function(a, b)
        return a > b
    end)

    return candidates[1]
end

task.spawn(function()
    while ScreenGui.Parent do
        local level = FindLevel()

        LevelLabel.Text = level
            and "LEVEL: " .. level
            or "LEVEL: 인식 대기 중..."

        task.wait(1)
    end
end)

--==================================================
-- LOG FORMATTER
--==================================================

local function FormatValue(value, depth)
    depth = depth or 0

    if depth > 3 then
        return "{...}"
    end

    if typeof(value) == "Instance" then
        return value.ClassName .. "(" .. value:GetFullName() .. ")"
    end

    if type(value) ~= "table" then
        return tostring(value)
    end

    local parts = {}

    for key, item in pairs(value) do
        table.insert(
            parts,
            "[" .. tostring(key) .. "]="
            .. FormatValue(item, depth + 1)
        )

        if #parts >= 20 then
            table.insert(parts, "...")
            break
        end
    end

    return "{" .. table.concat(parts, ", ") .. "}"
end

local function AddLog(line)
    table.insert(State.logs, line)

    if #State.logs > 80 then
        table.remove(State.logs, 1)
    end

    if State.onLog then
        pcall(State.onLog)
    end
end

State.onLog = function()
    LogBox.Text = table.concat(State.logs, "\n")
    LogBox.CursorPosition = -1
    LogBox.SelectionStart = -1
end

--==================================================
-- OBSERVE QUEST REMOTE CALLS
--==================================================

local targets = {
    Quest = true,
    CheckQuest = true,
    QuestRepeat = true
}

if not State.hooked then
    if type(hookmetamethod) ~= "function"
    or type(getnamecallmethod) ~= "function"
    or type(newcclosure) ~= "function" then

        Status.Text = "이 실행기는 호출 기록 기능을 지원하지 않음"
    else
        local oldNamecall

        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(
            function(self, ...)
                local method = getnamecallmethod()

                local shouldLog = State.enabled
                    and method == "InvokeServer"
                    and typeof(self) == "Instance"
                    and self:IsA("RemoteFunction")
                    and targets[self.Name] == true

                if not shouldLog then
                    return oldNamecall(self, ...)
                end

                local args = table.pack(...)

                AddLog(
                    "\n[호출]\n"
                    .. "Remote: " .. self:GetFullName() .. "\n"
                    .. "인자: " .. FormatValue(args)
                )

                local results = table.pack(oldNamecall(self, ...))

                AddLog(
                    "[반환값]\n"
                    .. FormatValue(results)
                )

                return table.unpack(results, 1, results.n)
            end
        ))

        State.hooked = true
        Status.Text = "호출 기록 준비 완료"
    end
end

--==================================================
-- BUTTONS
--==================================================

StartButton.Activated:Connect(function()
    State.enabled = true
    Status.Text = "기록 중 | 게임에서 퀘스트를 직접 수락해 줘"
    StartButton.Text = "기록 중..."
    StartButton.BackgroundColor3 = Color3.fromRGB(180, 110, 35)
end)

StopButton.Activated:Connect(function()
    State.enabled = false
    Status.Text = "기록 중지됨"
    StartButton.Text = "기록 시작"
    StartButton.BackgroundColor3 = Color3.fromRGB(35, 150, 110)
end)

CopyButton.Activated:Connect(function()
    if #State.logs == 0 then
        Status.Text = "아직 기록이 없어"
        return
    end

    if setclipboard then
        local success = pcall(
            setclipboard,
            table.concat(State.logs, "\n")
        )

        Status.Text = success
            and "기록 복사 성공"
            or "복사 실패"
    else
        Status.Text = "클립보드 기능을 지원하지 않음"
    end
end)

Status.Text = State.hooked
    and "준비 완료"
    or Status.Text
