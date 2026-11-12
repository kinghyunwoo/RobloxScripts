
--==================================================
-- kinghyunwoo LEVEL UP
-- 자동 레벨 인식 + 레벨별 퀘스트 + 자동 사냥
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
local LastNPCInteract = 0
local LastQuestScan = 0

--==================================================
-- GUI 제거
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
-- GUI 생성
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "kinghyunwoo_LevelUp"
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999

local guiOK = pcall(function()
    GUI.Parent = CoreGui
end)

if not guiOK then
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

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

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
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Parent = Frame

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(30, 30)
Minimize.Position = UDim2.new(1, -70, 0, 4)
Minimize.BackgroundTransparency = 1
Minimize.Text = "−"
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.TextSize = 22
Minimize.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(12, 45)
Status.Size = UDim2.new(1, -24, 0, 72)
Status.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
Status.Text = "준비 완료"
Status.TextColor3 = Color3.new(1, 1, 1)
Status.TextSize = 13
Status.TextWrapped = true
Status.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(12, 126)
Toggle.Size = UDim2.new(1, -24, 0, 38)
Toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 65)
Toggle.Text = "자동레벨업 : OFF"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Frame

local Info = Instance.new("TextLabel")
Info.Position = UDim2.fromOffset(12, 170)
Info.Size = UDim2.new(1, -24, 0, 38)
Info.BackgroundTransparency = 1
Info.Text = "자동 퀘스트 · 평타 · 스킬"
Info.TextColor3 = Color3.fromRGB(190, 170, 210)
Info.TextSize = 11
Info.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    Toggle.Text = Enabled and "자동레벨업 : ON" or "자동레벨업 : OFF"

    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30, 150, 85)
        or Color3.fromRGB(170, 45, 65)

    Status.Text = Enabled
        and "레벨 및 퀘스트 확인 중..."
        or "자동레벨업 중지"
end)

local minimized = false

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    Status.Visible = not minimized
    Toggle.Visible = not minimized
    Info.Visible = not minimized

    Frame.Size = minimized
        and UDim2.fromOffset(280, 40)
        or UDim2.fromOffset(280, 220)
end)

Close.MouseButton1Click:Connect(function()
    Running = false
    Enabled = false
    GUI:Destroy()
end)

--==================================================
-- 공통 함수
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
        if node:IsA("GuiObject") and not node.Visible then
            return false
        end
        node = node.Parent
    end

    return true
end

local function ClickButton(button)
    if not button or not button.Visible then
        return false
    end

    local success = pcall(function()
        button:Activate()
    end)

    if success then
        return true
    end

    return pcall(function()
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize

        local x = pos.X + size.X / 2
        local y = pos.Y + size.Y / 2

        VirtualInput:SendMouseButtonEvent(
            x, y, 0, true, game, 0
        )

        task.wait(0.08)

        VirtualInput:SendMouseButtonEvent(
            x, y, 0, false, game, 0
        )
    end)
end

local function FindButton(text, root)
    root = root or PlayerGui

    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("TextButton")
        and IsVisible(obj)
        and obj.Text:lower():match(
            "^%s*" .. text:lower() .. "%s*$"
        ) then
            return obj
        end
    end
end

local function ParseNumber(value)
    local number = tonumber(
        tostring(value):gsub(",", ""):gsub("%s", "")
    )

    if number and number >= 1 and number <= 1000000 then
        return number
    end
end

--==================================================
-- 플레이어 레벨 인식
--==================================================

