
--==================================================
-- kinghyunwoo LEVEL UP
-- FULL INTEGRATED TEST VERSION
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualInput = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

local Settings = {
    Enabled = false,
    AttackEnabled = true,
    SkillEnabled = true,
    AttackDistance = 18,
    QuestDistance = 12,
    MonsterDistance = 18,
    AttackInterval = 0.4,
    QuestInterval = 3,
}

local SkillKeys = {"Z", "X", "C", "V", "E"}
local SkillLastUsed = {}
for _, key in ipairs(SkillKeys) do
    SkillLastUsed[key] = 0
end

local LastAttack = 0
local LastQuestAction = 0
local CurrentLevel = nil

--==================================================
-- GUI
--==================================================

pcall(function()
    local old = CoreGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)

pcall(function()
    local old = Player.PlayerGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "kinghyunwoo_LevelUp"
Gui.ResetOnSpawn = false

local ok = pcall(function()
    Gui.Parent = CoreGui
end)

if not ok or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 250)
Frame.Position = UDim2.new(0.5, -140, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
Frame.BorderSizePixel = 0
Frame.Parent = Gui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local function MakeLabel(text, y, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, height)
    label.Position = UDim2.new(0, 10, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = Frame
    return label
end

local Title = MakeLabel("kinghyunwoo LEVEL UP", 5, 30)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 28)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.Parent = Frame

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 30, 0, 28)
Minimize.Position = UDim2.new(1, -70, 0, 5)
Minimize.Text = "ㅡ"
Minimize.Parent = Frame

local LevelLabel = MakeLabel("레벨: 탐색 중...", 42, 28)
LevelLabel.TextColor3 = Color3.fromRGB(100, 255, 190)
LevelLabel.TextSize = 19

local QuestLabel = MakeLabel("퀘스트: 대기 중", 75, 25)
local MonsterLabel = MakeLabel("몬스터: 대기 중", 103, 25)
local AttackLabel = MakeLabel("공격: 대기 중", 131, 25)
local StatusLabel = MakeLabel("상태: OFF", 159, 25)

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -30, 0, 42)
Toggle.Position = UDim2.new(0, 15, 0, 195)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 130, 90)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Text = "자동 레벨업 : OFF"
Toggle.TextSize = 16
Toggle.Parent = Frame

Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

local minimized = false

Toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    Toggle.Text = Settings.Enabled
        and "자동 레벨업 : ON"
        or "자동 레벨업 : OFF"
    StatusLabel.Text = Settings.Enabled and "상태: 작동 중" or "상태: OFF"
end)

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    LevelLabel.Visible = not minimized
    QuestLabel.Visible = not minimized
    MonsterLabel.Visible = not minimized
    AttackLabel.Visible = not minimized
    StatusLabel.Visible = not minimized
    Toggle.Visible = not minimized

    Frame.Size = minimized
        and UDim2.new(0, 280, 0, 40)
        or UDim2.new(0, 280, 0, 250)
end)

Close.MouseButton1Click:Connect(function()
    Settings.Enabled = false
    Gui:Destroy()
end)

--==================================================
-- CHARACTER
--==================================================

local function GetCharacter()
    return Player.Character
end

local function GetRoot()
    local character = GetCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function ParseNumber(value)
    if not value then return nil end
    local n = tostring(value):gsub(",", ""):match("^%s*(%d+)%s*$")
    n = tonumber(n)

    if n and n >= 1 and n <= 1000000 then
        return n
    end

    return nil
end

--==================================================
-- LEVEL DETECTION
-- 실제 HUD: 화면 하단 중앙의 노란색 숫자
--==================================================

