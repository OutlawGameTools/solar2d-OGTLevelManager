--[[ ==========================================

	** Change settings in the ogt_lmdata.lua 
	file, not this file! **
	
  Outlaw Game Tools Level Manager (OGTLM) v1.8
  Copyright 2013-2024 Jay Jennings
  
 MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
--===========================================]]

local k = require("ogt_lmdata") -- tweak the variables in this file!

local sceneMgr = require( "composer" ) -- or use "storyboard"

local GGData = require( "GGData" )

--snippet table.show

-- most commonly used screen coordinates
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

print(screenLeft)
print(screenWidth)
print(screenRight)
print(screenTop)
print(screenHeight)
print(screenBottom)

local grid = {}
local prevArrow
local nextArrow
local entryXOffset
local imgPfx = k.imagePrefix or ""
local audPfx = k.audioPrefix or ""

local selectSound
local nextPageSound
local prevPageSound

local swipeOGTLM
local bgswiper

local checkSwipeDirection

local lastTileYPos

local isSliding = false
--==============================================================
-- pass in the sound handle and play if audioOn is true.
local function playAudio(snd)
	if k.audioOn and snd then
		audio.play ( snd )
	end
end

--==============================================================
-- hide both the next/prev arrows.
local function hideArrows()
	isSliding = true
	if k.nextImage and k.prevImage then
		prevArrow.isVisible = false
		nextArrow.isVisible = false
	end
end

--==============================================================
-- show the page dots when they should be visible.
k.pageDotsGroup = display.newGroup()
local function showPageDots()
	if k.showPageDots and k.numPages > 1 then
		
		local dotsWidth = (k.numPages * (k.pagesDotRadius) + (k.numPages-1) * k.pageDotsSpacing)
		local xPos = centerX - dotsWidth/2-- - k.pageDotsSpacing - (k.pagesDotRadius/2)
		
		if k.pageDotsGroup.remove then
			k.pageDotsGroup:removeSelf()
		end
		k.pageDotsGroup = display.newGroup()
		for x=1, k.numPages do
			local dot = display.newCircle(k.pageDotsGroup, 1, 1, k.pagesDotRadius)
			dot.x = xPos
			dot.y = lastTileYPos + k.pageDotsYOffset
			xPos = xPos + k.pageDotsSpacing + k.pagesDotRadius
			dot:setFillColor(unpack(k.pageDotsColorTable))
			if k.currentPage == x then
				dot:scale(k.pagesDotScale, k.pagesDotScale)
			end
		end
		k.sceneGroup:insert(k.pageDotsGroup)
	end

end

--==============================================================
-- show the next/prev arrows when they should be visible.
local function showArrows()
	if k.nextImage and k.prevImage then
		prevArrow.isVisible = (k.currentPage ~= 1)
		nextArrow.isVisible = (k.currentPage < k.numPages)
	end
	showPageDots()
	isSliding = false
end
	
local function slideLeft(event)
	hideArrows()
	transition.to ( grid, {time=k.slideTime, x=grid.x-screenWidth, onComplete=showArrows} )
end

local function slideRight(event)
	hideArrows()
	transition.to ( grid, {time=k.slideTime, x=grid.x+screenWidth, onComplete=showArrows} )
end

local function prevPage(event)
	if k.currentPage > 1 then
		k.currentPage = k.currentPage - 1
		slideRight()
		playAudio(prevPageSound)
	end
	return true
end
local function prevArrowTouched(event)
	if event.phase == "began" then
		prevPage()
	end
	return true
end

local function nextPage(event)
	if k.currentPage < k.numPages then
		k.currentPage = k.currentPage + 1
		slideLeft()
		playAudio(nextPageSound)
	end
	return true
end
local function nextArrowTouched(event)
	if event.phase == "began" then
		nextPage()
	end
	return true
end


