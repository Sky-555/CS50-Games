GameLevel = Class{}

function GameLevel:init(entities, objects, tilemap)
    self.entities = entities
    self.objects = objects
    self.tileMap = tilemap
end

function GameLevel:clear()
    for i = #self.entities, 1, -1 do
        if not self.entities[i] then
            table.remove(self.entities, i)
        end
    end

    for k, object in pairs(self.objects) do
        for i = #object, 1, -1 do
            if not object[i] then
                table.remove(object, i)
            end
        end
    end
end

function GameLevel:update(dt)
    for k, entity in pairs(self.entities) do
        entity:update(dt)
    end
end

function GameLevel:render()
    self.tileMap:render()

    for k, type in pairs(self.objects) do
        for k, object in pairs(type) do
            object:render()
        end
    end

    for k, entity in pairs(self.entities) do
        entity:render()
    end
end