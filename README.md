# solar2d-OGTLevelManager
Many games are based on levels, and most of those games have a screen where:  

- The user can choose a level to play.
- Some levels are locked until previous levels have been played.
- A number of stars are shown based on the player’s score for that level.

One of the most commonly asked game dev questions is, “How do I lock and unlock levels?” Until now I’ve tried to explain the concept to people but now I have a better answer…  

The Outlaw Game Tools Level Manager

OGT Level Manager is a library you include in your game and then “tweak” some variables to specify which graphics you want to use, how many total levels you have, etc. And then in your game it’s as easy as this to unlock the next level when the player has finished with the current level:  

unlockNextLevel()  

GT Level Manager keeps track of which levels have been unlocked and it’s shown automatically when the player goes back to the level select screen!  

If you’re using a “stars” system in your game, OGT Level Manager will even keep track of how many stars were earned on each level. And it’s this easy to use:  

updateStars(2)  

That one call will let OGT Level Manager know the player earned two stars on that level and it will automatically show the correct number on the level select screen.  

Here are some of the features found in this library:  

- No limit to the number of levels.
- Multiple pages with next and previous arrows.
- One to three stars shown on levels (optional).
- Use your own graphics. Using smileys instead of stars? No problem!
- Tweak the position of level boxes, arrows, stars, numbers, etc.
- One Composer scene with data loaded for each level? Works that way.
- A different Composer scene for each level? Works that way, too!

Basically, I’ve made it easy to drop in your own graphics, and then tweak the position of any that may need it by setting variables. Changing the actual code is not necessary.  

Requirements:  
Solar2D.
Use Composer for scene management in your game (built-in to Solar2D).

You will save a LOT of time by using OGT Level Manager -- time you can spend working on the more fun parts of your new game!  
