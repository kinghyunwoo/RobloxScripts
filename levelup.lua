
--==================================================
-- kinghyunwoo LEVEL UP
-- GUI + LEVEL DETECTION + AUTO QUEST + ATTACK
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualInput = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

local Settings = {
    Enabled = false,
    AttackEnabled = true,
    SkillEnabled = false,
    QuestDistance = 12,
    MonsterDistance = 18,
    AttackInterval = 0.4,
    QuestInterval = 3
}

local SkillKeys = {"Z", "X", "C", "V", "E"}
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

    StatusLabel.Text = Settings.Enabled
        and "상태: 작동 중"
        or "상태: OFF"
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

local function MoveTo(position)
    local root = GetRoot()
    if not root then return end

    pcall(function()
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end)
end

--==================================================
-- LEVEL DETECTION
-- 기존 HUD 인식 방식 유지
--==================================================

local function FindLevel()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local viewport = camera.ViewportSize
    if viewport.X <= 0 or viewport.Y <= 0 then
        return nil
    end

    local candidates = {}

    local function Scan(container)
        if not container then return end

        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local number = tonumber(
                    tostring(obj.Text or ""):gsub(",", "")
                    :match("^%s*(%d+)%s*$")
                )

                if number and number >= 1 and number <= 1000000 then
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
                            Score = color.R + color.G
                        })
                    end
                end
            end
        end
    end

    pcall(function()
        Scan(Player:FindFirstChildOfClass("PlayerGui"))
        Scan(CoreGui)
    end)

    table.sort(candidates, function(a, b)
        return a.Score > b.Score
    end)

    return candidates[1] and candidates[1].Level or nil
end

--==================================================
-- VISIBLE GAME UI
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

local function GetVisibleButtons()
    local result = {}

    for _, obj in ipairs(GetVisibleTextObjects()) do
        if obj:IsA("TextButton") and obj.Active then
            table.insert(result, obj)
        end
    end

    return result
end

local function GetDialogText()
    local texts = {}

    for _, obj in ipairs(GetVisibleTextObjects()) do
        table.insert(texts, tostring(obj.Text):gsub("%s+", " "))
    end

    return table.concat(texts, " ")
end

local function FindDialogButton(keyword)
    keyword = keyword:lower()

    for _, button in ipairs(GetVisibleButtons()) do
        if button.Text:lower():find(keyword, 1, true) then
            return button
        end
    end

    return nil
end

local function IsQuestDialogOpen()
    local text = GetDialogText():lower()

    return text:find("select a quest", 1, true) ~= nil
        or text:find("level required", 1, true) ~= nil
end

--==================================================
-- READ QUEST DETAILS
--==================================================

local function ReadQuestDetails()
    local text = GetDialogText()

    local requiredText =
        text:match("[Ll]evel%s+[Rr]equired%s*:?%s*([%d,]+)")
        or text:match("[Rr]equired%s+[Ll]evel%s*:?%s*([%d,]+)")

    if not requiredText then return nil end

    local required = tonumber(requiredText:gsub(",", ""))
    if not required then return nil end

    local objective = text:match(
        "[Oo]bjective%s*:?%s*(.-)%s*%$[%d,]+"
    )

    local count, target

    if objective then
        count, target = objective:match(
            "[Kk]ill%s+(%d+)%s+(.+)"
        )
    end

    if not count then
        count, target = text:match(
            "[Kk]ill%s+(%d+)%s+([%w%s]+)"
        )
    end

    if target then
        target = target:gsub("%s+$", "")
    end

    return {
        RequiredLevel = required,
        Target = target,
        Count = tonumber(count)
    }
end

--==================================================
-- FIND QUEST OPTIONS
--==================================================

local function FindQuestOptionButtons()
    local result = {}

    for _, button in ipairs(GetVisibleButtons()) do
        local name = button.Text:lower()

        if #name >= 3
            and not name:find("confirm", 1, true)
            and not name:find("return", 1, true)
            and not name:find("abandon", 1, true)
            and not name:find("close", 1, true)
            and not name:find("kinghyunwoo", 1, true) then

            table.insert(result, button)
        end
    end

    return result
end

--==================================================
-- AUTOMATIC QUEST SELECTION
-- 현재 레벨 이하 중 가장 높은 요구 레벨 선택
--==================================================

local function TryQuest()
    if not CurrentLevel then return false end
    if os.clock() - LastQuestAction < Settings.QuestInterval then
        return false
    end

    if not IsQuestDialogOpen() then return false end

    LastQuestAction = os.clock()

    local dialogText = GetDialogText():lower()

    if dialogText:find("select a quest", 1, true) then
        local options = FindQuestOptionButtons()

        local bestButton = nil
        local bestLevel = -1
        local bestTarget = nil

        for _, option in ipairs(options) do
            pcall(function()
                option:Activate()
            end)

            task.wait(0.4)

            local details = ReadQuestDetails()

            if details
                and details.RequiredLevel <= CurrentLevel
                and details.RequiredLevel > bestLevel then

                bestButton = option
                bestLevel = details.RequiredLevel
                bestTarget = details.Target
            end

            local returnButton = FindDialogButton("return")

            if returnButton then
                pcall(function()
                    returnButton:Activate()
                end)
                task.wait(0.3)
            end
        end

        if bestButton then
            pcall(function()
                bestButton:Activate()
            end)

            task.wait(0.4)

            local confirm = FindDialogButton("confirm")

            if confirm then
                pcall(function()
                    confirm:Activate()
                end)

                QuestLabel.Text = "퀘스트: 수락 (" .. bestLevel .. ")"

                if bestTarget then
                    MonsterLabel.Text = "목표: " .. bestTarget
                end
            else
                QuestLabel.Text = "퀘스트: Confirm 탐색 실패"
            end
        else
            QuestLabel.Text = "퀘스트: 레벨에 맞는 항목 없음"
        end

        return true
    end

    if dialogText:find("level required", 1, true) then
        local details = ReadQuestDetails()

        if details and details.RequiredLevel <= CurrentLevel then
            local confirm = FindDialogButton("confirm")

            if confirm then
                pcall(function()
                    confirm:Activate()
                end)

                QuestLabel.Text =
                    "퀘스트: 수락 (" .. details.RequiredLevel .. ")"
            end
        else
            local back = FindDialogButton("return")
            if back then
                pcall(function()
                    back:Activate()
                end)
            end
        end

        return true
    end

    return false