local function selectLevel(event)
	-- if event.phase ~= nil then
	-- 	print("in selectLevel phase = " .. event.phase)
	-- end
	-- 
	-- if event.phase ~= "ended" then
	-- 	 return
	--  end
	-- print("in selectLevel")
	-- print(checkSwipeDirection())
	-- if checkSwipeDirection() ~= "none" then
	-- 	return
	-- end
	-- save the current page so we can come back to that later
	if k.rememberPage then
		local levelInfo  = GGData:new( k.dataFile )
		levelInfo.currentPage = k.currentPage
		levelInfo:save()
	end
	playAudio(selectSound)
	k.currentLevel = event.target.levelNum
	k.displayText = event.target.displayText
	local newScene = k.playScene or k.sequentialScene .. tostring(k.currentLevel)
	if k.sceneNames and k.sceneNames[levelNum] then
		newScene = k.sceneNames[levelNum]
	end
	local function goto()
		event.target.xScale = 1
		event.target.yScale = 1
		if k.cancelLeave then
			if k.swipe then
				bgswiper:addEventListener ( "touch", swipeOGTLM ) -- put the event listener back on if we're not leaving
			end
		else
			sceneMgr.gotoScene ( newScene, {effect=k.transitionEffect, time=k.transitionTime} )
		end
		k.cancelLeave = false -- reset this every time
	end

	if k.swipe then
		--print("Killing swipeOGTLM inside selectLevel")
		bgswiper:removeEventListener("touch", swipeOGTLM)
	end

	-- is there something we need to do before switching scenes?
	if k.beforeLeaving then
		k.beforeLeaving(k.currentLevel)
	end
		
	-- give the user visual feedback that the level was touched
	transition.to(event.target, {time = 50, xScale = 1.2, yScale=1.2, onComplete=goto})

	return true
end


local bDoingTouch
local mAbs = math.abs
local xDistance
local yDistance
local totalSwipeDistanceLeft
local beginX
local beginY

function checkSwipeDirection()
	if bDoingTouch == true then
		local dir = "none"
		xDistance =  mAbs(endX - beginX) -- abs will return the absolute, or non-negative value, of a given value. 
		yDistance =  mAbs(endY - beginY)
		if xDistance > yDistance then
			if beginX > endX then
				totalSwipeDistanceLeft = beginX - endX
				if totalSwipeDistanceLeft > k.minSwipeDistance then
					dir = "left"
				end
			else 
				totalSwipeDistanceRight = endX - beginX
				if totalSwipeDistanceRight > k.minSwipeDistance then
					dir = "right"
				end
			end
		else 
			if beginY > endY then
				totalSwipeDistanceUp = beginY - endY
				if totalSwipeDistanceUp > k.minSwipeDistance then
					dir = "up"
				end
			else 
				totalSwipeDistanceDown = endY - beginY
				if totalSwipeDistanceDown > k.minSwipeDistance then
					dir = "down"
				end
			end
		end
		return dir
	end
end


function swipeOGTLM(event)
	if event.phase == "began" then
		bDoingTouch = true
		beginX = event.x
		beginY = event.y
	end
	if event.phase == "ended" then
		endX = event.x
		endY = event.y
		--print("endX, endY" , endX, endY)
		--if profSprite.busy == false then
			local dir = checkSwipeDirection()
			if dir == "none" then
				-- what about a tap?
				
			else
				--print("dir", dir)
				--moveProf( dir )
				if dir == "left" then
					nextPage()
				elseif dir == "right" then
					prevPage()
				end
			end
			bDoingTouch = false
		--end
	end
end