local function FindLevel()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local viewport = camera.ViewportSize
    if viewport.X <= 0 or viewport.Y <= 0 then return nil end

    local candidates = {}

    local function Scan(container)
        if not container then return end

        local descendants = {}

        pcall(function()
            descendants = container:GetDescendants()
        end)

        for _, obj in ipairs(descendants) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local number = ParseNumber(obj.Text)

                if number then
                    local color = obj.TextColor3
                    local pos = obj.AbsolutePosition
                    local size = obj.AbsoluteSize

                    local x = (pos.X + size.X / 2) / viewport.X
                    local y = (pos.Y + size.Y / 2) / viewport.Y

                    local yellow =
                        color.R > 0.65 and
                        color.G > 0.35 and
                        color.B < 0.45 and
                        color.R >= color.G

                    local correctPosition =
                        x >= 0.42 and x <= 0.57 and
                        y >= 0.70 and y <= 0.82

                    if yellow and correctPosition then
                        table.insert(candidates, {
                            Level = number,
                            Score = color.R + color.G,
                        })
                    end
                end
            end
        end
    end

    Scan(Player:FindFirstChildOfClass("PlayerGui"))
    Scan(CoreGui)

    table.sort(candidates, function(a, b)
        return a.Score > b.Score
    end)

    if candidates[1] then
        return candidates[1].Level
    end

    -- HUD 탐색 실패 시 이름이 명확한 leaderstats만 사용
    local stats = Player:FindFirstChild("leaderstats")

    if stats then
        for _, obj in ipairs(stats:GetDescendants()) do
            local name = obj.Name:lower()

            if name == "level" or name == "lv" then
                local value = tonumber(obj.Value)
                if value and value > 0 then
                    return value
                end
            end
        end
    end

    return nil
end

--==================================================
-- QUEST UI
--==================================================

local function GetVisibleTextObjects()
    local result = {}
    local playerGui = Player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return result end

    for _, obj in ipairs(playerGui:GetDescendants()) do
        if (obj:IsA("TextButton") or obj:IsA("TextLabel"))
            and obj.Visible and obj.Text ~= "" then
            table.insert(result, obj)
        end
    end

    return result
end

local function ReadRequiredLevel(text)
    text = tostring(text):lower()

    local patterns = {
        "required%s*level%s*:?%s*(%d+)",
        "level%s*:?%s*(%d+)",
        "lv%.?%s*(%d+)",
        "(%d+)%s*level",
    }

    for _, pattern in ipairs(patterns) do
        local value = text:match(pattern)
        if value then return tonumber(value) end
    end

    return nil
end

local function FindBestQuestButton()
    if not CurrentLevel then return nil end

    local bestButton = nil
    local bestLevel = -1

    for _, obj in ipairs(GetVisibleTextObjects()) do
        if obj:IsA("TextButton") then
            local required = ReadRequiredLevel(obj.Text)

            if required and required <= CurrentLevel
                and required > bestLevel then
                bestLevel = required
                bestButton = obj
            end
        end
    end

    return bestButton, bestLevel
end

local function ClickButton(button)
    if not button then return false end

    return pcall(function()
        button:Activate()
    end)
end

local function TryQuest()
    if os.clock() - LastQuestAction < Settings.QuestInterval then
        return
    end

    LastQuestAction = os.clock()

    local button, required = FindBestQuestButton()

    if button then
        QuestLabel.Text = "퀘스트: 선택 중 (" .. required .. ")"
        ClickButton(button)
    else
        QuestLabel.Text = "퀘스트: NPC 탐색 중"
    end
end

--==================================================
-- QUEST NPC
--==================================================

local function FindQuestNPC()
    local root = GetRoot()
    if not root then return nil end

    local best, bestDistance = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local model = obj.Parent and obj.Parent:FindFirstAncestorOfClass("Model")

            if model then
                local name = (
                    model.Name .. " " ..
                    tostring(obj.ObjectText) .. " " ..
                    tostring(obj.ActionText)
                ):lower()

                if name:find("quest") or name:find("퀘스트") then
                    local part = model:FindFirstChild("HumanoidRootPart")
                        or model:FindFirstChildWhichIsA("BasePart")

                    if part then
                        local d = (root.Position - part.Position).Magnitude

                        if d < bestDistance then
                            bestDistance = d
                            best = {Part = part, Prompt = obj}
                        end
                    end
                end
            end
        end
    end

    return best
end

local function MoveTo(position)
    local root = GetRoot()
    if not root then return end

    pcall(function()
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end)
end

local function InteractQuestNPC()
    local npc = FindQuestNPC()

    if not npc then
        QuestLabel.Text = "퀘스트: NPC를 찾지 못함"
        return
    end

    local root = GetRoot()
    if not root then return end

    local distance = (root.Position - npc.Part.Position).Magnitude

    if distance > Settings.QuestDistance then
        MoveTo(npc.Part.Position)
        QuestLabel.Text = "퀘스트: NPC 이동 중"
    else
        pcall(function()
            if typeof(fireproximityprompt) == "function" then
                fireproximityprompt(npc.Prompt)
            end
        end)

        QuestLabel.Text = "퀘스트: NPC 상호작용"
    end
