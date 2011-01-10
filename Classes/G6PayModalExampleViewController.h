//
//  G6PayModalExampleViewController.h
//  G6PayModalExample
//
//  Created by Alexander Spasov on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayViewController.h"

@interface G6PayModalExampleViewController : UIViewController {
	G6Ads *g6Library;
	PayViewController *pay;
	UIActivityIndicatorView *activity;
	UIImageView *lockView;
	UIImageView *winView;
	NSString *userId;
	UIButton *button;
	BOOL rePromptBool;
}

@property(retain) UIActivityIndicatorView *activity;
@property(retain) G6Ads *g6Library;
@property(retain) UIImageView *lockView;
@property(retain) UIImageView *winView;
@property(retain) UIButton *button;
@property(retain) NSString *userId;
@property BOOL rePromptBool;

@end

