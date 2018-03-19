--https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-flee-and-arrival--gamedev-1303
local base = require("SteeringBehaviors.basebehaviors")
local M = class("arrival", base)

function M:ctor()
	self.max_velocity = cc.p(1, 2) --最大速度
	self.max_force = cc.p(2, 2) --最大力量
	self.mass = 1 --质量，暂时不用
	self.velocity = cc.p(-2, 0) --当前速度

	--减速半径
	self.slowing_radius = 100
	
	self._target = nil --目标
	self._follower = nil --搜索者
end

function M:setTarget(t)
	self._target = t
end

function M:setFollower(f)
	self._follower = f
end

function M:setSlowingRadius(r)
	self.slowing_radius = r
end

function M:update(dt)
	--arrival = seek and slow down

	--desired_velocity = normalize(target - position) * max_velocity
	--desired_velocity = -desired_velocity
	--steering = desired_velocity - velocity
	--steering = truncate (steering, max_force)
	--steering = steering / mass
	--velocity = truncate (velocity + steering , max_speed)
	--position = position + velocity

	local target_x, target_y = self._target:getPosition()
	local flee_x, flee_y = self._follower:getPosition()

	--理想移动
	local desired_velocity = self:getDesiredVelocity(cc.p(flee_x, flee_y), cc.p(target_x, target_y))

	local distance = cc.pGetLength(desired_velocity)

	desired_velocity = cc.pNormalize(desired_velocity)
	if distance < self.slowing_radius then
		desired_velocity.x = desired_velocity.x * self.max_velocity.x * (distance / self.slowing_radius)
		desired_velocity.y = desired_velocity.y * self.max_velocity.y * (distance / self.slowing_radius)
	else
		desired_velocity.x = desired_velocity.x * self.max_velocity.x
		desired_velocity.y = desired_velocity.y * self.max_velocity.y
	end

	--加上转向
	local steering = self:getSteering(desired_velocity)
	self:truncateVec2(steering, self.max_force)
	steering.x = steering.x / self.mass
	steering.y = steering.y / self.mass
	self.velocity.x = self.velocity.x + steering.x
	self.velocity.y = self.velocity.y + steering.y
	self:truncateVec2(self.velocity, self.max_velocity)

	local positionx, positiony = self._follower:getPosition()
	positionx = positionx + self.velocity.x
	positiony = positiony + self.velocity.y
	self._follower:setPosition(positionx, positiony)

end

return M