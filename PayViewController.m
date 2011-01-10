    //
//  PayViewController.m
//  G6PayModalExample
//
//  Created by Alexander Spasov on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "G6PayModalExampleViewController.h";
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
	
	//[self.view setBackgroundColor:[UIColor redColor]];
	
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
	
	//instantiates the G6Ads class, creates a valid URL and loads it into the UIWebView element created in the previous step
	
	self.g6Library = [[G6Ads alloc] init];
	self.g6Library.requestsAllowed = TRUE;

	NSString *userId = @"raspasov";
	NSString *urlAddress=[self.g6Library displayOffers:userId];
	
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[myWebView loadRequest:request];

	//loader animation
	[self.view addSubview:myWebView];
	activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activity setCenter:CGPointMake(160,210)];
	[activity startAnimating];
	[self.view addSubview:activity];	
	
	unichar backArrowCode = 0x25C0; //BLACK LEFT-POINTING TRIANGLE
	NSString *backArrowString = [NSString stringWithCharacters:&backArrowCode length:1];
	
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backArrowString style:UIBarButtonItemStylePlain target:myWebView action:@selector(goBack)];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closePressed:)];
	
	UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	flexButton.width = 20;
	
	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	unichar forwardArrowCode = 0x25B6; //BLACK RIGHT-POINTING TRIANGLE
	NSString *forwardArrowString = [NSString stringWithCharacters:&forwardArrowCode length:1];
	
	UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:forwardArrowString style:UIBarButtonItemStylePlain target:myWebView action:@selector(goForward)];
	
	NSArray *buttons = [[NSArray alloc] initWithObjects:backBarButtonItem, flexButton, forwardBarButtonItem, fixedSpace, closeButton, nil];
	[myToolbar setItems:buttons animated:YES];
	

	 [self.view addSubview:myToolbar];

	
	[myWebView release];
	
	checkCompletionTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(checkCompletionTimerAction:) userInfo:userId repeats:YES];
	
	//[self.g6Library checkOffer:userId];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cpaComplete:) name:@"cpaActionComplete" object:nil];
	
}

-(void)checkCompletionTimerAction:(NSTimer *)timer {
	
	[self.g6Library checkOffer:[timer userInfo]];
	
}


- (void) closePressed:(id)sender {
	
	//notify library to stop checking for offer completion
	
	//self.g6Library.requestsAllowed = NO;
	
	[self dismissModalViewControllerAnimated:YES];
		
}

- (void) cpaComplete:(NSNotification *)aNote {

	[checkCompletionTimer invalidate];
	
	UIAlertView *purchaseComplete = [[UIAlertView alloc] initWithTitle:@"Purchase complete" message:@"You've got virtual currency!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	
	//post notification to fade out lock
		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"fadeOutLock" object:nil];
	
	[purchaseComplete show];
	[purchaseComplete release];
	
	[self dismissModalViewControllerAnimated:YES];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger )buttonIndex {
	
	if(buttonIndex == 0) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"rePrompt" object:nil];
			
		}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[activity stopAnimating];
	UIDevice *device = [UIDevice currentDevice];
	NSString *uniqueIdentifier = [device uniqueIdentifier];
	NSString *javaScriptCode = [NSString stringWithFormat:@"%@%@%@", @"$('#ppi').attr('href', $('#ppi').attr('href').replace('udidrplc','", uniqueIdentifier, @"'));" ];
	
	
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
