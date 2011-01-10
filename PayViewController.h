//
//  PayViewController.h
//  G6PayModalExample
//
//  Created by Alexander Spasov on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G6Ads.h"

@interface PayViewController : UIViewController <UIWebViewDelegate> {

	
	G6Ads *g6Library;
	NSTimer *checkCompletionTimer;
}

@property(retain) G6Ads *g6Library;
@property(retain) NSTimer *checkCompletionTimer;

@end
