---@class events
---@field listeners table<string, function[]>
events = {
    listeners = {}
}

local function executeHandlers(event)
    for _, handler in ipairs(events.listeners[event.name]) do
        handler(event)
    end
end

---@param eventName defines.events
---@param handler function
function events.addHandler(eventName, handler)
    if events.listeners[eventName] == nil then
        events.listeners[eventName] = {}
        script.on_event(eventName, executeHandlers)
    end
    table.insert(events.listeners[eventName], handler)
end
