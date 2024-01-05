local MainGui = require("MainGui")
local SelectTeamGui = require("SelectTeamGui")
local TeamCreationGui = require("TeamCreationGui")

require("trading")

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
    if not event.element.valid then
        return
    end
    if event.element.name == "clt_enemy" then
        team = player.force
        otherTeamName = event.element.parent.clt_team_name.caption
        ---@cast otherTeamName string
        team.set_cease_fire(otherTeamName, (not event.element.toggled))
        MainGui.updateDynamicElements(game.forces[otherTeamName].players)
        MainGui.updateDynamicElements(team.players)
    end
end

script.on_event("clt_toggle_maingui", function (event)
    player = game.get_player(event.player_index)
    gui = global.guis[event.player_index] ---@type LuaGuiElement
    if gui ~= nil then
        gui.visible = not gui.visible
    end
end)

local function deleteEmptyTeams()
    for _, team in pairs(global.teams) do
        if table_size(team.players) <= 0 then
            global.teams[team.index] = nil
            game.merge_forces(team, game.forces.player)
        end
    end
end

local function rebuildGuis(player, newTeam)
    for playerIndex, element in pairs(global.dynamicGuiElements) do
        global.dynamicGuiElements[playerIndex] = nil
    end

    for playerIndex, gui in pairs(global.guis) do
        visibility = gui.visible
        gui.destroy()
        local playerWithGui = game.get_player(playerIndex)
        ---@cast playerWithGui -?
        local force = player.force
        ---@cast force LuaForce
        gui = MainGui.buildFrame(playerWithGui.gui.screen, "Teams", force, playerIndex)
        gui.visible = visibility
        global.guis[playerIndex] = gui
    end

    if global.guis[player.index] ~= nil then
        global.guis[player.index].destroy()
        global.guis[player.index] = nil
    end
    gui = MainGui.buildFrame(player.gui.screen, "Teams", newTeam, player.index)
    gui.visible = false
    global.guis[player.index] = gui
end

function on_gui_click_SelectTeamGui(event)
    player = game.get_player(event.player_index)
    element = event.element
    if not element.valid then
        return
    end
    if player.controller_type == defines.controllers.cutscene then
        return
    end

    if element.name == "clt_join_team" then
        teamToJoin = game.forces[element.parent.clt_team_name.caption]
        player.force = teamToJoin
        deleteEmptyTeams()
        rebuildGuis(player, teamToJoin)
        global.selectTeamGuis[player.index].destroy()
        global.selectTeamGuis[player.index] = nil

    elseif element.name == "clt_create_team" then
        global.selectTeamGuis[player.index].visible = false
        TeamCreationGui.buildFrame(player.gui.center, "Wähle einen Team Namen")
    end
end

local function doesForceExist(name)
    for _, team in pairs(game.forces) do
        if team.name == name then
            return true
        end
    end
    return false
end

local function createTeam(name, player)
    local newTeam = game.create_force(name)
    global.teams[newTeam.index] = newTeam

    --- set initial relations to other teams
    for _, team in pairs(global.teams) do
        newTeam.set_cease_fire(team, true)
        newTeam.set_friend(team, false)
        team.set_cease_fire(newTeam, true)
        team.set_friend(newTeam, false)
    end

    player.force = newTeam

    deleteEmptyTeams()
    rebuildGuis(player, newTeam)
end

function on_gui_click_TeamCreationGui(event)
    player = game.get_player(event.player_index)
    element = event.element
    if not element.valid then
        return
    end
    if element.name == "createTeamConfirmButton" then
        textInput = element.parent.parent.textInput
        text = textInput.text ---@type string
        if string.len(text) <= 0 then
            return
        end
        if doesForceExist(text) then
            text = "Ein Team mit diesem Namen existiert bereits"
            textInput.select_all()
            return
        end
        createTeam(text, player)
        element.parent.parent.destroy()
        global.selectTeamGuis[player.index].destroy()
        global.selectTeamGuis[player.index] = nil

    elseif element.name == "createTeamBackButton" then
        element.parent.parent.destroy()
        global.selectTeamGuis[player.index].visible = true
    end
end

script.on_event(defines.events.on_gui_click, function (event)
    on_gui_click_MainGui(event)
    on_gui_click_SelectTeamGui(event)
    on_gui_click_TeamCreationGui(event)
end)

-- Define your custom command
commands.add_command("open_team_selection", "Allows you to open the team selection window mid game", function(command)
    local player = game.get_player(command.player_index)

    -- Check if the player is an administrator
    if player and player.admin then
        if global.selectTeamGuis[player.index] == nil then
            playerName = command.parameter
            if playerName == nil then
                global.selectTeamGuis[player.index] = SelectTeamGui.buildFrame(player.gui.center, "Team Auswahl", player.index)
                return
            end
            selectedPlayer = game.get_player(playerName)
            if selectedPlayer == nil then
                selectedPlayer.print(playerName.." doesn't exist")
            end
            global.selectTeamGuis[selectedPlayer.index] = SelectTeamGui.buildFrame(selectedPlayer.gui.center, "Team Auswahl", selectedPlayer.index)
        end
    end
end)