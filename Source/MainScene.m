//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "DataHelper.h"

@implementation MainScene {
    BOOL isAudioMute;
    CCButton *_musicButton;
}

-(void)didLoadFromCCB
{
    [[DataHelper sharedInstance] loadData];
    isAudioMute = [DataHelper sharedInstance].isAudioMute;
}

-(void)start
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GameScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

-(void)toggleMusic
{
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    if (!isAudioMute) {
        [audio stopEverything];
        isAudioMute = YES;
        [DataHelper sharedInstance].isAudioMute = isAudioMute;
        [[DataHelper sharedInstance] saveData];
    } else {
        [audio playBg:@"theme.mp3" loop:YES];
        isAudioMute = NO;
        [DataHelper sharedInstance].isAudioMute = isAudioMute;
        [[DataHelper sharedInstance] saveData];
    }
}

@end
