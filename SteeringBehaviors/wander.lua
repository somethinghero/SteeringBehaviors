--https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-wander--gamedev-1624
local base = require("SteeringBehaviors.basebehaviors")
local M = class("wander", base)

function M:ctor()
	self.max_velocity = cc.p(22, 22) --最大速度
	self.max_force = cc.p(22, 22) --最大力量
	self.mass = 1 --质量，暂时不用
	self.velocity = cc.p(-1, 0) --当前速度

	self._wander = nil

	self.circle_radius = 1
	self.circle_distance = 0.01

	self.wander_angle = 0
	self.angle_change = 6.18

	self._wander_interval = 0.5
	self._tick = 0
	self._wander_velocity = nil
end

function M:setVelocity(v)
	self.velocity = v
end

function M:setWander(w)
	self._wander = w
end

function M:getWander()
	return self._wander
end

function M:setAngle(vec, angle)
	local length = cc.pGetLength(vec)
	vec.x = math.cos(angle) * length
	vec.y = math.sin(angle) * length
end

function M:wander()
	--calc circle position
	local v = cc.p(self.velocity.x, self.velocity.y)
	local circle_center = cc.pNormalize(v)

	circle_center.x = circle_center.x * self.circle_distance
	circle_center.y = circle_center.y * self.circle_distance

	--calc displacement force
	local displacement = cc.p(0, 1)
	self.wander_angle = self.wander_angle + (math.random() - 0.5) * self.angle_change
	self:setAngle(displacement, self.wander_angle)
	displacement.x = displacement.x * self.circle_radius
	displacement.y = displacement.y * self.circle_radius

	circle_center.x = circle_center.x + displacement.x * 0.2
	circle_center.y = circle_center.y + displacement.y * 0.2
	return circle_center
end

function M:lerp(val1, val2, t)
	return val1 + t * (val2 - val1)
end

function M:lerpVec2(v1, v2, t)
	return cc.p(self:lerp(v1.x, v2.x, t), self:lerp(v1.y, v2.y, t))
end

function M:change()
	local steering = self:wander()
	self:truncateVec2(steering, self.max_force)
	steering.x = steering.x / self.mass
	steering.y = steering.y / self.mass

	local velocity = cc.p(self.velocity.x, self.velocity.y)
	velocity.x = velocity.x + steering.x
	velocity.y = velocity.y + steering.y
	self:truncateVec2(velocity, self.max_velocity)

	self._wander_velocity = velocity
end

function M:update(dt)
	if nil == self._wander_velocity then
		self:change()
	end
	self._tick = self._tick + dt
	if self._tick > self._wander_interval then
		self._tick = 0
		--wander
		self:change()
	end

	self.velocity = self:lerpVec2(self.velocity, self._wander_velocity, dt)

	local positionx, positiony = self._wander:getPosition()
	positionx = positionx + self.velocity.x
	positiony = positiony + self.velocity.y
	self._wander:setPosition(positionx, positiony)

	local angle = math.asin(self.velocity.y / cc.pGetLength(self.velocity)) * 180 / 3.14
	angle = -angle
	if self.velocity.x < 0 then
		angle = 180 - angle
	end

	self._wander:setRotation(angle)
end

return M