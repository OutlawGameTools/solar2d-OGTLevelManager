local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------
local lm = require("ogt_levelmanager")

-- most commonly used screen coordinates
-- thanks to crawlSpaceLib for initial set
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.contentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.contentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

local function backToLevels(event)
	composer.gotoScene ( "chooselevel", {effect="fade"} )
	return true
end

local function numStarsTapped(event)
	lm.updateStars(event.target.numStars)
	if event.target.numStars > 0 then
		lm.unlockNextLevel()
		backToLevels(event)
	end
	return true
end

-- local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
	local bg = display.newImage( "images/skybox_3.jpg" )
	bg.width = 1024
	bg.height = 768
	bg.x = centerX
	bg.y = centerY
	sceneGroup:insert( bg )

	local title = display.newEmbossedText( sceneGroup, "Level 3", centerX, 40, "Helvetica", 68 )

	local stars = display.newEmbossedText( sceneGroup, "How Many Stars Did You Earn?", centerX, 100, "Helvetica", 32 )
	
	local zero = display.newText( sceneGroup, "0", screenWidth/5 * 1, 200, "Helvetica", 44 )
	zero.numStars = 0
	zero:addEventListener("tap", numStarsTapped)
	local one = display.newText( sceneGroup, "1", screenWidth/5 * 2, 200, "Helvetica", 44 )
	one.numStars = 1
	one:addEventListener("tap", numStarsTapped)
	local two = display.newText( sceneGroup, "2", screenWidth/5 * 3, 200, "Helvetica", 44 )
	two.numStars = 2
	two:addEventListener("tap", numStarsTapped)
	local three = display.newText( sceneGroup, "3", screenWidth/5 * 4, 200, "Helvetica", 44 )
	three.numStars = 3
	three:addEventListener("tap", numStarsTapped)

end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        
        composer.removeScene( "chooselevel" )
        
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
