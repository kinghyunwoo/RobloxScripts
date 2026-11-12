
--========================================
-- kinghyunwoo LEVEL UP
-- 퀘스트 추적 UI 인식 개선판
--========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
if not Player then return end

pcall(function()
    local old = CoreGui:FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)
pcall(function()
    local old = Player:WaitForChild("PlayerGui"):FindFirstChild("kinghyunwoo_LevelUp")
    if old then old:Destroy() end
end)

local Enabled = false
local Running = true

-- GUI 생성
local GUI = Instance.new("ScreenGui")
GUI.Name = "kinghyunwoo_LevelUp"
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999

local ok = pcall(function()
    GUI.Parent = CoreGui
end)
if not ok then
    GUI.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(270, 205)
Frame.Position = UDim2.new(0.5, -135, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -105, 0, 38)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "kinghyunwoo"
Title.TextColor3 = Color3.fromRGB(230, 120, 255)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30, 30)
Close.Position = UDim2.new(1, -35, 0, 4)
Close.BackgroundTransparency = 1
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 16
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
Status.Position = UDim2.fromOffset(12, 48)
Status.Size = UDim2.new(1, -24, 0, 48)
Status.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
Status.Text = "준비 완료"
Status.TextColor3 = Color3.new(1,1,1)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.TextWrapped = true
Status.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(12, 108)
Toggle.Size = UDim2.new(1, -24, 0, 38)
Toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 65)
Toggle.Text = "자동레벨업 : OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.Parent = Frame

local Info = Instance.new("TextLabel")
Info.Position = UDim2.fromOffset(12, 153)
Info.Size = UDim2.new(1, -24, 0, 38)
Info.BackgroundTransparency = 1
Info.Text = "퀘스트 추적창 인식 / 1해·2해·3해"
Info.TextColor3 = Color3.fromRGB(190, 170, 210)
Info.TextSize = 11
Info.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    if Enabled then
        Toggle.Text = "자동레벨업 : ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(30, 150, 85)
        Status.Text = "왼쪽 퀘스트 창 확인 중..."
    else
        Toggle.Text = "자동레벨업 : OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 65)
        Status.Text = "자동레벨업 중지"
    end
end)

local minimized = false
Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    Status.Visible = not minimized
    Toggle.Visible = not minimized
    Info.Visible = not minimized
    Frame.Size = minimized
        and UDim2.fromOffset(270, 40)
        or UDim2.fromOffset(270, 205)
end)

Close.MouseButton1Click:Connect(function()
    Running = false
    Enabled = false
    GUI:Destroy()
end)

-- 표시 중인 텍스트인지 확인
local function IsVisible(obj)
    if not obj:IsA("TextLabel") and not obj:IsA("TextButton") then
        return false
    end

    if not obj.Visible then return false end

    local node = obj.Parent
    local pg = Player:FindFirstChild("PlayerGui")

    while node and node ~= pg do
        if node:IsA("GuiObject") and not node.Visible then
            return false
        end
        node = node.Parent
    end

    return true
end

-- 퀘스트 진행도 읽기
local function GetProgress(txt)
    local a, b = txt:match("%((%d+)%s*/%s*(%d+)%)")

    if not a then
        a, b = txt:match("(%d+)%s*/%s*(%d+)")
    end

    if a and b then
        local current = tonumber(a)
        local required = tonumber(b)

        if required and required > 0 and current <= required then
            return current, required
        end
    end
end

-- 몬스터 이름 읽기
local function GetTarget(txt)
    local name = txt:match("^%s*(.-)%s*%[Lv%.?%s*%d+%]")

    if name then
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        if #name > 1 then
            return name
        end
    end
end

-- 진행도가 있는 퀘스트 패널 안에서만 목표 검색
local function ReadQuest()
    local pg = Player:FindFirstChild("PlayerGui")
    if not pg then return nil end

    local best = nil

    for _, progressObj in ipairs(pg:GetDescendants()) do
        if IsVisible(progressObj) then
            local current, required =
                GetProgress(progressObj.Text or "")

            if current then
                local ancestor = progressObj.Parent
                local depth = 0

                while ancestor and ancestor ~= pg and depth <= 8 do
                    local target = nil

                    for _, textObj in ipairs(ancestor:GetDescendants()) do
                        if textObj ~= progressObj and IsVisible(textObj) then
                            target = GetTarget(textObj.Text or "")
                            if target then break end
                        end
                    end

                    if target then
                        local candidate = {
                            target = target,
                            current = current,
                            required = required,
                            depth = depth
                        }

                        if not best or candidate.depth < best.depth then
                            best = candidate
                        end
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

    return nil
end

-- 상태 표시
task.spawn(function()
    while Running and GUI.Parent do
        task.wait(0.7)

        if Enabled then
            local target, current, required = ReadQuest()

            if target then
                Status.Text = "퀘스트: " .. target ..
                    "\n진행도: " .. current .. "/" .. required
            else
                Status.Text = "왼쪽 퀘스트 추적창을 찾지 못했습니다."
            end
        end
    end
end)
