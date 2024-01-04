---@type Team[]
global.teams = {}

---@class Team
---@field name string
---@field raw LuaForce
Team = {}
Team.__index = Team

---create a new Team
---@param name string
---@return Team
function Team.new(name)
    instance = setmetatable({}, Team)
    instance.name = name
    instance.raw = game.create_force(name)
    instance.guis = {}
    table.insert(global.teams, instance)
    return instance
end

---@param player LuaPlayer
function Team:addPlayer(player)
    player.force = self.raw
end

---@param player LuaPlayer
---@return boolean
function Team:containsPlayer(player)
    return player.force == self.raw
end

---@param otherTeam Team | LuaForce
---@param isFriend boolean
function Team:setFriend(otherTeam, isFriend)
    otherForce = otherTeam
    if otherForce.raw ~= nil then
        otherForce = otherForce.raw
    end
    self.raw.set_friend(otherForce, isFriend)
end

---@param otherTeam Team | LuaForce
---@param isCeaseFire boolean
function Team:setCeaseFire(otherTeam, isCeaseFire)
    otherForce = otherTeam
    if otherForce.raw ~= nil then
        otherForce = otherForce.raw
    end
    self.raw.set_cease_fire(otherForce, isCeaseFire)
end