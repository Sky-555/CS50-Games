GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {frame = 2},
            ['pressed'] = {frame = 1}
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'pots',
        frame = POTS[math.random(#POTS)],
        width = 16,
        height = 16,
        solid = true,
        defaultState = 'pot1',
        states = {
            ['pot1'] = {frame = POTS[1]},
            ['pot2'] = {frame = POTS[2]},
            ['pot3'] = {frame = POTS[3]},
            ['pot4'] = {frame = POTS[4]}
        }
    },
    ['heart'] = {
        type = 'heart',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'full',
        states = {
            ['full'] = {frame = 5},
            ['half'] = {frame = 3}
        },
        consumable = true
    }
}