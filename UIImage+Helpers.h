//
//  UIImage+WaypointsHelpers.h
//  GPS
//
//  Created by Carl Peto on 26/07/2013.
//  Copyright (c) 2013 Petosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helpers)

+(CGRect)containingRect:(NSArray*)fields inViewCoordinates:(UIView*)inViewCoordinates;
+(CGMutablePathRef)newPathFromStart:(CGPoint)startPoint toEnd:(CGPoint)endPoint;
+(CGImageRef)newMaskImageForFields:(NSArray*)fields inViewCoordinates:(UIView*)inViewCoordinates;
+(UIImage*)getPhotographFromFields:(NSArray*)fields inViewCoordinates:(UIView*)inViewCoordinates withMask:(CGImageRef)maskImage;
+(CGPoint)snapshopStartCenterFromFields:(NSArray*)fields inViewCoordinates:(UIView*)inViewCoordinates;
+(CGPoint)snapshotEndCenterOnTable:(UITableView*)destinationWPTableView inViewCoordinates:(UIView*)inViewCoordinates;

+(CGImageRef)newRoughViewImage:(UIView*)view inRect:(CGRect)inRect withScale:(CGFloat)scale fillBg:(UIColor*)fillBg;

@end