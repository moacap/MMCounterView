//
//  ViewController.m
//  Demo
//
//  Created by Matthew McCroskey on 10/2/12.
//  Copyright (c) 2012 Matthew McCroskey. All rights reserved.
//

#import "ViewController.h"
#import "MMCounterView.h"

@interface ViewController ()

@property (weak) IBOutlet MMCounterView *counterView;
@property NSInteger previousInteger;

@end

@implementation ViewController

@synthesize counterView = counterView_;
@synthesize previousInteger = previousInteger_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.previousInteger = 0;
    [self performSelector:@selector(updateValue) withObject:nil afterDelay:1.5];
}

- (void)updateValue
{
    self.previousInteger = self.counterView.integer;
    NSInteger integer = (arc4random() % 120);
    [self.counterView setInteger:integer];
    
    NSInteger numberOfTicks = abs(integer-self.previousInteger);
    [self performSelector:@selector(updateValue) withObject:nil afterDelay:((1.0/self.counterView.ticksPerSecond)*numberOfTicks+1)];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
