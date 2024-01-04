---@class MainGui
---@field parent LuaGuiElement
---@field name string
---@field raw LuaGuiElement
---@field dynamicElements LuaGuiElement[]
MainGui = {}
MainGui.__index=MainGui

---@private
function buildButton(parent, name, caption)
    return parent.add{
        type="button",
        auto_toggle=true,
        tags={action="clt_button"},
        name=name,
        caption=caption
    }
end

---@private
function MainGui:buildFrame()
    frame = self.parent.add{
        type = "frame",
        name = self.name,
        direction = "vertical",
        caption = "Teams"
    }

    frame.auto_center = true
    frame.style.maximal_height = 250
    frame.style.minimal_width = 50

    local scrollPane = frame.add({type="scroll-pane", name="content_frame", direction="vertical"})
    scrollPane.horizontal_scroll_policy = "never"

    for _, team in pairs(global.teams) do
        local subpanelFrame = scrollPane.add{type="frame", direction="horizontal",style="subpanel_frame"}
        subpanelFrame.style.horizontally_stretchable = true
        subpanelFrame.add{type="label", name="clt_team_name", caption=team.name}

        table.insert(self.dynamicElements, buildButton(subpanelFrame, "clt_enemy", "Feind"))
        table.insert(self.dynamicElements, buildButton(subpanelFrame, "clt_friend", "Freund"))
    end

    self.raw = frame
end

---create a new MainGui
---@param parent LuaGuiElement
---@param name string
---@return MainGui
function MainGui.new(parent, name)
    local instance = setmetatable({}, MainGui)
    instance.parent = parent
    instance.name = name
    instance.dynamicElements = {}
    instance:buildFrame()
    return instance
end

---@param player LuaPlayer
---@return Team?
local function getTeamOfPlayer(player)
    for _, team in ipairs(global.teams) do
        if team:containsPlayer(player) then
            return team
        end
    end
    return nil
end

local function getTeam(teamName)
    for _, team in pairs(global.teams) do
        if team.name == teamName then
            return team
        end
    end
end

script.on_event(defines.events.on_gui_click, function (event)
    player = game.get_player(event.player_index)
    ---@cast player -?
    if event.element.name == "clt_enemy" then
        team = getTeamOfPlayer(player)
        if team == nil then return end
        if event.element.toggled then
            otherTeamName = event.element.parent.clt_team_name
            player.print("Hi")
            --for _, gui in pairs(global.guis.otherTeamName) do
             --   gui.dynamicElements.clt_enemy = event.element.toggled
           -- end
        end
    end
end)