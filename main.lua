--quest lua runner thing

local oldrequire = require
__requirepath = ""
requirepath = function(p)
	__requirepath = p or ''
end
require = function(r)
	return oldrequire(__requirepath..r)
end

requirepath('lib/xml2lua/')
	xml2lua = require("xml2lua")
	handler = require("xmlhandler.tree")
requirepath()

inspect = require('lib/inspect')


function readobject(o,path)
	for k,v in pairs(o) do
		print(k,type(v))
		
	end
	path = path or ''
	local newo = {}
	for k,v in pairs(o) do
		if type(v) == 'table' then
			
			
			local cname = k
			local cv = v
			if v._attr and v._attr.name then
				cname = v._attr.name
				print(inspect(cv))
				
				local newv = {}
				if v._attr.type then
					print('giving name to value at ' .. path .. '.' ..cname ..', value is ' .. v[1])
					local newv = {v[1]}
				else
					print('giving name to value at ' .. path .. '.' ..cname ..', value is table')
					for _k,_v in pairs(v) do
						newv[_k] = _v
					end
				end
				newv._attr = nil
				for _k,_v in pairs(v._attr) do
					if _k ~= 'name' then
						newv._attr = newv._attr or {}
						newv._attr[_k]=_v
					end
				end
				cv = newv
				
			end
				
			if cv._attr and cv._attr.type then
			
				print('found type ' .. cv._attr.type .. ' at '.. path .. '.' .. cname)
				if cv._attr.type == 'boolean' then 
					newo[cname] = (cv[1] == 'true')
				elseif cv._attr.type == 'int' then
					newo[cname] = tonumber(cv[1])
				elseif cv._attr.type == 'scriptdictionary' then
					print(inspect(cv))
					newo[cname] = {}
					
					if cv.item._attr then
						cv.item = {cv.item}
					end
					for _i,_v in ipairs(cv.item) do
						print(_i,_v)
						newo[cname][_v._attr.key] = _v[1]
					end
				elseif cv._attr.type == 'script' or cv._attr.type == 'string' then
					newo[cname] = cv[1]
				else
					error('unknown type found')
				end
			else 
				local i = 0
				for _k,_v in pairs(cv) do
					i = i + 1
				end
				
				if i == 0 then
					print('found empty table boolean at '.. path .. '.' .. cname)
					newo[cname] = true
				else
					if cname ~= '_attr' then
						print('found real table at '.. path .. '.' .. cname)
						newo[cname] = readobject(cv,path .. '.' .. cname)
					else
						print('found _attr at '.. path .. '.' .. cname ..', ignoring')
					end
				end
			end
				
		else
			print('found normal value at '.. path .. '.' .. k)
			newo[k] = v
		end
	end
	return newo
end



function loadgame(questfile)

	local aslx = xml2lua.loadFile(questfile)

	local parser = xml2lua.parser(handler)
	parser:parse(aslx)

	local asl = handler.root.asl
	
	
	for k,v in pairs(asl) do
		print(k,type(v))
		
	end
	
	local game = {}
	
	game = readobject(asl,'root')

	
	--print(inspect(asl.game))
	
	
	return game
end

game = loadgame('A Messenger\'s Duty.aslx')
print('-------------------------------------------------------------------------------------------')
print(inspect(game))