end

--==================================================
-- QUEST TARGET TEXT
--==================================================

local function ReadQuestTarget()
    for _, obj in ipairs(GetVisibleTextObjects()) do
        local text = obj.Text
        local lower = text:lower()

        if lower:find("defeat") or lower:find("kill")
            or text:find("처치") then

            local target = text
            target = target:gsub("%d+/%d+", "")
            target = target:gsub("[Dd]efeat", "")
            target = target:gsub("[Kk]ill", "")
            target = target:gsub("처치", "")
            target = target:gsub("^%s+", "")
            target = target:gsub("%s+$", "")

            if #target > 2 then return target end
        end
    end

    return nil
end

--==================================================
-- MONSTER DETECTION
--==================================================

local function FindMonster()
    local root = GetRoot()
    if not root then return nil end

    local questTarget = ReadQuestTarget()
    local best, bestDistance = nil, math.huge

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= GetCharacter() then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local monsterRoot = obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChildWhichIsA("BasePart")

            if humanoid and monsterRoot and humanoid.Health > 0 then
                local matches = true

                if questTarget then
                    matches = obj.Name:lower():find(
                        questTarget:lower(), 1, true
                    ) ~= nil
                end

                if matches then
                    local d = (root.Position - monsterRoot.Position).Magnitude

                    if d < bestDistance then
                        bestDistance = d
                        best = obj
                    end
                end
            end
        end
    end

    return best
end

--==================================================
-- BASIC ATTACK
--==================================================

local function GetEquippedTool()
    local character = GetCharacter()
    if not character then return nil end

    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end

    return nil
end

local function BasicAttack()
    if not Settings.AttackEnabled then return end
    if os.clock() - LastAttack < Settings.AttackInterval then return end

    LastAttack = os.clock()

    local tool = GetEquippedTool()

    if tool then
        pcall(function()
            tool:Activate()
        end)

        AttackLabel.Text = "공격: 무기 평타"
    else
        AttackLabel.Text = "공격: 장착 무기 없음"
    end
end

--==================================================
-- SKILLS
-- 쿨타임 UI 구조가 확인되지 않아 자동 입력은 보류
--==================================================

local function PressKey(key)
    pcall(function()
        VirtualInput:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

local function IsSkillReady(key)
    -- 실제 쿨타임 표시를 확인하지 못했으므로
    -- 준비 상태를 임의로 true로 판정하지 않음.
    return false
end

local function UseSkills()
    if not Settings.SkillEnabled then return end

    for _, key in ipairs(SkillKeys) do
        if IsSkillReady(key) then
            PressKey(key)
            SkillLastUsed[key] = os.clock()
        end
    end
end

--==================================================
-- MAIN LOOP
--==================================================

task.spawn(function()
    while Gui.Parent do
        if Settings.Enabled then
            CurrentLevel = FindLevel()

            if CurrentLevel then
                LevelLabel.Text = "현재 레벨: " .. CurrentLevel

                local target = FindMonster()

                if target then
                    local humanoid = target:FindFirstChildOfClass("Humanoid")
                    local monsterRoot = target:FindFirstChild("HumanoidRootPart")
                        or target:FindFirstChildWhichIsA("BasePart")

                    MonsterLabel.Text = "몬스터: " .. target.Name

                    if humanoid and monsterRoot then
                        local root = GetRoot()

                        if root then
                            local distance =
                                (root.Position - monsterRoot.Position).Magnitude

                            if distance > Settings.MonsterDistance then
                                MoveTo(monsterRoot.Position)
                                AttackLabel.Text = "공격: 몬스터 접근 중"
                            else
                                BasicAttack()
                                UseSkills()
                            end
                        end
                    end
                else
                    MonsterLabel.Text = "몬스터: 탐색 중"
                    TryQuest()
                    InteractQuestNPC()
                end
            else
                LevelLabel.Text = "레벨: 인식 실패"
                StatusLabel.Text = "상태: 레벨 탐색 중"
            end
        end

        task.wait(0.5)
    end
end)

print("kinghyunwoo LEVEL UP loaded")
