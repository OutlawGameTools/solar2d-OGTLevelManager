--[[ ====== G A M E  D A T A  F I L E =========
	
	 See bottom of ogt_levelmanager.lua file for 
	 update history.
	
  Outlaw Game Tools Level Manager (OGTLM) v1.8
  Copyright 2013-2024 Jay Jennings
  
--=========================================== ]]

local k = {}

--[[ ==============================================================
When a level is selected OGTLM needs to send the user to another
composer scene. If you use the same scene for all levels (just
loading new data for each level, you'll use the k.playScene option
below. Enter the name of the composer scene to switch to.

If you have a different composer scene for each level you'll use
	the second option below as long as the scenes are named sequentially.
	For example, level1, level2, level3, etc. Or stage1, stage2, stage3, 
		etc. in that case, enter the "base name" for the scenes, such
		as level or stage. OGTLM will add the chosen level number
		to the end when the user clicks a level.
		
Or, create a table in k.sceneNames that holds the composer scene
name for each level you have.
	-- ==============================================================]]
k.playScene = "play" -- name of scene or nil to go to sequential scenes
k.sequentialScene = "level" -- will turn into level1, level2, etc.
k.sceneNames = nil -- {"scene01", "playme", "world3"}

--[[ =========================================
 If images or audio files are in folders, define
	those here. Be sure and add a slash / to the
 end of any folder names.
	If you're not using folders, set vars to nil
--==========================================]]
k.imagePrefix = "images/"
k.audioPrefix = "audio/"

--==============================================================
-- filenames for the images used in the level manager

k.backgroundImage = "skybox_3.jpg" -- optional, define as nil if not used
k.customLevel = nil -- get level image from function rather than next var
k.levelSquareImage = "level-wood.png" -- required unless customLevel is specified
k.lockImage = "lock-black.png" -- optional, define as nil if not used
k.starImage = "staryellow.png" -- optional, nil if not using stars
k.prevImage = "prev-white.png" -- optional unless you need paging, define as nil if not used
k.nextImage = "next-white.png" -- optional unless you need paging, define as nil if not used

--==============================================================
-- filenames for the images used in the level manager

k.selectSoundFile = "levelselect.wav" -- sound when level selected, define as nil if not used
k.nextPageSoundFile = "changepage.wav"-- sound when next page clicked, define as nil if not used
k.prevPageSoundFile = "changepage.wav"-- sound when previous page clicked, define as nil if not used

k.audioOn = true

--==============================================================
-- the default font to be used for level number and score
k.fontName = "Helvetica" -- required

--==============================================================
-- info about the level number (or text) being displayed
k.showLevelNum = true
k.levelNumFontName = nil -- optional, use instead of default font for level num
k.levelNumFontSize = 44
k.levelNumFontColor = {1,1,1}
k.levelNumEmbossedFont = true
k.levelNumTextXOffset = 0 	-- horizontal offset for the level number text
k.levelNumTextYOffset = -5   -- vertical offset for the level number text
k.tileNums = nil --{"H","He","Li","Be","B","C","N","O","F","Ne","Na","Mg","Al","Si","P","S","Cl"} -- use a table of string values if desired {"A", "B", "C"}
k.showLevelNumTextWhenLocked = false

--==============================================================
-- info about the score being displayed (optional)
k.showScore = true
k.scoreFontName = nil -- optional, use instead of default font for score
k.scoreFontSize = 18
k.scoreFontColor = {1,1,1}
k.scoreEmbossedFont = true
k.scoreTextXOffset = 0 	-- horizontal offset for the score text
k.scoreTextYOffset = 0   -- vertical offset for the score text
k.scorePrefix = nil
k.scoreSuffix = " Pts"
k.showScoreWhenLocked = false

--==============================================================
-- Info about the grid itself
k.totalLevels = 24	-- total number of levels in the game. should equal (numCols * numRows) * numPages
k.numCols = 4		 -- how many columns on each page of levels
k.numRows = 2 		-- how many rows on each page of levels
k.colSpace = 10 	  -- extra spacing between each column
k.rowSpace = 40 	  -- extra spacing between each row
k.gridOffsetX = 0 	-- horizontal offset for the entire grid on the page
k.gridOffsetY = 0 	-- vertical offset for the entire grid on the page

-- info about the paging dots beneath the grid
k.showPageDots = true
k.pageDotsSpacing = 20 -- how far apart are the dots (center to center)
k.pageDotsYOffset = 20 -- distance from the bottom of the grid
k.pagesDotRadius = 3 -- size of each normal page dot 
k.pagesDotScale = 1.3 -- size of each selected page dot (1.3 scales it 130% of normal size)
k.pageDotsColorTable = {0, 0, 0.8, 1} -- color of the page dots

-- misc variables

k.numUnlocked = 3 -- how many of the first levels are unlocked (minimum 1)

k.rememberPage = true -- if true, shows page from last selected level
k.currentPage = 1 	-- probably won't change this (much) manually
k.currentLevel = 0 	-- probably won't change this (much) manually

k.swipe = true -- allow swiping left/right to page
k.minSwipeDistance = 20 -- number of pixels required to trigger paging

k.beforeLeaving = nil -- name of function to call after choosing level but before going there.
k.cancelLeave = false -- set to true to cancel level selection (would be set in k.beforeLeaving function)

--==============================================================
-- star stuff
k.maxStars = 3
k.starOffsetX = 0
k.starOffsetY = -4
k.singleStarOffsetX = {0, 0, 0} -- number of elements must match k.maxStars
k.singleStarOffsetY = {0, 3, 0} -- number of elements must match k.maxStars
k.showMissingStar = true

-- next and prev arrows
k.nextOffsetX = 0 	-- tweak the positioning for the arrows here
k.nextOffsetY = 0
k.prevOffsetX = 0
k.prevOffsetY = 0

-- lock image
k.lockOffsetX = 0 	-- tweak position of the lock here
k.lockOffsetY = 0

-- transition effect and time for switching from level selector to chosen level.
k.transitionEffect = "crossFade"
k.transitionTime = 700

-- how fast does the level selector slide when using next/prev arrows
k.slideTime = 300 	-- milliseconds (lower number = faster slide)

k.dataFile = "ogtlm_levels"

k.userName = nil

--==============================================================
-- extra variables below that are not user-configurable.

k.sceneGroup = nil
k.pageDotsGroup = nil

k.displayText = nil

k.numPerPage = (k.numCols * k.numRows)
k.numPages = math.ceil ( k.totalLevels / ((k.numCols * k.numRows)) )

k.tileWidth = 100
k.tileHeight = 70

k.lockWidth = 0
k.lockHeight = 0

k.prevWidth = 0
k.prevHeight = 0

k.nextWidth = 0
k.nextHeight = 0

k.starWidth = 0 	-- will be filled in dynamically
k.starHeight = 0	-- will be filled in dynamically

k.levelInfo = {}
k.levelLocked = {}
k.starsOnLevel = {}
k.levelScores = {}

return k

--[[ =========================================

	 See bottom of ogt_lvelmanager.lua file for 
	 update history.

--==========================================]]
