require("MainGui")
require("Team")

---@type table<string, table<int, MainGui>>
global.guis = {}

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
    local newTeamNumber = tostring(tablelength(existingTeams) + 1)
    local newTeam = Team.new("Team"..newTeamNumber)
    newTeam:addPlayer(player)

    gui = MainGui.new(player.gui.screen, "Teams")
    if global.guis[newTeam.name] == nil then
        global.guis[newTeam.name] = {}
    end
    global.guis[newTeam.name][player.index] = gui
end)
