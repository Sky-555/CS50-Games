StatsMenuState = Class{__includes = BaseState}

function StatsMenuState:init(battleState, takeTurnState)
    self.battleState = battleState
    self.takeTurnState = takeTurnState

    self.pokemon = self.battleState.player.party.pokemon[1]

    self.HPIncrease, self.attackIncrease, self.defenseIncrease, self.speedIncrease = self.takeTurnState:statsIncrease()

    self.statsMenu = Menu {
        x = 16,
        y = 16,
        width = VIRTUAL_WIDTH - 32,
        height = VIRTUAL_HEIGHT - 64,
        onCursor = false,
        items = {
            {
                text = 'Level: ' .. tostring(self.pokemon.level - 1) .. ' + 1 -> ' .. tostring(self.pokemon.level),
                onSelect = function()
                    gStateStack:pop()
                    self.takeTurnState:fadeOutWhite()
                end
            },
            {
                text = 'HP: ' .. tostring(self.pokemon.HP - self.HPIncrease) .. ' + ' .. 
                    tostring(self.HPIncrease) .. ' -> ' .. tostring(self.pokemon.HP),
                onSelect = function() 
                    gStateStack:pop()
                    self.takeTurnState:fadeOutWhite() 
                end
            },
            {
                text = 'Attack: ' .. tostring(self.pokemon.attack - self.attackIncrease) .. ' + ' .. 
                    tostring(self.attackIncrease) .. ' -> ' .. tostring(self.pokemon.attack),
                onSelect = function() 
                    gStateStack:pop()
                    self.takeTurnState:fadeOutWhite() 
                end
            },
            {
                text = 'Defense: ' .. tostring(self.pokemon.defense - self.defenseIncrease) .. ' + ' .. 
                    tostring(self.defenseIncrease) .. ' -> ' .. tostring(self.pokemon.defense),
                onSelect = function() 
                    gStateStack:pop()
                    self.takeTurnState:fadeOutWhite() 
                end
            },
            {
                text = 'Speed: ' .. tostring(self.pokemon.speed - self.speedIncrease) .. ' + ' .. 
                    tostring(self.speedIncrease) .. ' -> ' .. tostring(self.pokemon.speed),
                onSelect = function() 
                    gStateStack:pop()
                    self.takeTurnState:fadeOutWhite() 
                end
            }
        }
    }
end

function StatsMenuState:update(dt)
    self.statsMenu:update(dt)
end

function StatsMenuState:render()
    self.statsMenu:render()
end