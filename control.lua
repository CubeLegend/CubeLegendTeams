local MainGui = require("MainGui")
local SelectTeamGui = require("SelectTeamGui")

global.guis = {} ---@type table<int, LuaGuiElement>
global.dynamicGuiElements = {} ---@type table<int, LuaGuiElement[]>
global.selectTeamGuis = {} ---@type table<int, LuaGuiElement>
global.teams = {} ---@type LuaForce[]

script.on_event(defines.events.on_player_created, function (event)
    local player = game.get_player(event.player_index)
    ---@cast player -?

    global.selectTeamGuis[player.index] = SelectTeamGui.buildFrame(player.gui.center, "Team Auswahl", player.index)
end)

function on_gui_click_MainGui(event)
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
end

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
---script.on_event(defines.events.on_cutscene_cancelled, afterCutscene)
---script.on_event(defines.events.on_cutscene_finished, afterCutscene)

script.on_event("clt_toggle_maingui", function (event)
    player = game.get_player(event.player_index)
    gui = global.guis[event.player_index] ---@type LuaGuiElement
    gui.visible = not gui.visible
end)

local function deleteEmptyTeams()
    for _, team in pairs(global.teams) do
        if table_size(team.players) <= 0 then
            game.merge_forces(team, game.forces.player)
        end
    end
end

function on_gui_click_SelectTeamGui(event)
    player = game.get_player(event.player_index)
    element = event.element
    if player.controller_type == defines.controllers.cutscene then
        return
    end

    if element.name == "clt_join_team" then
        teamToJoin = game.forces[element.parent.clt_team_name.caption]
        player.force = teamToJoin
        deleteEmptyTeams()
        global.selectTeamGuis[player.index].destroy()
        global.selectTeamGuis[player.index] = nil

    elseif element.name == "clt_create_team" then
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

        if global.guis[player.index] ~= nil then
            global.guis[player.index].destroy()
            global.guis[player.index] = nil
        end
        gui = MainGui.buildFrame(player.gui.screen, "Teams", newTeam, event.player_index)
        gui.visible = false
        global.guis[player.index] = gui
        deleteEmptyTeams()
        global.selectTeamGuis[player.index].destroy()
        global.selectTeamGuis[player.index] = nil
    end
end

script.on_event(defines.events.on_gui_click, function (event)
    on_gui_click_MainGui(event)
    on_gui_click_SelectTeamGui(event)
end)
