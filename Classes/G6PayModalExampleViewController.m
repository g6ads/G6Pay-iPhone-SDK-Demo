//
//  G6PayModalExampleViewController.m
//  G6PayModalExample
//
//  Created by Rangel Spasov on 12/23/10.
//  Copyright 2010 G6 Media. All rights reserved.
//
#import "G6Pay.h"
#import "G6PayModalExampleViewController.h"




@implementation G6PayModalExampleViewController

@synthesize activity, g6Library, lockView, winView, button, rePromptBool, userId, pay, virtualCurrencyBalanceView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/		

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	
	userId = @"raspasov";
	
	self.rePromptBool = NO;
	
	//instantiates the G6Pay class, creates a valid URL and loads it into the UIWebView element created in the previous step
	
    
    [G6Pay initSDKWithAppId:@"8" andSecretKey:@"3754cc6199343d095.77764861"];

	
	//initiate virtual currency balance frame
	CGRect currencyBalanceFrame = CGRectMake(10, 10, 300, 30);
	virtualCurrencyBalanceView = [[UITextView alloc] initWithFrame:currencyBalanceFrame];
	[virtualCurrencyBalanceView setEditable:NO];
	
	
	//set  background color
    self.view.backgroundColor = [UIColor whiteColor];
	
	
	//add virtual gift image
	UIImage *gift = [UIImage imageNamed:@"gift.jpg"]; 
	UIImageView *giftView = [[UIImageView alloc] initWithImage:gift];
	CGSize giftViewSize = giftView.bounds.size;
	giftViewSize.width = giftViewSize.width * 0.5;
	giftViewSize.height = giftViewSize.height * 0.5;
	CGRect newFrame = CGRectMake (80, 120, giftViewSize.width, giftViewSize.height);
	[giftView setFrame:newFrame];
	[self.view addSubview:giftView];
	[giftView release];
	
	//add lock image
	UIImage *lock = [UIImage imageNamed:@"lock.png"]; 
	lockView = [[UIImageView alloc] initWithImage:lock];
	CGSize lockViewSize = lockView.bounds.size;
	lockViewSize.width = lockViewSize.width * 0.3;
	lockViewSize.height = lockViewSize.height * 0.3;
	CGRect lockFrame = CGRectMake (80, 140, lockViewSize.width, lockViewSize.height);
	[lockView setFrame:lockFrame];
	[self.view addSubview:lockView];
	
	
	//add smiley face image
	UIImage *win = [UIImage imageNamed:@"win.png"]; 
	winView = [[UIImageView alloc] initWithImage:win];
	CGSize winViewSize = winView.bounds.size;
	winViewSize.width = winViewSize.width * 0.25;
	winViewSize.height = winViewSize.height * 0.25;
	CGRect winFrame = CGRectMake (80, 60, winViewSize.width, winViewSize.height);
	[winView setFrame:winFrame];
	winView.alpha = 0;
	[self.view addSubview:winView];
	
	//create the Buy button
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	//set the position of the button
	button.frame = CGRectMake(65, 320, 170, 30);
	//set the button's title
	[button setTitle:@"Buy This! (300 points)" forState:UIControlStateNormal];
	//listen for clicks
	[button addTarget:self action:@selector(buyGift) 
	 forControlEvents:UIControlEventTouchUpInside];

	//add the button to the view
	[self.view addSubview:button];
	
	//create the Check My Balance button
	UIButton *addFiftyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	//set the position of the button
	addFiftyButton.frame = CGRectMake(75, 370, 150, 30);
	//set the button's title
	[addFiftyButton setTitle:@"+50 points" forState:UIControlStateNormal];
	//addFiftyButton for clicks
	[addFiftyButton addTarget:self action:@selector(addFifty) 
	 forControlEvents:UIControlEventTouchUpInside];
	//add the button to the view
	[self.view addSubview:addFiftyButton];
	
	
	//create the Check My Balance button
	UIButton *subtractFiftyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	//set the position of the button
	subtractFiftyButton.frame = CGRectMake(75, 410, 150, 30);
	//set the button's title
	[subtractFiftyButton setTitle:@"-50 points" forState:UIControlStateNormal];
	//addFiftyButton for clicks
	[subtractFiftyButton addTarget:self action:@selector(subtractFifty) 
			 forControlEvents:UIControlEventTouchUpInside];
	//add the button to the view
	[self.view addSubview:subtractFiftyButton];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBalanceSuccessNotification:) name:G6_NOTIFICATION_USER_BALANCE_SUCCESS object:nil];
	[self checkBalance];
	
	//add the activity spinner
	self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.activity setCenter:CGPointMake(160,210)];
	[self.view addSubview:self.activity];
	
}
//method that adds 50 points to the user's balance
-(void) addFifty {
	//start spinner
	[self.activity startAnimating];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creditUserSuccessNotification:) name:G6_NOTIFICATION_CREDIT_USER_SUCCESS object:nil];
    
    [[G6Pay getG6Instance] creditUser:[NSString stringWithFormat:@"%ld", [[NSDate date] timeIntervalSince1970]]
                               userId:userId
                               amount:50
                             delegate:nil];
	
}
//method that subtracts 50 points to the user's balance
-(void)subtractFifty {
	//start spinner
	[self.activity startAnimating];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debitUserSuccessNotification:) name:G6_NOTIFICATION_DEBIT_USER_SUCCESS
                                               object:nil];
    
    [[G6Pay getG6Instance] debitUser:[NSString stringWithFormat:@"%ld", [[NSDate date] timeIntervalSince1970]]
                               userId:userId
                               amount:50
                             delegate:nil];
}


