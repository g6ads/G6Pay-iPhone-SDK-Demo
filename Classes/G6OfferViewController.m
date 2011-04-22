//
//  G6OfferViewController.m
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 Abaca Technology. All rights reserved.
//

#import "G6OfferViewController.h"


@implementation G6OfferViewController

@synthesize navBarOnTop;
@synthesize showNavBar;
@synthesize parent;
@synthesize urlString;
@synthesize activityView;

- (id)initWithURL:(NSString *)url andG6Instance:(G6Pay *)g6Instance {
    self = [super init];
    
    if (self) {
        self.urlString = url;
        self.parent = g6Instance;
        
        self.navBarOnTop = YES;
        self.showNavBar = YES;
    }
    
    return self;
    
}

- (void)dealloc
{
    [urlString release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    CGSize viewSize = self.view.frame.size;
    float toolbarHeight = 0;
    float yOffset = 0;
    
    if (showNavBar) {
        toolbarHeight = 44.0;
        
        if (navBarOnTop)
            yOffset = toolbarHeight;
    }
    
    // Set up the webview
	CGRect webRect = CGRectMake(0,yOffset,
                                self.parentViewController.view.frame.size.width,
                                self.parentViewController.view.frame.size.height-yOffset);
    
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
	
    
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[myWebView loadRequest:request];
    
	[self.view addSubview:myWebView];
    [myWebView release];
    
    
    // Set up the nav bar, if appropriate
    if (showNavBar) {
        CGRect toolbarFrame;
        
        if (navBarOnTop)
            toolbarFrame = CGRectMake(0, 0,
                                      viewSize.width, toolbarHeight);
        else
            toolbarFrame = CGRectMake(0, viewSize.height-toolbarHeight,
                                      viewSize.width, toolbarHeight);

        UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
        myToolbar.tintColor = [UIColor blackColor];
        myToolbar.translucent = YES;
        
        myToolbar.autoresizingMask =    UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin;
        
        //the back arrow button
        
        unichar backArrowCode = 0x25C0; //BLACK LEFT-POINTING TRIANGLE
        NSString *backArrowString = [NSString stringWithCharacters:&backArrowCode length:1];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backArrowString style:UIBarButtonItemStylePlain target:myWebView action:@selector(goBack)];
        
        //the Close Button
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStyleBordered target:self action:@selector(userDidSelectClose:)];
        
        //the empty space on the bar
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        flexButton.width = 20;
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        //the forward arrow button
        unichar forwardArrowCode = 0x25B6; //BLACK RIGHT-POINTING TRIANGLE
        NSString *forwardArrowString = [NSString stringWithCharacters:&forwardArrowCode length:1];
        UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:forwardArrowString style:UIBarButtonItemStylePlain target:myWebView action:@selector(goForward)];
        
        //make an array and load the items onto the bar
        NSArray *buttons = [NSArray arrayWithObjects:backBarButtonItem, flexButton, forwardBarButtonItem, fixedSpace, closeButton, nil];
        [myToolbar setItems:buttons animated:YES];
        
        [backBarButtonItem release];
        [closeButton release];
        [flexButton release];
        [fixedSpace release];
        [forwardBarButtonItem release];
        
        
        [self.view addSubview:myToolbar];
        
        [myToolbar release];
        
    }
	

	// Set up the activity indicator
	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

	[activity setCenter:CGPointMake(myWebView.frame.size.width/2,
                                    myWebView.frame.size.height/2)];
	[activity startAnimating];
	[self.view addSubview:activity];
	
    self.activityView = activity;
    
	[activity release];
    
	
	

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[activityView stopAnimating];
	
	//get the phone's unique id
	UIDevice *device = [UIDevice currentDevice];
	NSString *uniqueIdentifier = [device uniqueIdentifier];
	
	//execute JavaScript on the loaded web view to put the unique phone id into the web view 
	NSString *javaScriptCode = [NSString stringWithFormat:@"%@%@%@", @"$('.ppi').each(function() {$(this).attr('href', $(this).attr('href').replace('udidrplc','", uniqueIdentifier, @"'));});" ];
	
	
	[webView stringByEvaluatingJavaScriptFromString:javaScriptCode];
}

#pragma mark user input

//executed when the Close button is pressed for the web view
- (void) userDidSelectClose:(id)sender {
    
	[self dismissModalViewControllerAnimated:YES];
    
}

@end
