TakeTurnState = Class{__includes = BaseState}

function TakeTurnState:init(battleState)
    self.battleState = battleState

    self.playerPokemon = self.battleState.player.party.pokemon[1]
    self.opponentPokemon = self.battleState.opponent.party.pokemon[1]

    self.playerSprite = self.battleState.playerSprite
    self.opponentSprite = self.battleState.opponentSprite

    if self.playerPokemon.speed > self.opponentPokemon.speed then
        self.firstPokemon = self.playerPokemon
        self.secondPokemon = self.opponentPokemon
        self.firstSprite = self.playerSprite
        self.secondSprite = self.opponentSprite
        self.firstBar = self.battleState.playerHealthBar
        self.secondBar = self.battleState.opponentHealthBar
    else
        self.firstPokemon = self.opponentPokemon
        self.secondPokemon = self.playerPokemon
        self.firstSprite = self.opponentSprite
        self.secondSprite = self.playerSprite
        self.firstBar = self.battleState.opponentHealthBar
        self.secondBar = self.battleState.playerHealthBar
    end
end

function TakeTurnState:enter(params)
    self:attack(self.firstPokemon, self.secondPokemon, self.firstSprite, self.secondSprite, self.firstBar, self.secondBar,

    function()
        gStateStack:pop()

        if self:checkDeaths() then
            gStateStack:pop()
            return
        end

        self:attack(self.secondPokemon, self.firstPokemon, self.secondSprite, self.firstSprite, self.secondBar, self.firstBar,

        function()
            gStateStack:pop()

            if self:checkDeaths() then
                gStateStack:pop()
                return
            end

            gStateStack:pop()
            gStateStack:push(BattleMenuState(self.battleState))
        end)
    end)
end

function TakeTurnState:attack(attacker, defender, attackerSprite, defenderSprite, attackerkBar, defenderBar, onEnd)
    gStateStack:push(BattleMessageState(attacker.name .. ' attacks ' .. defender.name .. '!',
        function() end, false))

    Timer.after(0.5, function()
        gSounds['powerup']:stop()
        gSounds['powerup']:play()

        Timer.every(0.1, function()
            attackerSprite.blinking = not attackerSprite.blinking
        end)
        :limit(6)
        :finish(function()
            gSounds['hit']:stop()
            gSounds['hit']:play()

            Timer.every(0.1, function()
                defenderSprite.opacity = defenderSprite.opacity == 64/255 and 1 or 64/255
            end)
            :limit(6)
            :finish(function()
                local dmg = math.max(1, attacker.attack - defender.defense)
                
                Timer.tween(0.5, {
                    [defenderBar] = {value = defender.currentHP - dmg}
                })
                :finish(function()
                    defender.currentHP = defender.currentHP - dmg
                    onEnd()
                end)
            end)
        end)
    end)
end

function TakeTurnState:checkDeaths()
    if self.playerPokemon.currentHP <= 0 then
        self:faint()
        return true
    elseif self.opponentPokemon.currentHP <= 0 then
        self:victory()
        return true
    end

    return false
end

function TakeTurnState:faint()
    Timer.tween(0.2, {
        [self.playerSprite] = {y = VIRTUAL_HEIGHT}
    })
    :finish(function()
        gStateStack:push(BattleMessageState('You fainted!',

        function()
            gStateStack:push(FadeInState({
                r = 0, g = 0, b = 0
            }, 1, function()
                self.playerPokemon.currentHP = self.playerPokemon.HP

                gSounds['battle-music']:stop()
                gSounds['field-music']:play()

                gStateStack:pop()
                gStateStack:push(FadeOutState({
                    r = 0, g = 0, b = 0
                }, 1, function() 
                    gStateStack:push(DialogueState('Your Pokemon has been fully restored; try again!'))
                end))
            end))
        end))
    end)
end

function TakeTurnState:victory()
    Timer.tween(0.2, {
        [self.opponentSprite] = {y = VIRTUAL_HEIGHT}
    })
    :finish(function()
        gSounds['battle-music']:stop()

        gSounds['victory-music']:setLooping(true)
        gSounds['victory-music']:play()

        gStateStack:push(BattleMessageState('Victory!',

        function()
            local exp = (self.opponentPokemon.HPIV + self.opponentPokemon.attackIV +
            self.opponentPokemon.defenseIV + self.opponentPokemon.speedIV) * self.opponentPokemon.level

            gStateStack:push(BattleMessageState('You earned ' .. tostring(exp) .. ' experience points!',
                function() end, false))

            Timer.after(1.5, function()
                gSounds['exp']:play()

                Timer.tween(0.5, {
                    [self.battleState.playerExpBar] = {value = math.min(self.playerPokemon.currentExp + exp, self.playerPokemon.expToLevel)}
                })
                :finish(function()
                    gStateStack:pop()

                    self.playerPokemon.currentExp = self.playerPokemon.currentExp + exp

                    if self.playerPokemon.currentExp > self.playerPokemon.expToLevel then
                        gSounds['level-up']:play()

                        self.playerPokemon.currentExp = self.playerPokemon.currentExp - self.playerPokemon.expToLevel
                        self.playerPokemon:levelUp()

                        gStateStack:push(BattleMessageState('Congratulations! Level Up!',
                        function()
                            self:fadeOutWhite()
                        end))
                    else
                        self:fadeOutWhite()
                    end
                end)
            end)
        end))
    end)
end

function TakeTurnState:fadeOutWhite()
    -- fade in
    gStateStack:push(FadeInState({
        r = 1, g = 1, b = 1
    }, 1, 
    function()

        -- resume field music
        gSounds['victory-music']:stop()
        gSounds['field-music']:play()
        
        -- pop off the battle state
        gStateStack:pop()
        gStateStack:push(FadeOutState({
            r = 1, g = 1, b = 1
        }, 1, function() end))
    end))
end