--==============================================================
-- get all the saved data and init if this is the first time.
local function loadData()
	local levelInfo  = GGData:new( k.dataFile )

	if k.rememberPage then
		k.currentPage = levelInfo.currentPage or 1
	end
	levelInfo.currentPage = k.currentPage
	
	k.userName = levelInfo.userName or "UserName"
	levelInfo.userName = k.userName
	
	k.audioOn = levelInfo.audioOn or true
	levelInfo.audioOn = k.audioOn
	if k.selectSoundFile then
		selectSound = audio.loadSound ( audPfx .. k.selectSoundFile )
	end
	if k.nextPageSoundFile then
		nextPageSound = audio.loadSound ( audPfx .. k.nextPageSoundFile )
	end
	if k.prevPageSoundFile then
		prevPageSound = audio.loadSound ( audPfx .. k.prevPageSoundFile )
	end
	
	if levelInfo.locked == nil then
		--print ( k.numUnlocked )
		for x = 1, k.totalLevels do
			local locked = false
			if x > k.numUnlocked then
				locked = true
			end
			k.levelLocked[x] = locked
		end
	else
		k.levelLocked = levelInfo.locked
		--if we now have more levels than before, increase lock table
		if #k.levelLocked < k.totalLevels then
			for x = #k.levelLocked+1, k.totalLevels do
				k.levelLocked[x] = 0
			end			
		end
	end
	levelInfo.locked = k.levelLocked

	if levelInfo.starsOnLevel == nil then
		for x = 1, k.totalLevels do
			k.starsOnLevel[x] = 0
		end
	else
		k.starsOnLevel = levelInfo.starsOnLevel
		--if we now have more levels than before, increase star table
		if #k.starsOnLevel < k.totalLevels then
			for x = #k.starsOnLevel+1, k.totalLevels do
				k.starsOnLevel[x] = 0
			end			
		end
	end
	levelInfo.starsOnLevel = k.starsOnLevel

	if levelInfo.levelScores == nil then
		for x = 1, k.totalLevels do
			k.levelScores[x] = 0
		end
	else
		k.levelScores = levelInfo.levelScores
		--if we now have more levels than before, increase score table
		if #k.levelScores < k.totalLevels then
			for x = #k.levelScores+1, k.totalLevels do
				k.levelScores[x] = 0
			end			
		end
	end
	levelInfo.levelScores = k.levelScores
	
	levelInfo:save()
end

local function getImageSize(img)
	-- get the width and height of a specific image
	-- useful for inside display.newImageRect
	local width = 0
	local height = 0
	local tile = display.newImage(img)
	if tile then
		width = tile.width
		height = tile.height
		display.remove( tile )
	end
	return width,height
end

function k.init(grp, pageNum)
	-- pass in the group from composer scene file
	-- optionally pass in specific page to display

	k.sceneGroup = grp

	if k.swipe then
		bgswiper = display.newRect( grp, screenLeft, screenTop, screenWidth, screenHeight )
		bgswiper.x = centerX
		bgswiper.y = centerY
		bgswiper.alpha = .01
		--print("STARTINGSWIPER")
		bgswiper:addEventListener("touch", swipeOGTLM)
	end
	
	--print("INSIDE ogt_levelmanager:init")	
	loadData()
	
	if pageNum then k.currentPage = pageNum end
	
	if k.backgroundImage then
		local bgWidth, bgHeight = getImageSize(imgPfx .. k.backgroundImage)
		local bg = display.newImageRect ( imgPfx .. k.backgroundImage, bgWidth, bgHeight )
		bg.x = centerX
		bg.y = centerY
		if grp then
			grp:insert(bg)
		end
	end
	
	-- grab the size of things for later use
	if k.levelSquareImage then k.tileWidth, k.tileHeight = getImageSize(imgPfx .. k.levelSquareImage) end
	if k.starImage then k.starWidth, k.starHeight = getImageSize(imgPfx .. tostring(k.starImage)) end
	if k.lockImage then k.lockWidth, k.lockHeight = getImageSize(imgPfx .. tostring(k.lockImage)) end
	if k.prevImage then k.prevWidth, k.prevHeight = getImageSize(imgPfx .. tostring(k.prevImage)) end
	if k.nextImage then k.nextWidth, k.nextHeight = getImageSize(imgPfx .. tostring(k.nextImage)) end

	grid = k.makeGrid()

	if grp then
		grp:insert(grid)
	end
	
	--put in next/prev arrows
	if k.nextImage and k.prevImage then
		prevArrow = display.newImageRect ( grp, imgPfx .. k.prevImage, k.prevWidth, k.prevHeight )
		prevArrow.x = screenLeft + (k.prevWidth/2) + k.prevOffsetX
		prevArrow.y = centerY + k.prevOffsetY
		prevArrow:addEventListener("touch", prevArrowTouched)
		
		nextArrow = display.newImageRect ( grp, imgPfx .. k.nextImage, k.nextWidth, k.nextHeight )
		nextArrow.x = screenRight - (k.nextWidth/2) + k.nextOffsetX
		nextArrow.y = centerY + k.nextOffsetY
		nextArrow:addEventListener("touch", nextArrowTouched)

		showArrows()
	else
		showPageDots()
	end
