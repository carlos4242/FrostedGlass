//
//  ViewController.m
//  FrostedGlass
//
//  Created by Carl Peto on 16/08/2013.
//  Copyright (c) 2013 Carl Peto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    _frostedGlass.optimise = NO;
    
    _frostedGlass.blurRadius = 3.5;
    _frostedGlass.lightColor = [UIColor whiteColor];
//    _frostedGlass.lightStrength = 0.4;
    
    _demoLabel.textColor = [UIColor whiteColor];
    _demoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _demoLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _demoLabel.layer.shadowOffset = CGSizeMake(0,0);
    _demoLabel.layer.shadowRadius = 1;
    _demoLabel.layer.shadowOpacity = 1;
    _demoLabel.layer.shouldRasterize = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
