//
//  WaveView.h
//  MultimediaProject
//
//  Created by PowerQian on 11/22/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicParameters.h"

@class WaveView;

@protocol WaveViewDataSource <NSObject>

- (Float32)yValueForX:(Float32)xValue inPixelValue:(CGFloat)pixel forSender:(WaveView *)sender;

@end

@interface WaveView : UIView

@property (nonatomic,weak) IBOutlet id <WaveViewDataSource> dataSource;
@property (nonatomic) BOOL isUpdatingUI;

@end
