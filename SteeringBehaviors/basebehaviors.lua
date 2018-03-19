local M = class("basebehaviors")

function M:ctor()

end

function M:truncateVec2(value, max)
	if value.x > max.x then
		value.x = max.x
	end
	if value.y > max.y then
		value.y = max.y
	end
end

function M:getDesiredVelocity(start_pos, end_pos)
	local desired_velocity = cc.p(end_pos.x - start_pos.x, end_pos.y - start_pos.y)
	
	return desired_velocity
end

function M:getSteering(desired_velocity)
	local steering = cc.p(desired_velocity.x - self.velocity.x, desired_velocity.y - self.velocity.y)

	return steering
end

--child class should implement this func
function M:update(dt)

end

return M