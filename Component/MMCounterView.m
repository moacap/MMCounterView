//
//  MMCounterView.m
//
//  Created by Matthew McCroskey on 01 October 2012.
//  This work is licensed under the
//  Creative Commons Attribution-NonCommercial-ShareAlike License.
//  For more info on this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//

#import "MMCounterView.h"
#import <QuartzCore/QuartzCore.h>
#import "CPAnimationSequence.h"

typedef enum CounterViewAnimationDirection
{
    kCounterViewAnimationDirectionAscending,
    kCounterViewAnimationDirectionDescending
} CounterViewAnimationDirection;

@interface MMCounterView ()

@property (strong) UILabel *labelA;
@property (strong) UILabel *labelB;

@property NSInteger sourceInteger;
@property NSInteger targetInteger;

@property CounterViewAnimationDirection counterViewAnimationDirection;

- (void)configure;
- (void)animate;
- (NSString*)stringForInteger:(NSInteger)integer;
- (void)ensureDefaultValue:(id)defaultValue forObject:(id)object;

@end

@implementation MMCounterView

// Public property synthesis
@synthesize integer = integer_;
@synthesize truncationBoundary = truncationBoundary_;
@synthesize ticksPerSecond = ticksPerSecond_;
@synthesize textColor = textColor_;
@synthesize font = font_;

// Private property synthesis
@synthesize labelA = labelA_;
@synthesize labelB = labelB_;
@synthesize sourceInteger = sourceInteger_;
@synthesize targetInteger = targetInteger_;
@synthesize counterViewAnimationDirection = counterViewAnimationDirection_;

#pragma mark - Custom Getters and Setters

- (NSInteger)integer
{
    return integer_;
}

- (void)setInteger:(NSInteger)integer
{
    if (integer > integer_)
    {
        [self setCounterViewAnimationDirection:kCounterViewAnimationDirectionAscending];
    }
    else
    {
        [self setCounterViewAnimationDirection:kCounterViewAnimationDirectionDescending];
    }
    
    self.sourceInteger = integer_;
    integer_ = integer;
    self.targetInteger = integer_;
    
    [self animate];
}

- (UIColor*)textColor
{
    return self.labelA.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    [self.labelA setTextColor:textColor];
    [self.labelB setTextColor:textColor];
}

- (UIFont*)font
{
    return self.labelA.font;
}

- (void)setFont:(UIFont *)font
{
    [self.labelA setFont:font];
    [self.labelB setFont:font];
}

#pragma mark - Initialization and Configuration Methods

- (void)configure
{
    // Configure properties with sane defaults
    integer_ = 0;
    sourceInteger_ = 0;
    targetInteger_ = 0;
    [self ensureDefaultValue:[UIColor lightGrayColor] forObject:self.backgroundColor];
    [self setTextColor:[UIColor darkTextColor]];
    [self setFont:[UIFont boldSystemFontOfSize:300.0]]; // Will be resized as appropriate below
    [self setTruncationBoundary:100];
    [self setTicksPerSecond:25.0];
    
    // Adjust the frame and font size of the label so that
    // it fits and is centered within our parent view with a nice margin
    CGFloat parentWidth  = self.frame.size.width;
    CGFloat parentHeight = self.frame.size.height;
    CGFloat eightyPercentOfWidth = floorf(parentWidth-(parentWidth*0.2)); // This leaves 10% margin on either side
    CGFloat actualFontSize = 0; // This is overwritten when passed by reference into the method below
    CGSize  labelSize = [[NSString stringWithFormat:@"%d+", self.truncationBoundary]
                         sizeWithFont:self.font
                         minFontSize:10.0 actualFontSize:&actualFontSize
                         forWidth:eightyPercentOfWidth
                         lineBreakMode:UILineBreakModeClip];
    CGFloat labelHeight = floorf(MIN(labelSize.height, parentHeight)); // For some reason, sizeWithFont sometimes returns huge heights
    CGFloat widthBorder  = floorf(((parentWidth - labelSize.width)/2.0)); // This gets us the margin that should be placed on either side for it to be centered
    CGFloat heightBorder = floorf(((parentHeight - labelHeight)/2.0)); // This gets us the margin that should be placed on top and bottom for it to be centered
    CGRect  labelFrame = CGRectMake(widthBorder, heightBorder, floorf(labelSize.width), labelHeight);
    
    // Configure labelA
    self.labelA = [[UILabel alloc] initWithFrame:labelFrame];
    [self.labelA setFont:[UIFont fontWithName:self.font.fontName size:actualFontSize]];
    [self.labelA setTextAlignment:UITextAlignmentCenter];
    [self.labelA setBackgroundColor:[UIColor clearColor]];
    
    // Configure labelB
    self.labelB = [[UILabel alloc] initWithFrame:labelFrame];
    [self.labelB setFont:[UIFont fontWithName:self.font.fontName size:actualFontSize]];
    [self.labelB setTextAlignment:UITextAlignmentCenter];
    [self.labelB setBackgroundColor:[UIColor clearColor]];
    
    // Add the labels to the parent view
    [self addSubview:self.labelB];
    [self addSubview:self.labelA];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self configure];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self configure];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configure];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self configure];
}

#pragma mark - Animation Methods

- (void)animate
{
    NSInteger steps = abs(self.targetInteger-self.sourceInteger);
    NSMutableArray *stepsArray = [[NSMutableArray alloc] initWithCapacity:steps+1];
    
    // Show the labels in their initial state
    CPAnimationStep *initialState = [CPAnimationStep for:0 animate:^{
        NSInteger labelAInteger  = self.sourceInteger;
        
        [self.labelA setText:[self stringForInteger:labelAInteger]];
        [self.labelA setAlpha:1];
        [self.labelB setAlpha:0];
    }];
    [stepsArray insertObject:initialState atIndex:0];
    
    NSInteger localCounter = 0;
    while (localCounter < steps)
    {
        CPAnimationStep *currentStep = [CPAnimationStep for:(1.0/self.ticksPerSecond) animate:^{
            NSInteger integer = -1;
            if (self.counterViewAnimationDirection == kCounterViewAnimationDirectionAscending)
            {
                integer = self.sourceInteger + localCounter + 1;
            }
            else
            {
                integer = self.sourceInteger - localCounter - 1;
            }
            
            // If counter is odd
            if (localCounter % 2)
            {
                [self.labelB setText:[self stringForInteger:integer]];
                [self.labelA setAlpha:0];
                [self.labelB setAlpha:1];
            }
            else
            {
                [self.labelA setText:[self stringForInteger:integer]];
                [self.labelA setAlpha:1];
                [self.labelB setAlpha:0];
            }
        }];
        
        [stepsArray insertObject:currentStep atIndex:0];
        
        localCounter++;
    }
    
    CPAnimationSequence *animationSequence = [CPAnimationSequence sequenceWithStepsArray:[NSArray arrayWithArray:stepsArray]];
	[animationSequence run];
}

#pragma mark - Custom Convenience Methods

- (NSString*)stringForInteger:(NSInteger)integer
{
    if (integer > self.truncationBoundary)
    {
        return [NSString stringWithFormat:@"%d+", self.truncationBoundary];
    }
    else
    {
        return [NSString stringWithFormat:@"%d", integer];
    }
}

- (void)ensureDefaultValue:(id)defaultValue forObject:(id)object
{
    object = object ? object : defaultValue;
}

@end
