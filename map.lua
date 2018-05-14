--the map library
maplib = {}


--chunkx,chunky = math.random(-1000,1000),math.random(-1000,-1000)
chunkx,chunky = 0,0

--tile size
map_max = 32

--ore generation
ore_min = 1 -- the minimum amount of ore that'll be generated in a map block
ore_max = 5 -- the max
ore_size_min = 1
ore_size_max = 3

--cave generation
cave_min = 50 --normal 50
cave_max = 60 --normal 60
cave_size_min = 1 --normal 1
cave_size_max = 2 --normal 2

--the chunk y which the rock starts
underground = 0

--the top of the dirt layer
earth_max = 2

--max chunks loaded ( chunk x chunk )
--the render distance
max_chunks = 1 --normal 1 -x to x * -x to x

--water height on the surface
water_height = 17

--makes player move to next map section
function maplib.new_block(oldposx,oldposy)
	--print(math.floor(player.playerx))
	if math.floor(player.playerx) < 1 then
		--if blocks[loaded_chunks[-1][0][map_max][player.playery]["block"]]["collide"] == false then
			maplib.save_chunks()
			chunkx = chunkx - 1
			maplib.createmap() -- create a new block
			player.playerx = player.playerx+map_max -- put player on other side of screen		
			print(" block x -1")
			return false
		--else
			--print("something blocking -1 x")
		--end
	elseif math.floor(player.playerx) > map_max then
		--if blocks[loaded_chunks[1][0][1][player.playery]["block"]]["collide"] == false then
			maplib.save_chunks()
			chunkx = chunkx + 1
			maplib.createmap() -- create a new block
			player.playerx = player.playerx - map_max -- put player on other side of screen
			print("block x +1")
			return false
		--else
			--print("something blocking 1 x")
		--end
	
	elseif math.floor(player.playery) < 1 then
		--if blocks[loaded_chunks[0][1][player.playerx][map_max]["block"]]["collide"] == false then
			maplib.save_chunks()
			chunky = chunky + 1
			maplib.createmap() -- create a new block
			player.playery = player.playery+map_max  -- put player on other side of screen
			print(" block y -1")
			return false
		---else
			--print("something blocking 1 y")
		--end
	elseif math.floor(player.playery) > map_max then
		--if blocks[loaded_chunks[0][-1][player.playerx][1]["block"]]["collide"] == false then
			maplib.save_chunks()
			chunky = chunky - 1
			maplib.createmap() -- create a new block
			player.playery = player.playery - map_max -- put player on other side of screen
			print("block y +1")
			return false
		--else
			--print("something blocking -1 y")
		--end
	end
	
	return true
end

savethread = love.thread.newThread("saving.lua")

savechannel = love.thread.getChannel("save")

loadchannel = love.thread.getChannel("load")

savethread:start()

--saves all memory data into file
function maplib.save_chunks()
	--print("saving chunks")
	savechannel:push{"saving_old",max_chunks,chunkx,chunky,loaded_chunks}
end
--maplib.save_chunks()

--watches and tells game to load up map tiles
buffer = {}
function maplib.load_chunks()

	for xx  = chunkx-max_chunks,chunkx+max_chunks do
		if buffer[xx] == nil then
			buffer[xx] = {}
		end
		if loaded_chunks[xx] == nil then
			loaded_chunks[xx] = {}
		end
		for yy  = chunky-max_chunks,chunky+max_chunks do

			--print(xx,yy)
			if loaded_chunks[xx][yy] == nil and buffer[xx][yy] == nil then
				--print("MABLIB LOADCHUNKS")
				--print("push load")
				savechannel:push{"load_old",max_chunks,loaded_chunks,xx,yy}
				buffer[xx][yy] = true
			end
		end
	end
	
	
	local count = loadchannel:getCount()
	--tell thread to load chunk
	if count > 0 then
	
		--for i = 1,count do
			--print(count)
		
			local chunkeyy = loadchannel:pop()
			
			local data,xxer,yyer
			if chunkeyy then
				data = chunkeyy[1] 
				xxer = chunkeyy[2]
				yyer = chunkeyy[3]
			end
			
			loaded_chunks[xxer][yyer] = data
			--ERROR HERE wen i spam the F5 key ;D (index nil value)
		--end
	end
