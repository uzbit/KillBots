//
//  Sounds.m
//  AiWars
//
//  Created by Jeremiah Gage on 6/30/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Sounds.h"

void loadSounds()
{
	sounds = [[NSMutableArray alloc] initWithCapacity:20];
	soundIsOn = true;
	
	/*
	AudioSessionSetActive (true);
*/
	//The following checks to see if the user has music playing and disables game audio if so
	UInt32 propertySize, isPlaying = 0;
	propertySize = sizeof(isPlaying);
	AudioSessionInitialize(NULL, NULL, NULL, NULL);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &isPlaying);
	if (isPlaying)
	{
		soundIsOn = false;
		[[NSUserDefaults standardUserDefaults] setBool:soundIsOn forKey:@"soundIsOn"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
//	soundEngine = [[Finch alloc] init];

	normalWeaponSound = loadSound(@"default_weapon_sound");
	shottieWeaponSound = loadSound(@"shottie3");
	missileWeaponSound = loadSound(@"missile1");
	laserWeaponSound = loadSound(@"laser5");
	massDriverWeaponSound = loadSound(@"mass_driver1");
	flamethrowerWeaponSound = loadSound(@"flamethrower2");
	icyWeaponSound = loadSound(@"flamethrower1");
	lightningWeaponSound = loadSound(@"tesla1");
	plasmaWeaponSound = loadSound(@"bfg2");
	deathRayWeaponSound = loadSound(@"death_ray1");
	fatManWeaponSound = loadSound(@"fatman_explosion");

	botExplosionSound = loadSound(@"explosion5");
	suicideExplosionSound = loadSound(@"explosion3");
	plasmaExplosionSound = loadSound(@"explosion2");
	fatManExplosionSound = loadSound(@"fatman_explosion2");
	
	jammerSound = loadSound(@"jammer1");
	
	missileExplodeSound = loadSound(@"explosion6");
	mineExplodeSound = loadSound(@"explosion7");
	massDriverHitSound = loadSound(@"hit1");

	clickSound = loadSound(@"click2");
	shortClickSound = loadSound(@"click3");

	jumpDecreaseSound = loadSound(@"jump1");
	jumpIncreaseSound = loadSound(@"jump2");

	switchBotSound = loadSound(@"switch_bot1");
	spawnBotSound = loadSound(@"spawn1");

	countdownSound = loadSound(@"countdown");
	roundStartSound = loadSound(@"boxing_bell");
	playerWonSound = loadSound(@"cheer1");
	lostRoundSound = loadSound(@"crowdohh");
	selectBotSound = loadSound(@"bot_selector1");

	botSelectorSound = loadAVAudioPlayer(@"thinkin");
	mainMenuSound = loadAVAudioPlayer(@"main_menu1");
	preBattleSound = loadAVAudioPlayer(@"dramatic_orchestra_02_until_they_came_L2");
}

void unloadSounds()
{
//	[soundEngine release];
	[sounds release];
}

SoundEffect *loadSound(NSString *file)
{
	SoundEffect *audioPlayer = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource: file ofType: @"wav"]];

//	[sounds addObject:audioPlayer];
	
	return audioPlayer;
}

AVAudioPlayer *loadAVAudioPlayer(NSString *file)
{
	NSString *soundFilePath;
	soundFilePath = [[NSBundle mainBundle] pathForResource: file ofType: @"mp3"];
	NSURL *fileURL = [NSURL fileURLWithPath: soundFilePath];
	AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
	[fileURL release];
	
	[sounds addObject:audioPlayer];
	
	return audioPlayer;
}

void playSound(SoundEffect *audioPlayer)
{
	if (soundIsOn)
	{
		[audioPlayer play];
/*
		if ([audioPlayer isPlaying])
			audioPlayer.currentTime = 0; // start at beginning
		else
			[audioPlayer play];
*/
	}
}

void playSoundLoop(AVAudioPlayer *audioPlayer)
{
	if (soundIsOn && ![audioPlayer isPlaying])
	{
		audioPlayer.numberOfLoops = -1; // Loop indefinately
		audioPlayer.currentTime = 0; // start at beginning
		[audioPlayer play];
	}
}

void stopSoundLoop(AVAudioPlayer *audioPlayer)
{
	[audioPlayer stop];
}

void stopAllSounds()
{
	for (int i = 0; i < [sounds count]; i++)
	{
		AVAudioPlayer *audioPlayer = [sounds objectAtIndex:i];
		[audioPlayer stop];
	}
}

void vibrate()
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
