
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

    -- 모든 퀘스트의 요구 레벨을 검사
    for _, button in ipairs(buttons) do
        if not Enabled then
            return false, "중지됨"
        end

        ClickButton(button)
        task.wait(0.45)

        local required = ReadRequiredLevel()

        if required
        and required <= level
        and required > bestRequired then
            bestRequired = required
            bestButton = button
        end

        local back = FindButton("Return")

        if back then
            ClickButton(back)
            task.wait(0.35)
        end
    end

    if not bestButton then
        return false, "레벨에 맞는 퀘스트가 없습니다"
    end

    -- 가장 높은 요구 레벨의 퀘스트를 다시 선택
    ClickButton(bestButton)
    task.wait(0.45)

    local required = ReadRequiredLevel()

    if required and required == bestRequired and required <= level then
        local confirm = FindButton("Confirm")

        if confirm then
            ClickButton(confirm)
            task.wait(0.5)

            return true,
                "퀘스트 수락 완료 (" .. bestRequired .. "+)"
        end
    end

    return false, "퀘스트 재확인 실패"
end
