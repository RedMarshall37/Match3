local crystal = require("crystal")
---@class GameModel 
GameModel = {}
function GameModel:new()
    local private = {}
        private.board = {}
        private.size = 10
        private.colors = {"A", "B", "C", "D", "E", "F"} -- Возможные цвета кристаллов

        --- проверка на корректность координат для перемещения
        --- @param old_coordinate integer текущая координата x или y кристалла
        --- @param new_oordinate integer новая координата x или y кристалла
        --- @return boolean #true в случае корректности, #false в случае ошибки
        function private:coordinates_validation(old_coordinate, new_oordinate)
            if math.abs(old_coordinate-new_oordinate)>1 or
            new_oordinate > private.size or
            new_oordinate < 1 or
            old_coordinate > private.size or
            old_coordinate < 1 then
                return false
            else
                return true
            end
        end

        --- проврека массива на наличие последовательности одинаковых кристаллов
        --- @param crystals crystal[] одномерный массив строки/столбца кристаллов
        --- @param mark_crystals_to_remove boolean если true, метод также помечает кристаллы для удаления
        --- @return boolean #true при наличии последовательности, false в противном случае
        function private:check_array_matches(crystals, mark_crystals_to_remove)
            local has_matches = false -- переменная для проверки наличия совпадений

            for i = 1, private.size-2 do
                -- переведение цветов в одинаковый формат
                local color_1 = string.gsub(crystals[i].color, "%s", "")
                local color_2 = string.gsub(crystals[i+1].color, "%s", "")
                local color_3 = string.gsub(crystals[i+2].color, "%s", "")
                
                if color_1 == color_2 and color_1 == color_3 then
                    -- пометка кристаллов для удаления
                    if mark_crystals_to_remove == true then
                        crystals[i].to_remove = true
                        crystals[i+1].to_remove = true
                        crystals[i+2].to_remove = true
                    end
                    -- фиксация наличия совпадений и выход из метода, если нет необходимости в удалении кристаллов
                    has_matches = true
                    if mark_crystals_to_remove == false then
                        return has_matches
                    end

                    -- исследование массива на продолжнение последовательности
                    local index = i+2
                    while true do
                        if index >= private.size then
                            break;
                        end

                        index = index + 1;
                        local color_with_index = string.gsub(crystals[index].color, "%s", "")
                        if color_with_index == color_1 then
                            crystals[index].to_remove = true;
                        else
                            break;
                        end
                    end
                end
            end
            return has_matches
        end

        --- проверка наличия последовательностей одинаковых кристаллов во всем массиве
        --- @return boolean #true при наличии последовательности, false в противном случае
        function private:check_matches()
            local has_matches = false
            -- проверка строк
            for i = 1, private.size do
                if private:check_array_matches(private.board[i], false) then
                    return true
                end
            end

                -- проверка столбцов
                for j = 1, private.size do
                    local column = {}
                    for i = 1, private.size do
                        table.insert(column, private.board[i][j])
                    end
                    if private:check_array_matches(column, false) then
                        return true
                    end
                end

            return has_matches
        end

        --- проверка на наличие последовательности одинаковых кристаллов после перемещения
        --- @param x1 integer координата x, на которой находился кристалл
        --- @param y1 integer координата y, на которой находился кристалл
        --- @param x2 integer координата x, куда перемещается кристалл
        --- @param y2 integer координата y, куда перемешается кристалл
        --- @return boolean #true, если после перемещения есть последовательности кристаллов, false в противном
        function private:has_matches_after_swap(x1, y1, x2, y2)
            -- передвижение кристаллов
            private.board[y1][x1], private.board[y2][x2] = private.board[y2][x2], private.board[y1][x1]

            -- проверка строк на наличие последовательности
            local match_found = private:check_array_matches(private.board[y1], false)
            if not match_found then 
                match_found = private:check_array_matches(private.board[y2], false)
            end
            -- проверка столбцов на наличие последовательности
            if not match_found then
                local column_x1 = {}
                local column_x2 = {}
                for i = 1, private.size do
                    table.insert(column_x1, private.board[i][x1])
                    table.insert(column_x2, private.board[i][x2])
                end
                match_found = private:check_array_matches(column_x1, false)
                if not match_found then
                    match_found = private:check_array_matches(column_x2, false)
                end
            end

            -- возвращение кристаллов обратно
            private.board[y1][x1], private.board[y2][x2] = private.board[y2][x2], private.board[y1][x1]
            return match_found
        end

        --- проверка наличия возможных ходов
        --- @return boolean #true, если есть возможные ходы, false в противном случае
        function private:check_possible_turns()
            -- проверка возможных ходов для каждой ячейки
            for y = 1, private.size do
                for x = 1, private.size do
                    -- проверка хода вправо
                    if x < private.size and private:has_matches_after_swap(x, y, x + 1, y) then
                        return true
                    end
                    -- проверка хода вниз
                    if y < private.size and private:has_matches_after_swap(x, y, x, y + 1) then
                        return true 
                    end
                end
            end

            return false
        end

    local public = {}
        --- генерация и первичное перемешивание игрового поля
        function public:init()
            for i = 1, private.size do
                private.board[i] = {}
                for j = 1, private.size do
                    private.board[i][j] = crystal:new(private.colors[math.random(#private.colors)])
                end
            end
            public:mix()
        end

        --- печать игрового поля в консоль
        function public:dump()
            io.write("    ")
            for x = 0, private.size-1 do
                io.write(x .. " ") -- вывод номеров столбцов сверху
            end
            print("\n    " .. string.rep("- ", private.size))
            for i = 1, private.size do
                io.write(string.format("%d", i-1) .. " | ") -- вывод номера строки слева
                for j = 1, private.size do
                    io.write(private.board[i][j].color .. " ") -- вывод цвета каждого кристалла в строке
                end
                print()
            end
        end

       --- обработка перемещения кристалла. 
       --- @param from {x:integer, y:integer} координаты ячейки, из которой перемещается кристалл
       --- @param to {x:integer, y:integer} координаты ячейкм, в которую перемешается кристалл
       --- @return integer 0 при успешном перемещении, 1 при невозможности получить комбинацию при перемещении, 2 при неправильных координатах
        function public:move(from, to)
            local from_x, from_y, to_x, to_y = from.x, from.y, to.x, to.y
            if private:coordinates_validation(from_x, to_x) and private:coordinates_validation(from_y, to_y) then -- проверка корректности координат
                if private:has_matches_after_swap(from_x, from_y, to_x, to_y) then
                    private.board[from_y][from_x], private.board[to_y][to_x] = private.board[to_y][to_x], private.board[from_y][from_x] -- перемещение кристаллов
                    return 0
                else
                    return 1 -- комбинацию получить невозможно
                end
            else
                return 2 -- введены некорректные данные
            end
        end

        --- проверка и удаление повторяющихся последовательностей, обработка падения кристаллов
        --- @return boolean #true при наличии изменений, #false при отсутствии изменений
        function public:tick()
            local removed = false
            -- проверка строк
            for i = 1, private.size do
                private:check_array_matches(private.board[i], true) 
            end
            -- проверка столбцов
            for j = 1, private.size do
                local column = {}
                for i = 1, private.size do
                    table.insert(column, private.board[i][j]) -- сборка столбца
                end
                private:check_array_matches(column, true) -- проверка столбца
            end

            -- удаление отмеченных кристаллов и "падение" оставшиеся вниз
            for j = 1, private.size do
                local empty_slots = 0 -- счетчик пустых ячеек в столбце
      
                -- обработка столбца снизу вверх
                for i = private.size, 1, -1 do
                    if private.board[i][j].to_remove then
                        removed = true
                        empty_slots = empty_slots + 1
                        private.board[i][j] = nil
                    elseif empty_slots > 0 then
                        -- сдвиг кристалла вниз на количество пустых ячеек
                        private.board[i + empty_slots][j] = private.board[i][j]
                        private.board[i][j] = nil
                    end
                end
        
                -- заполнение верхних пустых ячеек новыми кристаллами
                for i = 1, empty_slots do
                    private.board[i][j] = crystal:new(private.colors[math.random(#private.colors)])
                end
            end
        
            -- сброс флаги `to_remove` у всех кристаллов
            for i = 1, private.size do
                for j = 1, private.size do
                    private.board[i][j].to_remove = false
                end
            end
        
            return removed
        end

        --- перемешивание поля
        function public:mix()
            local mixed = false
            local flat_board = {} -- временный массив для записи всех элементов на поле

            for i = 1, private.size do
                for j = 1, private.size do
                    table.insert(flat_board, private.board[i][j])
                end
            end

            local function isSafeToPlace(x, y, color)
                -- Проверка, не создаст ли этот цвет тройку в строке или столбце
                return not ((x > 2 and string.gsub(private.board[y][x-1].color, "%s", "") == color and string.gsub(private.board[y][x-2].color, "%s", "") == color) or
                            (y > 2 and string.gsub(private.board[y-1][x].color, "%s", "") == color and string.gsub(private.board[y-2][x].color, "%s", "") == color))
            end

            while private:check_matches() == true or private:check_possible_turns() == false do -- цикл выполняется до тех пор, пока на поле есть последовательности одинаковых кристаллов или нет возможных ходов
                mixed = true
                for x = 1, private.size do
                    for y = 1, private.size do
                        local randomIndex
                        repeat
                                randomIndex = math.random(1, #flat_board)
                        until isSafeToPlace(x, y, flat_board[randomIndex].color)
                        private.board[y][x] = flat_board[randomIndex];
                        table.remove(flat_board, randomIndex)
                    end
                end
            end
        
            return mixed
        end
        

    setmetatable(public,self)
    self.__index = self;
    return public
end
return GameModel
