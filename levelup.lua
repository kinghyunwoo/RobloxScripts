
--==================================================
-- kinghyunwoo LEVEL UP
-- B + C IMPROVED VERSION
-- Monster Hunting + Skill Cooldown Detection
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualInput = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
if not Player then return end

local PlayerGui = Player:WaitForChild("PlayerGui")

local Enabled = false
local Running = true

local LastSkillUse = {}
local LastAttack = 0
local LastMove = 0
local LastMonsterScan = 0

local MonsterCache = {}
local CurrentMonster = nil

-- SETTINGS
local SETTINGS = {
    MonsterScanInterval = 1.2,
    MonsterMoveDistance = 12,
    AttackDistance = 18,
    SkillDistance = 30,

    AttackInterval = 0.45,
    MoveInterval = 1.5,
    SkillInterval = 1.5,

    SkillDelay = 0.07,
    SkillAfterDelay = 0.15
}

--==================================================
-- OLD GUI REMOVE
--==================================================

pcall(function()
    local old = CoreGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)

pcall(function()
    local old = PlayerGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "kinghyunwoo_LevelUp"
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999

local ok = pcall(function()
    GUI.Parent = CoreGui
end)

if not ok then
    GUI.Parent = PlayerGui
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(280, 220)
Frame.Position = UDim2.new(0.5, -140, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = GUI

Instance.new("UICorner", Frame).CornerRadius =
    UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -105, 0, 38)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "kinghyunwoo LevelUp"
Title.TextColor3 = Color3.fromRGB(230, 120, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30, 30)
Close.Position = UDim2.new(1, -35, 0, 4)
Close.BackgroundTransparency = 1
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
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
Status.Position = UDim2.fromOffset(12, 45)
Status.Size = UDim2.new(1, -24, 0, 72)
Status.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
Status.Text = "준비 완료"
Status.TextColor3 = Color3.new(1,1,1)
Status.TextSize = 13
Status.TextWrapped = true
Status.Parent = Frame

Instance.new("UICorner", Status).CornerRadius =
    UDim.new(0, 7)

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(12, 126)
Toggle.Size = UDim2.new(1, -24, 0, 38)
Toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 65)
Toggle.Text = "자동레벨업 : OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Frame

Instance.new("UICorner", Toggle).CornerRadius =
    UDim.new(0, 7)

local Info = Instance.new("TextLabel")
Info.Position = UDim2.fromOffset(12, 170)
Info.Size = UDim2.new(1, -24, 0, 38)
Info.BackgroundTransparency = 1
Info.Text = "퀘스트 추적 · 평타 · Z/X/C/V/E"
Info.TextColor3 = Color3.fromRGB(190, 170, 210)
Info.TextSize = 11
Info.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    Toggle.Text = Enabled
        and "자동레벨업 : ON"
        or "자동레벨업 : OFF"

    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30,150,85)
        or Color3.fromRGB(170,45,65)

    Status.Text = Enabled
        and "퀘스트 목표 확인 중..."
        or "자동레벨업 중지"
end)

local minimized = false

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    Status.Visible = not minimized
    Toggle.Visible = not minimized
    Info.Visible = not minimized

    Frame.Size = minimized
        and UDim2.fromOffset(280,40)
        or UDim2.fromOffset(280,220)
end)

Close.MouseButton1Click:Connect(function()
    Running = false
    Enabled = false
    GUI:Destroy()
end)

--==================================================
-- UI VISIBILITY
--==================================================

local function IsVisible(obj)
    if not (
        obj:IsA("TextLabel")
        or obj:IsA("TextButton")
    ) then
        return false
    end

    if not obj.Visible then
        return false
    end

    local node = obj.Parent

    while node and node ~= PlayerGui do
        if node:IsA("GuiObject")
        and not node.Visible then
            return false
        end

        node = node.Parent
    end

    return true
end

--==================================================
-- QUEST PROGRESS
--==================================================

local function GetProgress(txt)
    local a,b = txt:match(
        "%((%d+)%s*/%s*(%d+)%)"
    )

    if not a then
        a,b = txt:match(
            "(%d+)%s*/%s*(%d+)"
        )
    end

    if a and b and tonumber(b)
    and tonumber(b) > 0 then
        return tonumber(a), tonumber(b)
    end
end

local function GetTarget(txt)
    local name = txt:match(
        "^%s*(.-)%s*%[Lv%.?%s*%d+%]"
    )

    if name then
        name = name:gsub("^%s+","")
        name = name:gsub("%s+$","")

        if #name > 1 then
            return name
        end
    end
end

--==================================================
-- READ QUEST
--==================================================

