push = require 'lib/push'
Class = require 'lib/class'
Timer = require 'lib/knife.timer'

require 'src/StateMachine'
require 'src/Util'
require 'src/Board'
require 'src/Tile'
require 'src/ShinyTile'

require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/BeginGameState'
require 'src/states/PlayState'
require 'src/states/GameOverState'

gTextures = {
    ['main'] = love.graphics.newImage('graphics/match3.png'),
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['shuffle'] = love.graphics.newImage('graphics/swap.png'),
    ['shiny'] = love.graphics.newImage('graphics/shiny.png'),
    ['particle'] = love.graphics.newImage('graphics/particle.png')
}

gSounds = {
    ['clock'] = love.audio.newSource('sounds/clock.wav', 'static'),
    ['error'] = love.audio.newSource('sounds/error.wav', 'static'),
    ['game-over'] = love.audio.newSource('sounds/game-over.wav', 'static'),
    ['match'] = love.audio.newSource('sounds/match.wav', 'static'),
    ['next-level'] = love.audio.newSource('sounds/next-level.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['line-clear'] = love.audio.newSource('sounds/line-clear.wav', 'static'),
    ['shiny-formed'] = love.audio.newSource('sounds/shiny-formed.wav', 'static'),

    ['music'] = love.audio.newSource('sounds/music3.mp3', 'static')
}

gFrames = {
    ['tiles'] = generateTileQuads(gTextures['main'])
}

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
}

-- removed brownish-green(3) because too similar in colour
gColourPackage = {
    [1] = {1, 2, 14},
    [2] = {4, 5},
    [3] = {6, 7},
    [4] = {8, 9},
    [5] = {10, 11},
    [6] = {12, 13},
    [7] = {15},
    [8] = {16, 17, 18}
}

--[[
    Colours represented by each indices
    brown - 1
    green - 2
    blue -3
    purple - 4
    pink - 5
    red - 6
    orange - 7
    grey - 8
]] 