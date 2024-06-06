push = require 'lib/push'
Class = require 'lib/class'
Timer = require 'lib/knife.timer'

require 'src/StateMachine'
require 'src/Util'
require 'src/Board'
require 'src/Tile'

require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/BeginGameState'
require 'src/states/PlayState'
require 'src/states/GameOverState'

gTextures = {
    ['main'] = love.graphics.newImage('graphics/match3.png'),
    ['background'] = love.graphics.newImage('graphics/background.png')
}

gSounds = {
    ['clock'] = love.audio.newSource('sounds/clock.wav', 'static'),
    ['error'] = love.audio.newSource('sounds/error.wav', 'static'),
    ['game-over'] = love.audio.newSource('sounds/game-over.wav', 'static'),
    ['match'] = love.audio.newSource('sounds/match.wav', 'static'),
    ['next-level'] = love.audio.newSource('sounds/next-level.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),

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