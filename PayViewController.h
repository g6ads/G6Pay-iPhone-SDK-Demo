//
//  PayViewController.h
//  G6PayModalExample
//
//  Created by Rangel Spasov on 12/23/10.
//  Copyright 2010 G6 Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G6Pay.h"

@interface PayViewController : UIViewController <UIWebViewDelegate> {

	
	G6Pay *g6Library;
	NSTimer *checkCompletionTimer;
}

@property(retain) G6Pay *g6Library;
@property(retain) NSTimer *checkCompletionTimer;

@end
