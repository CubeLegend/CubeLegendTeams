---@class TeamCreationGui
local TeamCreationGui = {}

---@param parent LuaGuiElement
---@param name string
---@return LuaGuiElement
function TeamCreationGui.buildFrame(parent, name)
    local frame = parent.add{
        type = "frame",
        name = name,
        caption = "Dialog Window",
        direction = "vertical",
        style = "frame"
    }

    -- Add a text input
    local textInput = frame.add{
        type = "textfield",
        name = "textInput",
    }

    local flow = frame.add{
        type = "flow",
        name = "dialogButtons",
        direction = "horizontal"
    }

    -- Add a back button
    local backButton = flow.add{
        type = "button",
        name = "createTeamBackButton",
        caption = "Zurück",
        style = "back_button"
    }

    -- Add a confirm button
    local confirmButton = flow.add{
        type = "button",
        name = "createTeamConfirmButton",
        caption = "Team erstellen",
        style = "confirm_button"
    }

    textInput.style.horizontally_stretchable = true

    -- Register on_gui_click events for button actions
    confirmButton.mouse_button_filter = {"left"}
    confirmButton.tooltip = "Confirm the input"

    backButton.mouse_button_filter = {"left"}
    backButton.tooltip = "Go back"
    return frame
end

return TeamCreationGui
