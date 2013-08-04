//
//  CPMUCViewController.m
//  CouchParty
//
//  Created by 呆呆 on 13-7-28.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import "CPMUCViewController.h"
#import "CPFacebookConnection.h"

@interface CPMUCViewController ()

@property (nonatomic, strong) XMPPRoomHybridStorage* xmppRoomStorage;
@property (nonatomic, strong) NSMutableArray* messages;
@property (nonatomic, strong) NSMutableArray* occupants;
@property (nonatomic, strong) XMPPRoom* xmppRoom;

- (void)joinRoom;

@end

@implementation CPMUCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self joinRoom];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.xmppRoom leaveRoom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)joinRoom
{
    self.xmppRoomStorage = [XMPPRoomHybridStorage sharedInstance];
    self.xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:self.xmppRoomStorage jid:self.roomJID];
    
    [self.xmppRoom addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [self.xmppRoom activate:self.xmppStream];
    [self.xmppRoom joinRoomUsingNickname:[CPFacebookConnection sharedConnection].myvCard.formattedName history:nil];
}

- (void)sendMessage:(NSString *)messsage
{
    [self.xmppRoom sendMessage:messsage];
    [super sendMessage:messsage];
}

#pragma mark - XMPP room delegate

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"You are the first!");
    [self.xmppRoom changeRoomSubject:self.roomSubject];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    
}

@end
