//
//  CBUIActivityView.m
//  CBUIKit
//
//  Created by Christian Beer on 05.07.11.
//  Copyright 2011 Christian Beer. All rights reserved.
//

#import "CBUIActivityView.h"
#import <QuartzCore/QuartzCore.h>

#import "CBUIGlobal.h"

@interface CBUIActivityView ()

// these are mutualy exclusive. last set wins.
@property (nonatomic, retain) UIView    *centerView;
@property (nonatomic, retain) UILabel   *messageLabel;

- (void) rotateToDeviceOrientation:(BOOL)animated;
@end

CATransform3D ApplyInterfaceRotationToCATransform3D(CATransform3D transform);


@implementation CBUIActivityView

@synthesize centerView = _centerView, messageLabel = _messageLabel;

+ (CBUIActivityView*) sharedInstance
{
    static CBUIActivityView *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[[self class] alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGFloat width  = CBIsIPad() ? 180 : 160;
    CGFloat height = CBIsIPad() ? 180 : 160;
    CGRect frame = CGRectIntegral(CGRectMake(keyWindow.bounds.size.width/2 - width/2,
                                             keyWindow.bounds.size.height/2 - height/2,
                                             width, height));
    
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.alpha = 0;
    
    self.layer.cornerRadius = 10;
    
    self.userInteractionEnabled = NO;
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin |  UIViewAutoresizingFlexibleBottomMargin;
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.centerView = nil;
    self.messageLabel = nil;
    
    [super dealloc];
}

#pragma mark -

- (void) setMessage:(NSString *)message
{
    if (message == nil && self.messageLabel != nil) {
        [UIView animateWithDuration:0.2 
                         animations:^{
                             self.messageLabel.alpha = 0.0;
                         } 
                         completion:^(BOOL finished) {
                             [self.messageLabel removeFromSuperview];
                         }];
        self.messageLabel = nil;
    }
    
    if (!self.messageLabel) {
        CGRect frame = CGRectMake(10, self.bounds.size.height - 50, 
                                  self.bounds.size.width - 20, 40);
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:frame];
        messageLabel.font = [UIFont boldSystemFontOfSize:16];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.opaque = NO;
        messageLabel.textAlignment = UITextAlignmentCenter;
        messageLabel.shadowColor = [UIColor darkGrayColor];
        messageLabel.shadowOffset = CGSizeMake(1,1);
        messageLabel.adjustsFontSizeToFitWidth = YES;
        messageLabel.lineBreakMode = UILineBreakModeWordWrap;
        messageLabel.numberOfLines = 2;
        [self addSubview:messageLabel];
        self.messageLabel = messageLabel;
        [messageLabel release];
    }
    self.messageLabel.text = message;
}

- (CBUIActivityView*) applyBackgroundColor:(UIColor*)color;
{
    if (self.superview) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.backgroundColor = [color colorWithAlphaComponent:0.5];
                         }];
    } else {
        self.backgroundColor = [color colorWithAlphaComponent:0.5];
    }
    return self;
}

#pragma mark -

- (void) show
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide)
                                               object:nil];
    
    if (![self superview]) {
        self.layer.transform = ApplyInterfaceRotationToCATransform3D(CATransform3DMakeScale(0.3, 0.3, 1.0));
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1.0;
                         self.layer.transform = ApplyInterfaceRotationToCATransform3D(CATransform3DMakeScale(1.2, 1.2, 1.0));
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1 
                                          animations:^{
                                              self.layer.transform = ApplyInterfaceRotationToCATransform3D(CATransform3DMakeScale(1.0, 1.0, 1.0));
                                          } 
                                          completion:^(BOOL finished) {
                                          }];
                     }];
}

- (void) hide:(BOOL)animated
{
    [UIView animateWithDuration:0.3 delay:0.0 
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn 
                     animations:^{
                         self.alpha = 0.0;
                         self.layer.transform = ApplyInterfaceRotationToCATransform3D(CATransform3DMakeScale(0.1, 0.1, 1.0));
                     } 
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         
                         [self.centerView removeFromSuperview];
                         [self.messageLabel removeFromSuperview];
                         self.messageLabel = nil;
                         self.centerView = nil;
                         
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                     }];
}
- (void) hide
{
    [self hide:YES];
}
- (void) hideAfterDelay:(NSTimeInterval)delay;
{
    [self performSelector:@selector(hide) withObject:nil afterDelay:delay];
}

#pragma mark -

