require "game_model"

---@class GameView 
GameView = {}
function GameView:new()
    local private = {}
        private.GameModel = GameModel:new()

        ---высчитывание новых координат кристалла на основе его текущих координат и направления
        ---@param x integer текущая x-координата кристалла
        ---@param y integer текущая y-координата кристалла
        ---@param direction string направление движения кристалла (l-left, r-right, u-up, d-down)
        ---@return integer, integer #новая x-координата кристалла, новая y-координата кристалла
        function private:calculate_new_coords(x, y, direction)
            local new_x, new_y
            if direction == "r" then
                new_x = x+1
                new_y = y
            elseif direction == "l" then
                new_x = x-1
                new_y = y
            elseif direction == "u" then
                new_x = x
                new_y = y-1
            elseif direction == "d" then
                new_x = x
                new_y = y+1
            end
            return new_x, new_y
        end

        --- обработка метода tick модели и вывод на экран обновленного поля
        function private:processTick()
            local removed = true
            while true do
                removed = private.GameModel:tick()
                if removed == true then
                    private.GameModel:dump()
                else
                    break
                end
            end
        end

    local public = {}
        function public:run()
            -- первичная иницализация и вывод
            private.GameModel:init()
            private.GameModel:dump()
            while true do
                    io.write("> ")
                    local input = io.read()
                    if input == "q" then
                        print("Thanks for playing!")
                        break
                    end

                    -- проверка на валидность введеной команды
                    local x, y, direction = input:match("m (%d) (%d) ([lrud])")
                    if x and y and direction then
                        x, y = tonumber(x+1), tonumber(y+1)
                        local newX, newY = private:calculate_new_coords(x,y, direction)

                        local move_result = private.GameModel:move({x=x, y=y}, {x=newX, y=newY})
                        if move_result == 1 then
                            print("The changes will not result in a combination")
                        elseif move_result ==2  then
                            print("Error:going outside the board")
                        end
 
                        private:processTick()

                        if private.GameModel:mix() then
                            print("There are no possible moves. Shuffle the board...")
                        end
                    else
                        print("Wrong command. Format: m x y d or q for output.")
                    end
            end
        end
        setmetatable(public,self)
        self.__index = self;
        return public
end

local gameView = GameView:new()
gameView:run()