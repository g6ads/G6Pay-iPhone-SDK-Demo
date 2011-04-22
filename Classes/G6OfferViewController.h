//
//  G6OfferViewController.h
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 Abaca Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@class G6Pay;

@interface G6OfferViewController : UIViewController <UIWebViewDelegate> {
    
    NSString *urlString;
    G6Pay *parent;
    BOOL showNavBar;
    BOOL navBarOnTop;
    
    UIActivityIndicatorView *activityView;
}

- (id)initWithURL:(NSString *)urlString andG6Instance:(G6Pay *)g6Instance;

@property (nonatomic) BOOL showNavBar;
@property (nonatomic) BOOL navBarOnTop;

@property (nonatomic, assign) G6Pay *parent;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) UIActivityIndicatorView *activityView;

@end
