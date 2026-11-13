
--==================================================
-- KINGHYUNWOO QUEST ANALYZER V6
-- FULL QUESTFRAME INSPECTOR
-- NO HOOK / NO REMOTE CALL
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

pcall(function()
    local old = CoreGui:FindFirstChild("KingHyunwooQuestV6")
    if old then old:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "KingHyunwooQuestV6"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 360, 0, 420)
Frame.Position = UDim2.new(0.5, -180, 0.5, -210)
Frame.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "KINGHYUNWOO QUEST ANALYZER V6"
Title.TextColor3 = Color3.fromRGB(100, 255, 180)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = Frame

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.Parent = Frame

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

local Scan = Instance.new("TextButton")
Scan.Size = UDim2.new(1, -20, 0, 38)
Scan.Position = UDim2.new(0, 10, 0, 45)
Scan.BackgroundColor3 = Color3.fromRGB(45, 115, 85)
Scan.TextColor3 = Color3.new(1, 1, 1)
Scan.Text = "QuestFrame 전체 분석"
Scan.Font = Enum.Font.GothamBold
Scan.TextSize = 13
Scan.Parent = Frame

local Output = Instance.new("ScrollingFrame")
Output.Size = UDim2.new(1, -20, 1, -100)
Output.Position = UDim2.new(0, 10, 0, 90)
Output.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
Output.BorderSizePixel = 0
Output.ScrollBarThickness = 6
Output.CanvasSize = UDim2.new(0, 0, 0, 0)
Output.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.Parent = Output

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingLeft = UDim.new(0, 5)
Padding.Parent = Output

local function AddLine(text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 48)
    Label.BackgroundColor3 = Color3.fromRGB(35, 38, 45)
    Label.TextColor3 = color or Color3.fromRGB(230, 230, 230)
    Label.Text = text
    Label.TextSize = 10
    Label.Font = Enum.Font.Code
    Label.TextWrapped = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Output
end

local function Analyze()
    for _, obj in ipairs(Output:GetChildren()) do
        if obj:IsA("TextLabel") then
            obj:Destroy()
        end
    end

    AddLine("분석 중...", Color3.fromRGB(100, 255, 180))

    local questFrames = {}

    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Name:lower():find("questframe", 1, true) then
            table.insert(questFrames, obj)
        end
    end

    if #questFrames == 0 then
        AddLine("QuestFrame을 찾지 못했습니다.")
        AddLine("NPC 퀘스트 창을 열고 다시 눌러주세요.")
    else
        local seen = {}
        local count = 0

        for _, questFrame in ipairs(questFrames) do
            AddLine("FRAME: " .. questFrame:GetFullName(),
                Color3.fromRGB(100, 255, 180))

            for _, obj in ipairs(questFrame:GetDescendants()) do
                if obj:IsA("TextLabel")
                or obj:IsA("TextButton")
                or obj:IsA("TextBox") then

                    local text = tostring(obj.Text or "")

                    if text ~= "" and not seen[obj] then
                        seen[obj] = true
                        count += 1

                        AddLine(
                            "[" .. obj.ClassName .. "] " .. text ..
                            "\n이름: " .. obj.Name ..
                            "\n경로: " .. obj:GetFullName(),
                            obj:IsA("TextButton")
                            and Color3.fromRGB(120, 220, 255)
                            or Color3.fromRGB(255, 220, 130)
                        )
                    end
                end
            end
        end

        AddLine("분석 완료: " .. count .. "개 텍스트",
            Color3.fromRGB(100, 255, 180))
    end

    task.wait()
    Output.CanvasSize = UDim2.new(
        0, 0, 0, Layout.AbsoluteContentSize.Y + 15
    )
end

Scan.MouseButton1Click:Connect(Analyze)

AddLine("NPC 퀘스트 선택창을 열어주세요.")
AddLine("열린 상태에서 분석 버튼을 누르세요.")