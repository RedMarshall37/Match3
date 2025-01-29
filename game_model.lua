local crystal = require("crystal")

GameModel = {}
function GameModel:new()
    local private = {}
        private.board = {}
        private.size = 10
        private.colors = {"A", "B", "C", "D", "E", "F"} -- Возможные цвета кристаллов

        -- проверка на корректность координат для перемещения
        function private:coordinates_validation(old_coordinate, new_oordinate)
            if math.abs(old_coordinate-new_oordinate)>1 or
            new_oordinate > private.size or
            new_oordinate < 1 or
            old_coordinate > private.size or
            old_coordinate < 1 then
                return false --возвращаем false, если данные некорректны
            else
                return true --если все хорошо, возвращаем true
            end
        end

        -- пометка последовательностей кристаллов для удаления
        function private:check_row_matches(crystals, mark_crystals_to_remove)
            local has_matches = false --нашли ли последовательности кристаллов

            for i = 1, private.size-2 do
                local color_1 = string.gsub(crystals[i].color, "%s", "")
                local color_2 = string.gsub(crystals[i+1].color, "%s", "")
                local color_3 = string.gsub(crystals[i+2].color, "%s", "")

                if color_1 == color_2 and color_1 == color_3 then
                    if mark_crystals_to_remove == true then
                        crystals[i].to_remove = true
                        crystals[i+1].to_remove = true
                        crystals[i+2].to_remove = true
                    end
                    has_matches = true
                    if mark_crystals_to_remove == false then
                        return true
                    end
                    local index = i+2
                    while true do
                        -- Если индекс вышел за пределы массива, или уже отработал на последнем элементе, выходим
                        if index >= private.size then
                            break;
                        end

                        -- Иначе увеличиваем индекс и сравниваем следующий элемент с первым. Если у них один цвет, помечаем его как поддежащий удалению
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
            return has_matches  --возвращаем, нашли ли последовательности кристаллов
        end

        -- проверка наличия последовательностей кристаллов
        function private:check_matches()
            local has_matches = false
            -- Проверяем строки
            for i = 1, private.size do
                if private:check_row_matches(private.board[i], false) then
                    return true
                end
            end

                -- Проверяем столбцы
                for j = 1, private.size do
                    local column = {}
                    for i = 1, private.size do
                        table.insert(column, private.board[i][j])
                    end
                    if private:check_row_matches(column, false) then
                        return true
                    end
                end

            return has_matches
        end

        function private:has_matches_after_swap(x1, y1, x2, y2)
            -- Меняем два кристалла местами
            private.board[y1][x1], private.board[y2][x2] = private.board[y2][x2], private.board[y1][x1]

            -- Проверяем строки и столбцы на наличие троек
            local match_found = false
            match_found = private:check_row_matches(private.board[y1], false)
            if not match_found then match_found = private:check_row_matches(private.board[y2], false) end

            if not match_found then
                local column_x1 = {}
                local column_x2 = {}
                for i = 1, private.size do
                    table.insert(column_x1, private.board[i][x1])
                    table.insert(column_x2, private.board[i][x2])
                end
                match_found = private:check_row_matches(column_x1, false)
                if not match_found then
                    match_found = private:check_row_matches(column_x2, false)
                end
            end

            -- Меняем кристаллы обратно
            private.board[y1][x1], private.board[y2][x2] = private.board[y2][x2], private.board[y1][x1]
            return match_found
        end

        -- проверка наличия возможных ходов
        function private:check_possible_turns()
            -- Проверяем каждую ячейку и возможные ходы
            for y = 1, private.size do
                for x = 1, private.size do
                    -- Проверяем вправо
                    if x < private.size and private:has_matches_after_swap(x, y, x + 1, y) then
                        return true -- Найден возможный ход
                    end
                    -- Проверяем вниз
                    if y < private.size and private:has_matches_after_swap(x, y, x, y + 1) then
                        return true -- Найден возможный ход
                    end
                end
            end

            return false -- Ходов не осталось
        end

    local public = {}
        -- инициализация игрового поля
        function public:init()
            for i = 1, private.size do
                private.board[i] = {}
                for j = 1, private.size do
                    private.board[i][j] = crystal:new(private.colors[math.random(#private.colors)])
                end
            end
            public:mix()
        end

        -- вывод игрового поля
        function public:dump()
            io.write("    ")
            for x = 0, private.size-1 do
                io.write(x .. " ") -- Выводим номера столбцов сверху
            end
            print("\n    " .. string.rep("- ", private.size)) -- Отделяем заголовок горизонтальной линией
            for i = 1, private.size do
                io.write(string.format("%d", i-1) .. " | ") -- Выводим номер строки слева
                for j = 1, private.size do
                    io.write(private.board[i][j].color .. " ") -- Выводим цвет каждого кристалла в строке
                end
                print() -- Переход на новую строку после вывода всей строки
            end
        end

       -- обработка перемещения кристалла. 
       -- в случае успеха функция возвразает 0
       -- если в результате перемещения не образуется комбинация - 1
       -- если координаты переданы неправильно - 2
        function public:move(from, to)
            local from_x, from_y, to_x, to_y = from.x, from.y, to.x, to.y
            if private:coordinates_validation(from_x, to_x) and private:coordinates_validation(from_y, to_y) then -- проверяем корректность координат
                if private:has_matches_after_swap(from_x, from_y, to_x, to_y) then
                    private.board[from_y][from_x], private.board[to_y][to_x] = private.board[to_y][to_x], private.board[from_y][from_x] -- меняем элементы местами
                    return 0
                else
                    return 1
                end
            else
                return 2
            end
        end

        -- проверка и удаление троек, обработка падения кристаллов
        function public:tick()
            local removed = false

            -- Помечаем все кристаллы, которые должны быть удалены
            for i = 1, private.size do
                private:check_row_matches(private.board[i], true) -- Проверяем строки
            end
            for j = 1, private.size do
                local column = {}
                for i = 1, private.size do
                    table.insert(column, private.board[i][j]) -- Собираем столбец
                end
                private:check_row_matches(column, true) -- Проверяем столбцы
            end

            -- Удаляем помеченные кристаллы и сдвигаем оставшиеся вниз
            for j = 1, private.size do
                local empty_slots = 0 -- Счетчик пустых ячеек в столбце
      
                -- Обрабатываем столбец снизу вверх
                for i = private.size, 1, -1 do
                    if private.board[i][j].to_remove then
                        removed = true -- Если нашли кристалл для удаления, отмечаем, что произошло изменение
                        empty_slots = empty_slots + 1
                        private.board[i][j] = nil -- Удаляем кристалл
                    elseif empty_slots > 0 then
                        -- Сдвигаем кристалл вниз на количество пустых ячеек
                        private.board[i + empty_slots][j] = private.board[i][j]
                        private.board[i][j] = nil
                    end
                end
        
                -- Шаг 3: Заполняем верхние пустые ячейки новыми кристаллами
                for i = 1, empty_slots do
                    private.board[i][j] = crystal:new(private.colors[math.random(#private.colors)])
                end
            end
        
            -- Сбрасываем флаги `to_remove` у всех кристаллов
            for i = 1, private.size do
                for j = 1, private.size do
                    private.board[i][j].to_remove = false
                end
            end
        
            return removed -- Возвращаем true, если были изменения
        end

        -- перемешивание поля, пока не появятся возможные ходы
        function public:mix()
            local mixed = false
            local flat_board = {}

            for i = 1, private.size do
                for j = 1, private.size do
                    table.insert(flat_board, private.board[i][j])
                end
            end

            while private:check_matches() == true or private:check_possible_turns() == false do
                -- Убираем пометки "to_remove"
                for i = 1, private.size do
                    for j = 1, private.size do
                        private.board[i][j].to_remove = false
                    end
                end

                mixed = true

                -- Перемешиваем массив
                for i = #flat_board, 2, -1 do
                    local j = math.random(i)
                    flat_board[i], flat_board[j] = flat_board[j], flat_board[i]
                end

                -- Заполняем поле заново
                local index = 1
                for i = 1, private.size do
                    for j = 1, private.size do
                        private.board[i][j] = flat_board[index]
                        index = index + 1
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
