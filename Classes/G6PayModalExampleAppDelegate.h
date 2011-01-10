//
//  G6PayModalExampleAppDelegate.h
//  G6PayModalExample
//
//  Created by Rangel Spasov on 12/23/10.
//  Copyright 2010 G6 Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G6PayModalExampleViewController;

@interface G6PayModalExampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    G6PayModalExampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet G6PayModalExampleViewController *viewController;

@end

