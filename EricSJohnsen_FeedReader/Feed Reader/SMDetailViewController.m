//
//  SMDetailViewController.m
//  Feed Reader
//
//  Created by Eric Johnsen on 11/25/12.
//  Copyright (c) 2012 Eric S. Johnsen. All rights reserved.
//

#import "SMDetailViewController.h"
#import "SMFeedItem.h"

@implementation SMDetailViewController

@synthesize feedItem;

- (void)viewDidLoad {

    [super viewDidLoad];

    // Set the nav. bar's title to the title of the feed item we're showing.
    self.title = self.feedItem.itemTitle;
    
    // Create the web view and tell it to load this feed item's HTML content.
    //
    // I was originally setting it's frame to [self.view bounds] but was having
    // an issue where the last bit of content was being hidden because the web view
    // is contained within a scroll view. My simple solution was to make the
    // web view's CGRect 50. pixels shorter than [self.view bounds].
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0., 0., self.view.bounds.size.width, self.view.bounds.size.height - 50.)];
    [webView loadHTMLString:self.feedItem.itemContent baseURL:nil];
    
    // Add the web view as a subview of this view controller.
    [self.view addSubview:webView];
}

- (void)viewDidUnload {

    [super viewDidUnload];

    // Make sure we nil our reference to our subview.
    webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // The style delivered to us in the feed's content sets the width of the content to 
    // the width of an iPhone screen in portrait orientation. Therefore, we only support 
    // portrait orientation.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