end

--generates ore
function maplib.generate_ore(tiles)

	local limit = math.random(ore_min, ore_max)
	
	
	if limit ~= 0 then
		for limit = ore_min,ore_max do
			local ore_size_local = math.random(ore_size_min,ore_size_max)
			local x,y = math.random(1,map_max),math.random(1,map_max)
			
			--add this to the x,y
			for xer = -ore_size_local,ore_size_local do
				for yer = -ore_size_local,ore_size_local do
					--stay within map boundaries
					if (x + xer > 0 and x+xer <= map_max) and (y+yer >0 and y + yer <= map_max) then
						tiles[x+xer][y+yer]["block"] = 3
					end
					
				end
			end
		
		
		end
	end

end

--generates caves
function maplib.generate_cave(tiles)

	local limit = math.random(cave_min, cave_max)
	
	
	if limit ~= 0 then
		for limit = 1,limit do
			local cavesize = math.random(cave_size_min,cave_size_max)
			local x,y = math.random(1,map_max),math.random(1,map_max)
			
			--add this to the x,y
			for xer = -cavesize,cavesize do
				for yer = -cavesize,cavesize do
					--stay within map boundaries
					if (x + xer > 0 and x+xer <= map_max) and (y+yer >0 and y + yer <= map_max) then
						--if y+yer > map_max-1 then
						--	print(y+yer)
						--end
						tiles[x+xer][y+yer]["block"] = 1
					end
					
				end
			end
		end
	end

end


--[[
when walking around seemlessly generate chunks

unload chunks that are not visible <-
or
keep all chunks loaded, just do not render them off screen

create a x * x table, set max loaded chunks (x)

render, and modify everything to work correctly with all loaded chunks

]]--

--max_chunks = 1 --x * x chunks loaded --does -1 - 1 (-x to x) -- (x * 2) + 1 to get max chunks in memory

--create stuff
if loaded_chunks == nil then
	loaded_chunks = {} --chunks in memory
end

if not love.filesystem.getInfo("map") then
	love.filesystem.createDirectory( "map" )
end

--generates tile blocks
function maplib.createmap()	
	for xx  = chunkx-max_chunks,chunkx+max_chunks do
		--if loaded_chunks[xx] == nil then
		--	loaded_chunks[xx] = {}
		--end
		for yy  = chunky-max_chunks,chunky+max_chunks do 
				
			local block_exists = love.filesystem.getInfo("/map/"..xx.."_"..yy..".txt")
			
			local number = 0
			local val = 0
			tiles = {}
			--generate map block
			if not block_exists then
				--print(chunky)
				--generate underground
				if chunky+yy <= underground then
					for x = 1,map_max do
						tiles[x] = {}
						for y = 1,map_max do
							tiles[x][y] =  {}
							tiles[x][y]["block"] = 2
										
						end
					end
					maplib.generate_ore(tiles)
					
					maplib.generate_cave(tiles)
				--generate the grass top
				elseif chunky+yy == earth_max then
					local yer = math.random(1,map_max)
					for x = 1,map_max do
						tiles[x] = {}
						yer =  yer + math.random(-1,1)
						if yer == 1 then
							yer = 2
						end
						for y = 1,map_max do
							tiles[x][y] =  {}
							--generate dirt as debug
							if y == yer then
								tiles[x][y]["block"] = 4
							elseif y < yer and y  >= water_height then
								tiles[x][y]["block"] = 5
							elseif y < yer then
								tiles[x][y]["block"] = 1
							else
								tiles[x][y]["block"] = 3
							end								
						end
					end
					--generate trees
					for x = 1,map_max do
					for y = 1,map_max do 
						if tiles[x][y]["block"] == 4 then
						
						-- added on 2018-05-14
							if math.random() > 0.87 then
								tiles = schematics.load(tiles,x,y,tree_schem)
							elseif math.random() < 0.3 then
								tiles[x][y-1]["block"] = 10
							end
						end
					end
					end
				--generate dirt under grass
				elseif chunky+yy < earth_max and chunky+yy > underground then
					--print("test")
					for x = 1, map_max do
						tiles[x] = {}
						for y = 1,map_max do
							tiles[x][y] =  {}
							tiles[x][y]["block"] = 3
										
						end
					end
				else
					--print("generate air")
					for x = 1,map_max do
						tiles[x] = {}
						for y = 1,map_max do
							tiles[x][y] =  {}
							tiles[x][y]["block"] = 1
										
						end
					end
				end
				
				--save
				--love.filesystem.write( "/map/"..xx.."_"..yy..".txt", TSerial.pack(tiles))
				savechannel:push{"save_new",tiles,xx,yy}
				--loaded_chunks[xx][yy] = tiles
			end
		end
	end
	--for xx  = -max_chunks,max_chunks do
	--	for yy  = -max_chunks,max_chunks do 
	--		print(loaded_chunks[xx][yy])
	--	end
	--end
