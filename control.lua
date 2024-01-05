local MainGui = require("MainGui")

global.guis = {} ---@type table<int, LuaGuiElement>
global.dynamicGuiElements = {} ---@type table<int, LuaGuiElement[]>
global.teamPanel = {} ---@type table<int, LuaGuiElement[]>
global.teams = {} ---@type LuaForce[]

local function tablelength(T)
    local count = 0
    if T == nil then
        return count
    end
    for _ in pairs(T) do count = count + 1 end
    return count
end

script.on_event(defines.events.on_player_created, function (event)
    local player = game.get_player(event.player_index)
    ---@cast player -?

    local existingTeams = global.teams
    local newTeamNumber = tostring(table_size(existingTeams) + 1)
    local newTeam = game.create_force("Team"..newTeamNumber)
    global.teams[newTeam.index] = newTeam

    --- set initial relations to other teams
    for _, team in pairs(global.teams) do
        newTeam.set_cease_fire(team, true)
        newTeam.set_friend(team, false)
        team.set_cease_fire(newTeam, true)
        team.set_friend(newTeam, false)
    end

    player.print(player.force.name)
    player.force = newTeam
    player.print(player.force.name)

    --- rebuild guis
    for playerIndex, gui in pairs(global.guis) do
        gui.destroy()
        local playerWithGui = game.get_player(playerIndex)
        ---@cast playerWithGui -?
        local force = player.force
        ---@cast force LuaForce
        gui = MainGui.buildFrame(playerWithGui.gui.screen, "Teams", force, playerIndex)
        global.guis[playerIndex] = gui
    end

    gui = MainGui.buildFrame(player.gui.screen, "Teams", newTeam, event.player_index)
    global.guis[player.index] = gui
end)

script.on_event(defines.events.on_gui_click, function (event)
    player = game.get_player(event.player_index)
    ---@cast player -?
    if event.element.name == "clt_enemy" then
        team = player.force
        otherTeamName = event.element.parent.clt_team_name.caption
        ---@cast otherTeamName string
        player.print(otherTeamName)
        player.print(event.element.toggled)
        team.set_cease_fire(otherTeamName, (not event.element.toggled))
        player.print(team.get_cease_fire(otherTeamName))
        MainGui.updateDynamicElements(team.players)
    end
end)

function afterCutscene(event)
    for _, player in pairs(game.forces.player.players) do
        player.force = global.teams[4]
    end
    for i = 1, 4 do
        local existingTeams = global.teams
        local newTeamNumber = tostring(table_size(existingTeams) + 1)
        local newTeam = game.create_force("Team"..newTeamNumber)
        global.teams[newTeam.index] = newTeam
    end
    --- rebuild guis
    for playerIndex, gui in pairs(global.guis) do
        gui.destroy()
        local playerWithGui = game.get_player(playerIndex)
        ---@cast playerWithGui -?
        local force = player.force
        ---@cast force LuaForce
        gui = MainGui.buildFrame(playerWithGui.gui.screen, "Teams", force, playerIndex)
        global.guis[playerIndex] = gui
    end
end
script.on_event(defines.events.on_cutscene_cancelled, afterCutscene)
script.on_event(defines.events.on_cutscene_finished, afterCutscene)

script.on_event("clt_toggle_maingui", function (event)
    player = game.get_player(event.player_index)
    gui = global.guis[event.player_index] ---@type LuaGuiElement
    gui.visible = not gui.visible
end)
