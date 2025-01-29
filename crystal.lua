---@class Crystal
local Crystal = {}
Crystal.__index = Crystal

--- класс кристалла
--- @param color string Цвет кристалла
--- @return table
function Crystal:new(color)
    return setmetatable({ color = color, to_remove = false }, self)
end

return Crystal