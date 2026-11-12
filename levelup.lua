
--==================================================
-- kinghyunwoo LEVEL UP - FULL VERSION
-- GUI + LEVEL + QUEST + MONSTER + ATTACK
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualInput = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local Settings = {
    Enabled = false,
    AttackEnabled = true,
    SkillEnabled = true,

    AttackDistance = 12,
    QuestDistance = 12,
    MonsterDistance = 18,

    MoveSpeed = 0.25,
    SkillInterval = 0.25,
    AttackInterval = 0.35,
    QuestInterval = 3,
}

local SkillKeys = {"Z", "X", "C", "V", "E"}
local SkillLastUsed = {}

for _, key in ipairs(SkillKeys) do
    SkillLastUsed[key] = 0
end

local CurrentLevel = nil
local CurrentTarget = nil
local CurrentQuestTarget = nil
local LastQuestAction = 0
local LastAttack = 0

--==================================================
-- GUI
--==================================================

pcall(function()
    CoreGui:FindFirstChild("kinghyunwoo_LevelUp"):Destroy()
end)

pcall(function()
    Player.PlayerGui:FindFirstChild("kinghyunwoo_LevelUp"):Destroy()
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "kinghyunwoo_LevelUp"
Gui.ResetOnSpawn = false

local success = pcall(function()
    Gui.Parent = CoreGui
end)

if not success or not Gui.Parent then
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

local Minimized = false

Toggle.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    Toggle.Text = Settings.Enabled and "자동 레벨업 : ON" or "자동 레벨업 : OFF"
    StatusLabel.Text = Settings.Enabled and "상태: 작동 중" or "상태: OFF"
end)

Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    LevelLabel.Visible = not Minimized
    QuestLabel.Visible = not Minimized
    MonsterLabel.Visible = not Minimized
    AttackLabel.Visible = not Minimized
    StatusLabel.Visible = not Minimized
    Toggle.Visible = not Minimized

    Frame.Size = Minimized
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

local function GetHumanoid()
    local character = GetCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function ParseNumber(value)
    if not value then return nil end

    local number = tostring(value):gsub(",", ""):match("%d+")

    if number then
        number = tonumber(number)
        if number and number > 0 and number <= 1000000 then
            return number
        end
    end

    return nil
end

--==================================================
-- LEVEL DETECTION
--==================================================

local function FindLevel()
    local stats = Player:FindFirstChild("leaderstats")

    if stats then
        for _, obj in ipairs(stats:GetDescendants()) do
            local name = obj.Name:lower()

            if name == "level" or name == "lv" then
                local value = ParseNumber(obj.Value)
                if value then
                    return value
                end
            end
        end
    end

    local playerGui = Player:FindFirstChildOfClass("PlayerGui")

    if playerGui then
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local name = obj.Name:lower()
                local txt = tostring(obj.Text)

                if name:find("level") or name:find("lv") then
                    local value = ParseNumber(txt)
                    if value then
                        return value
                    end
                end

                local value = ParseNumber(txt)

                if value and (txt:lower():find("level") or txt:lower():find("lv")) then
                    return value
                end
            end
        end
    end

    return nil
end

--==================================================
-- QUEST UI DETECTION
--==================================================

local function GetVisibleTextObjects()
    local result = {}
    local playerGui = Player:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return result
    end

    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("TextLabel") then
            if obj.Visible and obj.Text ~= "" then
                table.insert(result, obj)
            end
        end
    end

    return result
end

local function ReadRequiredLevel(text)
    text = tostring(text):lower()

    local patterns = {
        "[Rr]equired%s*[Ll]evel%s*:?%s*(%d+)",
        "[Ll]evel%s*:?%s*(%d+)",
        "[Ll]v%.?%s*(%d+)",
        "(%d+)%s*[Ll]evel",
    }

    for _, pattern in ipairs(patterns) do
        local value = text:match(pattern)
        if value then
            return tonumber(value)
        end
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

            if required and required <= CurrentLevel and required > bestLevel then
                bestLevel = required
                bestButton = obj
            end
        end
    end

    return bestButton, bestLevel
