//
//  CBUIGlobal.h
//  ArabianRaces2
//
//  Created by Christian Beer on 20.12.10.
//  Copyright 2010 Christian Beer. All rights reserved.
//

#import <Foundation/Foundation.h>

extern inline double CBUIRadians (double degrees);


BOOL CBIsIPad();

UIBarButtonItem *CBUIBarButtonSetTintColor(UIBarButtonItem *itm, UIColor *tintColor);
UIBarButtonItem *CBUIBarButtonSetStyle(UIBarButtonItem *itm, UIBarButtonItemStyle style);
UIBarButtonItem *CBUIBarFlexibleSpace();
UIBarButtonItem *CBUIBarButtonFixedSpace(CGFloat width);
UIBarButtonItem *CBUIBarButtonSystemItem(UIBarButtonSystemItem type, id target, SEL action);
UIBarButtonItem *CBUIBarButtonTextItem(NSString *title, id target, SEL action);
UIBarButtonItem *CBUIBarButtonImageItem(NSString *img, id target, SEL action);
UIBarButtonItem *CBUIBarButtonCustomItem(UIView *view);

#pragma mark -
#pragma mark Internationalization

NSString *I18N(NSString *key, NSString *comment);
NSString *I18N1(NSString *key, id param1);
NSString *I18N2(NSString *key, id param1, id param2);


CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat radius);


void ShowNetworkIndicator();
void HideNetworkIndicator();


BOOL CBUIMinimumVersion(float version);

CGPoint CBCGPointDelta(CGPoint point, CGFloat deltaX, CGFloat deltaY);
CGPoint CBCGPointSetX(CGPoint point, CGFloat x);
CGPoint CBCGPointSetY(CGPoint point, CGFloat y);

CGPoint CBCGRectGetCenter(CGRect rect);