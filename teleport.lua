
--========================================================
-- KINGHYUNWOO TELEPORT GUI
-- NEON PURPLE + PINK EDITION
-- TELEPORT / FOLLOW / MINIMIZE / RESTORE / DRAG
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================
-- CLEANUP
--========================================================

local old = PlayerGui:FindFirstChild("kinghyunwoo")
if old then
    old:Destroy()
end

--========================================================
-- COLORS
--========================================================

local BG = Color3.fromRGB(17, 10, 27)
local PANEL = Color3.fromRGB(29, 16, 43)
local PURPLE = Color3.fromRGB(115, 45, 170)
local PINK = Color3.fromRGB(255, 65, 190)
local WHITE = Color3.fromRGB(255, 240, 255)
local MUTED = Color3.fromRGB(180, 145, 195)
local RED = Color3.fromRGB(180, 40, 80)
local GREEN = Color3.fromRGB(45, 145, 100)

--========================================================
-- STATE
--========================================================

local selected = nil
local following = false
local minimized = false
local followConnection = nil
local buttons = {}

--========================================================
-- GUI
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "kinghyunwoo"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(290, 390)
frame.Position = UDim2.new(0.5, -145, 0.5, -195)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local outline = Instance.new("UIStroke")
outline.Color = PINK
outline.Thickness = 1.7
outline.Parent = frame

--========================================================
-- TITLE BAR
--========================================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = PANEL
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.ZIndex = 2
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "KINGHYUNWOO"
title.TextColor3 = PINK
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = titleBar

--========================================================
-- BUTTON CREATOR
--========================================================

local function makeButton(parent, text, size, position, color)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = WHITE
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.ZIndex = 4
    button.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    return button
end

--========================================================
-- TITLE BUTTONS
--========================================================

local minimize = makeButton(
    titleBar,
    "−",
    UDim2.fromOffset(32, 30),
    UDim2.new(1, -76, 0, 9),
    PURPLE
)

local close = makeButton(
    titleBar,
    "X",
    UDim2.fromOffset(32, 30),
    UDim2.new(1, -38, 0, 9),
    RED
)

--========================================================
-- CONTENT CONTAINER
-- All content hidden together when minimized
--========================================================

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -48)
content.Position = UDim2.fromOffset(0, 48)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.Parent = frame

--========================================================
-- SUBTITLE
--========================================================

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 20)
subtitle.Position = UDim2.fromOffset(12, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PLAYER TELEPORT SYSTEM"
subtitle.TextColor3 = MUTED
subtitle.TextSize = 10
subtitle.Font = Enum.Font.GothamBold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = content

--========================================================
-- PLAYER LIST
--========================================================

local list = Instance.new("ScrollingFrame")
list.Name = "PlayerList"
list.Position = UDim2.fromOffset(12, 30)
list.Size = UDim2.new(1, -24, 1, -112)
list.BackgroundColor3 = PANEL
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = PINK
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = content

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 9)
listCorner.Parent = list

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 7)
padding.PaddingRight = UDim.new(0, 7)
padding.Parent = list

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.Name
layout.Parent = list

--========================================================
-- STATUS
--========================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 20)
status.Position = UDim2.new(0, 12, 1, -80)
status.BackgroundTransparency = 1
status.Text = "선택된 플레이어: 없음"
status.TextColor3 = MUTED
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = content

--========================================================
-- TELEPORT BUTTON
--========================================================

local teleport = makeButton(
    content,
    "순간이동",
    UDim2.new(0.5, -17, 0, 39),
    UDim2.new(0, 12, 1, -49),
    PURPLE
)

local teleportStroke = Instance.new("UIStroke")
teleportStroke.Color = PINK
teleportStroke.Thickness = 1
teleportStroke.Parent = teleport

--========================================================
-- FOLLOW BUTTON
--========================================================

local followButton = makeButton(
    content,
    "추적 시작",
    UDim2.new(0.5, -17, 0, 39),
    UDim2.new(0.5, 5, 1, -49),
    GREEN
)

--========================================================
-- FOLLOW STOP
--========================================================

local function stopFollowing(message)
    following = false

    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end

    followButton.Text = "추적 시작"
    followButton.BackgroundColor3 = GREEN

    if message then
        status.Text = message
    end
end

--========================================================
-- FOLLOW START
--========================================================

