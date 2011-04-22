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

@synthesize activity;
@synthesize lockView;
@synthesize winView;
@synthesize buyButton;
@synthesize userId;
@synthesize virtualCurrencyBalanceView;
@synthesize notificationLabel;
@synthesize notificationStatusLabel;

#pragma mark cute UI stuff

- (void)setNotificationStatusText:(NSString *)text {
    notificationStatusLabel.alpha = 1.0;
    notificationStatusLabel.text = text;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3.0];
    [UIView setAnimationBeginsFromCurrentState:NO];
    
    notificationStatusLabel.alpha = 0;
    [UIView commitAnimations];
}

- (void)setNotificationText:(NSString *)text {
    notificationLabel.alpha = 1.0;
    notificationLabel.text = text;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3.0];
    [UIView setAnimationBeginsFromCurrentState:NO];
    
    notificationLabel.alpha = 0;
    [UIView commitAnimations];
    
    
}

#pragma mark G6Pay SDK calls
//checks user's balance
- (void) checkBalance {
    [self setNotificationText:@"Fetching user balance.."];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBalanceSuccessNotification:) name:G6_NOTIFICATION_USER_BALANCE_SUCCESS object:nil];
    
    [self.activity startAnimating];
    [[G6Pay getG6Instance] getUserBalance:userId delegate:nil];
    
	
}


//method that adds 50 points to the user's balance
-(void) addFifty {
    [self setNotificationText:@"Crediting user account.."];
	//start spinner
	[self.activity startAnimating];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creditUserSuccessNotification:) name:G6_NOTIFICATION_CREDIT_USER_SUCCESS object:nil];
    
    [[G6Pay getG6Instance] creditUser:[NSString stringWithFormat:@"%ld", [[NSDate date] timeIntervalSince1970]]
                               userId:userId
                               amount:50
                             delegate:nil];
	
}

//method that subtracts 50 points from the user's balance
-(void)subtractFifty {
    [self setNotificationText:@"Debiting user account.."];
	//start spinner
	[self.activity startAnimating];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debitUserSuccessNotification:) name:G6_NOTIFICATION_DEBIT_USER_SUCCESS
                                               object:nil];
    
    [[G6Pay getG6Instance] debitUser:[NSString stringWithFormat:@"%ld", [[NSDate date] timeIntervalSince1970]]
                               userId:userId
                               amount:50
                             delegate:nil];
}

//download all transactions for the user
-(void) getTransactions {
    [self setNotificationText:@"Fetching transactions.."];
	[self.activity startAnimating];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTransactionsSuccessNotification:) name:G6_NOTIFICATION_GET_TRANSACTIONS_SUCCESS object:nil];
    
    [[G6Pay getG6Instance] getAllTransactions:userId delegate:nil];
    
}

#pragma mark handle user input

- (void) fadeOutLock {
	
    [self setNotificationStatusText:@"Gift earned! Congrats - you've earned it!"];
    
	[buyButton removeFromSuperview];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[lockView setAlpha:0];
	[winView setAlpha:100];
	[UIView commitAnimations];
	[self.activity stopAnimating];
	
}

- (void)doBuyGift {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyGiftSuccess:) name:G6_NOTIFICATION_DEBIT_USER_SUCCESS
                                               object:nil];
    
    [[G6Pay getG6Instance] debitUser:[NSString stringWithFormat:@"%ld", [[NSDate date] timeIntervalSince1970]]
                              userId:userId
                              amount:300
                            delegate:nil];
}

- (void)buyGift {
	
	if(currentBalance >= 300.00) {
        [self doBuyGift];
	}
	else {
		UIAlertView *purchasePrompt = [[UIAlertView alloc] initWithTitle:@"Virtual Currency Needed" message:@"Would you like to purchase virtual currency now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		
        purchaseAlertView = purchasePrompt;
        
		[purchasePrompt show];
		[purchasePrompt release];
		
	}
	
	
}

-(void) rePrompt:(NSNotification *)msg {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBalanceSuccessNotification:) name:G6_NOTIFICATION_USER_BALANCE_SUCCESS object:nil];
	[self checkBalance];
	
	UIAlertView *purchasePrompt = [[UIAlertView alloc] initWithTitle:@"Complete purchase" message:@"Would you like to complete your virtual item purchase?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	
	[purchasePrompt show];
	[purchasePrompt release];
	
}



#pragma mark G6Pay NSNotification event callbacks

-(void) debitUserSuccessNotification:(NSNotification *)notification {
    [self.activity stopAnimating];
    [self setNotificationStatusText:@"Debit user call success.."];
    [self checkBalance];
}

-(void) creditUserSuccessNotification:(NSNotification *)notification {
    [self.activity stopAnimating];
    [self setNotificationStatusText:@"Credit user call success.."];
    [self checkBalance];
}

- (void)buyGiftSuccess:(NSNotification *)notification {
    [self.activity stopAnimating];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:G6_NOTIFICATION_DEBIT_USER_SUCCESS object:nil];
    
    [self fadeOutLock];
}


