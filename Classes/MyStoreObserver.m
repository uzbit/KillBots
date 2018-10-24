//
//  MyStoreObserver.m
//  AiWars
//
//  Created by Jeremiah Gage on 11/9/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "MyStoreObserver.h"


@implementation MyStoreObserver

@synthesize mainMenuViewController;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	// Your application should implement these two methods.
//    [self recordTransaction: transaction];
//    [self provideContent: transaction.payment.productIdentifier];

	NSLog(@"Purchased!");
	NSLog(transaction.payment.productIdentifier);

	[mainMenuViewController doneWithPurchase];

	// Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"liteVersion"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[mainMenuViewController unlockApp];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	[mainMenuViewController doneWithPurchase];
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction Failed!");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unlock failed! Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];		
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
