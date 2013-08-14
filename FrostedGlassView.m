//
//  FrostedGlassView.m
//  GPS
//
//  Created by Carl Peto on 26/07/2013.
//  Copyright (c) 2013 Petosoft. All rights reserved.
//
#define kDebug DEBUG
#if (kDebug)
#import <sys/time.h>
/*for debugging only */
void logTtoT2(struct timeval *t,struct timeval *t2) {
    time_t ms = (t2->tv_sec-t->tv_sec)*1000+(t2->tv_usec-t->tv_usec)/1000;
    NSLog(@"render : %ld ms",ms);
}
#endif

#define kSaturate 0

#import "FrostedGlassView.h"
#import "UIImage+WaypointsHelpers.h"


#define kBorder 20.0
#define ScaledRect(rect,scale) CGRectMake((rect).origin.x*scale,(rect).origin.y*scale,(rect).size.width*scale,(rect).size.height*scale)

@interface FrostedGlassView () <UIScrollViewDelegate> {
    // open gl es / glkit
    GLKView *_glView;
    CIContext *_imagecontext;
    EAGLContext *_eaglContext;
    CGFloat scale;
    CGFloat trueScale;
    CGFloat scalingFactor;
    
    // display link / timer
    CADisplayLink *_fps;
    
    // this is for efficient control of the frame rate
    NSMutableArray *_scrollViews;
    NSMutableArray *_scrollViewDelegates;
    BOOL _pause;
    BOOL _oneshot;
    
    // this view provides the lit glass effect
    UIView *_foggingView;
}
@end

@implementation FrostedGlassView

#pragma mark - setup and teardown
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // setup view
        self.clipsToBounds = YES;

        // setup defaults
        _blurRadius = 2.0;
        scale = 1.0f;
        trueScale = [UIScreen mainScreen].scale;
        scalingFactor = trueScale;
        
        // open gl es
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_eaglContext];

        // core image
        _imagecontext = [CIContext contextWithEAGLContext:_eaglContext
                                                  options:nil];

        // glkit view
        _glView = [[GLKView alloc] initWithFrame:CGRectInset(self.bounds, -kBorder, -kBorder)
                                         context:_eaglContext];
        _glView.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
        _glView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _glView.opaque = YES;
        _glView.delegate = self;
        [self addSubview:_glView];
        
        // fogging view over the top
//        _foggingView = [[UIView alloc] initWithFrame:self.bounds];
//        _foggingView.backgroundColor = [UIColor whiteColor];
//        _foggingView.alpha = 1;
//        [self addSubview:_foggingView];

        // create display link and start the timer
        _fps = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
        _frameRate = 15;
        _fps.frameInterval = 3;
        [_fps addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        // optimise by default, track all scroll views in the superview and only update the frame when they scroll
        
        [self scanViewForScrollViews:self.superview];
    }
    return self;
}
-(void)dealloc {
    // cleanup timer and restore scroll view delegates
    [_fps invalidate];
    for (int i=0;i<[_scrollViews count];i++) {
        ((UIScrollView*)[_scrollViews objectAtIndex:i]).delegate = [_scrollViewDelegates objectAtIndex:i];
    }
}

#pragma mark - the main render function
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
#if (kDebug)
    // record start time
    struct timeval t,t3;
    gettimeofday(&t, NULL);
#endif

    // create screen shot of the contents of the views under the frosted glass
    self.hidden = YES;
    CGImageRef cgimagein = [UIImage newRoughViewImage:self.superview //_container?_container:
                                               inRect:CGRectInset(self.frame, -kBorder, -kBorder)
                                            withScale:scale fillBg:[UIColor whiteColor]];
    self.hidden = NO;

    // convolute the screen shot with a blur filter
    CIImage *original = [CIImage imageWithCGImage:cgimagein];
#if (kSaturate)
    CIFilter *saturate = [CIFilter filterWithName:@"CIColorControls"
                                    keysAndValues:kCIInputImageKey,original,@"InputSaturation",@(2.0),@"InputContrast",@(0.2),
                          nil];
#endif
    CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"
                                keysAndValues:kCIInputImageKey,
#if (kSaturate)
saturate.outputImage,
#else
original
#endif
@"InputRadius",@(_blurRadius),
                      nil];
    CIImage *output = blur.outputImage;

    // draw the resulting image using open gl es and the glkit view
    [_imagecontext drawImage:output
                      inRect:ScaledRect(rect,scalingFactor)
                    fromRect:ScaledRect(rect,scale)];

    // clean up
    CGImageRelease(cgimagein);

#if (kDebug)
    // log frame render time
    gettimeofday(&t3, NULL);
    logTtoT2(&t, &t3);
#endif
}


#pragma mark - this section mostly concerns running the frame rate efficiently
-(void)pause {
    _pause = YES;
}
-(void)unpause {
    _pause = NO;
}
-(void)updateImage {
    [_glView display];
    if (_oneshot) {
        _pause = YES;
        _oneshot = NO;
    }
}
-(void)tick {
    if (!_pause||_oneshot) {
        [self updateImage];
    }
}
-(void)update {
    _oneshot = YES; // update on next frame
}
-(void)layoutIfNeeded {
    [self updateImage];
}
//-(void)setContainer:(UIView *)container {
//    if (_container!=container) {
//        _container = container;
//        [self scanViewForScrollViews:container];
//    }
//    [self update]; // rely on scroll view detection
//}
-(void)scanViewForScrollViews:(UIView*)view {
    if (view==self) return;
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *sv = (UIScrollView*)view;
        if (sv.delegate) {
            [_scrollViews addObject:sv];
            [_scrollViewDelegates addObject:sv.delegate];
            sv.delegate = self;
        }
    }
    for (UIView *s in view.subviews) {
        [self scanViewForScrollViews:s];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self update];
    int i = [_scrollViews indexOfObject:scrollView];
    if (i!=NSNotFound&&i>=0&&i<[_scrollViewDelegates count]) {
        [[_scrollViewDelegates objectAtIndex:i] scrollViewDidScroll:scrollView];
    }
}
#pragma mark - properties
-(void)setUseRetinaRender:(BOOL)useRetinaRender {
    _useRetinaRender = useRetinaRender;
    scale = useRetinaRender?trueScale:1.0F;
}
-(void)setFrameRate:(int)frameRate {
    if (frameRate>=1&&frameRate<=60) {
        _frameRate = frameRate;
        _fps.frameInterval = 60/frameRate;
    }
}
-(UIColor*)lightColor {
    return _foggingView.backgroundColor;
}
-(void)setLightColor:(UIColor *)lightColor {
    _foggingView.backgroundColor = lightColor;
}
-(CGFloat)lightStrength {
    return _foggingView.alpha;
}
-(void)setLightStrength:(CGFloat)lightStrength {
    _foggingView.alpha = lightStrength;
}
@end
