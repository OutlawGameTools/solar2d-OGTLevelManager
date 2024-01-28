local composer = require( "composer" )

local scene = composer.newScene()

local widget = require("widget")

local lm = require("ogt_levelmanager")

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.safeScreenOriginX
local screenWidth = display.viewableContentWidth -- screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

print (screenLeft)
print (screenWidth)

local title
local slider
local scoreText

local function backToLevels(event)
	composer.gotoScene ( "chooselevel", {effect="fade"} )
	return true
end

local function numStarsTapped(event)
	local numStars = event.target.numStars
	lm.updateStars(numStars)
	lm.updateScore(tonumber(scoreText.text))
	if numStars > 0 then
		lm.unlockNextLevel()
	end
	backToLevels(event)
	return true
end

local function sliderListener(event)
	scoreText.text = event.value * 10
	return true
end

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
	local eforest02 = display.newImage( "images/eforest02.jpg" )
	eforest02.width = 1024
	eforest02.height = 768
	eforest02.x = centerX
	eforest02.y = centerY
	sceneGroup:insert( eforest02 )

	title = display.newEmbossedText( sceneGroup, "Level 0", centerX, 40, "Helvetica", 68 )

	local stars = display.newEmbossedText( sceneGroup, "How Many Stars Did You Earn?", centerX, 100, "Helvetica", 32 )
	
	local zero = display.newText( sceneGroup, "0", screenWidth/5 * 1, 180, "Helvetica", 44 )
	zero.numStars = 0
	zero:addEventListener("tap", numStarsTapped)
	local one = display.newText( sceneGroup, "1", screenWidth/5 * 2, 180, "Helvetica", 44 )
	one.numStars = 1
	one:addEventListener("tap", numStarsTapped)
	local two = display.newText( sceneGroup, "2", screenWidth/5 * 3, 180, "Helvetica", 44 )
	two.numStars = 2
	two:addEventListener("tap", numStarsTapped)
	local three = display.newText( sceneGroup, "3", screenWidth/5 * 4, 180, "Helvetica", 44 )
	three.numStars = 3
	three:addEventListener("tap", numStarsTapped)
	
	-- Create a slider widget
	slider = widget.newSlider ({
		left = 150,
		top = 250,
		width = 200,
		height = 200,
		value = 0,
		orientation = "horizontal",
		listener = sliderListener
	})
	sceneGroup:insert(slider)
	
	local score = display.newText( sceneGroup, "Score:", slider.x-90, slider.y, "Helvetica", 40 )
	scoreText = display.newText( sceneGroup, "0", slider.x+slider.width+40, slider.y, "Helvetica", 40 )

end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        
        title.text = "Level " .. lm.currentLevel
        slider:setValue(lm.getLevelScore()/10)
        scoreText.text = lm.getLevelScore()
        
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