local function ReadQuest()
    local best

    for _, progressObj in ipairs(
        PlayerGui:GetDescendants()
    ) do

        if IsVisible(progressObj) then
            local current, required =
                GetProgress(progressObj.Text or "")

            if current then
                local ancestor = progressObj.Parent
                local depth = 0

                while ancestor
                and ancestor ~= PlayerGui
                and depth <= 8 do

                    for _, obj in ipairs(
                        ancestor:GetDescendants()
                    ) do

                        if obj ~= progressObj
                        and IsVisible(obj) then

                            local target =
                                GetTarget(obj.Text or "")

                            if target then
                                if not best
                                or depth < best.depth then

                                    best = {
                                        target = target,
                                        current = current,
                                        required = required,
                                        depth = depth
                                    }
                                end

                                break
                            end
                        end
                    end

                    if best and best.depth == depth then
                        break
                    end

                    ancestor = ancestor.Parent
                    depth = depth + 1
                end
            end
        end
    end

    if best then
        return best.target,
            best.current,
            best.required
    end
end

--==================================================
-- MONSTER NAME NORMALIZATION
--==================================================

local function NormalizeName(name)
    name = string.lower(name or "")
    name = name:gsub("[%p%s]", "")
    return name
end

--==================================================
-- MONSTER CACHE
--==================================================

local function RefreshMonsterCache()
    MonsterCache = {}

    for _, obj in ipairs(
        workspace:GetDescendants()
    ) do

        if obj:IsA("Model")
        and obj ~= Player.Character then

            local hum =
                obj:FindFirstChildOfClass("Humanoid")

            local root =
                obj:FindFirstChild("HumanoidRootPart")
                or obj.PrimaryPart

            if hum and hum.Health > 0 and root
            and root:IsA("BasePart") then

                local isPlayer = false

                pcall(function()
                    if Players:GetPlayerFromCharacter(obj) then
                        isPlayer = true
                    end
                end)

                if not isPlayer then
                    table.insert(MonsterCache, {
                        model = obj,
                        humanoid = hum,
                        root = root,
                        name = NormalizeName(obj.Name)
                    })
                end
            end
        end
    end

    LastMonsterScan = os.clock()
end

--==================================================
-- FIND BEST MONSTER
--==================================================

local function FindMonster(target)
    if os.clock() - LastMonsterScan
    >= SETTINGS.MonsterScanInterval then

        RefreshMonsterCache()
    end

    local char = Player.Character
    local myRoot = char and
        char:FindFirstChild("HumanoidRootPart")

    if not myRoot then
        return nil
    end

    local normalizedTarget = NormalizeName(target)

    if normalizedTarget == "" then
        return nil
    end

    local best
    local bestDistance = math.huge
    local bestScore = -1

    for _, item in ipairs(MonsterCache) do
        local model = item.model
        local hum = item.humanoid
        local root = item.root

        if model.Parent
        and hum.Parent
        and hum.Health > 0
        and root.Parent then

            local name = NormalizeName(model.Name)
            local score = 0

            if name == normalizedTarget then
                score = 1000
            elseif name:find(normalizedTarget,1,true) then
                score = 800
            elseif normalizedTarget:find(name,1,true) then
                score = 500
            end

            if score > 0 then
                local distance =
                    (root.Position-myRoot.Position).Magnitude

                if score > bestScore
                or (
                    score == bestScore
                    and distance < bestDistance
                ) then

                    best = model
                    bestScore = score
                    bestDistance = distance
                end
            end
        end
    end

    CurrentMonster = best
    return best
end

--==================================================
-- KEY INPUT
--==================================================

local function PressKey(key)
    local kc = Enum.KeyCode[key]

    if not kc then
        return false
    end

    local success = pcall(function()
        VirtualInput:SendKeyEvent(
            true, kc, false, game
        )

        task.wait(SETTINGS.SkillDelay)

        VirtualInput:SendKeyEvent(
            false, kc, false, game
        )
    end)

    return success
end

--==================================================
-- FIND SKILL LABELS
--==================================================

local function FindSkillKeyLabels()
    local found = {}

    for _, obj in ipairs(
        PlayerGui:GetDescendants()
    ) do

        if IsVisible(obj) then
            local key = (obj.Text or "")
                :upper()
                :match("^%s*([ZXCV E])%s*$")

            if key then
                key = key:gsub("%s","")

                if key ~= "" then
                    found[key] = found[key] or obj
                end
            end
        end
    end

    return found
end

--==================================================
-- GRAY COOLDOWN OVERLAY DETECTION
--==================================================

local function IsGray(color)
    if not color then
        return false
    end

    local difference = math.max(
        math.abs(color.R-color.G),
        math.abs(color.G-color.B),
        math.abs(color.R-color.B)
    )

    local brightness =
        (color.R+color.G+color.B)/3

    return difference < 0.18
        and brightness > 0.18
        and brightness < 0.88