local function GetPlayerLevel()

    -- 1. leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")

    if leaderstats then
        for _, value in ipairs(leaderstats:GetDescendants()) do
            if (
                value:IsA("IntValue")
                or value:IsA("NumberValue")
                or value:IsA("StringValue")
            ) and value.Name:lower():find("level") then

                local number = ParseNumber(value.Value)
                if number then
                    return number
                end
            end
        end
    end

    -- 2. Level 텍스트
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if IsVisible(obj) then
            local txt = obj.Text or ""

            local number = txt:match(
                "[Ll]evel%s*[:%-]?%s*([%d,]+)"
            )

            if not number then
                number = txt:match(
                    "[Ll]v%.?%s*[:%-]?%s*([%d,]+)"
                )
            end

            if number then
                local parsed = ParseNumber(number)
                if parsed then
                    return parsed
                end
            end
        end
    end

    -- 3. 스크린샷의 아래쪽 중앙 노란색 숫자
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local viewport = camera.ViewportSize

    if viewport.X <= 0 or viewport.Y <= 0 then
        return nil
    end

    local bestLevel = nil
    local bestScore = math.huge

    local roots = {PlayerGui}

    pcall(function()
        table.insert(roots, CoreGui)
    end)

    for _, root in ipairs(roots) do
        local descendants = {}

        pcall(function()
            descendants = root:GetDescendants()
        end)

        for _, obj in ipairs(descendants) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then

                if obj:IsDescendantOf(GUI) then
                    continue
                end

                local visible = false
                pcall(function()
                    visible = IsVisible(obj)
                end)

                if not visible then
                    continue
                end

                local number = ParseNumber(obj.Text)

                if number then
                    local pos = obj.AbsolutePosition
                    local size = obj.AbsoluteSize

                    local cx = (pos.X + size.X / 2) / viewport.X
                    local cy = (pos.Y + size.Y / 2) / viewport.Y

                    local color = obj.TextColor3

                    local isYellow =
                        color.R > 0.75
                        and color.G > 0.45
                        and color.B < 0.4

                    local correctPosition =
                        cx >= 0.46
                        and cx <= 0.54
                        and cy >= 0.70
                        and cy <= 0.85

                    if isYellow and correctPosition and size.X > 10 then
                        local score =
                            math.abs(cx - 0.50)
                            + math.abs(cy - 0.77)

                        if score < bestScore then
                            bestScore = score
                            bestLevel = number
                        end
                    end
                end
            end
        end
    end

    return bestLevel
end

--==================================================
-- 퀘스트 진행도
--==================================================

local function GetProgress(txt)
    local a, b = txt:match("%((%d+)%s*/%s*(%d+)%)")

    if not a then
        a, b = txt:match("(%d+)%s*/%s*(%d+)")
    end

    if a and b and tonumber(b) and tonumber(b) > 0 then
        return tonumber(a), tonumber(b)
    end
end

local function GetTarget(txt)
    local name = txt:match(
        "^%s*(.-)%s*%[Lv%.?%s*%d+%]"
    )

    if name then
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        if #name > 1 then
            return name
        end
    end
end

local function ReadQuest()
    local best

    for _, progressObj in ipairs(PlayerGui:GetDescendants()) do
        if IsVisible(progressObj) then
            local current, required =
                GetProgress(progressObj.Text or "")

            if current then
                local ancestor = progressObj.Parent
                local depth = 0

                while ancestor
                and ancestor ~= PlayerGui
                and depth <= 8 do

                    for _, obj in ipairs(ancestor:GetDescendants()) do
                        if obj ~= progressObj and IsVisible(obj) then
                            local target = GetTarget(obj.Text or "")

                            if target then
                                if not best or depth < best.depth then
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
        return best.target, best.current, best.required
    end
end

--==================================================
-- 퀘스트 메뉴
--==================================================

local function HasQuestMenu()
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if IsVisible(obj)
        and (obj.Text or ""):lower():find("select a quest", 1, true) then
            return true
        end
    end

    return false
end

local function ReadRequiredLevel()
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if IsVisible(obj) then
            local number = (obj.Text or ""):match(
                "[Ll]evel%s+[Rr]equired%s*:%s*([%d,]+)"
            )

            if number then
                return tonumber(number:gsub(",", ""))
            end
        end
    end

    return nil
end

local function FindQuestPanel()
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if IsVisible(obj)
        and (obj.Text or ""):lower():find("select a quest", 1, true) then

            local node = obj.Parent

            for _ = 1, 8 do
                if not node or node == PlayerGui then
                    break
                end

                local count = 0

                for _, child in ipairs(node:GetDescendants()) do
                    if child:IsA("TextButton") and IsVisible(child) then
                        count = count + 1
                    end
                end

                if count >= 2 then
                    return node
                end

                node = node.Parent
            end
        end
    end

    return nil
end

--==================================================
-- 현재 레벨 이하에서 가장 높은 퀘스트 선택
--==================================================

