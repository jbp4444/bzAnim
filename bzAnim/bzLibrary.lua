-- 
-- Copyright 2021, https://github.com/jbp4444
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
-- https://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 

-- convenience functions for the bezier-animation module

local bz = {}

local bzController = nil

-- make uid always positive (so that errors can be negative)
local bzUid = 1

function bz.animate( inargs )
	local rtn = 0
	local gobj   = inargs.obj or nil
	local dur    = inargs.duration or 1.0
	local delay  = inargs.delay or 0.0
	local easing = inargs.easing or 'TYPE_LINEAR'
	local prepend_cur = inargs.prepend_current or true
	local path   = inargs.path or nil
	local on_complete = inargs.on_complete or nil

	-- check that input args are meaningful
	if( gobj == nil ) then
		rtn = -1
	end
	if( path == nil ) then
		rtn = -2
	end
	if( EASING_TYPES[easing] == nil ) then
		rtn = -3
	end
	if( bzController == nil ) then
		rtn = -999
	end

	if( rtn >= 0 ) then
		msg.post( bzController, 'play', {
			gobj = gobj,
			dur = dur,
			delay = delay,
			prepend_cur = prepend_cur,
			easing = easing,
			path = path,
			on_complete = on_complete,
			uid = bzUid,
		} )

		-- uid is always positive (so it is different than an error return)
		rtn = bzUid
	end

	-- simple unique-id number for each animation
	bzUid = bzUid + 1

	return rtn
end

function bz.cancel( idn )
	-- silently ignore bad id-numbers
	if( (bzController ~= nil) and (idn>0) ) then
		msg.post( bzController, 'cancel', {
			uid = idn,
		} )
	end
end

function bz.animateSequence( inargs )
	local rtn = 0
	local gobj   = inargs.obj or nil
	local seg_list = inargs.segments or inargs.segment or nil
	local on_complete = inargs.on_complete or false

	-- check that input args are meaningful
	if( gobj == nil ) then
		rtn = -1
	end
	if( seg_list == nil ) then
		rtn = -2
	end
	if( bzController == nil ) then
		rtn = -999
	end

	if( rtn >= 0 ) then
		local accum_delay = 0
		-- TODO: could do something fancier to allow the 1st segment to start
		--       somewhere other than the current go.position
		local go_pos = go.get_position( gobj )
		local cur_pos = { x=go_pos.x, y=go_pos.y, z=go_pos.z }
		for i,anim in ipairs(seg_list) do
			local dur    = anim.duration or 1.0
			local delay  = anim.delay or 0.0
			local easing = anim.easing or 'TYPE_LINEAR'
			local path   = anim.path or nil

			-- TODO: check that each segment has duration and path

			table.insert( path, 1, cur_pos )
			pprint( path )
			
			msg.post( bzController, 'play', {
				gobj = gobj,
				dur = dur,
				delay = accum_delay + delay,
				prepend_cur = false,
				easing = easing,
				path = path,
				on_complete = on_complete,
				-- NOTE: each segment-animation has same UID to make cancelation easier
				uid = bzUid,
			} )

			accum_delay = accum_delay + delay + dur

			-- update current position to the end of this segment
			cur_pos.x = path[#path].x or cur_pos.x
			cur_pos.y = path[#path].y or cur_pos.y
			cur_pos.z = path[#path].z or cur_pos.z
		end
		
		-- uid is always positive (so it is different than an error return)
		rtn = bzUid
	end

	-- simple unique-id number for each animation
	bzUid = bzUid + 1

	return rtn
end

function bz.info()
	local rtn = {
		script_url = bzController,
		easing_samples = EASING_SAMPLES,
		easing_types = {},
		easing_lookup_size = #EASING_LOOKUP,
		debug_flag = debugFlag,
	}
	for k,v in pairs(EASING_TYPES) do
		table.insert( rtn.easing_types, k )
	end
	rtn.num_easing_types = #rtn.easing_types

	return rtn
end

function bz.setMaxPoints( num )
	if( bzController ~= nil ) then
		msg.post( bzController, 'max_pts', { max_pts=num } )
	end
end

function bz.setDebugLevel( lvl )
	if( bzController ~= nil ) then
		msg.post( bzController, 'debug_level', { debug_level=lvl } )
	end
end

function bz.isReady()
	local rtn = false
	if( bzController ~= nil ) then
		rtn = true
	end
	return rtn
end

function bz.registerController( obj )
	-- TODO: what if a controller is already registered?
	bzController = obj
end
function bz.unregisterController( obj )
	if( bzController == obj ) then
		bzController = nil
	end
end

return bz
