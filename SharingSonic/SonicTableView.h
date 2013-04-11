//
//  SonicTableView.h
//  MultimediaProject
//
//  Created by PowerQian on 12/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSSonicData.h"

@class SonicTableView;

@protocol SonicTableViewDataSource <NSObject>

@optional

@required

- (NSInteger)rowsForSonicTable:(SonicTableView *)tableView;
- (NSSonicData *)sonicTableView:(SonicTableView *)tableView dataForRow:(NSInteger)row;

@end

@protocol SonicTableViewDelegate <NSObject>

- (void)tappedOnPhotoWithImage:(UIImage *)image;

@end

@interface SonicTableView : UITableView <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet id <SonicTableViewDataSource> sonicDataSource;
@property (nonatomic, weak) id <SonicTableViewDelegate> sonicDelegate;
@property (nonatomic) NSTimeInterval snapInterval;

@end