local function SelectLevelQuest(level)
    local panel = FindQuestPanel()

    if not panel then
        return false, "퀘스트 목록을 찾지 못했습니다"
    end

    local buttons = {}

    for _, obj in ipairs(panel:GetDescendants()) do
        if obj:IsA("TextButton") and IsVisible(obj) then
            local name = (obj.Text or ""):lower()

            if name ~= ""
            and not name:find("abandon", 1, true)
            and not name:find("return", 1, true)
            and not name:find("confirm", 1, true) then

                table.insert(buttons, obj)
            end
        end
    end

    local bestButton = nil
    local bestRequired = -1
    local bestName = ""

    -- 모든 선택지의 요구 레벨 검사
    for _, button in ipairs(buttons) do
        if not Enabled then
            return false, "중지됨"
        end

        ClickButton(button)
        task.wait(0.5)

        local required = ReadRequiredLevel()

        if required
        and required <= level
        and required > bestRequired then

            bestRequired = required
            bestButton = button
            bestName = button.Text
        end

        local back = FindButton("Return")

        if back then
            ClickButton(back)
            task.wait(0.4)
        end
    end

    if not bestButton then
        return false, "현재 레벨 이하의 퀘스트가 없습니다"
    end

    -- 선택한 퀘스트 다시 열기
    if not Enabled then
        return false, "중지됨"
    end

    ClickButton(bestButton)
    task.wait(0.5)

    local verifyRequired = ReadRequiredLevel()

    if not verifyRequired
    or verifyRequired ~= bestRequired
    or verifyRequired > level then

        return false, "퀘스트 요구 레벨 재확인 실패"
    end

    local confirm = FindButton("Confirm")

    if not confirm then
        return false, "Confirm 버튼을 찾지 못했습니다"
    end

    ClickButton(confirm)
    task.wait(0.6)

    return true,
        "수락: " .. bestName .. " (" .. bestRequired .. "+)"
end

--==================================================
-- 퀘스트 상세 화면 수락
--==================================================

local function ConfirmEligibleQuest(level)
    local required = ReadRequiredLevel()

    if not required then
        return false
    end

    if required > level then
        local back = FindButton("Return")
        if back then
            ClickButton(back)
        end
        return false
    end

    local confirm = FindButton("Confirm")

    if confirm then
        ClickButton(confirm)
        task.wait(0.5)
        return true
    end

    return false
end

--==================================================
-- 퀘스트 NPC 검색
--==================================================

local function FindQuestNPC()
    local char = Player.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")

    if not myRoot then
        return nil
    end

    local candidates = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt")
        or obj:IsA("ClickDetector") then

            local model = obj:FindFirstAncestorOfClass("Model")

            if model and model ~= char then
                local root =
                    model:FindFirstChild("HumanoidRootPart")
                    or model.PrimaryPart

                if root then
                    local name = model.Name:lower()
                    local promptText = ""

                    if obj:IsA("ProximityPrompt") then
                        promptText = (
                            obj.ActionText .. " " .. obj.ObjectText
                        ):lower()
                    end

                    local hasBillboard =
                        model:FindFirstChildWhichIsA(
                            "BillboardGui", true
                        ) ~= nil

                    local isQuestNPC =
                        name:find("quest", 1, true)
                        or promptText:find("quest", 1, true)
                        or (
                            hasBillboard
                            and obj:IsA("ProximityPrompt")
                        )

                    if isQuestNPC then
                        table.insert(candidates, {
                            model = model,
                            root = root,
                            interaction = obj,
                            distance = (
                                root.Position - myRoot.Position
                            ).Magnitude
                        })
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.distance < b.distance
    end)

    return candidates[1]
end

local function TryInteractNPC()
    if os.clock() - LastNPCInteract < 2 then
        return "퀘스트 NPC 접근 중..."
    end

    local npc = FindQuestNPC()

    if not npc then
        return "NPC 탐색 중: 현재 로드된 NPC 없음"
    end

    local char = Player.Character

    if not char then
        return "캐릭터 대기 중"
    end

    LastNPCInteract = os.clock()

    if npc.distance > 10 then
        pcall(function()
            char:PivotTo(
                npc.root.CFrame * CFrame.new(0, 0, 5)
            )
        end)

        return "NPC 이동 시도 중..."
    end

    local interaction = npc.interaction

    if interaction:IsA("ProximityPrompt") then
        local success = false

        if typeof(fireproximityprompt) == "function" then
            success = pcall(function()
                fireproximityprompt(interaction)
            end)
        end

        if not success then
            success = pcall(function()
                interaction:InputHoldBegin()
                task.wait(0.2)
                interaction:InputHoldEnd()
            end)
        end

        if success then
            return "NPC 상호작용 시도"
        end

    elseif interaction:IsA("ClickDetector") then
        if typeof(fireclickdetector) == "function" then
            local success = pcall(function()
                fireclickdetector(interaction)
            end)

            if success then
                return "NPC 클릭 시도"
            end
        end
    end

    return "NPC 상호작용 실패"
end

--==================================================
-- 자동 퀘스트
--==================================================

local function TryAutoQuest()
    local level = GetPlayerLevel()

    if not level then
        return "레벨 인식 실패"
    end

    if HasQuestMenu() then
        local success, message = SelectLevelQuest(level)
        return message
    end

    local required = ReadRequiredLevel()

    if required then
        if ConfirmEligibleQuest(level) then
            return "레벨 " .. level .. " 퀘스트 수락 완료"
        end

        return "퀘스트 요구 레벨 확인 중..."
    end

    return TryInteractNPC()
