//
//  ViewController.m
//  AudioTouchConflict
//
//  Created by david oneill on 2/16/15.
//  Copyright (c) 2015 david oneill. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MYGLKView.h"








#define USEPLAYER  1
#define PREROLL    0
#define PRINTSTUFF 0






@interface ViewController (){
    CADisplayLink *displayLink;
    UIPanGestureRecognizer *panRec;
    UILabel *playerLabel;
    MusicPlayer player;
    MusicSequence sequence;
    MYGLKView *myglkView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    myglkView = [[MYGLKView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    myglkView.enableSetNeedsDisplay = 0;
    [self.view addSubview:myglkView];

    panRec = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecCallback:)];
    [myglkView addGestureRecognizer:panRec];
    
    
    [self addUI];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(display)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setPreferredIOBufferDuration:256.0 / 44100.0 error:NULL];
    [audioSession setActive:1 error:NULL];
    
    
    if (!USEPLAYER) {
        return;
    }
    
    NewMusicSequence(&sequence);
    NewMusicPlayer(&player);
    MusicPlayerSetSequence(player, sequence);
    
    MusicTrack track;
    MusicSequenceNewTrack(sequence, &track);
   
    MIDINoteMessage note = {0};
    note.duration = 0.125;
    note.velocity = 30;
    for (int i = 0; i < 1024; i ++){
        if (i % 4) {
            note.note = 69;
        }
        else {
            note.note = 81;
        }
        MusicTrackNewMIDINoteEvent(track, i, &note);
    }
    if (PREROLL) {
        MusicPlayerPreroll(player);
    }
}

-(void)panRecCallback:(UIPanGestureRecognizer *)rec{
    myglkView.rectOrigin = CGPointAdd(myglkView.rectOrigin, [rec translationInView:rec.view]);
    [rec setTranslation:CGPointZero inView:rec.view];
    
    if (PRINTSTUFF){
        CGPoint loc = [panRec locationInView:self.view];
        printf("    rec loc %3.3f %3.3f\n",loc.x,loc.y);
    }
}
-(void)display{
    [myglkView display];
    
    if (PRINTSTUFF && panRec.state != UIGestureRecognizerStatePossible) {
        CGPoint loc = [panRec locationInView:self.view];
        printf("display loc %3.3f %3.3f\n",loc.x,loc.y);
    }
    
    if (USEPLAYER) {
        MusicTimeStamp playerTime;
        MusicPlayerGetTime(player, &playerTime);
        playerLabel.text = [NSString stringWithFormat:@"%2.2f",playerTime];
    }
    
}

-(void)stopPlay:(UIButton *)button{
    
    Boolean playerPlaying;
    MusicPlayerIsPlaying(player, &playerPlaying);
    
    if (playerPlaying) {
        MusicPlayerStop(player);
    }
    else{
        MusicPlayerStart(player);
    }
    
}
CGPoint CGPointAdd(CGPoint a,CGPoint b){
    return CGPointMake(a.x + b.x, a.y + b.y);
}
-(void)addUI{
    playerLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 40, 100, 40)];
    playerLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:playerLabel];
    
    UIButton *stopPlayButt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopPlayButt.frame = CGRectMake(120, 40, 100, 100);
    [stopPlayButt setTitle:@"stop/play" forState:UIControlStateNormal];
    [stopPlayButt addTarget:self action:@selector(stopPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopPlayButt];
    
    UIButton *killButt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    killButt.frame = CGRectMake(120, self.view.frame.size.height - 80, 100, 40);
    [killButt setTitle:@"KILL" forState:UIControlStateNormal];
    [killButt addTarget:self action:@selector(kill) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:killButt];
}
-(void)kill{
    exit(0);
}
@end













