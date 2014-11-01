//
//  GameScene.m
//  KoalaHatesRain
//
//  Created by Jake Johnson on 10/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameScene.h"
#import "Bug.h"
#import "Bat.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation GameScene
{
    CCPhysicsNode *_physicsNode;
    CCNode *_contentNode;
    Bat *_bat;
    float timeSinceBug;
    float spawnBugInterval;
    int score;
    int life;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_lifeLabel;
    NSMutableArray *_bugs;
    NSMutableArray *offScreenBugs;
    CCNode *_heart1;
    CCNode *_heart2;
    CCNode *_heart3;
    NSMutableArray *_hearts;
    BOOL _gameOver;
    CCNode *_restartButton;
}

-(void)didLoadFromCCB
{
    //_physicsNode.debugDraw = YES;
    _physicsNode.collisionDelegate = self;
    self.userInteractionEnabled = YES;
    life = 4.f;
    _bugs = [NSMutableArray array];
    _hearts = [NSMutableArray arrayWithObjects:_heart1, _heart2, _heart3, nil];
    _gameOver = NO;
}

-(void)update:(CCTime)delta
{
    if (!_gameOver) {
        timeSinceBug += delta;
        
        if (timeSinceBug > spawnBugInterval) {
            [self spawnBug];
            timeSinceBug = 0.0f;
        }
        
        if (score < 10.f) {
            spawnBugInterval = 4.0f;
        } else if (score > 10.f && score < 20.f) {
            spawnBugInterval = 2.0f;
        } else if (score > 20.f && score < 30.f) {
            spawnBugInterval = 1.0f;
        } else if (score > 30.f && score < 40.f) {
            spawnBugInterval = 0.5f;
        } else if (score > 40.f) {
            spawnBugInterval = 0.2f;
        }
    }
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!_gameOver) {
        CGPoint touchLocation = [touch locationInNode:_contentNode];
        CGPoint moveLocation = ccp(touchLocation.x, _bat.position.y);
        
        CCActionMoveTo *moveBat = [CCActionMoveTo actionWithDuration:0.15 position:moveLocation];
        [_bat runAction:moveBat];
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bug:(CCNode *)nodeA bat:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        [self bugEaten:nodeA];
        [self incrementScore];
    } key:nodeA];
    
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair detector:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    [self decrementLife];
    return YES;
}

-(void)spawnBug
{
    CGPoint randomPoint = [self getRandomPoint];
    Bug *bug = (Bug *)[CCBReader load:@"Bug"];
    CGPoint screenPosition = [self convertToWorldSpace:randomPoint];
    CGPoint worldPosition = [_physicsNode convertToNodeSpace:screenPosition];
    bug.position = worldPosition;
    [_physicsNode addChild:bug];
    [_bugs addObject:bug];
}

-(CGPoint)getRandomPoint
{
    CGRect r = [self boundingBox];
    CGPoint p = r.origin;
    p.x += arc4random() % (int)r.size.width;
    p.y += 600;
    return p;
}

-(void)bugEaten:(CCNode *)bug
{
    CCParticleSystem *eaten = (CCParticleSystem *)[CCBReader load:@"BugEaten"];
    eaten.autoRemoveOnFinish = YES;
    eaten.position = bug.position;
    [bug.parent addChild:eaten];
    [bug removeFromParent];
    [_bugs removeObject:bug];
}

-(void)incrementScore
{
    score += 1;
    [_scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

-(void)decrementLife
{
    if (!_gameOver) {
        life -= 1;
        CCNode *currentHeart = [_hearts objectAtIndex:life-1];
        currentHeart.visible = NO;
        if (life == 1) {
            [self gameOver];
        }
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"GameScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)gameOver
{
    if (!_gameOver) {
        _gameOver = YES;
        _restartButton.visible = YES;
        
        [_bat stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        
        [self runAction:bounce];
    }
}

@end
