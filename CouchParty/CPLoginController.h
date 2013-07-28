//
//  CPLoginController.h
//  CouchParty
//
//  Created by 呆呆 on 13-6-22.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"

@interface CPLoginController : UIViewController <XMPPStreamDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *connectionIndicator;
}

- (IBAction)login:(id)sender;

@end