local function startFollowing()
    if not selected then
        status.Text = "플레이어를 먼저 선택하세요!"
        return
    end

    if selected == LocalPlayer then
        status.Text = "자기 자신은 추적할 수 없습니다."
        return
    end

    local targetCharacter = selected.Character
    local targetRoot = targetCharacter
        and targetCharacter:FindFirstChild("HumanoidRootPart")

    if not targetRoot then
        status.Text = "대상 캐릭터를 찾을 수 없습니다."
        return
    end

    following = true

    followButton.Text = "추적 중지"
    followButton.BackgroundColor3 = RED

    status.Text = selected.Name .. " 추적 중..."

    if followConnection then
        followConnection:Disconnect()
    end

    followConnection = RunService.RenderStepped:Connect(function()
        if not following then
            return
        end

        if not selected or not selected.Parent then
            stopFollowing("대상이 나갔습니다.")
            return
        end

        local target = selected.Character
        local targetRoot = target
            and target:FindFirstChild("HumanoidRootPart")

        local character = LocalPlayer.Character
        local myRoot = character
            and character:FindFirstChild("HumanoidRootPart")

        if not targetRoot or not myRoot then
            stopFollowing("캐릭터를 찾을 수 없어 추적 중지")
            return
        end

        -- 대상 뒤쪽 3 스터드 위치 유지
        local destination =
            targetRoot.CFrame * CFrame.new(0, 0, 3)

        character:PivotTo(destination)
    end)
end

followButton.MouseButton1Click:Connect(function()
    if following then
        stopFollowing("추적을 중지했습니다.")
    else
        startFollowing()
    end
end)

--========================================================
-- PLAYER SELECTION
--========================================================

local function updateSelection()
    for player, button in pairs(buttons) do
        if button.Parent then
            if player == selected then
                button.BackgroundColor3 =
                    Color3.fromRGB(150, 45, 160)
            else
                button.BackgroundColor3 =
                    Color3.fromRGB(65, 35, 90)
            end
        end
    end

    if selected then
        status.Text = "선택된 플레이어: " .. selected.Name
    else
        status.Text = "선택된 플레이어: 없음"
    end
end

--========================================================
-- REFRESH PLAYER LIST
--========================================================

local function refresh()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    buttons = {}

    local currentPlayers = Players:GetPlayers()

    table.sort(currentPlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    for _, player in ipairs(currentPlayers) do
        if player ~= LocalPlayer then

            local button = Instance.new("TextButton")
            button.Name = player.Name
            button.Size = UDim2.new(1, 0, 0, 38)
            button.BackgroundColor3 =
                Color3.fromRGB(65, 35, 90)
            button.BorderSizePixel = 0
            button.Text = "  " .. player.Name
            button.TextColor3 = WHITE
            button.TextSize = 13
            button.Font = Enum.Font.GothamBold
            button.TextXAlignment = Enum.TextXAlignment.Left
            button.Parent = list

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 7)
            bc.Parent = button

            buttons[player] = button

            button.MouseButton1Click:Connect(function()

                if selected ~= player and following then
                    stopFollowing("대상이 변경되어 추적 중지")
                end

                selected = player
                updateSelection()
            end)
        end
    end

    if selected and not selected.Parent then
        selected = nil

        if following then
            stopFollowing("대상이 나갔습니다.")
        end
    end

    updateSelection()
end

--========================================================
-- ONE-TIME TELEPORT
--========================================================

teleport.MouseButton1Click:Connect(function()
    if not selected then
        status.Text = "플레이어를 먼저 선택하세요!"
        return
    end

    local targetCharacter = selected.Character
    local character = LocalPlayer.Character

    if not targetCharacter or not character then
        status.Text = "캐릭터를 찾을 수 없습니다."
        return
    end

    local targetRoot =
        targetCharacter:FindFirstChild("HumanoidRootPart")

    if targetRoot then
        character:PivotTo(
            targetRoot.CFrame * CFrame.new(0, 0, 3)
        )

        status.Text = selected.Name .. " 에게 이동 완료!"
    else
        status.Text = "대상 위치를 찾을 수 없습니다."
    end
end)

--========================================================
-- MINIMIZE / RESTORE
--========================================================

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        -- 제목 표시줄만 남김
        content.Visible = false
        frame.Size = UDim2.fromOffset(290, 48)
        minimize.Text = "+"
    else
        -- 전체 창 복구
        content.Visible = true
        frame.Size = UDim2.fromOffset(290, 390)
        minimize.Text = "−"
    end
end)

--========================================================
-- DRAG SYSTEM
--========================================================

local dragging = false
local dragInput
local dragStart
local startPosition

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--========================================================
-- PLAYER EVENTS
--========================================================

Players.PlayerAdded:Connect(refresh)

Players.PlayerRemoving:Connect(function(player)
    if selected == player then
        if following then
            stopFollowing("대상이 나갔습니다.")
        end

        selected = nil
    end

    refresh()
end)

--========================================================
-- CLOSE / CLEANUP
--========================================================

close.MouseButton1Click:Connect(function()
    stopFollowing()

    gui:Destroy()
end)

--========================================================
-- INITIALIZE
--========================================================

refresh()

print("[KINGHYUNWOO] TELEPORT GUI LOADED")
