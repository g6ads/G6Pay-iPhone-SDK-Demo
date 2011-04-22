//
//  G6PayModalExampleViewController.h
//  G6PayModalExample
//
//  Created by Rangel Spasov on 12/23/10.
//  Copyright 2010 G6 Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G6PayModalExampleViewController : UIViewController {
	UIActivityIndicatorView *activity;
	UIImageView *lockView;
	UIImageView *winView;
    UILabel *virtualCurrencyBalanceView;
    UILabel *notificationLabel;
    UILabel *notificationStatusLabel;
    UIAlertView *purchaseAlertView;
	UIButton *buyButton;
    
	NSString *userId;
    
    float currentBalance;

}

@property(assign) UIActivityIndicatorView *activity;
@property(assign) UIImageView *lockView;
@property(assign) UIImageView *winView;
@property(assign) UILabel *virtualCurrencyBalanceView;
@property(assign) UILabel *notificationLabel;
@property(assign) UILabel *notificationStatusLabel;
@property(assign) UIButton *buyButton;

@property(retain) NSString *userId;

@end

