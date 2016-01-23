//
//  MySharesAppDelegate.h
//  MyShares
//
//  Created by Adam Teale on 12/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MySharesAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSMutableArray *portfolioData;
	
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *companyCode;
	IBOutlet NSTextField *pricePaid;
	IBOutlet NSTextField *quantity;
	IBOutlet NSTableView *portfolioTableView;

	IBOutlet NSPopUpButton *currencies;
	IBOutlet NSPopUpButton *currenciesBuy;

	NSString *foliofilename;
	NSString *exchangerateHKDtoUSD;
	NSString *exchangerateUSDtoHKD;
	NSMutableArray *currenciesArray;

}


-(IBAction)removeSelectedRowFromTable:(id)sender;

-(IBAction)doAddCode:(id)sender;
-(IBAction)getPrices:(id)sender;
-(IBAction)getExchangeRates:(id)sender;
-(IBAction)save:(id)sender;
-(IBAction)open:(id)sender;

-(void)doCurrenciesPopUp;

@property (assign) IBOutlet NSWindow *window;

@end
