
--========================================
-- kinghyunwoo LEVEL UP
-- Use 버튼 미사용 버전
--========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualInput = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer
if not Player then return end

local PlayerGui = Player:WaitForChild("PlayerGui")
local Enabled, Running = false, true
local LastSkillUse = {}
local LastAttack, LastMove = 0, 0

pcall(function()
    local old = CoreGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)
pcall(function()
    local old = PlayerGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "kinghyunwoo_LevelUp"
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999

local ok = pcall(function()
    GUI.Parent = CoreGui
end)
if not ok then GUI.Parent = PlayerGui end

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

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(12, 126)
Toggle.Size = UDim2.new(1, -24, 0, 38)
Toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 65)
Toggle.Text = "자동레벨업 : OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Frame

local Info = Instance.new("TextLabel")
Info.Position = UDim2.fromOffset(12, 170)
Info.Size = UDim2.new(1, -24, 0, 38)
Info.BackgroundTransparency = 1
Info.Text = "퀘스트 추적 · 평타 · 스킬 키"
Info.TextColor3 = Color3.fromRGB(190, 170, 210)
Info.TextSize = 11
Info.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Toggle.Text = Enabled and "자동레벨업 : ON" or "자동레벨업 : OFF"
    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30,150,85)
        or Color3.fromRGB(170,45,65)
    Status.Text = Enabled and "퀘스트 목표 확인 중..." or "자동레벨업 중지"
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
    Running, Enabled = false, false
    GUI:Destroy()
end)

-- UI 표시 여부
local function IsVisible(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
        return false
    end
    if not obj.Visible then return false end

    local node = obj.Parent
    while node and node ~= PlayerGui do
        if node:IsA("GuiObject") and not node.Visible then
            return false
        end
        node = node.Parent
    end
    return true
end

-- 퀘스트 진행도
local function GetProgress(txt)
    local a,b = txt:match("%((%d+)%s*/%s*(%d+)%)")
    if not a then
        a,b = txt:match("(%d+)%s*/%s*(%d+)")
    end
    if a and b and tonumber(b) and tonumber(b) > 0 then
        return tonumber(a), tonumber(b)
    end
end

-- 몬스터 이름
local function GetTarget(txt)
    local name = txt:match("^%s*(.-)%s*%[Lv%.?%s*%d+%]")
    if name then
        name = name:gsub("^%s+",""):gsub("%s+$","")
        if #name > 1 then return name end
    end
end

-- 현재 퀘스트 읽기
local function ReadQuest()
    local best

    for _, progressObj in ipairs(PlayerGui:GetDescendants()) do
        if IsVisible(progressObj) then
            local current, required =
                GetProgress(progressObj.Text or "")

            if current then
                local ancestor = progressObj.Parent
                local depth = 0

                while ancestor and ancestor ~= PlayerGui and depth <= 8 do
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

                    if best and best.depth == depth then break end
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

-- 퀘스트 몬스터 찾기
local function FindMonster(target)
    local matches = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
        and obj.Name:lower():find(target:lower(),1,true) then

            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
                or obj.PrimaryPart

            if hum and hum.Health > 0 and root then
                table.insert(matches,obj)
            end
        end
    end

    local char = Player.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")

    if myRoot then
        table.sort(matches,function(a,b)
            local ar = a:FindFirstChild("HumanoidRootPart") or a.PrimaryPart
            local br = b:FindFirstChild("HumanoidRootPart") or b.PrimaryPart
            return (ar.Position-myRoot.Position).Magnitude
                < (br.Position-myRoot.Position).Magnitude
        end)
    end

    return matches[1]
end

-- Z/X/C/V/E 키 입력
local function PressKey(key)
    local kc = Enum.KeyCode[key]
    if not kc then return false end

    return pcall(function()
        VirtualInput:SendKeyEvent(true,kc,false,game)
        task.wait(0.07)
        VirtualInput:SendKeyEvent(false,kc,false,game)
    end)
end

-- 화면에 표시된 스킬 키 찾기
local function FindSkillKeyLabels()
    local found = {}

    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if IsVisible(obj) then
            local key = (obj.Text or ""):upper():match("^%s*([ZXCV E])%s*$")

            if key then
                key = key:gsub("%s","")
                if key ~= "" then
                    table.insert(found,{
                        label = obj,
                        key = key
                    })
                end
            end
        end
    end

    return found
end

-- 회색 쿨타임 표시 감지 시도
local function IsCooldownVisible(label)
    local node = label.Parent

    for _ = 1,3 do
        if not node then break end

        for _, child in ipairs(node:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("ImageLabel") then
                local gray = child.BackgroundColor3
                local looksGray = gray
                    and gray.R > 0.25 and gray.R < 0.8
                    and math.abs(gray.R-gray.G) < 0.12
                    and math.abs(gray.G-gray.B) < 0.12

                if child.Visible and looksGray
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

-- 스킬별로 따로 입력
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

-- 몬스터 공격
local function AttackTarget(targetName)
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not root then return "캐릭터 대기 중" end

    local monster = FindMonster(targetName)
    if not monster then
        return "몬스터 검색 중: "..targetName
    end

    local monsterRoot =
        monster:FindFirstChild("HumanoidRootPart")
        or monster.PrimaryPart

    if not monsterRoot then
        return "몬스터 위치 확인 실패"
    end

    if (root.Position-monsterRoot.Position).Magnitude > 12
    and os.clock()-LastMove > 1.5 then

        LastMove = os.clock()
        pcall(function()
            char:PivotTo(monsterRoot.CFrame * CFrame.new(0,0,7))
        end)
    end

    if os.clock()-LastAttack > 0.45 then
        LastAttack = os.clock()
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
    end

    UseReadySkills()
    return "사냥 중: "..targetName
end

-- 자동 실행
task.spawn(function()
    while Running and GUI.Parent do
        task.wait(0.65)

        if Enabled then
            local target,current,required = ReadQuest()

            if target then
                local result = AttackTarget(target)
                Status.Text =
                    "퀘스트: "..target..
                    "\n진행도: "..current.."/"..required..
                    "\n"..result
            else
                Status.Text =
                    "퀘스트 목표를 찾지 못했습니다.\n퀘스트를 먼저 받아주세요."
            end
        end
    end
end)
