//
//  GameOverScene.m
//  BatLovesBugs
//
//  Created by Jake Johnson on 11/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameOverScene.h"
#import "DataHelper.h"

@implementation GameOverScene {
    CCNode *_restartButton;
    CCLabelTTF *_pointsLabel;
    CCLabelTTF *_highScoreLabel;
    int highScore;
    int score;
}

- (void)didLoadFromCCB {
    [[DataHelper sharedInstance] loadData];
    highScore = [DataHelper sharedInstance].highScore;
    score = [DataHelper sharedInstance].score;
    [self updateUI];
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"GameScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)updateUI {
    NSString *highScoreString = [NSString stringWithFormat:@"Your highest score was %d", highScore];
    NSString *scoreString = [NSString stringWithFormat:@"You got %d point(s) this time!", score];
    
    [_pointsLabel setString:scoreString];
    [_highScoreLabel setString:highScoreString];
}


@end
