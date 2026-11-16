
local minimized = false

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        frame.Size = UDim2.fromOffset(290, 48)

        subtitle.Visible = false
        list.Visible = false
        teleport.Visible = false
        followButton.Visible = false
        status.Visible = false

        minimize.Text = "+"
    else
        frame.Size = UDim2.fromOffset(290, 390)

        subtitle.Visible = true
        list.Visible = true
        teleport.Visible = true
        followButton.Visible = true
        status.Visible = true

        minimize.Text = "−"
    end
end)