end

--==================================================
-- QUEST NPC
--==================================================

local function FindQuestNPC()
    local root = GetRoot()
    if not root then return nil end

    local best = nil
    local bestDistance = math.huge
    local seen = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local model = obj:FindFirstAncestorOfClass("Model")

            if model and model ~= GetCharacter()
                and not seen[model] then

                seen[model] = true

                local humanoid =
                    model:FindFirstChildOfClass("Humanoid")

                local part =
                    model:FindFirstChild("HumanoidRootPart")
                    or model:FindFirstChildWhichIsA("BasePart")

                if humanoid and part then
                    local distance =
                        (root.Position - part.Position).Magnitude

                    if distance < bestDistance then
                        bestDistance = distance
                        best = {
                            Part = part,
                            Prompt = obj
                        }
                    end
                end
            end
        end
    end

    return best
end

local function InteractQuestNPC()
    if IsQuestDialogOpen() then return end

    local npc = FindQuestNPC()

    if not npc then
        QuestLabel.Text = "퀘스트: NPC 탐색 실패"
        return
    end

    local root = GetRoot()
    if not root then return end

    local distance =
        (root.Position - npc.Part.Position).Magnitude

    if distance > Settings.QuestDistance then
        MoveTo(npc.Part.Position)
        QuestLabel.Text = "퀘스트: NPC 접근 중"
    else
        pcall(function()
            if typeof(fireproximityprompt) == "function" then
                fireproximityprompt(npc.Prompt)
            else
                npc.Prompt:InputHoldBegin()
                task.wait(math.max(npc.Prompt.HoldDuration, 0.1))
                npc.Prompt:InputHoldEnd()
            end
        end)

        QuestLabel.Text = "퀘스트: NPC 상호작용"
    end
end

--==================================================
-- ACTIVE QUEST TARGET
--==================================================

local function ReadQuestTarget()
    for _, obj in ipairs(GetVisibleTextObjects()) do
        local text = tostring(obj.Text):gsub("%s+", " ")

        local target = text:match(
            "^%s*(.-)%s*%(%s*[Ll][Vv]%.?%s*[%d,]+%s*%)"
        )

        if target and #target > 2 then
            target = target:gsub("^%s+", ""):gsub("%s+$", "")

            if not target:lower():find("quest", 1, true) then
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

    local targetName = ReadQuestTarget()
    if not targetName then return nil end

    local best = nil
    local bestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= GetCharacter() then
            local humanoid =
                obj:FindFirstChildOfClass("Humanoid")

            local monsterRoot =
                obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChildWhichIsA("BasePart")

            if humanoid and monsterRoot
                and humanoid.Health > 0
                and obj.Name:lower():find(
                    targetName:lower(), 1, true
                ) then

                local distance =
                    (root.Position - monsterRoot.Position).Magnitude

                if distance < bestDistance then
                    bestDistance = distance
                    best = obj
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
        if obj:IsA("Tool") then
            return obj
        end
    end

    return nil
end

local function BasicAttack()
    if not Settings.AttackEnabled then return end
    if os.clock() - LastAttack < Settings.AttackInterval then
        return
    end

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
-- 쿨타임 UI 판별은 아직 연결되지 않아 기본 OFF
--==================================================

local function PressKey(key)
    pcall(function()
        VirtualInput:SendKeyEvent(
            true, Enum.KeyCode[key], false, game
        )

        task.wait(0.05)

        VirtualInput:SendKeyEvent(
            false, Enum.KeyCode[key], false, game
        )
    end)
end

local function UseSkills()
    if not Settings.SkillEnabled then return end

    -- 스킬별 쿨타임 표시 판별을 확인한 뒤 연결할 것
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
                StatusLabel.Text = "상태: 레벨 인식 성공"

                local activeTarget = ReadQuestTarget()

                if activeTarget then
                    local target = FindMonster()

                    if target then
                        local humanoid =
                            target:FindFirstChildOfClass("Humanoid")

                        local monsterRoot =
                            target:FindFirstChild("HumanoidRootPart")
                            or target:FindFirstChildWhichIsA("BasePart")

                        MonsterLabel.Text = "몬스터: " .. target.Name

                        if humanoid and monsterRoot then
                            local root = GetRoot()

                            if root then
                                local distance =
                                    (root.Position - monsterRoot.Position).Magnitude

                                if distance > Settings.MonsterDistance then
                                    MoveTo(monsterRoot.Position)
                                    AttackLabel.Text = "공격: 접근 중"
                                else
                                    BasicAttack()
                                    UseSkills()
                                end
                            end
                        end
                    else
                        MonsterLabel.Text =
                            "몬스터 탐색 중: " .. activeTarget
                    end
                else
                    MonsterLabel.Text = "몬스터: 대기 중"

                    if not TryQuest() then
                        InteractQuestNPC()
                    end
                end
            else
                LevelLabel.Text = "레벨: HUD 인식 실패"
                StatusLabel.Text = "상태: 레벨 탐색 중"
            end
        end

        task.wait(0.5)
    end
end)

print("kinghyunwoo LEVEL UP loaded")
