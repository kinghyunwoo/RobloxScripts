
-- kinghyunwoo | LEVEL UP
-- Quest UI reader / nearby quest interaction

if getgenv().LevelUpRunning then
    getgenv().LevelUpRunning = false
    task.wait(0.5)
end

getgenv().LevelUpRunning = true

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

local Enabled = false
local Busy = false

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "kinghyunwoo_LevelUp"
GUI.ResetOnSpawn = false

pcall(function()
    GUI.Parent = game:GetService("CoreGui")
end)

if not GUI.Parent then
    GUI.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(250, 150)
Frame.Position = UDim2.new(0.5, -125, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(28, 20, 40)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(130, 45, 190)
Title.Text = "kinghyunwoo LEVEL UP"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(8, 42)
Status.Size = UDim2.new(1, -16, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "대기 중"
Status.TextColor3 = Color3.new(1,1,1)
Status.TextSize = 12
Status.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(10, 92)
Toggle.Size = UDim2.new(1, -20, 0, 35)
Toggle.BackgroundColor3 = Color3.fromRGB(170, 40, 60)
Toggle.Text = "AUTO LEVEL : OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 13
Toggle.Parent = Frame

local Close = Instance.new("TextButton")
Close.Position = UDim2.new(1, -28, 0, 3)
Close.Size = UDim2.fromOffset(25, 25)
Close.BackgroundTransparency = 1
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Toggle.Text = Enabled and "AUTO LEVEL : ON" or "AUTO LEVEL : OFF"
    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30,150,80)
        or Color3.fromRGB(170,40,60)
end)

Close.MouseButton1Click:Connect(function()
    Enabled = false
    getgenv().LevelUpRunning = false
    GUI:Destroy()
end)

local function GetCharacter()
    local char = Player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if hum and root and hum.Health > 0 then
        return char, hum, root
    end
end

-- Read player level
local function GetLevel()
    local stats = Player:FindFirstChild("leaderstats")

    if stats then
        for _, v in ipairs(stats:GetChildren()) do
            if v.Name:lower():find("level") then
                return tonumber(v.Value)
            end
        end
    end

    for _, obj in ipairs(Player:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local n = obj.Text:match("^%s*(%d+)%s*$")
            if n and obj.Name:lower():find("level") then
                return tonumber(n)
            end
        end
    end

    return nil
end

-- Collect visible UI text
local function GetVisibleText()
    local result = {}

    for _, obj in ipairs(Player.PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            if obj.Visible and obj.Text ~= "" then
                table.insert(result, obj.Text)
            end
        end
    end

    return result
end

-- Read active quest
local function ReadQuest()
    local texts = GetVisibleText()
    local name, current, required

    for _, s in ipairs(texts) do
        local n = s:match("^%s*(.-)%s*%[Lv%.%s*%d+%]")
        if n then name = n end

        local a,b = s:match("%((%d+)%s*/%s*(%d+)%)")
        if a then
            current = tonumber(a)
            required = tonumber(b)
        end
    end

    if name and current and required then
        return name, current, required
    end
end

-- Read quest detail panel
local function ReadQuestRequirement()
    local texts = GetVisibleText()
    local level, objective

    for _, s in ipairs(texts) do
        local n = s:match("[Ll]evel [Rr]equired:%s*(%d+)")
        if n then level = tonumber(n) end

        local o = s:match("[Oo]bjective:%s*(.+)")
        if o then objective = o end
    end

    return level, objective
end

local function FindButton(buttonName)
    for _, obj in ipairs(Player.PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Visible then
            if obj.Text:lower() == buttonName:lower() then
                return obj
            end
        end
    end
end

-- Nearby quest interaction
local function FindNearbyQuestPrompt()
    local _, _, root = GetCharacter()
    if not root then return end

    local best, bestDistance

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent

            if not part:IsA("BasePart") then
                part = part:FindFirstChildWhichIsA("BasePart", true)
            end

            if part then
                local d = (root.Position - part.Position).Magnitude

                if d <= obj.MaxActivationDistance + 2 then
                    if not bestDistance or d < bestDistance then
                        best = obj
                        bestDistance = d
                    end
                end
            end
        end
    end

    return best
end

-- Find matching monster
local function FindMonster(name)
    local _, _, root = GetCharacter()
    if not root then return end

    local best, distance

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local enemyRoot = obj:FindFirstChild("HumanoidRootPart")

            if hum and enemyRoot and hum.Health > 0 then
                if obj.Name:lower():find(name:lower(), 1, true) then
                    local d = (root.Position - enemyRoot.Position).Magnitude

                    if not distance or d < distance then
                        best = obj
                        distance = d
                    end
                end
            end
        end
    end

    return best
end

local function Attack()
    local char, hum = GetCharacter()
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")

    if not tool then
        local backpack = Player:FindFirstChild("Backpack")
        tool = backpack and backpack:FindFirstChildOfClass("Tool")

        if tool then
            hum:EquipTool(tool)
        end
    end

    if tool then
        pcall(function()
            tool:Activate()
        end)
    end
end

-- Main loop
task.spawn(function()
    while getgenv().LevelUpRunning do
        task.wait(0.4)

        if not Enabled or Busy then
            continue
        end

        local level = GetLevel()
        local questName, progress, needed = ReadQuest()

        if questName then
            Status.Text = "레벨: " .. tostring(level or "?")
                .. "\n대상: " .. questName
                .. " (" .. progress .. "/" .. needed .. ")"

            if progress < needed then
                local enemy = FindMonster(questName)

                if enemy then
                    local _, _, root = GetCharacter()
                    local er = enemy:FindFirstChild("HumanoidRootPart")

                    if root and er then
                        root.CFrame = er.CFrame * CFrame.new(0, 6, 0)
                        Attack()
                    end
                else
                    Status.Text = questName .. "\n대상 몬스터 탐색 중"
                end

        else
            local required, objective = ReadQuestRequirement()

            if required and level and required <= level then
                Status.Text = "퀘스트 조건 충족\n" .. (objective or "")

                local confirm = FindButton("Confirm")
                if confirm then
                    pcall(function()
                        confirm:Activate()
                    end)
                end

            elseif required and level and required > level then
                Status.Text = "현재 레벨에 맞지 않는 퀘스트\n다른 퀘스트를 선택하세요"
                
                local back = FindButton("Return")
                if back then
                    pcall(function()
                        back:Activate()
                    end)
                end
            else
                Status.Text = "퀘스트 NPC 근처에서 상호작용 필요"

                local prompt = FindNearbyQuestPrompt()
                if prompt and typeof(fireproximityprompt) == "function" then
                    pcall(function()
                        fireproximityprompt(prompt)
                    end)
                end
            end
        end
    end
end)
