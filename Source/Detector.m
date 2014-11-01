//
//  Detector.m
//  BatLovesBugs
//
//  Created by Jake Johnson on 10/31/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Detector.h"

@implementation Detector

-(void)didLoadFromCCB {
    self.physicsBody.collisionType = @"detector";
    self.physicsBody.sensor = TRUE;
}

@end