end

--==================================================
-- 몬스터 검색
--==================================================

local function FindMonster(target)
    local matches = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
        and obj.Name:lower():find(target:lower(), 1, true) then

            local hum = obj:FindFirstChildOfClass("Humanoid")

            local root =
                obj:FindFirstChild("HumanoidRootPart")
                or obj.PrimaryPart

            if hum and hum.Health > 0 and root then
                table.insert(matches, obj)
            end
        end
    end

    local char = Player.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")

    if myRoot then
        table.sort(matches, function(a, b)
            local ar =
                a:FindFirstChild("HumanoidRootPart")
                or a.PrimaryPart

            local br =
                b:FindFirstChild("HumanoidRootPart")
                or b.PrimaryPart

            return (ar.Position - myRoot.Position).Magnitude
                < (br.Position - myRoot.Position).Magnitude
        end)
    end

    return matches[1]
end

--==================================================
-- 스킬 입력
--==================================================

local function PressKey(key)
    local kc = Enum.KeyCode[key]

    if not kc then
        return false
    end

    return pcall(function()
        VirtualInput:SendKeyEvent(true, kc, false, game)
        task.wait(0.07)
        VirtualInput:SendKeyEvent(false, kc, false, game)
    end)
end

local function FindSkillKeyLabels()
    local found = {}

    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if IsVisible(obj) then
            local key = (obj.Text or ""):upper():match(
                "^%s*([ZXCVE])%s*$"
            )

            if key then
                table.insert(found, {
                    label = obj,
                    key = key
                })
            end
        end
    end

    return found
end

local function IsCooldownVisible(label)
    local node = label.Parent

    for _ = 1, 3 do
        if not node then
            break
        end

        for _, child in ipairs(node:GetDescendants()) do
            if child:IsA("Frame")
            or child:IsA("ImageLabel") then

                local gray = child.BackgroundColor3

                local looksGray = gray
                    and gray.R > 0.25
                    and gray.R < 0.8
                    and math.abs(gray.R - gray.G) < 0.12
                    and math.abs(gray.G - gray.B) < 0.12

                if child.Visible
                and looksGray
                and child.AbsoluteSize.X > 4
                and child.AbsoluteSize.Y > 4 then
                    return true
                end
            end
        end

        node = node.Parent
    end

    return false
end

local function UseReadySkills()
    for _, item in ipairs(FindSkillKeyLabels()) do
        local label = item.label
        local key = item.key

        local skillId = label:GetFullName() .. ":" .. key
        local now = os.clock()

        if not IsCooldownVisible(label)
        and now - (LastSkillUse[skillId] or 0) > 1 then

            if PressKey(key) then
                LastSkillUse[skillId] = now
                task.wait(0.18)
            end
        end
    end
end

--==================================================
-- 몬스터 공격
--==================================================

local function AttackTarget(targetName)
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not root then
        return "캐릭터 대기 중"
    end

    local monster = FindMonster(targetName)

    if not monster then
        return "몬스터 검색 중: " .. targetName
    end

    local monsterRoot =
        monster:FindFirstChild("HumanoidRootPart")
        or monster.PrimaryPart

    if not monsterRoot then
        return "몬스터 위치 확인 실패"
    end

    if (root.Position - monsterRoot.Position).Magnitude > 12
    and os.clock() - LastMove > 1.5 then

        LastMove = os.clock()

        pcall(function()
            char:PivotTo(
                monsterRoot.CFrame * CFrame.new(0, 0, 7)
            )
        end)
    end

    if os.clock() - LastAttack > 0.45 then
        LastAttack = os.clock()

        local tool = char:FindFirstChildOfClass("Tool")

        if tool then
            pcall(function()
                tool:Activate()
            end)
        end
    end

    UseReadySkills()

    return "사냥 중: " .. targetName
end

--==================================================
-- 메인 반복 실행
--==================================================

task.spawn(function()
    while Running and GUI.Parent do
        task.wait(0.65)

        if Enabled then
            local level = GetPlayerLevel()
            local target, current, required = ReadQuest()

            if target then
                local result = AttackTarget(target)

                Status.Text =
                    "레벨: " .. tostring(level or "인식 실패")
                    .. "\n퀘스트: " .. target
                    .. "\n진행도: " .. current .. "/" .. required
                    .. "\n" .. result
            else
                local result = TryAutoQuest()

                Status.Text =
                    "레벨: " .. tostring(level or "인식 실패")
                    .. "\n자동 퀘스트 진행 중"
                    .. "\n" .. result
            end
        end
    end
end)