end

local function Overlaps(a, b)
    local ap = a.AbsolutePosition
    local as = a.AbsoluteSize

    local bp = b.AbsolutePosition
    local bs = b.AbsoluteSize

    local left = math.max(ap.X,bp.X)
    local top = math.max(ap.Y,bp.Y)

    local right = math.min(
        ap.X+as.X,
        bp.X+bs.X
    )

    local bottom = math.min(
        ap.Y+as.Y,
        bp.Y+bs.Y
    )

    if right <= left or bottom <= top then
        return false
    end

    local overlapArea =
        (right-left)*(bottom-top)

    local smallerArea = math.min(
        as.X*as.Y,
        bs.X*bs.Y
    )

    if smallerArea <= 0 then
        return false
    end

    return overlapArea/smallerArea > 0.15
end

local function IsCooldownVisible(label)
    local reference = label.Parent

    if not reference
    or not reference:IsA("GuiObject") then
        reference = label
    end

    if not reference:IsA("GuiObject") then
        return false
    end

    for _, child in ipairs(
        reference:GetDescendants()
    ) do

        if child:IsA("Frame")
        or child:IsA("ImageLabel") then

            if child.Visible
            and child.AbsoluteSize.X > 4
            and child.AbsoluteSize.Y > 4
            and Overlaps(child, reference) then

                local color

                if child:IsA("Frame") then
                    if child.BackgroundTransparency < 0.95 then
                        color = child.BackgroundColor3
                    end
                elseif child:IsA("ImageLabel") then
                    if child.ImageTransparency < 0.95 then
                        color = child.ImageColor3
                    end
                end

                if IsGray(color) then
                    return true
                end
            end
        end
    end

    return false
end

--==================================================
-- USE READY SKILLS
--==================================================

local function UseReadySkills()
    local skills = FindSkillKeyLabels()
    local now = os.clock()

    for key, label in pairs(skills) do
        local lastUse = LastSkillUse[key] or 0

        if label.Parent
        and not IsCooldownVisible(label)
        and now-lastUse >= SETTINGS.SkillInterval then

            if PressKey(key) then
                LastSkillUse[key] = os.clock()
                task.wait(SETTINGS.SkillAfterDelay)
            end
        end
    end
end

--==================================================
-- ATTACK TARGET
--==================================================

local function AttackTarget(targetName)
    local char = Player.Character

    local root = char and
        char:FindFirstChild("HumanoidRootPart")

    if not root then
        return "캐릭터 대기 중"
    end

    local monster = FindMonster(targetName)

    if not monster then
        return "몬스터 검색 중: "..targetName
    end

    local hum =
        monster:FindFirstChildOfClass("Humanoid")

    local monsterRoot =
        monster:FindFirstChild("HumanoidRootPart")
        or monster.PrimaryPart

    if not hum or hum.Health <= 0
    or not monsterRoot then

        CurrentMonster = nil
        return "다음 몬스터 탐색 중"
    end

    local distance =
        (root.Position-monsterRoot.Position).Magnitude

    -- 몬스터에게 이동
    if distance > SETTINGS.MonsterMoveDistance
    and os.clock()-LastMove >= SETTINGS.MoveInterval then

        LastMove = os.clock()

        pcall(function()
            char:PivotTo(
                monsterRoot.CFrame * CFrame.new(0,0,7)
            )
        end)

        return "몬스터에게 이동 중: "..targetName
    end

    -- 평타 공격
    if distance <= SETTINGS.AttackDistance
    and os.clock()-LastAttack >= SETTINGS.AttackInterval then

        LastAttack = os.clock()

        local tool =
            char:FindFirstChildOfClass("Tool")

        if tool then
            pcall(function()
                tool:Activate()
            end)
        end
    end

    -- 스킬 공격
    if distance <= SETTINGS.SkillDistance then
        UseReadySkills()
    end

    return "사냥 중: "..targetName
end

--==================================================
-- MAIN LOOP
--==================================================

task.spawn(function()
    while Running and GUI.Parent do
        task.wait(0.65)

        if Enabled then
            local success, target, current, required =
                pcall(ReadQuest)

            if success and target then
                local attackSuccess, result =
                    pcall(AttackTarget, target)

                if attackSuccess then
                    Status.Text =
                        "퀘스트: "..target..
                        "\n진행도: "..current.."/"..required..
                        "\n"..tostring(result)
                else
                    Status.Text =
                        "공격 오류: "..tostring(result)
                end
            else
                Status.Text =
                    "퀘스트 목표를 찾지 못했습니다.\n퀘스트를 먼저 받아주세요."
            end
        end
    end
end)

print(
    "[kinghyunwoo LEVEL UP] B+C 개선 버전 실행 완료"
)