end

--executed in love.draw to draw map

--function maplib.draw()
--	love.graphics.setFont(font)
--	
--	for x = 1,map_max do
--		for y = 1,map_max do
--			love.graphics.setColor(blocks[tiles[x][y]["block"]]["rgb"][1],blocks[tiles[x][y]["block"]]["rgb"][2],blocks[tiles[x][y]["block"]]["rgb"][3],255)
--			love.graphics.print(blocks[tiles[x][y]["block"]]["image"], x*scale, y*scale)
--			if x == math.floor(map_max / 2) and y == math.floor(map_max / 2) then
--				love.graphics.print("X", x*scale, y*scale)
--			end
--		end
--	end
--	
--end
--drawing the map
function maplib.draw()
	--love.graphics.setFont(font)
	for xx  = chunkx-max_chunks,chunkx+max_chunks do
		for yy  = chunky-max_chunks,chunky+max_chunks do
			--draw sky
			
			if yy > underground then
				love.graphics.setColor(65,105,225,255)
				love.graphics.rectangle( "fill", player_drawnx+scale+(map_max*scale*(xx-chunkx))-(player.playerx*scale), player_drawny+scale+(map_max*scale*(chunky-yy))-(player.playery*scale), scale*map_max,scale*map_max )
				love.graphics.setColor(255, 255, 255,255)
			end
			--love.graphics.setColor(255,255,255)
			
			for x = 1,map_max do
				for y = 1,map_max do
					--love.graphics.setColor(blocks[loaded_chunks[xx][-yy][x][y]["block"]]["rgb"][1],blocks[loaded_chunks[xx][-yy][x][y]["block"]]["rgb"][2],blocks[loaded_chunks[xx][-yy][x][y]["block"]]["rgb"][3],255)
					--print(loaded_chunks[xx][-yy][x][y]["block"])
					--local drawx = (((x*scale)-(player.playerx*scale))+((scale*map_max)/2))+(map_max*scale*xx)+offsetx
					--local drawy =  (((y*scale)-((player.playery)*scale))+((scale*map_max)/2))+(map_max*scale*yy)+offsety-4
					
					local drawx = player_drawnx+(x*scale)+(map_max*scale*(xx-chunkx))-(player.playerx*scale)
					local drawy = player_drawny+(y*scale)+(map_max*scale*(chunky-yy))-(player.playery*scale)
					
					
					
					if drawx >= -scale and drawx < love.graphics.getWidth() and drawy >= -scale and drawy < love.graphics.getHeight( ) then
						if loaded_chunks[xx] and loaded_chunks[xx][yy] and loaded_chunks[xx][yy][x] and loaded_chunks[xx][yy][x][y] then
							--print("Drawing")
							love.graphics.draw(texture_table[loaded_chunks[xx][yy][x][y]["block"]],  drawx,drawy,0, scale/16, scale/16)
						end
					end
					--love.graphics.print(,, )
					--if x == math.floor(map_max / 2) and y == math.floor(map_max / 2) then
					--	love.graphics.print("X", x*scale, y*scale)
					--end
				end
			end
			--love.graphics.print(tostring(xx).." "..tostring(yy), (((1*scale)-(player.playerx*scale))+((scale*map_max)/2))+(map_max*scale*xx)+offsetx, (((1*scale)-(player.playery*scale))+((scale*map_max)/2))+(map_max*scale*yy)+offsety-4, 0, 2, 2)
		end
	end
end