end

local function ClickButton(button)
    if not button then return false end

    local ok = pcall(function()
        if typeof(firesignal) == "function" then
            firesignal(button.Activated)
        else
            button:Activate()
        end
    end)

    return ok
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
        return
    end

    QuestLabel.Text = "퀘스트: NPC 탐색 중"
end

--==================================================
-- QUEST NPC DETECTION
--==================================================

local function FindQuestNPC()
    local root = GetRoot()
    if not root then return nil end

    local best = nil
    local distance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            local model = parent and parent:FindFirstAncestorOfClass("Model")

            if model then
                local name = (model.Name .. " " .. obj.ObjectText .. " " .. obj.ActionText):lower()

                if name:find("quest") or name:find("퀘스트") then
                    local part = model:FindFirstChild("HumanoidRootPart")
                        or model:FindFirstChildWhichIsA("BasePart")

                    if part then
                        local d = (root.Position - part.Position).Magnitude

                        if d < distance then
                            distance = d
                            best = {Model = model, Prompt = obj, Part = part}
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
-- QUEST TARGET DETECTION
--==================================================

local function ReadQuestTarget()
    local objects = GetVisibleTextObjects()

    for _, obj in ipairs(objects) do
        local text = obj.Text

        if text:lower():find("defeat") or text:lower():find("kill")
            or text:lower():find("defeat") or text:find("처치") then

            local target = text
            target = target:gsub("%d+/%d+", "")
            target = target:gsub("Defeat", "")
            target = target:gsub("Kill", "")
            target = target:gsub("처치", "")
            target = target:gsub("^%s+", "")
            target = target:gsub("%s+$", "")

            if #target > 2 then
                return target
            end
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
    CurrentQuestTarget = questTarget

    local best = nil
    local bestDistance = math.huge

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= GetCharacter() then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local monsterRoot = obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChildWhichIsA("BasePart")

            if humanoid and monsterRoot and humanoid.Health > 0 then
                local name = obj.Name:lower()
                local matches = true

                if questTarget then
                    local cleanTarget = questTarget:lower()
                    matches = name:find(cleanTarget, 1, true) ~= nil
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
-- WEAPON ATTACK
--==================================================

local function GetEquippedTool()
    local character = GetCharacter()
    if not character then return nil end

    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            return obj
        end
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
-- SKILL ATTACK
--==================================================

local function PressKey(key)
    pcall(function()
        VirtualInput:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

local function IsSkillReady(key)
    -- 실제 게임의 스킬별 쿨타임 UI 구조를
    -- 아직 확인하지 못했으므로 임의로 준비 상태를
    -- 판정하지 않음.
    return false
end

local function UseSkills()
    if not Settings.SkillEnabled then return end

    for _, key in ipairs(SkillKeys) do
        if IsSkillReady(key) then
            if os.clock() - SkillLastUsed[key] > Settings.SkillInterval then
                PressKey(key)
                SkillLastUsed[key] = os.clock()
            end
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
                CurrentTarget = target

                if target then
                    local humanoid = target:FindFirstChildOfClass("Humanoid")
                    local monsterRoot = target:FindFirstChild("HumanoidRootPart")
                        or target:FindFirstChildWhichIsA("BasePart")

                    if humanoid and monsterRoot then
                        MonsterLabel.Text = "몬스터: " .. target.Name

                        local root = GetRoot()

                        if root then
                            local distance = (root.Position - monsterRoot.Position).Magnitude

                            if distance > Settings.MonsterDistance then
                                MoveTo(monsterRoot.Position)
                            else
                                BasicAttack()
                                UseSkills()
                            end
                        end
                    end
                else
                    MonsterLabel.Text = "몬스터: 탐색 중"

                    local questTarget = ReadQuestTarget()

                    if questTarget then
                        TryQuest()
                    else
                        TryQuest()
                        InteractQuestNPC()
                    end
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