-(void) getTransactionsSuccessNotification:(NSNotification *)notification {
    [self.activity stopAnimating];
    [self setNotificationStatusText:@"Transactions logged to NSLog"];
    
    NSArray *transactions = [notification object];
    NSLog(@"Transactions count %d", [transactions count]);
    
    for (G6TransactionDTO *transaction in transactions) {
        NSLog(@"Transaction offerId:%@ offerName:%@ netPayout:%2.2f userId:%@ balance:%2.2f %@", 
              transaction.offerId, transaction.offerName, transaction.netPayout,
              transaction.userId, transaction.virtualCurrencyAmount,
              transaction.description);
        
    }
}
//receives the notification when the user balance check is completed and received back from the server (receives notification from G6Pay
-(void) getBalanceSuccessNotification:(NSNotification *)notification  {
    
    [self.activity stopAnimating];
    [self setNotificationStatusText:@"Get balance call success"];

	NSNumber *balance = [notification object];
	virtualCurrencyBalanceView.text =  [NSString stringWithFormat:@"%@%@%@", @"Current balance:", [balance stringValue], @" points"];
									   
	
	[self.activity stopAnimating];
    
    currentBalance = [balance floatValue];
    
	
}

#pragma mark UIAlertViewDelegate callbacks

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger )buttonIndex {
		
	if(buttonIndex == 1) {
		
        if (purchaseAlertView == alertView) {
            
            [[G6Pay getG6Instance] showOffers:userId
                                     delegate:nil
                                       parent:self
                            showNavigationBar:YES
                           navigationBarOnTop:YES];
		}

	}
	
}



#pragma mark view setup

- (void)setupView {
    
    
	//set  background color
    self.view.backgroundColor = [UIColor whiteColor];
	
	//add virtual gift image
	UIImage *gift = [UIImage imageNamed:@"gift.jpg"]; 
	UIImageView *giftView = [[UIImageView alloc] initWithImage:gift];
	CGSize giftViewSize = giftView.bounds.size;
	giftViewSize.width = giftViewSize.width * 0.5;
	giftViewSize.height = giftViewSize.height * 0.5;
	CGRect newFrame = CGRectMake (80, 80, giftViewSize.width, giftViewSize.height);
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
	CGRect winFrame = CGRectMake (80, 110, winViewSize.width, winViewSize.height);
	[winView setFrame:winFrame];
	winView.alpha = 0;
	[self.view addSubview:winView];
	
    
    float buttonStartY = 290;
    float buttonOffset = 40;
    
	//create the Buy button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.buyButton = button;
    
	//set the position of the button
	button.frame = CGRectMake(65, buttonStartY, 170, 30);
	[button setTitle:@"Buy This! (300 points)" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buyGift) 
	 forControlEvents:UIControlEventTouchUpInside];
    
	//add the button to the view
	[self.view addSubview:button];
	
	//create the debit button
	UIButton *addFiftyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	addFiftyButton.frame = CGRectMake(75, buttonStartY+buttonOffset, 150, 30);
	[addFiftyButton setTitle:@"+50 points" forState:UIControlStateNormal];
	[addFiftyButton addTarget:self action:@selector(addFifty) 
             forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:addFiftyButton];
	
	
	//create the credit button
	UIButton *subtractFiftyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	subtractFiftyButton.frame = CGRectMake(75, buttonStartY+buttonOffset*2, 150, 30);
	[subtractFiftyButton setTitle:@"-50 points" forState:UIControlStateNormal];
	[subtractFiftyButton addTarget:self action:@selector(subtractFifty) 
                  forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:subtractFiftyButton];
	
	
    //create the get transactions button
	UIButton *getTransactionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	getTransactionsButton.frame = CGRectMake(75, buttonStartY+buttonOffset*3, 150, 30);
	[getTransactionsButton setTitle:@"Fetch transactions" forState:UIControlStateNormal];
	[getTransactionsButton addTarget:self action:@selector(getTransactions) 
                    forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:getTransactionsButton];
	
    
    
    // Set up text labels
    
    // balance label
	UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    [self.view addSubview:balanceLabel];
    self.virtualCurrencyBalanceView = balanceLabel;
    [balanceLabel release];
    
	virtualCurrencyBalanceView.font = [UIFont systemFontOfSize:15];
    virtualCurrencyBalanceView.textColor = [UIColor greenColor];
    
    // notification label
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 30)];
    [self.view addSubview:label];
    self.notificationLabel = label;
    [label release];
    
    notificationLabel.numberOfLines = 1;
	notificationLabel.font = [UIFont systemFontOfSize:15];
    notificationLabel.textColor = [UIColor blueColor];
    notificationLabel.backgroundColor = [UIColor clearColor];

    // status label
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 30)];
    [self.view addSubview:label2];
    self.notificationStatusLabel = label2;
    [label2 release];
    
    notificationStatusLabel.numberOfLines = 1;
	notificationStatusLabel.font = [UIFont systemFontOfSize:15];
    notificationStatusLabel.textColor = [UIColor redColor];
    notificationStatusLabel.backgroundColor = [UIColor clearColor];
    
    
    //add the activity spinner
	self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.activity setCenter:CGPointMake(160,210)];
	[self.view addSubview:self.activity];
    

}


- (void)viewDidLoad {
	
	userId = @"raspasov";
	
    // Initialize the SDK
    [G6Pay initSDKWithAppId:@"8" andSecretKey:@"3754cc6199343d095.77764861"];
    
    [[G6Pay getG6Instance] installConfirm];
    
    [[G6Pay getG6Instance] setPollForCompletedOffers:NO];
    [self setupView];
    
    // register for 
	[self checkBalance];
	
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