function maplib.delete_map()
	if love.filesystem.getInfo("map",isDirectory) then
	
		for _, child in pairs(love.filesystem.getDirectoryItems("map")) do
			love.filesystem.remove("map/" .. child);
		end
	elseif love.filesystem.isFile(item) then
		love.filesystem.remove("map");
	end
	
	print("generating new map")
	chunkx,chunky = math.random(-1000,1000),1
	maplib.createmap()
end

flowtimer = 0

--make liquids flow
function maplib.liquid_flow(dt)
	flowtimer = flowtimer + dt
	
	local after_table = {}
	if flowtimer > 0.1 then
		flowtimer = 0
		for xx  = chunkx-max_chunks,chunkx+max_chunks do
			--if not after_table[xx] then
			--	after_table[xx] = {}
			--end
			for yy  = chunky-max_chunks,chunky+max_chunks do
				--if not after_table[xx][yy] then
				--	after_table[xx][yy] = {}
				--end
				for x = 1,map_max do
					--if not after_table[xx][yy][x] then
					--	after_table[xx][yy][x] = {}
					--end
					
					for y = 1,map_max do
						--if not after_table[xx][yy][x][y] then
						--	after_table[xx][yy][x][y] = {}
						--end
						if loaded_chunks[xx] and loaded_chunks[xx][yy] and loaded_chunks[xx][yy][x] and loaded_chunks[xx][yy][x][y] then

							
							local block = loaded_chunks[xx][yy][x][y]["block"]
							
							--if block == 5 then
							--	print(yy-1)
							--end
							--downward flow
							if blocks[block]["prop"] == "liquid"  and y + 1 <= map_max and loaded_chunks[xx][yy][x][y+1]["block"] == 1  then
								if not after_table[xx] then
									after_table[xx] = {}
								end
								if not after_table[xx][yy] then
									after_table[xx][yy]  = {}
								end
								if not after_table[xx][yy][x] then
									after_table[xx][yy][x] = {}
								end
								if not after_table[xx][yy][x][y+1] then
									after_table[xx][yy][x][y+1]= {}
								end
								
								after_table[xx][yy][x][y+1]["block"] = block
								after_table[xx][yy][x][y+1]["down"] = "down"
							--flow into new chunk -1 y
							elseif blocks[block]["prop"] == "liquid"  and y + 1 > map_max and loaded_chunks[xx] and loaded_chunks[xx][yy-1] and loaded_chunks[xx][yy-1][x] and loaded_chunks[xx][yy-1][x][1] and loaded_chunks[xx][yy-1][x][1]["block"] == 1  then
								--print("flow down")
								--forward workaround for table sub elements that have not been created
								if not after_table[xx] then
									after_table[xx] = {}
								end
								if not after_table[xx][yy-1] then
									after_table[xx][yy-1]  = {}
								end
								if not after_table[xx][yy-1][x] then
									after_table[xx][yy-1][x] = {}
								end
								if not after_table[xx][yy-1][x][1] then
									--print("create new block element success")
									after_table[xx][yy-1][x][1]= {}
								end
								after_table[xx][yy-1][x][1]["block"] = block
								after_table[xx][yy-1][x][1]["newy"] = "newy"
							end
							--rightward flow
							if blocks[block]["prop"] == "liquid"  and x + 1 <= map_max and loaded_chunks[xx][yy][x+1][y]["block"] == 1  then
								if not after_table[xx] then
									after_table[xx] = {}
								end
								if not after_table[xx][yy] then
									after_table[xx][yy]  = {}
								end
								if not after_table[xx][yy][x+1] then
									after_table[xx][yy][x+1] = {}
								end
								if not after_table[xx][yy][x+1][y] then
									after_table[xx][yy][x+1][y]= {}
								end
								after_table[xx][yy][x+1][y]["block"] = block
								after_table[xx][yy][x+1][y]["right"] = "right"
							--flow into new chunk +1 x
							elseif blocks[block]["prop"] == "liquid"  and x == map_max and loaded_chunks[xx+1] and loaded_chunks[xx+1][yy] and loaded_chunks[xx+1][yy][1] and loaded_chunks[xx+1][yy][1][y] and loaded_chunks[xx+1][yy][1][y]["block"] == 1  then
								--hack to create new table sub element
								if not after_table[xx+1] then
									after_table[xx+1] = {}
								end
								if not after_table[xx+1][yy] then
									after_table[xx+1][yy]  = {}
								end
								if not after_table[xx+1][yy][1] then
									after_table[xx+1][yy][1] = {}
								end
								if not after_table[xx+1][yy][1][y] then
									--print("create new block element success")
									after_table[xx+1][yy][1][y]= {}
								end
								--print(after_table[xx+1][yy][1][y]["block"])
								after_table[xx+1][yy][1][y]["block"] = block
								after_table[xx+1][yy][1][y]["xright"] = "xright"
							end
							--print(xx-1)
							--leftward flow
							if blocks[block]["prop"] == "liquid"  and x - 1 >= 1 and loaded_chunks[xx][yy][x-1][y]["block"] == 1  then
								if not after_table[xx] then
									after_table[xx] = {}
								end
								if not after_table[xx][yy] then
									after_table[xx][yy]  = {}
								end
								if not after_table[xx][yy][x-1] then
									after_table[xx][yy][x-1] = {}
								end
								if not after_table[xx][yy][x-1][y] then
									after_table[xx][yy][x-1][y]= {}
								end
								after_table[xx][yy][x-1][y]["block"] = block
								after_table[xx][yy][x-1][y]["left"] = "left"
							--flow into new chunk -1 x
							elseif blocks[block]["prop"] == "liquid"  and x == 1 and loaded_chunks[xx-1] and loaded_chunks[xx-1][yy] and loaded_chunks[xx-1][yy][map_max] and loaded_chunks[xx-1][yy][map_max][y] and loaded_chunks[xx-1][yy][map_max][y]["block"] == 1  then
								--print("Test")
								--hack to create new table sub element
								if not after_table[xx-1] then
									after_table[xx-1] = {}
								end
								if not after_table[xx-1][yy] then
									after_table[xx-1][yy]  = {}
								end
								if not after_table[xx-1][yy][map_max] then
									after_table[xx-1][yy][map_max] = {}
								end
								if not after_table[xx-1][yy][map_max][y] then
									--print("create new block element success")
									after_table[xx-1][yy][map_max][y]= {}
								end
								--print(after_table[xx-1][yy][map_max][y]["block"])
								after_table[xx-1][yy][map_max][y]["block"] = block
								after_table[xx-1][yy][map_max][y]["xleft"] = "xleft"
							end
							--love.graphics.draw(texture_table[loaded_chunks[xx][yy][x][y]["block"]],  (((x*scale)-(player.playerx*scale))+((scale*map_max)/2))+(map_max*scale*xx)+offsetx, (((y*scale)-(player.playery*scale))+((scale*map_max)/2))+(map_max*scale*yy)+offsety-4,0, scale/16, scale/16)
					
						end
					end
				end
			end
		end
	end
	--a hack to delay water flow
	for keyxx,valuexx in pairs(after_table) do
		for keyyy,valueyy in pairs(valuexx) do
			for keyx, valuex in pairs(valueyy) do
				for keyy,valuey in pairs(valuex) do
					if valuey["block"] ~= nil then
						--flowing
						if valuey["down"] == "down" then
							loaded_chunks[keyxx][keyyy][keyx][keyy]["block"] = valuey["block"]
						end
						if valuey["right"] == "right" then
							loaded_chunks[keyxx][keyyy][keyx][keyy]["block"] = valuey["block"]
						end
						if valuey["left"] == "left" then
							loaded_chunks[keyxx][keyyy][keyx][keyy]["block"] = valuey["block"]
						end
						--flowing to new chunk
						if valuey["newy"] == "newy" then
							--print(keyy)
							loaded_chunks[keyxx][keyyy][keyx][keyy]["block"] = valuey["block"]
						end
						if valuey["xright"] == "xright" then
							--print(keyy)
							loaded_chunks[keyxx][keyyy][keyx][keyy]["block"] = valuey["block"]
						end
						if valuey["xleft"] == "xleft" then
							--print(keyy)
							loaded_chunks[keyxx][keyyy][keyx][keyy]["block"] = valuey["block"]
						end
					end
				end
			end
		end
	end
end
--[[ a test
for x = 1,10 do
	local line = ""
	for y = 1,10 do
		line = line..tiles.x.y
	end
	print(line.."\n")
end

]]--
