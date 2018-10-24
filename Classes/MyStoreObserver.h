//
//  MyStoreObserver.h
//  AiWars
//
//  Created by Jeremiah Gage on 11/9/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MainMenuViewController.h"

@interface MyStoreObserver : NSObject <SKPaymentTransactionObserver>
{
	MainMenuViewController *mainMenuViewController;
}

@property ATOMICITY_ASSIGN MainMenuViewController *mainMenuViewController;

- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

@end
