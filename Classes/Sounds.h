//
//  Sounds.h
//  AiWars
//
//  Created by Jeremiah Gage on 6/30/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

/*
#import "Finch.h"
#import "Sound+IO.h"
#import "RevolverSound.h"
*/
#import "SoundEffect.h"

NSMutableArray *sounds;
bool soundIsOn;

//Finch *soundEngine;

SoundEffect *normalWeaponSound, *shottieWeaponSound, *missileWeaponSound, *laserWeaponSound, *massDriverWeaponSound, *mineLayerWeaponSound, *plasmaWeaponSound;
SoundEffect *flamethrowerWeaponSound, *icyWeaponSound, *lightningWeaponSound, *deathRayWeaponSound, *fatManWeaponSound;
SoundEffect *jammerSound;
SoundEffect *missileExplodeSound, *mineExplodeSound, *massDriverHitSound;
SoundEffect *botExplosionSound, *suicideExplosionSound, *plasmaExplosionSound, *fatManExplosionSound;
SoundEffect *jumpDecreaseSound, *jumpIncreaseSound, *switchBotSound;
SoundEffect *clickSound, *shortClickSound;
SoundEffect *selectBotSound, *spawnBotSound;
SoundEffect *countdownSound, *roundStartSound, *playerWonSound, *lostRoundSound;

//loops
AVAudioPlayer *botSelectorSound, *mainMenuSound, *preBattleSound;

SoundEffect *loadSound(NSString *file);
void playSound(SoundEffect *audioPlayer);

AVAudioPlayer *loadAVAudioPlayer(NSString *file);
void playSoundLoop(AVAudioPlayer *audioPlayer);
void stopSoundLoop(AVAudioPlayer *audioPlayer);
void loadSounds();
void unloadSounds();
void stopAllSounds();
void vibrate();