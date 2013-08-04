//
//  CPSingleChatViewController.m
//  CouchParty
//
//  Created by 呆呆 on 13-7-28.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import "CPSingleChatViewController.h"
#import "XMPPMessage.h"

@interface CPSingleChatViewController ()
- (void)sendXMPPMessage:(NSString *)message;
@end

@implementation CPSingleChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = self.friendName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendXMPPMessage:(NSString *)message
{
    [self sendXMPPMessage:message withType:@"chat" to:self.friendJID];
}

- (void)sendMessage:(NSString *)messsage
{
    [self sendXMPPMessage:messsage];
    [super sendMessage:messsage];
}

#pragma mark - ChatView message delegate

- (void)chatViewDidReceiveMessage:(XMPPMessage *)message
{
    if ([message isMessageWithBody]) {
        NSBubbleData* bubble = [NSBubbleData dataWithText:message.body date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        bubble.avatar = self.friendAvatar;
        [self addBubble:bubble];
    }
}

@end
