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

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local function createTile(x,y,r,g,b)
  local tile=display.newRect(x,y,50,20)
  tile:setFillColor(r,g,b)
  tile:setStrokeColor(0,0)
  tileRectParams = { halfWidth=tileWidth/2, halfHeight=tileHeight/2 }
  physics.addBody( tile, "static", {bounce=1.0, box=tileRectParams })
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
  paddleRectParams = { halfWidth=150/2, halfHeight=30/2 }
  physics.addBody( paddle, "static",{bounce=1.0,box=paddleRectParams} )
end

local function createBall()
  ball = display.newCircle( display.contentCenterX,
    display.contentHeight-80-35, 20)
  ball:setFillColor(1,0,1)
  physics.addBody( ball, "dynamic",{bounce=1.0,radius=20} )
end

local function pushBall(x,y)
    ball:applyLinearImpulse( x, y, ball.x, ball.y )
end

createWall()
createTileSet()
createPaddle()
createBall()
pushBall(0,1)
