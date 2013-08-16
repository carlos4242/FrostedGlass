//
//  ViewController.h
//  FrostedGlass
//
//  Created by Carl Peto on 16/08/2013.
//  Copyright (c) 2013 Carl Peto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FrostedGlassView.h"

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet FrostedGlassView *frostedGlass;
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) IBOutlet UILabel *demoLabel;

@end
