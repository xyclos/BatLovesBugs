//
//  Bug.m
//  BatLovesBugs
//
//  Created by Jake Johnson on 10/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bug.h"

@implementation Bug

-(void)didLoadFromCCB
{
    self.physicsBody.collisionType = @"bug";
    self.physicsBody.collisionGroup = @"bug";
}

@end
