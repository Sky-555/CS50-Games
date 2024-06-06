BattleMenuState = Class{__includes = BaseState}

function BattleMenuState:init(battleState)
    self.battleState = battleState

    self.battleMenu = Menu {
        x = VIRTUAL_WIDTH - 64,
        y = VIRTUAL_HEIGHT - 64,
        width = 64,
        height = 64,
        items = {
            {
                text = 'Fight',
                onSelect = function()
                    gStateStack:pop()
                    gStateStack:push(TakeTurnState(self.battleState))
                end
            },
            {
                text = 'Run',
                onSelect = function()
                    gSounds['run']:play()

                    gStateStack:pop()
                    gStateStack:push(BattleMessageState('You fled successfully!', function() end, false))

                    Timer.after(0.5, function()
                        gStateStack:push(FadeInState({
                            r = 1, g = 1, b = 1
                        }, 1, 
                        
                        function()
                            gSounds['field-music']:play()
                            gStateStack:pop()
                            gStateStack:pop()
                            gStateStack:push(FadeOutState({
                                r = 1, b = 1, g = 1
                            }, 1, function()

                            end))
                        end))
                    end)
                end
            },
        }
    }
end

function BattleMenuState:update(dt)
    self.battleMenu:update(dt)
end

function BattleMenuState:render()
    self.battleMenu:render()
end