//
//  GameScene.m
//  KoalaHatesRain
//
//  Created by Jake Johnson on 10/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameScene.h"
#import "Bat.h"
#import "Bug.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation GameScene
{
    CCPhysicsNode *_physicsNode;
    CCNode *_contentNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCSprite *_bat;
    float timeSinceBug;
    int score;
    CCLabelTTF *_scoreLabel;
}

-(void)didLoadFromCCB
{
    //_physicsNode.debugDraw = YES;
    _physicsNode.collisionDelegate = self;
    self.userInteractionEnabled = YES;
}

-(void)update:(CCTime)delta
{
    timeSinceBug += delta;
    
    if (timeSinceBug > 1.0f) {
        [self spawnBug];
        timeSinceBug = 0.0f;
    }
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    CGPoint moveLocation = ccp(touchLocation.x, _bat.position.y);
    
    CCActionMoveTo *moveBat = [CCActionMoveTo actionWithDuration:0.15 position:moveLocation];
    [_bat runAction:moveBat];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bug:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        [self bugRemoved:nodeA];
        [self incrementScore];
    } key:nodeA];
    
}

-(void)spawnBug
{
    CGPoint randomPoint = [self getRandomPoint];
    Bug *bug = (Bug *)[CCBReader load:@"Bug"];
    CGPoint screenPosition = [self convertToWorldSpace:randomPoint];
    CGPoint worldPosition = [_physicsNode convertToNodeSpace:screenPosition];
    bug.position = worldPosition;
    [_physicsNode addChild:bug];
}

-(CGPoint)getRandomPoint
{
    CGRect r = [self boundingBox];
    CGPoint p = r.origin;
    p.x += arc4random() % (int)r.size.width;
    p.y += 600;
    return p;
}

-(void)bugRemoved:(CCNode *)bug
{
    CCParticleSystem *eaten = (CCParticleSystem *)[CCBReader load:@"BugEaten"];
    eaten.autoRemoveOnFinish = YES;
    eaten.position = bug.position;
    [bug.parent addChild:eaten];
    [bug removeFromParent];
}

-(void)incrementScore
{
    score += 1;
    [_scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}



@end
