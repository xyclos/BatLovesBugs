//
//  DataHelper.h
//  BatLovesBugs
//
//  Created by Jake Johnson on 11/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHelper : NSObject

+ (DataHelper *)sharedInstance;

@property (assign) int score;
@property (assign) int highScore;

-(void) saveData;
-(void) loadData;

@end
