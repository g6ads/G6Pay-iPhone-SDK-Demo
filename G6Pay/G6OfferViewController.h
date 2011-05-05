//
//  G6OfferViewController.h
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol G6OffersDelegate;
@class G6Pay;

@interface G6OfferViewController : UIViewController <UIWebViewDelegate> {
    
    NSString *urlString;
    G6Pay *parent;
    id<G6OffersDelegate> offersDelegate;
    NSString *signature;
    
    BOOL showNavBar;
    BOOL navBarOnTop;
    BOOL autoclose;
    
    BOOL wasClosed;
    
    UIActivityIndicatorView *activityView;
}

- (id)initWithURL:(NSString *)urlString
     andSignature:(NSString *)signature
andOffersDelegate:(id<G6OffersDelegate>)delegate
    andG6Instance:(G6Pay *)g6Instance;

@property (nonatomic) BOOL showNavBar;
@property (nonatomic) BOOL navBarOnTop;
@property (nonatomic) BOOL autoclose;

@property (nonatomic, assign) G6Pay *parent;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, assign)  id<G6OffersDelegate> offersDelegate;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) UIActivityIndicatorView *activityView;

@end
