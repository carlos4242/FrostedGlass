//
//  UIImage+WaypointsHelpers.m
//  GPS
//
//  Created by Carl Peto on 26/07/2013.
//  Copyright (c) 2013 Petosoft. All rights reserved.
//

#import "UIImage+Helpers.h"

@implementation UIImage (Helpers)

+(CGRect)containingRect:(NSArray*)fields inViewCoordinates:(UIView*)inViewCoordinates {
    CGRect containingRect = CGRectZero;
    for (UIView *field in fields) {
        containingRect = CGRectUnion(containingRect, [inViewCoordinates convertRect:field.frame fromView:field.superview]);
    }
    return containingRect;
}
+(CGMutablePathRef)newPathFromStart:(CGPoint)startPoint toEnd:(CGPoint)endPoint {
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat midPointX = (startPoint.x-endPoint.x)/2;
    CGFloat midPointY = fminf(startPoint.y,endPoint.y)-40;
    CGFloat controlPointY = midPointY-10;
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(path, NULL, midPointX, controlPointY, midPointX, controlPointY, endPoint.x, endPoint.y);
    return path;
}
+(CGImageRef)newMaskImageForFields:(NSArray*)fields inViewCoordinates:(UIView*)inViewCoordinates {
    CGRect container = [UIImage containingRect:fields inViewCoordinates:inViewCoordinates];
    CGFloat squareSize = fminf(container.size.width,container.size.height);
    void *bitBuffer = malloc(squareSize*squareSize*8);
    CGColorSpaceRef greySpace = CGColorSpaceCreateDeviceGray();
    CGContextRef maskContext = CGBitmapContextCreate(bitBuffer, squareSize, squareSize, 8, squareSize*8, greySpace, kCGImageAlphaNone);
    CGFloat greyColors[4] = {1,1,0,1};
    CGFloat greyLocations[2] = {0,1};
    CGGradientRef circularGradient = CGGradientCreateWithColorComponents(greySpace, greyColors, greyLocations, 2);
    CGColorSpaceRelease(greySpace);
    CGPoint centerPoint = CGPointMake(squareSize/2, squareSize/2);
    CGContextDrawRadialGradient(maskContext,
                                circularGradient,
                                centerPoint,0,
                                centerPoint, squareSize/2.0,
                                kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(circularGradient);
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGImageRef maskImage = CGBitmapContextCreateImage(maskContext);
    CGContextRelease(maskContext);
    free(bitBuffer);
    return maskImage;
}
+(CGImageRef)newRoughViewImage:(UIView*)view inRect:(CGRect)inRect withScale:(CGFloat)scale fillBg:(UIColor*)fillBg {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(inRect.size.width,inRect.size.height),YES,scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -inRect.origin.x, -inRect.origin.y);
    CGContextClipToRect(context, inRect);
    if (fillBg) {
        [fillBg setFill];
        CGContextFillRect(context, inRect);
    }
    [view.layer renderInContext:context];
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    return cgimage;
}
+(UIImage*)getPhotographFromFields:(NSArray*)fields inViewCoordinates:(UIView*)inViewCoordinates withMask:(CGImageRef)maskImage {
    CGRect container = [UIImage containingRect:fields inViewCoordinates:inViewCoordinates];
    UIGraphicsBeginImageContextWithOptions(container.size,NO,0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (maskImage) {
        CGRect imageBounds = CGRectMake(0, 0, container.size.width, container.size.height);
        CGContextClipToMask(context, imageBounds, maskImage);
    }
    // draw the fields
    for (UIView *field in fields) {
        CGRect fieldRectInView = [inViewCoordinates convertRect:field.frame fromView:field.superview];
        CGPoint layerPoint = CGPointMake(fieldRectInView.origin.x-container.origin.x, fieldRectInView.origin.y-container.origin.y);
        CGContextTranslateCTM(context, layerPoint.x, layerPoint.y);
        [field.layer renderInContext:context];
    }
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgimage];
    CGImageRelease(cgimage);
    UIGraphicsEndImageContext();
    return image;
}
+(CGPoint)snapshopStartCenterFromFields:(NSArray*)fields inViewCoordinates:(UIView*)inViewCoordinates {
    CGRect container = [UIImage containingRect:fields inViewCoordinates:inViewCoordinates];
    return CGPointMake(CGRectGetMidX(container), CGRectGetMidY(container));
}
+(CGPoint)snapshotEndCenterOnTable:(UITableView*)destinationWPTableView inViewCoordinates:(UIView*)inViewCoordinates {
    CGRect endRow = CGRectZero;
    int currentLastRow = [destinationWPTableView.dataSource tableView:destinationWPTableView numberOfRowsInSection:0];
    if (currentLastRow) {
        currentLastRow--;
        endRow = [destinationWPTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:currentLastRow inSection:0]];
    }
    if (CGRectIsEmpty(endRow)) {
        return [inViewCoordinates convertPoint:CGPointMake(destinationWPTableView.bounds.size.width/2, destinationWPTableView.rowHeight/2) fromView:destinationWPTableView];
    } else {
        CGRect rowAbsolutePosition = [inViewCoordinates convertRect:endRow fromView:destinationWPTableView];
        return CGPointMake(CGRectGetMidX(rowAbsolutePosition), CGRectGetMidY(rowAbsolutePosition)+rowAbsolutePosition.size.height);
    }
}

@end