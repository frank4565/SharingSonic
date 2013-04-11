//
//  SonicTableView.m
//  MultimediaProject
//
//  Created by PowerQian on 12/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "SonicTableView.h"
#import "SonicHeaderTableViewCell.h"
#import "SonicTableViewCell.h"
//#import "UIBubbleTypingTableViewCell.h"

@interface SonicTableView () <SonicTableViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *sonicSection;
@end

@implementation SonicTableView

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    
    //default interval
    self.snapInterval = 120;
//    self.typingBubble = NSBubbleTypingTypeNobody;
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

#pragma mark - Override

- (void)reloadData
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // Cleaning up
	self.sonicSection = nil;
    
    // Loading new data
    int count = 0;
    self.sonicSection = [[NSMutableArray alloc] init];
    
    if (self.sonicDataSource && (count = [self.sonicDataSource rowsForSonicTable:self]) > 0)
    {
        NSMutableArray *sonicData = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.sonicDataSource sonicTableView:self dataForRow:i];
            assert([object isKindOfClass:[NSSonicData class]]);
            [sonicData addObject:object];
        }
        
        [sonicData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             NSSonicData *sonicData1 = (NSSonicData *)obj1;
             NSSonicData *sonicData2 = (NSSonicData *)obj2;
             
             return [sonicData1.date compare:sonicData2.date];
         }];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        
        for (int i = 0; i < count; i++)
        {
            NSSonicData *data = (NSSonicData *)[sonicData objectAtIndex:i];
            
            if ([data.date timeIntervalSinceDate:last] > self.snapInterval)
            {
                currentSection = [[NSMutableArray alloc] init];
                [self.sonicSection addObject:currentSection];
            }
            
            [currentSection addObject:data];
            last = data.date;
        }
    }
    
    [super reloadData];
}

#pragma mark - UITableViewDelegate implementation

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    int result = [self.sonicSection count];
//    if (self.typingBubble != NSBubbleTypingTypeNobody) result++;
    return [self.sonicSection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This is for now typing bubble
    //	if (section >= [self.sonicSection count]) return 1;
    
    return [[self.sonicSection objectAtIndex:section] count] + 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // Now typing
//	if (indexPath.section >= [self.sonicSection count])
//    {
//        return MAX([UIBubbleTypingTableViewCell height], self.showAvatars ? 34 : 0);
//    }
    
    // Header
    if (indexPath.row == 0)
    {
        return [SonicHeaderTableViewCell height];
    }
    
    NSSonicData *data = [[self.sonicSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom + 20, 34 /*For typeImage*/);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // Now typing
//	if (indexPath.section >= [self.sonicSection count])
//    {
//        static NSString *cellId = @"tblBubbleTypingCell";
//        UIBubbleTypingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        
//        if (cell == nil) cell = [[UIBubbleTypingTableViewCell alloc] init];
//        
//        cell.type = self.typingBubble;
//        cell.showAvatar = self.showAvatars;
//        
//        return cell;
//    }
    
    // Header with date and time
    if (indexPath.row == 0)
    {
        static NSString *cellId = @"tblBubbleHeaderCell";
        SonicHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        NSSonicData *data = [[self.sonicSection objectAtIndex:indexPath.section] objectAtIndex:0];
        
        if (cell == nil) cell = [[SonicHeaderTableViewCell alloc] init];
        
        cell.date = data.date;
        
        return cell;
    }
    
    // Standard bubble
    static NSString *cellId = @"tblBubbleCell";
    SonicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSSonicData *data = [[self.sonicSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    
    if (cell == nil) cell = [[SonicTableViewCell alloc] init];
    
    cell.data = data;
    cell.delegate = self;
//    cell.showAvatar = self.showAvatars;
    
    return cell;
}


#pragma * Cell Delegation
- (void)tappedOnPhotoWithImage:(UIImage *)image
{
    [self.sonicDelegate tappedOnPhotoWithImage:image];
}


@end
