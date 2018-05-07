--the pause menu

pause = false

--menu items
pause_menu_items = {
"GRAPHICS",
"VOLUME",
"WORLD",
"HELP",
"EXIT"
}

pause_menu_submenu = nil

function pause_game()
	local x, y = love.mouse.getPosition( )
	local starter_y = 250
	local ier = 0
	pause_menu_submenu = nil
	
	--verifier si position de la souris sur un bouton
	for _,item in pairs(pause_menu_items) do
	--screenwidth
		if x > screenwidth/2-(fontbig:getWidth(item)/2)-2 and screenwidth/2-(fontbig:getWidth(item)/2)-2 +fontbig:getWidth(item) and 
	--	if x > love.graphics.getWidth( )/2-(fontbig:getWidth(item)/2)-2 and love.graphics.getWidth( )/2-(fontbig:getWidth(item)/2)-2 +fontbig:getWidth(item) and 
			y > starter_y-9+(ier*100) and y < starter_y-9+(ier*100) +  fontbig:getHeight(item) then
			pause_menu_submenu = item
		end
		ier = ier + 1
	end
	
	--liste des actions selon les boutons
	if love.mouse.isDown(1) then
		if pause_menu_submenu == "GRAPHICS" then
			render_graphics_menu()
		end
		if pause_menu_submenu == "VOLUME" then
			render_volume_menu()
		end
		if pause_menu_submenu == "WORLD" then
			render_world_menu()
		end
		if pause_menu_submenu == "HELP" then
			print ("NO HELP FOR YOU !")
		end
		if pause_menu_submenu == "EXIT" then
			exit_game()
		end
	end
end

function exit_game()
	maplib.save_chunks()
	--save in %appdata% (Windows system)
	love.filesystem.write( "/map/player.txt", TSerial.pack({inventory,chunkx,chunky,player.playerx,player.playery}))
	print("saving...")
	love.timer.sleep(1)
	love.event.push('quit')
end

function render_graphics_menu()
	print ("graphics menu")
end

function render_volume_menu()
	print ("Volume menu")
	love.graphics.setColor(1,0,0,255) -- rouge (debug visible)
	love.graphics.setFont(hugefont)
	love.graphics.print("VOLUME", 0,0)
	print ("ok")
	
	--lorsqu'on sortira du menu ne pas oublier d'apeller l'affichage du menu de base render_pause_menu() )
end

function render_world_menu()
	print ("World menu")
end

function render_pause_menu()
	
	--menu title
	--Shadow
	love.graphics.setColor(0.1,0.1,0.5,1)
	love.graphics.setFont(hugefont)
	love.graphics.print("GAME MENU", love.graphics.getWidth( )/2-(hugefont:getWidth("GAME MENU")/2)-10,40)
	--text
	love.graphics.setColor(0.2,0.5,1,1)
	love.graphics.setFont(hugefont)
	love.graphics.print("GAME MENU", love.graphics.getWidth( )/2-(hugefont:getWidth("GAME MENU")/2),50)
	
	--directories
	
	local starter_y = 250
	local ier = 0
	
	for _,item in pairs(pause_menu_items) do
		--selection
		if pause_menu_submenu == item then
			love.graphics.setColor(1,0.2,0.2,1)
			love.graphics.rectangle( "fill", love.graphics.getWidth( )/2-(fontbig:getWidth(item)/2)-5, starter_y-9+(ier*100)-5,fontbig:getWidth(item)+10, fontbig:getHeight(item)+10 )
		end
		-- Background of item
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle( "fill", love.graphics.getWidth( )/2-(fontbig:getWidth(item)/2)-2, starter_y-9+(ier*100),fontbig:getWidth(item), fontbig:getHeight(item) )
		---
		love.graphics.setColor(0,1,1,1)
		love.graphics.setFont(fontbig)
		-- debug for center text in height (y -7)
		love.graphics.print(item, love.graphics.getWidth( )/2-(fontbig:getWidth(item)/2),starter_y+(ier*100)-7)
		
		
		
		ier = ier + 1
	end
	love.graphics.setColor(0.1,0.1,0.5,255)
end
