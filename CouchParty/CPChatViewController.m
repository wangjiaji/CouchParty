//
//  CPChatViewController.m
//  CouchParty
//
//  Created by 呆呆 on 13-7-16.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import "CPChatViewController.h"
#import "XMPPStream.h"
#import "XMPPMessage.h"

@interface CPChatViewController ()

@property (nonatomic, strong, readonly) UIView* container;
@property (nonatomic, strong, readonly) UIBubbleTableView* chatMessageView;
@property (nonatomic, strong, readonly) PHFComposeBarView* chatInputView;


- (void)appendTextToMessageView:(NSString *)text from:(XMPPJID*)user;
- (void)appendTextToMessageView:(NSString*)text;
- (CGFloat)chatMessageViewOffset;
- (void)scrollTextViewToBottom;


@end

CGRect const kInitialViewFrame = { 0.0f, 0.0f, 320.0f, 460.0f };

@implementation CPChatViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.chatMessages = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillToggle:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillToggle:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:kInitialViewFrame];
    view.backgroundColor = [UIColor colorWithHue:220/360.0 saturation:0.08 brightness:0.93 alpha:1];
    
    UIView *container = self.container;
    [container addSubview:self.chatMessageView];
    [container addSubview:self.chatInputView];
    [view addSubview:container];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Bubble view properties
    self.chatMessageView.bubbleDataSource = self;
    self.chatMessageView.snapInterval = 120;     // Set message group interval to 120 seconds
    self.chatMessageView.showAvatars = YES;
    
    // Compose bar view properties
    self.chatInputView.maxCharCount = 160;
    self.chatInputView.maxLinesCount = 3;
    self.chatInputView.placeholder = @"Type something...";
    self.chatInputView.delegate = self;
    
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.chatMessages = [NSMutableArray array];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillToggle:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]        getValue:&startFrame];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&endFrame];
    
    NSInteger signCorrection = 1;
    if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0)
        signCorrection = -1;
    
    CGFloat widthChange  = (endFrame.origin.x - startFrame.origin.x) * signCorrection;
    CGFloat heightChange = (endFrame.origin.y - startFrame.origin.y) * signCorrection;
    
    CGFloat sizeChange = UIInterfaceOrientationIsLandscape([self interfaceOrientation]) ? widthChange : heightChange;
    
    CGFloat tabBarContainerHeight = self.tabBarController.tabBar.bounds.size.height;
    if (sizeChange > 0) {
        tabBarContainerHeight *= -1;
    }
    CGRect newContainerFrame = self.container.frame;
    newContainerFrame.size.height += (sizeChange + tabBarContainerHeight);
    
    
    CGFloat offsetY = [self chatMessageViewOffset];
    CGPoint newChatMessageViewContentOffset = CGPointMake(0, offsetY);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationCurve|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.container.frame = newContainerFrame;
                     }
                     completion:NULL];
    
    
    [self.chatMessageView setContentOffset:newChatMessageViewContentOffset animated:YES];
}

- (CGFloat)chatMessageViewOffset
{
    return MAX(0.0f, self.chatMessageView.contentSize.height - self.chatMessageView.frame.size.height);
}

- (void)scrollTextViewToBottom {
    CGFloat offsetY = [self chatMessageViewOffset];
    CGPoint newChatMessageViewContentOffset = CGPointMake(0, offsetY);
    self.chatMessageView.contentOffset = newChatMessageViewContentOffset;
}

- (void)addBubble:(NSBubbleData *)bubble
{
    [self.chatMessages addObject:bubble];
    [self.chatMessageView reloadData];
    [self scrollTextViewToBottom];
}

- (void)sendMessage:(NSString *)messsage
{
    NSBubbleData* bubble = [NSBubbleData dataWithText:messsage date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    bubble.avatar = self.myAvatar;
    
    [self addBubble:bubble];
}

- (void)sendXMPPMessage:(NSString *)message withType:(NSString*)type to:(XMPPJID *)jid
{
    XMPPMessage* xmppMessage = [XMPPMessage messageWithType:type to:jid];
    [xmppMessage addBody:message];
    [self.xmppStream sendElement:xmppMessage];
}

- (void)sendImage:(UIImage *)image
{
    NSLog(@"Sending image...");
}

@synthesize container = _container;
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:kInitialViewFrame];
        [_container setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    }
    
    return _container;
}

@synthesize chatInputView = _chatInputView;
- (PHFComposeBarView *)chatInputView {
    if (!_chatInputView) {
        CGRect frame = CGRectMake(0.0f,
                                  kInitialViewFrame.size.height - PHFComposeBarViewInitialHeight,
                                  kInitialViewFrame.size.width,
                                  PHFComposeBarViewInitialHeight);
        _chatInputView = [[PHFComposeBarView alloc] initWithFrame:frame];
        [_chatInputView setUtilityButtonImage:[UIImage imageNamed:@"Camera"]];
    }
    
    return _chatInputView;
}

@synthesize chatMessageView = _chatMessageView;
- (UIBubbleTableView*)chatMessageView
{
    if (!_chatMessageView) {
        CGRect frame = CGRectMake(0.0f,
                                  0.0f,
                                  kInitialViewFrame.size.width,
                                  kInitialViewFrame.size.height - self.chatInputView.bounds.size.height);
        _chatMessageView = [[UIBubbleTableView alloc] initWithFrame:frame];
        _chatMessageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _chatMessageView;
}

#pragma mark - Compose bar delegate

- (void)composeBarView:(PHFComposeBarView *)composeBarView willChangeFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame duration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)animationCurve
{
    CGFloat heightChange = endFrame.size.height - startFrame.size.height;
    
    CGRect newChatMessageViewFrame = self.chatMessageView.frame;
    newChatMessageViewFrame.size.height -= heightChange;
    
    CGFloat offsetY = MAX(0.0f, self.chatMessageView.contentSize.height - newChatMessageViewFrame.size.height);
    CGPoint newChatMessageViewContentOffset = CGPointMake(0, offsetY);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationCurve|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.chatMessageView.contentOffset = newChatMessageViewContentOffset;
                     }
                     completion:NULL];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView
{
    [self sendMessage:self.chatInputView.text];
    [composeBarView setText:@""];
    [composeBarView resignFirstResponder];
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView
{
    NSString* title = @"Choose a Photo Source";
    NSString* fromPhotoLibrary = @"From Photo Library";
    NSString* takeAPicture = @"Take a Picture";
    NSString* cancelTitle = @"Cancel";
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:fromPhotoLibrary, takeAPicture, nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [self.chatMessages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [self.chatMessages objectAtIndex:row];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    switch (buttonIndex) {
        case 0:
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 1:
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        default:
            return;
            break;
    }
    imagePicker.delegate = self;
    
    [self.tabBarController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
}

#pragma mark - ChatView message delegate

- (void)chatViewDidReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"Got message %@", message);
    
}

@end