end


function k.makeGrid(pageNum)
	--========================================
	-- grid code
	--========================================
	-- returns a display group holding all the goodies
	
	local tmpGrid = display.newGroup ( )
	
	local currPage = pageNum or k.currentPage
	
	local xPos
	local yPos
	local levelNum = 0
	lastTileYPos = 0
	
	for page = 1, k.numPages do
		xPos = (centerX + ((page-1) * screenWidth) + k.gridOffsetX) - (k.numCols * k.tileWidth + k.numCols * k.colSpace) / 2
		yPos = (centerY + k.gridOffsetY) - (k.numRows * k.tileHeight + k.numRows * k.rowSpace) / 2
		for row = 1, k.numRows do
			for col = 1, k.numCols do
				levelNum = levelNum + 1
				if levelNum <= k.totalLevels then
					local tile
					if k.customLevel then
						tile = k.customLevel(levelNum)
						tmpGrid:insert(tile)
					else
						tile = display.newImageRect(tmpGrid, imgPfx .. k.levelSquareImage, k.tileWidth, k.tileHeight)
					end
					tile.x = xPos + (col * (k.tileWidth + k.colSpace) - k.tileWidth/2 - k.colSpace/2)
					tile.y = yPos + row * (k.tileHeight + k.rowSpace) - k.tileHeight/2 - k.rowSpace/2
					tile.gridPos = {x=col, y=row}
					tile.levelNum = levelNum

					local levelNumText
					local dispText = tostring(levelNum)
					if k.showLevelNum then
						--print("k.levelLocked[levelNum]", k.levelLocked[levelNum])
						if not k.levelLocked[levelNum] or (k.levelLocked[levelNum] and k.showLevelNumTextWhenLocked) then	
							if k.tileNums and k.tileNums[levelNum] then
								dispText = k.tileNums[levelNum]
							end
							if k.levelNumEmbossedFont then
								levelNumText = display.newEmbossedText(tmpGrid, dispText, tile.x, tile.y, k.levelNumFontName, k.levelNumFontSize )
							else
								levelNumText = display.newText(tmpGrid, dispText, tile.x, tile.y, k.levelNumFontName, k.levelNumFontSize )
							end
							levelNumText.x = levelNumText.x + k.levelNumTextXOffset
							levelNumText.y = levelNumText.y + k.levelNumTextYOffset
							levelNumText:setFillColor(k.levelNumFontColor[1], k.levelNumFontColor[2], k.levelNumFontColor[3])
						 end
					end
					tile.displayText = dispText
					
					-- do we need a lock on here?
					if k.levelLocked[levelNum] and k.lockImage then
						local lock = display.newImageRect ( tmpGrid, imgPfx .. k.lockImage, k.lockWidth, k.lockHeight )
						lock.x = tile.x + k.lockOffsetX
						lock.y = tile.y + k.lockOffsetY
					end
							
					-- do we need stars on the level?
					if k.starImage and not k.levelLocked[levelNum] then
						if levelNum == 31 then
							--print(table.show(k.starsOnLevel))
						end
						--print(levelNum, #k.starsOnLevel, k.starsOnLevel[levelNum])
						for i = 1, k.maxStars do
							local starX = (tile.x - tile.width/2) + (i * (tile.width/(k.maxStars+1)))
							local star = display.newImageRect(tmpGrid, imgPfx .. k.starImage, k.starWidth, k.starHeight)
							star.x = starX + k.starOffsetX + (k.singleStarOffsetX[i] or 0)
							star.y = tile.y + tile.height/2 - star.height/2 + k.starOffsetY + (k.singleStarOffsetY[i] or 0)
							if i > k.starsOnLevel[levelNum] and k.showMissingStar then
								star.alpha = .3
							elseif i > k.starsOnLevel[levelNum] and not k.showMissingStar then
								star.alpha = 0
							end
						end
					end
					
					-- should we show a score for the level?
					local scoreText
					if k.showScore and (not k.levelLocked[levelNum] or (k.levelLocked[levelNum] and k.showScoreWhenLocked)) then	
						local scoreT = k.getLevelScore(levelNum)
						scoreT = (k.scorePrefix or "") .. scoreT .. (k.scoreSuffix or "")
						if k.scoreEmbossedFont then
							scoreText = display.newEmbossedText(tmpGrid, scoreT, tile.x, tile.y, k.scoreFontName, k.scoreFontSize )
						else
							scoreText = display.newText(tmpGrid, scoreT, tile.x, tile.y, k.scoreFontName, k.scoreFontSize )
						end
						scoreText.x = tile.x + k.scoreTextXOffset
						scoreText.y = tile.y + tile.height/2 + scoreText.height/2 + k.scoreTextYOffset
						scoreText:setFillColor(k.scoreFontColor[1], k.scoreFontColor[2], k.scoreFontColor[3])
					 end
					
										
					if not k.levelLocked[levelNum] then
						-- since level is unlocked, make it clickable
						--print("adding tap listener")
						tile:addEventListener("tap", selectLevel)
					end
					
					local thisTileYPos = tile.y + tile.height/2
					if thisTileYPos ~= nil and thisTileYPos > lastTileYPos then
						lastTileYPos = thisTileYPos
						if scoreText then lastTileYPos = lastTileYPos + scoreText.height end
					end

				end
			end
		end
	end
	-- see if we need to start on page 1 or page we last came from.
	if k.rememberPage then
		tmpGrid.x = tmpGrid.x - ((k.currentPage - 1) * screenWidth)
	end
	return tmpGrid
end

--==============================================================
-- should the audio clicks play or not?
-- onOrOff - boolean true or false (true = audio plays)
function k.updateAudio(onOrOff)
	local levelInfo = GGData:new( k.dataFile )
	levelInfo.audioOn = onOrOff or true
	levelInfo:save()
end

--==============================================================
-- save the score for a given level
-- score - the score to be saved
-- lvl - the level for the score, or k.currentLevel is left blank.
function k.updateScore(score, lvl)
	local levelNum = lvl or k.currentLevel
	local levelInfo = GGData:new( k.dataFile )
	levelInfo.levelScores[levelNum] = score
	levelInfo:save()
end

--==============================================================
-- returns the score saved for the level passed in, 
-- or k.currentLevel.
function k.getLevelScore(lvl)
	local levelNum = lvl or k.currentLevel
	local levelInfo = GGData:new( k.dataFile )
	local score = levelInfo.levelScores[levelNum]
	return score
end

--==============================================================
-- returns the username for the dataFile passed in, 
-- or k.dataFile if left blank
function k.getUserName(dataFile)
	local dFile = dataFile or k.dataFile
	local levelInfo = GGData:new( dFile )
	local userName = levelInfo.userName
	return userName
end

--==============================================================
-- save userName to dataFile or k.dataFile if left blank.
function k.updateUserName(uname, dataFile)
	local dFile = dataFile or k.dataFile
	local levelInfo = GGData:new( dFile )
	levelInfo.userName = uname
	levelInfo:save()
end

--==============================================================
-- save numStars to lvl or k.currentLevel if left blank.
function k.updateStars(numStars, lvl)
	local levelNum = lvl or k.currentLevel
	local levelInfo = GGData:new( k.dataFile )
--	if numStars > levelInfo.starsOnLevel[levelNum] then
--		levelInfo.starsOnLevel[levelNum] = numStars
--		levelInfo:save()
--	end
		levelInfo.starsOnLevel[levelNum] = numStars
		levelInfo:save()
end

function k.getLevelStars(lvl)
	local levelNum = lvl or k.currentLevel
	local levelInfo = GGData:new( k.dataFile )
	local numStars = levelInfo.starsOnLevel[levelNum]
	return numStars
end

--==============================================================
-- lock is true or false, whether the level lvl is locked or not.
function k.updateLock(lock, lvl)
	local levelNum = lvl or k.currentLevel+1
	local lock = lock or false
	--print("levelNum", levelNum)
	if levelNum > 0 and levelNum <= k.totalLevels then
		local levelInfo = GGData:new( k.dataFile )
		levelInfo.locked[levelNum] = lock
		levelInfo:save()
	end
end
-- just a shortcut that can be used to call the previous function.
function k.unlockNextLevel()
	k.updateLock()
end

-- is the specified level locked?
function k.getLockStatus(lvl)
	local levelNum = lvl or k.currentLevel
	local levelInfo = GGData:new( k.dataFile )
	local locked = levelInfo.locked[levelNum]
	return locked
end


--==============================================================
-- pass in a level (or use k.currentLevel) and get back a
-- boolean to let you know whether there's a next level.
function k.anotherLevel(currLvl)
	local levelNum = currLvl or k.currentLevel
	return levelNum+1 <= k.totalLevels
end

--==============================================================
-- pass in a level number (or use k.currentLevel) and the next level
-- will be loaded and started. works on sequential and named levels only.
function k.loadNextLevel(currLvl)
	local levelNum = currLvl or k.currentLevel
	local success = false
	if k.anotherLevel(levelNum) then
		success = true
		k.currentLevel = levelNum + 1
		local newScene = k.playScene or k.sequentialScene .. tostring(k.currentLevel)
		if k.sceneNames and k.sceneNames[levelNum] then
			newScene = k.sceneNames[levelNum]
		end
		sceneMgr.gotoScene ( newScene, {effect=k.transitionEffect, time=k.transitionTime} )
	end
end


--==============================================================
-- lock all levels except k.numUnlocked and change all stars to 0.
-- also resets all scores to 0. Doesn't touch username.
-- you'd do this if you wanted to reset everything back to "new".

function k.resetLevels(dataFile)
	local dFile = dataFile or k.dataFile
	local levelInfo  = GGData:new( dFile )

	for x = 1, k.totalLevels do
		local locked = false
		if x > k.numUnlocked then
			locked = true
		end
		k.levelLocked[x] = locked
	end
	levelInfo.locked = k.levelLocked

	for x = 1, k.totalLevels do
		k.starsOnLevel[x] = 0
	end
	levelInfo.starsOnLevel = k.starsOnLevel

	for x = 1, k.totalLevels do
		k.levelScores[x] = 0
	end
	levelInfo.levelScores = k.levelScores
	
	levelInfo:save()
end

return k

--[[ =========================================
Update History

To-Do List (maybe)
Allow image-based level numbers instead of just font-based.
Map support? List of page backgrounds plus ability to manually place level chips on each page.

v1.8 2024-01-27
Misc code cleanup to make sure it works with the latest version of Solar2D in
preparation for making it open source on Github.

v1.7 2020-10-17
Added isSliding flag so you can't select a level while group is sliding left/right.
This fixes a problem when using a mouse and clicking arrows to slide.
Changed sboardEffect/Time to transitionEffect/Time for more clarification

v1.6 2020-07-03 
Went back to tap events -- they are responsive enough on the device and touch causes problems.
Added optional paging dots beneath the grid so you can see where you are.

v1.5
Made next/prev arrows more responsive by switching from tap to touch events.
Made level tiles more responsive by switching from tap to touch events.

v1.4
Added k.cancelLeaving flag to stop switching to level. Used with k.beforeLeaving.
k.beforeLeaving now passes in k.currentLevel in case it's needed.
Tweaked code to make arrow showing more reliable.

v1.3
Refactored code to make swiping more reliable.

v1.2
Changed swipe() to swipeOGTLM() to guard against collisions.
Comment changes to refer to Composer rather than Storyboard.

v1.1
Fixed swipe code -- listener wasn't being removed after level selected.

v1.0
k.beforeLeaving is the name of function to call after choosing level but before going there.

v0.6
Removed debug code that was accidentally left in the last version.

v0.5
Broke game data out into separate file: ogt_lmdata.lua for easier updating.
Tweaked the code so it works with Composer or Storyboard.
Added k.singleStarOffsetX and k.singleStarOffsetY tables for star tweaking.
Added boolean k.showMissingStar to show (or not) shadow of missing stars.
Now you can swipe left or right on the screen to page.
Fixed showing level name/number underneath lock.
Fixed dev problem when you'd increase number of levels.
	
v0.4
k.loadNextLevel() fixed to allow named scenes
Misc tweaks to shorten code, etc.
Added k.updateUserName(uname, dataFile)
Added k.getUserName(dataFile)
Added k.getLockStatus(lvl)
New parameter for k.resetLevels(dataFile)

--==========================================]]
