-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

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
-- for f=1, 4 do
--     tileTable[f] = {}
--     for g=1, 10 do
--         tileTable[f][g] = 0
--     end
-- end
local backgroundMusic = audio.loadStream( "40mp.mp3" )
local hitSound = audio.loadSound( "Tutturu.mp3" )

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
          -- Set touch focus on the ship
          --display.currentStage:setFocus( target )
          -- Store initial offset position
          startX = event.x
          startY = event.y
      -- elseif ( "moved" == phase ) then
      --     -- Move the ship to the new touch position
      --     endX = event.x
      --     endY = event.y
      elseif ( "ended" == phase or "cancelled" == phase ) then
          -- Release touch focus on the ship
          endX = event.x
          endY = event.y
          forceX=(endX-startX)/display.contentWidth
          forceY=math.abs(endY-startY)/display.contentHeight
          if(endY-startY >0) then
            forceX = -forceX
          end
          pushBall(forceX,forceY)

          local toState1Closure = function() return toState(1) end
          timer.performWithDelay( 500, toState1Closure,1)
          -- state=1
      end
    end

    return true  -- Prevents touch propagation to underlying objects
end

local function movePaddle(event)
  local phase = event.phase
  if ( state == 1 ) then
    if ( "began" == phase ) then
        -- Set touch focus on the ship
        --display.currentStage:setFocus( target )
        -- Store initial offset position
        paddle.offsetX = event.x - paddle.x
    elseif ( "moved" == phase ) then
        -- Move the ship to the new touch position
        paddle.x = event.x - paddle.offsetX
    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the ship
        paddle.x = event.x - paddle.offsetX
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
      local hitChannel = audio.play( hitSound )
    elseif (obj2.isTile and obj1.isBall) then
      display.remove( obj2 )
      tileCount=tileCount-1
      tileText.text=tileCount
      local hitChannel = audio.play( hitSound )

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

local function gameLoop()
-- auto play
    -- paddle.x=ball.x
    if(tileCount<=0) then
      createTileSet()
      resetBallAndPaddle()
      state=0
    end
    if ( ball.x < -100 or
         ball.x > display.contentWidth + 100 or
         ball.y < -100 or
         ball.y > display.contentHeight + 100 )
    then
        -- display.remove( ball )
        -- display.remove( paddle )
        -- createPaddle()
        -- createBall()
        resetBallAndPaddle()
        state=0
    end


end



Runtime:addEventListener("touch",shotBall)
Runtime:addEventListener("touch",movePaddle)
Runtime:addEventListener("enterFrame", gameLoop)
Runtime:addEventListener( "collision", onCollision )

-- Play the background music on channel 1, loop infinitely, and fade in over 5 seconds
local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=5000 } )
createWall()
createTileSet()
createPaddle()
createBall()
--pushBall(forceX,forceY)
