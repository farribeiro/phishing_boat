local min = math.min
local abs = math.abs

function phishing_boat.physics(self)
    local friction = 0.996
	local vel=self.object:get_velocity()
		-- dumb friction
	if self.isonground and not self.isinliquid then
		self.object:set_velocity({x= vel.x> 0.2 and vel.x*friction or 0,
								y=vel.y,
								z=vel.z > 0.2 and vel.z*friction or 0})
	end
	
	-- bounciness
	if self.springiness and self.springiness > 0 then
		local vnew = vector.new(vel)
		
		if not self.collided then						-- ugly workaround for inconsistent collisions
			for _,k in ipairs({'y','z','x'}) do
				if vel[k]==0 and abs(self.lastvelocity[k])> 0.1 then
					vnew[k]=-self.lastvelocity[k]*self.springiness
				end
			end
		end
		
		if not vector.equals(vel,vnew) then
			self.collided = true
		else
			if self.collided then
				vnew = vector.new(self.lastvelocity)
			end
			self.collided = false
		end
		
		self.object:set_velocity(vnew)
	end
	
	-- buoyancy
	local surface = nil
	local surfnodename = nil
	local spos = airutils.get_stand_pos(self)
	spos.y = spos.y+0.01
	-- get surface height
	local snodepos = airutils.get_node_pos(spos)
	local surfnode = airutils.nodeatpos(spos)
	while surfnode and (surfnode.drawtype == 'liquid' or surfnode.drawtype == 'flowingliquid') do
		surfnodename = surfnode.name
		surface = snodepos.y+0.5
		if surface > spos.y+self.height then break end
		snodepos.y = snodepos.y+1
		surfnode = airutils.nodeatpos(snodepos)
	end
	self.isinliquid = surfnodename
	if surface then				-- standing in liquid
--		self.isinliquid = true
		local submergence = min(surface-spos.y,self.height)/self.height
--		local balance = self.buoyancy*self.height
		local buoyacc = airutils.gravity*(self.buoyancy-submergence)
		airutils.set_acceleration(self.object,
			{x=-vel.x*self.water_drag,y=buoyacc-vel.y*abs(vel.y)*0.4,z=-vel.z*self.water_drag})
	else
--		self.isinliquid = false
		self.object:set_acceleration({x=0,y=airutils.gravity,z=0})
	end
    
end
