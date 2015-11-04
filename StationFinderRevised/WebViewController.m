//
//  WebViewController.m
//  StationFinderRevised
//
//  Created by Charles Grier on 10/19/15.
//  Copyright © 2015 Grier Mobile Development. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_stationURL];
    [_webView loadRequest:request];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
}

-(IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
