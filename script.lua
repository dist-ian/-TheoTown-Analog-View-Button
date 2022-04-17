--- Analog View Button version 1.5.0
--  Created by ian` on 2022-04-15

local analogButton
local analogFrame
local config

local function clickRange(p0, p1, range)
    return math.abs(p0 - p1) < range
end

local function defConfig(value)
    return value == nil and true or value
end

local function resetConfig(init)
    config.showInBuildMode = true
    config.opposite        = true
    config.direction       = true
    config.hideButton      = true
    config.speed           = 25

    if init then return end

    config.bgColorRed   = 192
    config.bgColorGreen = 192
    config.bgColorBlue  = 192

    config.buttonColorRed   = 160
    config.buttonColorGreen = 160
    config.buttonColorBlue  = 160
end

local function setValue(value, min, max)
    local value = tonumber(value)

    return value < min and min or value > max and max or value
end

local function setVisible()
    local showUI = not TheoTown.SETTINGS.hideUI

    if config.showInBuildMode then
        return showUI
    end

    local hideCloseTool = not GUI.get("cmdCloseTool"):isVisible()

    return showUI and hideCloseTool
end

function script:init()
    analogFrame = Draft.getDraft("$iconAnalogButton_ian00")
    config      = Util.optStorage(TheoTown.getStorage(), "analogViewButton_ian00")

    config.showButton      = defConfig(config.showButton)
    config.showInBuildMode = defConfig(config.showInBuildMode)
    config.opposite        = defConfig(config.opposite)
    config.direction       = defConfig(config.direction)
    config.hideButton      = defConfig(config.hideButton)
    config.speed           = config.speed or 25

    if isnumber(config.direction) then
        resetConfig(true)
    end

    config.bgColorRed   = config.bgColorRed or 192
    config.bgColorGreen = config.bgColorGreen or 192
    config.bgColorBlue  = config.bgColorBlue or 192

    config.buttonColorRed   = config.buttonColorRed or 160
    config.buttonColorGreen = config.buttonColorGreen or 160
    config.buttonColorBlue  = config.buttonColorBlue or 160
end

function script:settings()
    if not City then return end

    local showButtonConfig = {
        name  = "Show Button",
        value = config.showButton,

        onChange = function(state)
            config.showButton = state
        end
    }

    if not config.showButton then
        return {showButtonConfig}
    end

    return {
        showButtonConfig,
        {
            name  = "Show In Build Mode",
            value = config.showInBuildMode,

            onChange = function(state)
                config.showInBuildMode = state
            end
        },
        {
            name  = "Auto Hide",
            value = config.hideButton,

            onChange = function(state)
                config.hideButton = state
            end
        },
        {
            name  = "Opposite Position",
            value = config.opposite,

            onChange = function(state)
                config.opposite = state
            end
        },
        {
            name  = "Follow Button Direction",
            value = config.direction,

            onChange = function(state)
                config.direction = state
            end
        },
        {
            name  = "Reset",
            value = false,

            onChange = function(state)
                resetConfig()
            end
        },
        {
            name  = "Movement Speed",
            desc  = "Enter a number (range 0 ~ 100)",
            value = config.speed,

            onChange = function(value)
                config.speed = setValue(value, 0, 100)
            end
        },
        {
            name  = "Analog Background Color (Red)",
            desc  = "Enter a number (range 0 ~ 255)",
            value = config.bgColorRed,

            onChange = function(value)
                config.bgColorRed = setValue(value, 0, 255)
            end
        },
        {
            name  = "Analog Background Color (Green)",
            desc  = "Enter a number (range 0 ~ 255)",
            value = config.bgColorGreen,

            onChange = function(value)
                config.bgColorGreen = setValue(value, 0, 255)
            end
        },
        {
            name  = "Analog Background Color (Blue)",
            desc  = "Enter a number (range 0 ~ 255)",
            value = config.bgColorBlue,

            onChange = function(value)
                config.bgColorBlue = setValue(value, 0, 255)
            end
        },
        {
            name  = "Analog Button Color (Red)",
            desc  = "Enter a number (range 0 ~ 255)",
            value = config.buttonColorRed,

            onChange = function(value)
                config.buttonColorRed = setValue(value, 0, 255)
            end
        },
        {
            name  = "Analog Button Color (Green)",
            desc  = "Enter a number (range 0 ~ 255)",
            value = config.buttonColorGreen,

            onChange = function(value)
                config.buttonColorGreen = setValue(value, 0, 255)
            end
        },
        {
            name  = "Analog Button Color (Blue)",
            desc  = "Enter a number (range 0 ~ 255)",
            value = config.buttonColorBlue,

            onChange = function(value)
                config.buttonColorBlue = setValue(value, 0, 255)
            end
        }
    }
end

function script:leaveCity()
    if config.showButton then
        analogButton = nil
    end
end

function script:buildCityGUI()
    if not config.showButton then return end

    local cameraX
    local cameraY
    local rotation
    local scale
    local tapToRotate
    local alpha        = 1
    local time         = 0
    local timeOut      = 0
    local root         = GUI.getRoot()
    local cityHeight   = City.getHeight()
    local cityWidth    = City.getWidth()
    local rightSidebar = TheoTown.SETTINGS.rightSidebar

    local function getX()
        local left  = 90
        local right = root:getClientWidth() - 95

        if rightSidebar then
            return config.opposite and left or right
        end

        return config.opposite and right or left
    end

    analogButton = root:addCanvas{
        x = getX(),
        y = root:getClientHeight() - 95,
        w = 45,
        h = 45,

        onInit = function(self)
            self:setChildIndex(11)
            self:setId("virtualAnalogButton00")
        end,

        onDraw = function(self, x, y, w, h)
            Drawing.setAlpha(alpha)
            Drawing.setColor(
                config.bgColorRed,
                config.bgColorGreen,
                config.bgColorBlue
            )
            Drawing.drawImageRect(
                analogFrame:getFrame(1),
                x, y, w, h
            )
            Drawing.reset()
        end
    }

    local analog = analogButton:addCanvas{
        w = 45,
        h = 45,

        onDraw = function(self, x, y, w, h)
            Drawing.setAlpha(alpha)
            Drawing.setColor(
                config.buttonColorRed,
                config.buttonColorBlue,
                config.buttonColorGreen
            )
            Drawing.drawImageRect(
                analogFrame:getFrame(2),
                x, y, w, h
            )

            if tapToRotate then
                Drawing.drawImageRect(
                    Icon.TURN_RIGHT,
                    x + 5, y + 6,
                    w - 10, h - 10
                )
            end

            Drawing.reset()
        end,

        onUpdate = function(self)
            if config.hideButton then
                if time < 25 then
                    time = time + .2

                    if time > 17 then
                        alpha = alpha - .05

                        if alpha < 0.2 then
                            alpha = 0.2
                        end
                    elseif time < 10 then
                        alpha = 1
                    end
                end
            end

            if tapToRotate then
                timeOut = timeOut + .2

                if timeOut > 17 then
                    tapToRotate = false
                    timeOut     = 0
                end
            else
                if timeOut ~= 0 then
                    timeOut = 0
                end
            end

            local cx, cy, fx, fy = self:getTouchPoint()

            if cx then
                local x = self:getX()
                local y = self:getY()
                time    = 0

                if cx == fx and cy == fy then
                    if self.diffX then return end

                    self.diffX = cx - x
                    self.diffY = cy - y
                    rotation   = City.getRotation()
                else
                    x = setValue(math.floor(cx - self.diffX), -10, 10)
                    y = setValue(math.floor(cy - self.diffY), -10, 10)
                    cameraX, cameraY, scale = City.getView()

                    local speed = (config.speed / scale) / 100
                    local moveX = (x / 10) * speed
                    local moveY = (y / 10) * speed

                    if rotation == 1 then
                        cameraX, cameraY = cityHeight - cameraY, cameraX

                        if config.direction then
                            moveX, moveY = moveY, -moveX
                        end
                    elseif rotation == 2 then
                        cameraX = cityWidth - cameraX
                        cameraY = cityHeight - cameraY

                        if config.direction then
                            moveX = -moveX
                            moveY = -moveY
                        end
                    elseif rotation == 3 then
                        cameraX, cameraY = cameraY, cityWidth - cameraX

                        if config.direction then
                            moveX, moveY = -moveY, moveX
                        end
                    end

                    City.setView(cameraX + moveX, cameraY - moveY)
                    self:setPosition(x, y)
                end
            else
                if self.diffX then
                    self.diffX = nil
                    self.diffY = nil
                    rotation   = nil
                    cameraX    = nil
                    cameraY    = nil

                    self:setPosition(0, 0)
                end
            end
        end,
        onClick = function(self)
            local cx, cy, fx, fy = self:getTouchPoint()

            if clickRange(cx, fx, 2) and clickRange(cy, fy, 2) then
                if tapToRotate then
                    local rotation = City.getRotation() + 1

                    if rotation > 3 then
                        rotation = 0
                    end

                    City.setRotation(rotation)
                    tapToRotate = nil

                    return
                end

                tapToRotate = true
            end
        end
    }
end

function script:update()
    if not City then return end
    if not config.showButton then return end

    analogButton:setVisible(setVisible())
end
