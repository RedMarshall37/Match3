require "game_model"

GameView = {}
function GameView:new()
    local private = {}
        private.gameModel = GameModel:new()

        function private:calculateNewCoords(x, y, direction)
            local newX, newY
            if direction == "r" then
                newX = x+1
                newY = y
            elseif direction == "l" then
                newX = x-1
                newY = y
            elseif direction == "u" then
                newX = x
                newY = y-1
            elseif direction == "d" then
                newX = x
                newY = y+1
            end
            return newX, newY
        end

        function private:processTick()
            local removed = true
            while true do
                removed = private.gameModel:tick()
                if removed == true then
                    private.gameModel:dump()
                else
                    break
                end
            end
        end
    local public = {}
        function public:run()
            private.gameModel:init()
            private.gameModel:dump()
            while true do
                    io.write("> ")
                    local input = io.read()
                    if input == "q" then
                        print("Thanks for playing!")
                        break
                    end
  
                    local x, y, direction = input:match("m (%d) (%d) ([lrud])")
                    if x and y and direction then
                        x, y = tonumber(x+1), tonumber(y+1)
                        local newX, newY = private:calculateNewCoords(x,y,direction)

                        local moveResult = private.gameModel:move({x=x, y=y}, {x=newX, y=newY})
                        if moveResult == 1 then
                            print("The changes will not result in a combination")
                        elseif moveResult ==2  then
                            print("Error:going outside the board")
                        end 
 
                        private:processTick()

                        if private.gameModel:mix() then
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