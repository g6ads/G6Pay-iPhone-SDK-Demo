    //
//  PayViewController.m
//  G6PayModalExample
//
//  Created by Rangel Spasov on 12/23/10.
//  Copyright 2010 G6 Media. All rights reserved.
//
#import "G6PayModalExampleViewController.h"
#import "PayViewController.h"

#import <QuartzCore/QuartzCore.h>
UIActivityIndicatorView *activity;

@implementation PayViewController

@synthesize g6Library, checkCompletionTimer;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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

	
	 //create the view and set autoresizing mask to be able to rotate
	CGSize viewSize = self.view.frame.size;
	float toolbarHeight = 44.0;
	CGRect toolbarFrame = CGRectMake(0, viewSize.height-toolbarHeight, viewSize.width, toolbarHeight);
	UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
	myToolbar.tintColor = [UIColor blackColor];
	myToolbar.translucent = YES;
	
	myToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth 
									|
								UIViewAutoresizingFlexibleLeftMargin
									|
								UIViewAutoresizingFlexibleRightMargin
									|
	UIViewAutoresizingFlexibleTopMargin;
	

	
	//creates the sample webview, set dimensions, and scales pages to fit
	CGRect webRect = CGRectMake(0,0, 320, 420.0);
	UIWebView *myWebView = [[UIWebView alloc] initWithFrame:webRect];
	myWebView.scalesPageToFit = YES;
	myWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth 
	| UIViewAutoresizingFlexibleHeight |
	UIViewAutoresizingFlexibleLeftMargin
	|
	UIViewAutoresizingFlexibleRightMargin
	|
	UIViewAutoresizingFlexibleTopMargin;
	
	myWebView.delegate = self;
	
	//instantiates the G6Pay class, creates a valid URL and loads it into the UIWebView element created in the previous step
	
	self.g6Library = [[G6Pay alloc] init];


	NSString *userId = @"raspasov";
	
	NSString *urlAddress=[self.g6Library displayOffers:userId];
	
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[myWebView loadRequest:request];

	//loader animation spinner
	[self.view addSubview:myWebView];
	activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activity setCenter:CGPointMake(160,210)];
	[activity startAnimating];
	[self.view addSubview:activity];	
	
	
	//the back arrow button
	unichar backArrowCode = 0x25C0; //BLACK LEFT-POINTING TRIANGLE
	NSString *backArrowString = [NSString stringWithCharacters:&backArrowCode length:1];
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backArrowString style:UIBarButtonItemStylePlain target:myWebView action:@selector(goBack)];
	
	//the Close Button
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closePressed:)];
	
	//the empty space on the bar
	UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	flexButton.width = 20;
	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	//the forward arrow button
	unichar forwardArrowCode = 0x25B6; //BLACK RIGHT-POINTING TRIANGLE
	NSString *forwardArrowString = [NSString stringWithCharacters:&forwardArrowCode length:1];
	UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:forwardArrowString style:UIBarButtonItemStylePlain target:myWebView action:@selector(goForward)];
	
	//make an array and load the items onto the bar
	NSArray *buttons = [[NSArray alloc] initWithObjects:backBarButtonItem, flexButton, forwardBarButtonItem, fixedSpace, closeButton, nil];
	[myToolbar setItems:buttons animated:YES];
	

	 [self.view addSubview:myToolbar];
	
	//release the adove items 
	[backBarButtonItem release];
	[closeButton release];
	[flexButton release];
	[fixedSpace release];
	[forwardBarButtonItem release];
	[buttons release];
	
	[myWebView release];
	
	//start checking for offer completion as soon as the view is loaded
	self.checkCompletionTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(checkCompletionTimerAction:) userInfo:userId repeats:YES];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cpaComplete:) name:@"cpaActionComplete" object:nil];
	
}

//calls the library to check if the payment process has been completed
-(void)checkCompletionTimerAction:(NSTimer *)timer {
	
	[self.g6Library checkOffer:[timer userInfo]];
	
}

//executed when the Close button is pressed for the web view
- (void) closePressed:(id)sender {

	//stop the timer from checking for completion
	[self.checkCompletionTimer invalidate];

	[self dismissModalViewControllerAnimated:YES];
	[self autorelease];

}

- (void) cpaComplete:(NSNotification *)aNote {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	//the Purchase complete alert
	UIAlertView *purchaseComplete = [[UIAlertView alloc] initWithTitle:@"Purchase complete" message:@"You've got virtual currency!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	
	//post notification to fade out lock
	[[NSNotificationCenter defaultCenter] postNotificationName:@"fadeOutLock" object:nil];
	
	[purchaseComplete show];
	[purchaseComplete release];
	
	[self dismissModalViewControllerAnimated:YES];
	
	//invalidate the timer that checks for payment completion
	[self.checkCompletionTimer invalidate];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger )buttonIndex {
	
	if(buttonIndex == 0) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"rePrompt" object:nil];
			
		}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[activity stopAnimating];
	
	//get the phone's unique id
	UIDevice *device = [UIDevice currentDevice];
	NSString *uniqueIdentifier = [device uniqueIdentifier];
	
	//execute JavaScript on the loaded web view to put the unique phone id into the web view 
	NSString *javaScriptCode = [NSString stringWithFormat:@"%@%@%@", @"$('.ppi').each(function() {$(this).attr('href', $(this).attr('href').replace('udidrplc','", uniqueIdentifier, @"'));});" ];
	
	
	[webView stringByEvaluatingJavaScriptFromString:javaScriptCode];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
