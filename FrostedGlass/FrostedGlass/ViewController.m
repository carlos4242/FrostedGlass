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
    _demoLabel.textColor = [UIColor whiteColor];
    _demoLabel.shadowColor = [UIColor blackColor];
    _demoLabel.shadowOffset = CGSizeMake(1,1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
