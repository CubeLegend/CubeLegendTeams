---@class SelectTeamGui
local SelectTeamGui = {}

---@param parent LuaGuiElement
---@param name string
---@param associatedPlayerIndex int
---@return LuaGuiElement
function SelectTeamGui.buildFrame(parent, name, associatedPlayerIndex)
    frame = parent.add{
        type = "frame",
        name = name,
        direction = "vertical",
        caption = "Teams"
    }

    frame.style.maximal_height = 250
    frame.style.minimal_width = 50

    local scrollPane = frame.add({type="scroll-pane", name="content_frame", direction="vertical"})
    scrollPane.horizontal_scroll_policy = "never"

    global.dynamicGuiElements[associatedPlayerIndex] = {}

    for _, team in pairs(global.teams) do
        ---@cast team LuaForce
        player = game.get_player(associatedPlayerIndex)
        if player.force.index == team.index then
            goto continue
        end

        local subpanelFrame = scrollPane.add{type="frame", direction="horizontal",style="subpanel_frame"}
        subpanelFrame.style.horizontally_stretchable = true
        local label = subpanelFrame.add{type="label", name="clt_team_name", caption=team.name}
        subpanelFrame.add{type="button", name="clt_join_team", caption="Join Team"}
        ::continue::
    end
    scrollPane.add{type="button", name="clt_create_team", caption="Create Team"}
    return frame
end

return SelectTeamGui
