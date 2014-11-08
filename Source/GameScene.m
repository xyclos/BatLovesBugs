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
#import "DataHelper.h"
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
    OALSimpleAudio *_audio;
    CCNode *_hudNode;
    BOOL isAudioMute;
}

-(void)didLoadFromCCB
{
    //_physicsNode.debugDraw = YES;
    _physicsNode.collisionDelegate = self;
    self.userInteractionEnabled = YES;
    life = 2.f;
    _bugs = [NSMutableArray array];
    _hearts = [NSMutableArray arrayWithObjects:_heart1, _heart2, _heart3, nil];
    _gameOver = NO;
    _audio = [OALSimpleAudio sharedInstance];
    [_audio preloadEffect:@"bite-small3.wav"];
    [[DataHelper sharedInstance] loadData];
    isAudioMute = [DataHelper sharedInstance].isAudioMute;
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
        } else if (score > 30.f) {
            spawnBugInterval = 0.7f;
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
    if (!isAudioMute) {
        [_audio playEffect:@"bite-small3.wav"];    
    }
}

-(void)incrementScore
{
    score += 1;
    [_scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

-(void)decrementLife
{
    if (!_gameOver) {
        if (life == -1) {
            [self gameOver];
            return;
        }
        CCNode *currentHeart = [_hearts objectAtIndex:life];
        CCParticleSystem *heartGone = (CCParticleSystem *)[CCBReader load:@"HeartGone"];
        heartGone.positionType = currentHeart.positionType;
        heartGone.position = currentHeart.position;
        heartGone.autoRemoveOnFinish = YES;
        [currentHeart.parent addChild:heartGone];
        [currentHeart removeFromParent];
        life -= 1;
    }
}

-(void)gameOver
{
    if (!_gameOver) {
        _gameOver = YES;
        
        [_bat stopAllActions];
        
        for (CCNode *bug in _bugs) {
            [bug removeFromParent];
        }
        [self updateScore];
        
        CCScene *scene = [CCBReader loadAsScene:@"GameOverScene"];
        [[CCDirector sharedDirector] replaceScene:scene];
    }
}

- (void)updateScore {
    [[DataHelper sharedInstance] loadData];
    [DataHelper sharedInstance].score = score;
    int currentHigh = [DataHelper sharedInstance].highScore;
    if (currentHigh < score) {
        [DataHelper sharedInstance].highScore = score;
    }
    [[DataHelper sharedInstance] saveData];
}

@end
