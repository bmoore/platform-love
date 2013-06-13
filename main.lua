local loader = require("Advanced-Tiled-Loader/Loader")
loader.path = "maps/"

local HC = require "HardonCollider"

local hero
local collider
local allSolidTiles

function love.load()
    print("Started")
    map = loader.load("level.tmx")

    collider = HC(100, on_collide, collision_stop)

    allSolidTiles = findSolidTiles(map)

    setupHero(32,32)
end

function love.draw()
    map:draw()
    hero:draw("fill")
end

function love.update(dt)
    updateHero(dt)

    collider:update(dt)
end

function love.focus(f)
end

function love.keypressed(key, unicode)
    if key == "up" then
        heroJump()
    end
end

function love.keyreleased(key, unicode)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.quit()
    print("Ended")
end

function findSolidTiles(map)
    local collidable_tiles = {}
    local layer = map.layers["ground"]

    for x, y, tile in map("ground"):iterate() do
        if tile and tile.properties.solid then
            local ctile = collider:addRectangle(x*16, y*16, 16, 16)
            ctile.type = "tile"
            collider:addToGroup("tiles", ctile)
            collider:setPassive(ctile)
            table.insert(collidable_tiles, ctile)
        end
    end

    return collidable_tiles
end

function setupHero(x, y)
    hero = collider:addRectangle(x,y,16,16)
    hero.vx = 200
    hero.vy = 1
    hero.gravity = 300
end

function updateHero(dt)
    local dx = 0
    local dy = 0

    if love.keyboard.isDown("left") then
        dx = -hero.vx*dt
    end

    if love.keyboard.isDown("right") then
        dx = hero.vx*dt
    end

    if hero.vy ~= 0 then
        dy = hero.vy*dt
        hero.vy = hero.vy + hero.gravity*dt
    end

    hero:move(dx, dy)
end

function heroJump()
    if hero.vy == 0 then
        hero.vy = -200
    end
end

function on_collide(dt, shape_a, shape_b, dx, dy)
    if (shape_a == hero or shape_b == hero) then
        collideHeroWithTile(dt, shape_a, shape_b, dx, dy)
    end
end

function collideHeroWithTile(dt, shape_a, shape_b, dx, dy)
    local hero_shape, tileshape
    if shape_a == hero and shape_b.type == "tile" then
        hero_shape = shape_a
    elseif shape_b == hero and shape_a.type == "tile" then
        hero_shape = shape_b
    else
        return
    end

    print("dx: ", dx)
    print("dy: ", dy)

    hero_shape:move(dx, dy)
    if math.abs(dy) > math.abs(dx) then
        if dy < 0 then
            -- set velocity to 0
            hero.vy = 0
        else
            -- set velocity to -1
            hero.vy = 1
        end
    end
end

function collision_stop()
    if hero.vy == 0 then
        hero.vy = 1
    end
end
