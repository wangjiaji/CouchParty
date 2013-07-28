//
//  CPBuddyListController.h
//  CouchParty
//
//  Created by 呆呆 on 13-6-22.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPFacebookConnection.h"

@interface CPBuddyListController : UITableViewController <NSFetchedResultsControllerDelegate, XMPPStreamDelegate>
{
    NSFetchedResultsController* fetchedResultsController;
    NSMutableDictionary* pendingMessages;
}

@end