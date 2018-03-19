local base = require("SteeringBehaviors.basebehaviors")
local M = class("flee", base)

function M:ctor()
	self.max_velocity = cc.p(1, 2) --最大速度
	self.max_force = cc.p(2, 2) --最大力量
	self.mass = 1 --质量，暂时不用
	self.velocity = cc.p(-2, 0) --当前速度
	
	self._target = nil --目标
	self._fleer = nil --搜索者
end

function M:setTarget(t)
	self._target = t
end

function M:setFleer(s)
	self._fleer = s
end

function M:update(dt)
	--flee = -seek

	--desired_velocity = normalize(target - position) * max_velocity
	--desired_velocity = -desired_velocity
	--steering = desired_velocity - velocity
	--steering = truncate (steering, max_force)
	--steering = steering / mass
	--velocity = truncate (velocity + steering , max_speed)
	--position = position + velocity

	local target_x, target_y = self._target:getPosition()
	local flee_x, flee_y = self._fleer:getPosition()

	--理想移动
	local desired_velocity = self:getDesiredVelocity(cc.p(target_x, target_y), cc.p(flee_x, flee_y))
	desired_velocity = cc.pNormalize(desired_velocity)
	desired_velocity.x = desired_velocity.x * self.max_velocity.x
	desired_velocity.y = desired_velocity.y * self.max_velocity.y

	--加上转向
	local steering = self:getSteering(desired_velocity)
	self:truncateVec2(steering, self.max_force)
	steering.x = steering.x / self.mass
	steering.y = steering.y / self.mass
	self.velocity.x = self.velocity.x + steering.x
	self.velocity.y = self.velocity.y + steering.y
	self:truncateVec2(self.velocity, self.max_velocity)

	local positionx, positiony = self._fleer:getPosition()
	positionx = positionx + self.velocity.x
	positiony = positiony + self.velocity.y
	self._fleer:setPosition(positionx, positiony)

end

return M