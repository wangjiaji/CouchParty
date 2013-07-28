//
//  CPLoginController.m
//  CouchParty
//
//  Created by 呆呆 on 13-6-22.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import "CPLoginController.h"
#import "CPFacebookConnection.h"

@interface CPLoginController ()

@end

@implementation CPLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    CPFacebookConnection* facebookConnection = [CPFacebookConnection sharedConnection];
    [facebookConnection addDelegate:self to:XMPPOjbectIdentifierStream];
    [connectionIndicator startAnimating];
    [facebookConnection connect];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"Authentication succeeded!");
    [connectionIndicator stopAnimating];
    [[CPFacebookConnection sharedConnection] removeDelegate:self from:XMPPOjbectIdentifierStream];
    [self performSegueWithIdentifier:@"LoginSegue" sender:sender];
}

@end
