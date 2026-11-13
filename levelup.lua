
--==================================================
-- KINGHYUNWOO QUEST ANALYZER V5
-- UI OBSERVER ONLY / NO REMOTE HOOK
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

pcall(function()
    CoreGui:FindFirstChild("KingHyunwooQuestV5"):Destroy()
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "KingHyunwooQuestV5"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 400)
Frame.Position = UDim2.new(0.5, -175, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "KINGHYUNWOO QUEST ANALYZER V5"
Title.TextColor3 = Color3.fromRGB(100, 255, 180)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
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
Scan.Text = "현재 퀘스트 UI 분석"
Scan.Font = Enum.Font.GothamBold
Scan.TextSize = 13
Scan.Parent = Frame

local Output = Instance.new("ScrollingFrame")
Output.Size = UDim2.new(1, -20, 1, -100)
Output.Position = UDim2.new(0, 10, 0, 90)
Output.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
Output.BorderSizePixel = 0
Output.ScrollBarThickness = 5
Output.CanvasSize = UDim2.new(0, 0, 0, 0)
Output.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.Parent = Output

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingLeft = UDim.new(0, 5)
Padding.Parent = Output

local function AddLine(Text, Color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 34)
    Label.BackgroundColor3 = Color3.fromRGB(35, 38, 45)
    Label.TextColor3 = Color or Color3.fromRGB(230, 230, 230)
    Label.Text = Text
    Label.TextSize = 11
    Label.Font = Enum.Font.Code
    Label.TextWrapped = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Output

    Instance.new("UICorner", Label).CornerRadius = UDim.new(0, 5)
end

local function Analyze()
    for _, Object in ipairs(Output:GetChildren()) do
        if Object:IsA("TextLabel") then
            Object:Destroy()
        end
    end

    AddLine("분석 시작...", Color3.fromRGB(100, 255, 180))

    local Count = 0
    local Keywords = {
        "quest",
        "level required",
        "objective",
        "confirm",
        "reward",
        "exp",
        "deep diver",
        "fugitive",
        "fishman"
    }

    for _, Object in ipairs(PlayerGui:GetDescendants()) do
        if Object:IsA("TextLabel")
        or Object:IsA("TextButton")
        or Object:IsA("TextBox") then

            local Text = tostring(Object.Text or "")
            local Lower = Text:lower()

            if Text ~= "" then
                local Relevant = false

                for _, Keyword in ipairs(Keywords) do
                    if Lower:find(Keyword, 1, true) then
                        Relevant = true
                        break
                    end
                end

                if Relevant then
                    Count += 1

                    local Type = Object.ClassName
                    AddLine(
                        "[" .. Type .. "] " ..
                        Text .. "\n경로: " ..
                        Object:GetFullName(),
                        Color3.fromRGB(255, 220, 130)
                    )
                end
            end
        end
    end

    AddLine(
        "분석 완료: " .. Count .. "개 항목",
        Color3.fromRGB(100, 255, 180)
    )

    task.wait()

    Output.CanvasSize = UDim2.new(
        0, 0, 0, Layout.AbsoluteContentSize.Y + 15
    )
end

Scan.MouseButton1Click:Connect(Analyze)

AddLine("NPC 퀘스트 창을 먼저 열어주세요.")
AddLine("그다음 분석 버튼을 눌러주세요.")