//checks user's balance
- (void) checkBalance {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBalanceSuccessNotification:) name:G6_NOTIFICATION_USER_BALANCE_SUCCESS object:nil];

    [self.activity startAnimating];
    [[G6Pay getG6Instance] getUserBalance:userId delegate:nil];

	
}

#pragma mark NSNotification events

-(void) debitUserSuccessNotification:(NSNotification *)notification {
    NSLog(@"Debit user success");
    [self checkBalance];
}

-(void) creditUserSuccessNotification:(NSNotification *)notification {
    NSLog(@"Credit user success");
    [self checkBalance];
}

//receives the notification when the user balance check is completed and received back from the server (receives notification from G6Pay
-(void) getBalanceSuccessNotification:(NSNotification *)notification  {
	virtualCurrencyBalanceView.font = [UIFont systemFontOfSize:14.0];
	NSNumber *balance = [notification object];
	virtualCurrencyBalanceView.text =  [NSString stringWithFormat:@"%@%@%@", @"My Balance is ", [balance stringValue], @" points"];
									   
	
	[self.activity stopAnimating];
    
    currentBalance = [balance floatValue];
    
	[self.view addSubview:virtualCurrencyBalanceView];
	
}

-(void)removeBuyButton:(NSNotification *)msg {

	[button removeFromSuperview];
	
}

-(void) doesUserHaveEnoughCurrency:(NSNotification *)notif {
	
	NSNumber *balance = [notif object];
	if([balance floatValue] >= 300.00) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debitUserSuccessNotification:) name:G6_NOTIFICATION_DEBIT_USER_SUCCESS
                                                   object:nil];
        
		[[G6Pay getG6Instance] debitUser:[NSString stringWithFormat:@"%ld", [[NSDate date] timeIntervalSince1970]]
                                  userId:userId
                                  amount:300
                                delegate:nil];
		[self fadeOutLock:nil];
	
		
	}
	else {
		self.rePromptBool = NO;
		self.pay = [[PayViewController alloc] init];
		UIAlertView *purchasePrompt = [[UIAlertView alloc] initWithTitle:@"Virtual Currency Needed" message:@"Would you like to purchase virtual currency now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		
		[purchasePrompt show];
		[purchasePrompt release];
		
		//add observer to look for fading out the lock image view
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rePrompt:) name:@"rePrompt" object:nil];		
	}
	
	
}

-(void) rePrompt:(NSNotification *)msg {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBalanceSuccessNotification:) name:G6_NOTIFICATION_USER_BALANCE_SUCCESS object:nil];
	[self checkBalance];
	
	self.rePromptBool = YES;
	UIAlertView *purchasePrompt = [[UIAlertView alloc] initWithTitle:@"Complete purchase" message:@"Would you like to complete your virtual item purchase?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	
	[purchasePrompt show];
	[purchasePrompt release];
	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger )buttonIndex {
		
	if(buttonIndex == 1) {
		
		if(self.rePromptBool) {
			[self buyGift];
		}
		else {
            
            [[G6Pay getG6Instance] showOffers:@"raspasov"
                                     delegate:nil
                                       parent:self
                            showNavigationBar:YES
                           navigationBarOnTop:YES];
		}

	}
	
}

-(void) buyGift {

	
	//start spinner
	
	//[self.activity startAnimating];
	
	//add observer to look for a response from the server
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doesUserHaveEnoughCurrency:) name:G6_NOTIFICATION_USER_BALANCE_SUCCESS object:nil];
    
	[self checkBalance];
	
	//add observer to look for fading out the lock image view
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fadeOutLock:) name:@"fadeOutLock" object:nil];
}

- (void) fadeOutLock:(NSNotification *)msg {
	
	UIAlertView *congrats = [[UIAlertView alloc] initWithTitle:@"Gift earned" message:@"You've earned it!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[congrats show];
	[congrats release];
	
	[self removeBuyButton:nil];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[lockView setAlpha:0];
	[winView setAlpha:100];
	[UIView commitAnimations];
	[self.activity stopAnimating];
	[self.pay release];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
