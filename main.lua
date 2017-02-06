-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
tileWidth=50
tileHeight=20
tilePerRow=10
tileRowGap=5
tileVerticalGap=5
verticalOffset=80
state=0
forceX=1
forceY=1
startX =0
startY =0
endX = 0
endY = 0
tileCount=0
tileTable = {}
winSoundChannel = {}
hitChannel = {}
winMusicChannel= {}
sorrySoundChannel= {}
backgroundMusicChannel= {}

background = display.newImage("nanami.jpg")
-- background.fill.effect = "filter.blur"
background.fill.effect = "filter.frostedGlass"
background.fill.effect.scale =  25
background.x = display.contentCenterX
background.y = display.contentCenterY
local backgroundMusic = audio.loadStream( "40mp.mp3" )
local winMusic = audio.loadStream( "UNICORN.ogg" )
local winSound = audio.loadSound( "nanami.mp3" )
local hitSound = audio.loadSound( "smw_coin.wav" )
local sorrySound = audio.loadSound( "sorry.mp3" )

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )
local tileText = display.newText( tileCount, display.contentCenterX, display.contentCenterY, native.systemFont, 40 )

function clamp(value, low, high)
    if low and value <= low then
        return low
    elseif high and value >= high then
        return high
    end
    return value
end

local function createTile(x,y,r,g,b)
  local tile=display.newRect(x,y,50,20)
  tile:setFillColor(r,g,b)
  tile:setStrokeColor(0,0)
  tile.isTile=true
  tileRectParams = { halfWidth=tileWidth/2, halfHeight=tileHeight/2 }
  physics.addBody( tile, "static", {bounce=1.0, box=tileRectParams })
  tileCount=tileCount+1
  tileText.text=tileCount
  -- table.insert(tileTable,tile)
end

local function createTileSet()
  tileCount=0
  for i=0,9 do
    createTile((display.contentWidth-tileWidth*tilePerRow-
      (tilePerRow-1)*tileRowGap)/2+i*tileWidth+i*tileRowGap+20,
      verticalOffset+0*(tileHeight+tileVerticalGap),1,0,0)
    createTile((display.contentWidth-tileWidth*tilePerRow-
      (tilePerRow-1)*tileRowGap)/2+i*tileWidth+i*tileRowGap+20,
      verticalOffset+1*(tileHeight+tileVerticalGap),0,1,0)
    createTile((display.contentWidth-tileWidth*tilePerRow-
      (tilePerRow-1)*tileRowGap)/2+i*tileWidth+i*tileRowGap+20,
      verticalOffset+2*(tileHeight+tileVerticalGap),0,0,1)
    createTile((display.contentWidth-tileWidth*tilePerRow-
      (tilePerRow-1)*tileRowGap)/2+i*tileWidth+i*tileRowGap+20,
      verticalOffset+3*(tileHeight+tileVerticalGap),0,1,1)
  end
end

local function createWall()
  wallLeft = display.newRect( 0+10, display.contentCenterY,
    20, display.contentHeight )
  wallRight = display.newRect( display.contentWidth-10,
    display.contentCenterY, 20, display.contentHeight )
  wallTop = display.newRect( display.contentCenterX, 0+10,
    display.contentWidth, 20 )
  wallTopRectParams = { halfWidth=display.contentWidth/2, halfHeight=20/2 }
  wallSideRectParams = { halfWidth=20/2, halfHeight=display.contentHeight/2 }

  physics.addBody( wallTop, "static", {bounce=1.0,box=wallTopRectParams} )
  physics.addBody( wallRight, "static", {bounce=1.0,box=wallSideRectParams} )
  physics.addBody( wallLeft, "static", {bounce=1.0,box=wallSideRectParams} )
end

local function createPaddle()
  paddle = display.newRect( display.contentCenterX,
    display.contentHeight-80, 150, 30 )
  paddle:setFillColor(0.56, 0.89, 0.41)
  paddle.offsetX=0
  paddleRectParams = { halfWidth=150/2, halfHeight=30/2 }
  physics.addBody( paddle, "static",{bounce=1.0,box=paddleRectParams} )
end

local function createBall()
  ball = display.newCircle( display.contentCenterX,
    display.contentHeight-80-35, 20)
  ball.isBall=true
  ball:setFillColor(1,0,1)
  physics.addBody( ball, "dynamic",{bounce=1.0,radius=20} )
end

local function pushBall(x,y)
    ball:applyLinearImpulse( x, y, ball.x, ball.y )
end

local function toState(s)
  state=s
end

