---@class MainGui
local MainGui = {}

---@private
function buildButton(parent, name, caption, associatedTeam)
    return parent.add{
        type="button",
        auto_toggle=true,
        tags={action="clt_button"},
        name=name,
        caption=caption
    }
end

---@param parent LuaGuiElement
---@param name string
---@param associatedTeam LuaForce
---@param associatedPlayerIndex int
---@return LuaGuiElement
function MainGui.buildFrame(parent, name, associatedTeam, associatedPlayerIndex)
    frame = parent.add{
        type = "frame",
        name = name,
        direction = "vertical",
        caption = "Teams"
    }

    frame.auto_center = true
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
        if game.forces[label.caption].get_cease_fire(team) then
            green = {0, 1, 0, 1}
            label.style.font_color = green
        else
            red = {1, 0, 0, 1}
            label.style.font_color = red
        end

        table.insert(global.dynamicGuiElements[associatedPlayerIndex], buildButton(subpanelFrame, "clt_enemy", "Feind"))
        ::continue::
    end

    MainGui.updateDynamicElements({game.get_player(associatedPlayerIndex)})
    return frame
end

---@param players LuaPlayer[]
function MainGui.updateDynamicElements(players)
    for _, player in pairs(players) do
        game.print(player)
        playerTeam = game.forces[player.force_index]
        for _, element in pairs(global.dynamicGuiElements[player.index]) do
            if element.name == "clt_enemy" then
                otherTeam = game.forces[element.parent.clt_team_name.caption]
                game.print(otherTeam.index)
                element.toggled = not playerTeam.get_cease_fire(otherTeam)
            end
        end
    end
end

return MainGui
