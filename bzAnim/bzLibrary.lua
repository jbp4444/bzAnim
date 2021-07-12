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

function bz.animate( inargs )
	local rtn = 0
	local gobj   = inargs.obj or nil
	local dur    = inargs.duration or 1.0
	local delay  = inargs.delay or 0.0
	local easing = inargs.easing or 'TYPE_LINEAR'
	local prepend_cur = inargs.prepend_current or true
	local path   = inargs.path or nil
	local on_complete = inargs.on_complete or false

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
		} )
	end

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
