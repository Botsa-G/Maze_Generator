fonts = {}
fonts.info = love.graphics.newFont("shf.ttf", 21)

local current
local cheker = 0
local move = 1
local comd = 0
local adder = -40
local size = 11
local sizeh = 38

cell = {
    x = 11,
    y = 100,
    w = 30,
    h = 30,
    u = true,
    d = true,
    r = true,
    l = true,
    vis = false,
    inde = 0,
    i = 0,
    j = 0
}

function cell:draw()
    if self.u == true then
        love.graphics.line(self.x, self.y, self.x + self.w, self.y)
    end
    if self.d == true then
        love.graphics.line(self.x, self.y + self.h, self.x + self.w, self.y + self.h)
    end
    if self.r == true then
        love.graphics.line(self.x + self.w, self.y, self.x + self.w, self.y + self.h)
    end
    if self.l == true then
        love.graphics.line(self.x, self.y, self.x, self.y + self.h)
    end
end

function cell:new(tab)
    tab = tab or {}
    setmetatable(tab, self)
    self.__index = self
    return tab
end

grids = {}

function creategrid(tabl)
    grids[#grids + 1] = cell:new(tabl)
end

for b = 1, sizeh do
    for a = 1, size do
        creategrid({
            x = 11 + (a - 1) * 30,
            y = 50 + (b - 1) * 30,
            w = 30,
            h = 30,
            u = true,
            d = true,
            r = true,
            l = true,
            i = a,
            j = b
        })
    end
end

for a = 1, size do
    for b = 1, sizeh do
        grids[a + ((b * size) - size)].inde = (a + ((b * size) - size))
    end
end

current = grids[1]

function ind(a, b)
    -- (a+b*size)
    if a > 0 and a < (size + 1) and b > 0 and b < (sizeh + 1) then
        return (a + ((b * size) - size))
    end
end

function getnebs(guy)
    local nebs = {}

    if guy.i > 0 and guy.i < (size + 1) and guy.j > 0 and guy.j < (sizeh + 1) then
        local upa = grids[ind(guy.i, guy.j - 1)]
        local downa = grids[ind(guy.i, guy.j + 1)]
        local righta = grids[ind(guy.i + 1, guy.j)]
        local lefta = grids[ind(guy.i - 1, guy.j)]

        if upa ~= nil and upa.vis ~= true then
            table.insert(nebs, upa)
        end
        if downa ~= nil and downa.vis ~= true then
            table.insert(nebs, downa)
        end
        if righta ~= nil and righta.vis ~= true then
            table.insert(nebs, righta)
        end
        if lefta ~= nil and lefta.vis ~= true then
            table.insert(nebs, lefta)
        end
    end

    return nebs[math.floor(love.math.random(1, #nebs))]
end

function dismantle(a, b)
    if (a.i - b.i) == -1 then
        a.r = false
        b.l = false
    end
    if (a.i - b.i) == 1 then
        a.l = false
        b.r = false
    end

    if (a.j - b.j) == -1 then
        a.d = false
        b.u = false
    end
    if (a.j - b.j) == 1 then
        a.u = false
        b.d = false
    end
end

function dist(x1, y1, x2, y2)
    return math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1))
end

function love.load()
    mf = love.graphics.newImage("mf.png")
    logo = love.graphics.newImage("spl.png")
end

local wait = 0
local namazed = 1
function love.update(dt)
    wait = wait + dt
    cheker = cheker + dt

    if cheker >= 0.8 and namazed == 0 and current.i == 1 and current.j == 1 then
        comd = comd + adder * dt
    end

    if comd < -1 * (sizeh * 30 - 600) then
        adder = 70
    end
    if adder == 70 and comd > 0 then
        adder = 0
    end

    if love.keyboard.isDown("return") and namazed == 1 then
        namazed = 0
    end
end

local stack = {}

function love.draw()
    love.graphics.setLineWidth(3)

    love.graphics.push()
    love.graphics.translate(0, comd)

    if namazed == 0 then
        for b = 1, #grids do
            bo = grids[b]
            if bo.vis == true then
                love.graphics.setColor(0, 0, 0.5)
                love.graphics.rectangle("fill", bo.x, bo.y, bo.w, bo.h)
                love.graphics.setColor(1, 1, 1)
            end
        end

        for b = 1, #grids do
            bo = grids[b]
            if bo == current then
                love.graphics.setColor(0, 0, 0.5)
                love.graphics.rectangle("fill", bo.x, bo.y, bo.w, bo.h)
                love.graphics.setColor(1, 1, 1)
            end
        end

        love.graphics.setColor(0.5, 0.5, 0.5)
        for d = 1, #grids do
            gr = grids[d]
            gr:draw()
        end
        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(mf, current.x + current.w / 2, current.y + current.h / 2, 0, 0.16, 0.16, mf:getWidth() / 2,
            mf:getHeight() / 2)

        -- love.graphics.print(#stack)

        ---love.graphics.print(current.i .."".. current.j)

        -- if wait >= 0.5 then

        current.vis = true
        local nextguy = getnebs(current)
        if nextguy ~= nil and nextguy.vis ~= true then
            dismantle(current, nextguy)
            table.insert(stack, current)
            current = nextguy
        elseif #stack > 0 then
            current = stack[#stack]
            table.remove(stack, #stack)
        end
        -- wait=0 end

        love.graphics.setFont(fonts.info)
        love.graphics.setColor(1, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont())
    end

    if namazed == 1 then
        love.graphics.setFont(fonts.info)
        love.graphics.setColor(0.7, 0.7, 1)
        love.graphics.print('PRESS "ENTER" TO SEE THE MAZE', 176, 450, 0, 1, 1.2,
            love.graphics.getFont():getWidth('PRESS "ENTER" TO SEE THE MAZE') / 2,
            love.graphics.getFont():getHeight('PRESS "ENTER" TO SEE THE MAZE') / 2)
        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(mf, love.graphics.getFont():getWidth('PRESS "ENTER" TO SEE THE MAZE') + 120, 250, 0, 0.35,
            0.35, mf:getWidth() / 2, mf:getHeight() / 2)
        love.graphics.draw(logo, 176, 300, 0, 0.7, 0.7, logo:getWidth() / 2, logo:getHeight() / 2)
        love.graphics.setFont(love.graphics.newFont())
    end

    love.graphics.pop()
end