- (void) hidePreviousCenterView
{
    if (self.centerView) {
        UIView *view = [self.centerView retain];
        self.centerView = nil;
        [UIView animateWithDuration:0.2 
                         animations:^{
                             view.alpha = 0.0;
                             view.layer.transform = ApplyInterfaceRotationToCATransform3D(CATransform3DMakeScale(0.01, 0.01, 1.0));
                         } 
                         completion:^(BOOL finished) {
                             [view removeFromSuperview];
                             [view release];
                         }];
    }
}

- (CBUIActivityView*) showSpinnerWithMessage:(NSString*)message
{
    [self hidePreviousCenterView];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner sizeToFit];
    spinner.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [spinner startAnimating];
    [self addSubview:spinner];
    self.centerView = spinner;
    [spinner release];
    
    [self setMessage:message];
    
    [self show];
    
    return self;
}

- (CBUIActivityView*) showInfoIcon:(UIImage*)icon withMessage:(NSString *)message
{
    [self hidePreviousCenterView];
    
    UIImageView *infoSymbol = [[UIImageView alloc] initWithImage:icon];
    [infoSymbol sizeToFit];
    infoSymbol.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:infoSymbol];
    self.centerView = infoSymbol;
    [infoSymbol release];
    
    [self setMessage:message];
    
    [self show];
    
    return self;
}

- (CBUIActivityView*) showCenterText:(NSString*)text withMessage:(NSString *)message;
{
    [self hidePreviousCenterView];
    
    UILabel *centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, self.bounds.size.height - 20)];
    centerLabel.text = text;
    centerLabel.backgroundColor = [UIColor clearColor];
    centerLabel.opaque = NO;
    centerLabel.textColor = [UIColor whiteColor];
    centerLabel.font = [UIFont boldSystemFontOfSize:40];
    centerLabel.textAlignment = UITextAlignmentCenter;
    centerLabel.shadowColor = [UIColor darkGrayColor];
    centerLabel.shadowOffset = CGSizeMake(1,1);
    centerLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:centerLabel];
    self.centerView = centerLabel;
    [centerLabel release];
    
    [self setMessage:message];
    
    [self show];
    
    return self;
}

#pragma mark - Rotation

- (void) rotateToDeviceOrientation:(BOOL)animated
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    void(^doRotate)(void) = ^(void) {
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                self.layer.transform = CATransform3DMakeRotation(M_PI,0,0,1);
                break;

            case UIInterfaceOrientationLandscapeRight:
                self.layer.transform = CATransform3DMakeRotation(M_PI_2,0,0,1);
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                self.layer.transform = CATransform3DMakeRotation(-M_PI_2,0,0,1);
                break;
            default:
                self.layer.transform = CATransform3DIdentity;
                break;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:doRotate];
    } else {
        doRotate();
    }
}
- (void) deviceOrientationDidChange:(NSNotification*)note
{
    [self rotateToDeviceOrientation:YES];
}

#pragma mark - Keyboard

- (void) keyboardDidShowNotification:(NSNotification*)note
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

    NSDictionary* info = [note userInfo];
    
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGSize kbSize = kbRect.size;
    
    CGSize windowSize = keyWindow.bounds.size;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        CGFloat t = kbSize.width;
        kbSize.width = kbSize.height;
        kbSize.height = t;
        
        t = windowSize.width;
        windowSize.width = windowSize.height;
        windowSize.height = t;
    }
    
    windowSize.height -= kbSize.height;
    
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGRect frame = CGRectIntegral(CGRectMake(windowSize.width / 2  - width / 2,
                                             windowSize.height / 2 - height / 2,
                                             width, height));
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = frame;
    }];

}
- (void) keyboardWillHideNotification:(NSNotification*)note
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGSize windowSize = keyWindow.bounds.size;
    
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGRect frame = CGRectIntegral(CGRectMake(windowSize.width / 2  - width / 2,
                                             windowSize.height / 2 - height / 2,
                                             width, height));
    
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = frame;
    }];
}

@end



CATransform3D ApplyInterfaceRotationToCATransform3D(CATransform3D transform)
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            return CATransform3DRotate(transform, M_PI, 0, 0, 1);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            return CATransform3DRotate(transform, M_PI_2, 0, 0, 1);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            return CATransform3DRotate(transform, -M_PI_2, 0, 0, 1);
            break;
        default:
            // don't do anything, intentionally
            break;
    }
    return transform;
}