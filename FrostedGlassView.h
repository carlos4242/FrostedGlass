//
//  FrostedGlassView.h
//  GPS
//
//  Created by Carl Peto on 26/07/2013.
//  Copyright (c) 2013 Petosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface FrostedGlassView : UIView <GLKViewDelegate>

@property (strong,nonatomic) UIColor *lightColor; // default is white
@property (nonatomic) CGFloat lightStrength; // defaults to 0.8, max 1, min 0
@property BOOL optimise; // only turn this off if you have rendering issues, may cause CPU use/battery drain otherwise

// default false, rarely worth doing since you're going to blur the view anyway and causes extra overhead
@property (nonatomic) BOOL useRetinaRender;

// 20 FPS is the default and probably fine for most purposes, anything over 60 or under 1 is ignored, 60FPS causes extra overhead
@property (nonatomic) int frameRate;

// defaults to 20.0
@property (nonatomic) CGFloat blurRadius;

// to improve performance use these methods are not constantly changing (this is normally the case)
// which will pause the display link while the contents underneath are not changing
// you should call pause once you're confident that the underneath views have stopped changing and
// call unpause when they have started changing again
// if a single change occurs, just leave it paused and call update
// an example is if you have a scroll view, table view, collection view, etc. underneath then when scrolling begins, call unpause
// and when it ends call pause
// as an easier alternative, use the container view below, the code will automatically walk the view hierarchy in it and look for any scroll views
// then track them automatically
-(void)pause;
-(void)unpause;
-(void)update;

@end