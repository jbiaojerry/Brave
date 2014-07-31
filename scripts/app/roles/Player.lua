
local Player = class("Player", function()
    local sprite = display.newSprite("#player1-1-1.png")
    return sprite
end)

function Player:ctor()
    -- 缓存动画数据
    self:addAnimation()
    self:addStateMachine()
end
function Player:addUI()
--    self.mBlood =
end

function Player:addAnimation()
    local animationNames = {"walk", "attack", "dead", "hit", "skill"}
    local animationFrameNum = {4, 4, 4, 2, 4}

    for i = 1, #animationNames do
        local frames = display.newFrames("player1-" .. i .. "-%d.png", 1, animationFrameNum[i])
        local animation = display.newAnimation(frames, 0.2)
        display.setAnimationCache("player1-" .. animationNames[i], animation)
    end
end

function Player:walkTo(pos, callback)

    local function moveStop()
        transition.stopTarget(self)
        if callback then
            callback()
        end
    end

    if self.moveAction then
        self:stopAction(self.moveAction)
        self.moveAction = nil
    end

    local currentPos = CCPoint(self:getPosition())
    local destPos = CCPoint(pos.x, pos.y)
    local posDiff = cc.PointDistance(currentPos, destPos)
    self.moveAction = transition.sequence({CCMoveTo:create(5 * posDiff / display.width, CCPoint(pos.x,pos.y)), CCCallFunc:create(moveStop)})
    transition.playAnimationForever(self, display.getAnimationCache("player1-walk"))
    self:runAction(self.moveAction)
    return true
end

function Player:attack()
    local animation = display.getAnimationCache("player1-attack")
    animation:setRestoreOriginalFrame(true)
    transition.playAnimationOnce(self, animation)
end

function Player:dead()
    transition.playAnimationOnce(self, display.getAnimationCache("player1-dead"))
end

function Player:doEvent(event)
    self.fsm_:doEvent(event)
end


function Player:addStateMachine()
    self.fsm_ = {}
    cc.GameObject.extend(self.fsm_)
    :addComponent("components.behavior.StateMachine")
    :exportMethods()

    self.fsm_:setupState({
        -- 初始状态
        initial = "idle",

        -- 事件和状态转换
        events = {
            -- t1:clickScreen; t2:clickEnemy; t3:beKilled; t4:stop
            {name = "clickScreen", from = {"idle", "walk", "attack"},   to = "walk" },
            {name = "clickEnemy",  from = {"idle", "walk"},  to = "attack"},
            {name = "beKilled", from = {"idle", "walk", "attack"},  to = "dead"},
            {name = "stop", from = {"idle", "walk", "attack"}, to = "idle"},
        },

        -- 状态转变后的回调
        callbacks = {
            onidle = function () print("idle") end,
            onwalk = function () print("move") end,
            onattack = function () print("attack") end,
            ondead = function () print("dead") end
        },
    })

end


return Player

