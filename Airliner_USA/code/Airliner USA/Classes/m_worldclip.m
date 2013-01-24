//
//  m_worldclip.m
//  Tiletest
//
//  Created by rabshakeh on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "m_worldclip.h"
#import "player_airplane.h"
#import "GameState.h"

@implementation m_worldclip

-(void) initWorldMap: (CCLayer *) world_layer
{
  GameState *gs = [GameState sharedInstance];

  [CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGB565];
  background = [CCTMXTiledMap tiledMapWithTMXFile:@"background.tmx"];
  map        = [CCTMXTiledMap tiledMapWithTMXFile:@"airliner-usa-1024.tmx"];
  [CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];

  for (CCSpriteSheet *child in[background children]) {
    [[child texture] setAliasTexParameters];
  }
  for (CCSpriteSheet *child in[map children]) {
    [[child texture] setAliasTexParameters];
  }

  [world_layer addChild:background z:-3 tag:kTagBackground];
  //[world_layer addChild:map_helper z:-2 tag:kTagTileMapX];
  [world_layer addChild:map z:-1 tag:kTagTileMap];

  map.position = [gs getMapPoint];
  //map_helper.visible = NO;
  /*
         a tilemap has multiple layers, calculate the offset for every tile in order to clip them
   */
  int layerid  = 0;        //start at the top row
  int numtiles = 0;

  for (CCTMXLayer *layer in[map children]) {
    CGSize s = [layer layerSize];
    numtiles = 0;
    for (int x = 0; x < s.width; x++) {
      for (int y = 0; y < s.height; y++) {
        unsigned int tmpgid = [layer tileGIDAt:ccp(x, y)];
        if (tmpgid != 0) {
          CGPoint tp;
          tp.x                            = x * 32;
          tp.y                            = WORLD_HEIGHT - (y * 32);
          tileposlayer[layerid][numtiles] = tp;
          numtiles++;
        }
      }
    }
    layerid++;
  }
}

-(void) moveWorldMapForPlayer: (ccTime) delta_time vector_x_delta: (float) vxd vector_y_delta: (float) vyd airplane_rotation: (float) a_rot targets: (m_targets *) targets
{
  GameState *gs = [GameState sharedInstance];
  float     helpermapx, mapx, helpermapy, mapy;

  helpermapx = [gs getMapX];
  mapx       = [gs getMapX];
  helpermapy = [gs getMapY];
  mapy       = [gs getMapY];

  mapx -= (vxd *[gs airplaneSpeed]) * delta_time;

  if (a_rot > 90 && a_rot < 270) {
    mapy += (vyd *[gs airplaneSpeed]) * delta_time;
  }
  else {
    mapy -= (vyd *[gs airplaneSpeed]) * delta_time;
  }

  // scroll of the right
  if (mapx > -50) {
    [gs setTurnRequested:1];
  }
  // scroll of the right
  if (mapx < -3500) {
    [gs setTurnRequested:4];
  }

  // scroll of the right
  if (mapy < -1550) {
    [gs setTurnRequested:2];
  }

  if (mapy > -100) {
    [gs setTurnRequested:3];
  }

  background.visible = YES;

  [gs setMapX:mapx];
  [gs setMapY:mapy];

  map.position = [gs getMapPoint];

  int lc = 0;
  for (CCTMXLayer *child in[map children]) {
    child.visible = NO;
    for (int tc = 0; tc < NUM_TILES_PER_LAYER; tc++) {
      int tx = tileposlayer[lc][tc].x;
      int ty = tileposlayer[lc][tc].y;

      int tcx = tx + mapx;
      int tcy = ty + mapy;

      if ((tcx + TILESIZE > 0 && tcx < SCREENWIDTH) &&
          (tcy + TILESIZE > 0 && tcy < SCREENHEIGHT + TILESIZE)) {
        child.visible = YES;
        break;
      }
    }
    lc++;
  }

  /*
     lc = 0;
     for (CCTMXLayer *child in[map_helper children]) {
     child.visible = NO;
     for (int tc = 0; tc < NUM_TILES_PER_LAYER; tc++) {
      int tx = tileposlayer[lc][tc].x;
      int ty = tileposlayer[lc][tc].y;

      int tcx = tx + helpermapx;
      int tcy = ty + helpermapy;

      if ((tcx + TILESIZE > 0 && tcx < SCREENWIDTH) &&
          (tcy + TILESIZE > 0 && tcy < SCREENHEIGHT + TILESIZE)) {
        child.visible = YES;
        break;
      }
     }
     lc++;
     }
   */
  //map_helper.visible = NO;
}

@end
