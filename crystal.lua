local Crystal = {}
Crystal.__index = Crystal

-- @param color Цвет кристалла
function Crystal:new(color)
    return setmetatable({ color = color, to_remove = false }, self)
end

return Crystal