local function shotBall( event )
    local phase = event.phase
    if ( state == 0 ) then
      if ( "began" == phase ) then
          startX = event.x
          startY = event.y
      elseif ( "ended" == phase or "cancelled" == phase ) then
          endX = event.x
          endY = event.y
          forceX=(endX-startX)*2.0/display.contentWidth
          forceY=math.abs(endY-startY)*2.0/display.contentHeight+0.05
          if(endY-startY >0) then
            forceX = -forceX
          end
          pushBall(forceX,forceY)
          local toState1Closure = function() return toState(1) end
          timer.performWithDelay( 500, toState1Closure,1)
      end
    end

    return true  -- Prevents touch propagation to underlying objects
end

local function movePaddle(event)
  local phase = event.phase
  if ( state == 1 ) then
    if ( "began" == phase ) then
        paddle.offsetX = event.x - paddle.x
    elseif ( "moved" == phase ) then
        paddle.x = clamp(event.x - paddle.offsetX, 0 , display.contentWidth)
    elseif ( "ended" == phase or "cancelled" == phase ) then
        paddle.x = clamp(event.x - paddle.offsetX, 0 , display.contentWidth)
    end
  end

  return true  -- Prevents touch propagation to underlying objects
end

local function onCollision(event)
  if ( event.phase == "began" ) then
    local obj1 = event.object1
    local obj2 = event.object2
    if (obj1.isTile and obj2.isBall) then
      display.remove( obj1 )
      tileCount=tileCount-1
      tileText.text=tileCount
       hitChannel = audio.play( hitSound )
    elseif (obj2.isTile and obj1.isBall) then
      display.remove( obj2 )
      tileCount=tileCount-1
      tileText.text=tileCount
       hitChannel = audio.play( hitSound )
    end
  end
end

local function resetBallAndPaddle()
  paddle.x = display.contentCenterX
  paddle.y = display.contentHeight-80
  ball.x = display.contentCenterX
  ball.y = display.contentHeight-80-35
  ball:setLinearVelocity(0,0)
end
local function onClickWin(event)
  if(state==2) then
    display.remove(victoryImg)
    display.remove(nanamiWinImg)
    audio.stop( winMusicChannel )
    createTileSet()
    audio.resume( backgroundMusicChannel )
    resetBallAndPaddle()
    -- loadingGif=display.newImage("nanami_sad.png")
    -- loadingGif.x=display.contentCenterX
    -- loadingGif.y=display.contentCenterY
    -- sorrySoundChannel=audio.play( sorrySound )
    local toState0Closure = function()
      resetBallAndPaddle()
      -- display.remove(loadingGif)
      return toState(0)
    end
    timer.performWithDelay( 1000, toState0Closure,1)
  end
end

local function gameLoop()
    -- auto play for debug
    -- paddle.x=ball.x
    -- for debug
    -- tileCount=0
    if(tileCount<=0 and state == 1) then
      state=-1
      audio.pause( backgroundMusicChannel )
      winSoundChannel=audio.play( winSound )
      winMusicChannel = audio.play( winMusic, { loops=-1 ,fadein=2000 } )
      victoryImg= display.newImage("victory.png")
      victoryImg.x=display.contentCenterX
      victoryImg.y=display.contentCenterY
      nanamiWinImg= display.newImage("nanami_win.png")
      nanamiWinImg.x=display.contentCenterX
      nanamiWinImg.y=display.contentCenterY+350
      resetBallAndPaddle()
      -- state=2
      local toState2Closure = function() return toState(2) end
      timer.performWithDelay( 1000, toState2Closure,1)
    end
    if ( ball.x < -100 or
         ball.x > display.contentWidth + 100 or
         ball.y < -100 or
         ball.y > display.contentHeight + 100 )
    then
        resetBallAndPaddle()
        state=-1
        loadingGif=display.newImage("nanami_sad.png")
        loadingGif.x=display.contentCenterX
        loadingGif.y=display.contentCenterY
        sorrySoundChannel=audio.play( sorrySound )

        local toState0Closure = function()
          resetBallAndPaddle()
          display.remove(loadingGif)
          return toState(0)
        end
        timer.performWithDelay( 1000, toState0Closure,1)
    end
end

Runtime:addEventListener("touch",shotBall)
Runtime:addEventListener("touch",movePaddle)
Runtime:addEventListener("touch",onClickWin)
Runtime:addEventListener("enterFrame", gameLoop)
Runtime:addEventListener( "collision", onCollision )

-- Play the background music on channel 1, loop infinitely
audio.setVolume( 0.2, { channel=1 } )
backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=500 } )

createWall()
createTileSet()
createPaddle()
createBall()
