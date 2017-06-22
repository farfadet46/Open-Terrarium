--the map library
maplib = {}


--create tiles
mapheight = 48
mapwidth  = 30
tiles = {}

--generates tile blocks
function maplib.createmap()
	local map_exists = love.filesystem.exists("map")

	if not map_exists then
		for x = 1,mapwidth do
			tiles[x] = {}
			for y = 1,mapheight do
				local value = love.math.noise( x/mapwidth, y/mapheight )
				tiles[x][y] =  {}
				if value > 0.5 then
					tiles[x][y]["block"] = 1--love.math.random(0,1)
				else
					tiles[x][y]["block"] = 0
				end
					
			end
		end
		
		
		
		love.filesystem.createDirectory( "map" )
	
		love.filesystem.write( "/map/testmap.txt", TSerial.pack(tiles))
	else
		
		tiles = TSerial.unpack(love.filesystem.read("/map/testmap.txt"))
	end
	
	

	
	


end

--executed in love.draw to draw map
function maplib.draw()
	love.graphics.setFont(font)
	love.graphics.setColor(255,255,255,255)
	for x = 1,mapwidth do
		for y = 1,mapheight do
			local graphic
			if tiles[x][y]["block"] == 0 then
				graphic = "" --air
			elseif tiles[x][y]["block"] == 1 then
				graphic = "#" --stone
			elseif tiles[x][y]["block"] == 2 then
				graphic = "/" --stairs
			end
			love.graphics.print(graphic, x*scale, y*scale)
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
