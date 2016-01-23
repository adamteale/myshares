//
//  MySharesAppDelegate.m
//  MyShares
//
//  Created by Adam Teale on 12/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MySharesAppDelegate.h"

@implementation MySharesAppDelegate

@synthesize window;

- (void)awakeFromNib{
	//array for content for subit document
	portfolioData = [[NSMutableArray alloc]init ];
	foliofilename = [[NSString alloc]init];
	[self doCurrenciesPopUp];
	
	[currenciesBuy addItemWithTitle:@"USD"];
	[currenciesBuy addItemWithTitle:@"HKD"];

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//	[window setBackgroundColor:[NSColor lightGrayColor]];
	// Insert code here to initialize your application 
	[progress setHidden:TRUE]; //Stop progress animation spinner.

	[self open:nil];
	
}

-(void)doCurrenciesPopUp{

	[currenciesArray removeAllObjects];
	[currenciesArray addObject:exchangerateHKDtoUSD];
	[currenciesArray addObject:exchangerateUSDtoHKD];

	[currencies removeAllItems];// necessary to remove "Item 1", etc
	[currencies addItemWithTitle:@"USD"];
	[currencies addItemWithTitle:@"HKD"];
	
	[currencies selectItemAtIndex:0];
	
}


- (IBAction)save:(id)sender
{

	if (foliofilename != nil) {
		[NSArchiver archiveRootObject:portfolioData toFile:foliofilename];
		
	}
	else{
		NSSavePanel * savePanel = [NSSavePanel savePanel];                  // a
		SEL sel = @selector(savePanelDidEnd:returnCode:contextInfo:);       // b
		[savePanel beginSheetForDirectory:@"~/Documents"                    // c
									 file:@""
						   modalForWindow:[portfolioTableView window]
							modalDelegate:self
						   didEndSelector:sel
							  contextInfo:nil];
	}
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet
			 returnCode:(int)returnCode
			contextInfo:(void *)context
{
	if (returnCode == NSOKButton) {                                   
		foliofilename = [[sheet filename] stringByAppendingString:@".myshares"];
		[NSArchiver archiveRootObject:portfolioData toFile:foliofilename];

	}
}





- (IBAction)open:(id)sender
{
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];                  // e
	SEL sel = @selector(openPanelDidEnd:returnCode:contextInfo:);
	[openPanel beginSheetForDirectory:@"~/Documents"
								 file:nil
								types:[NSArray arrayWithObjects:@"myshares", nil]
					   modalForWindow:[portfolioTableView window]
						modalDelegate:self
					   didEndSelector:sel
						  contextInfo:nil];

	[window makeFirstResponder:nil];

}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet
			 returnCode:(int)returnCode
			contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		NSMutableArray * array;                                         // f
		array = [NSUnarchiver unarchiveObjectWithFile:[sheet filename]]; 
		[array retain];
		[portfolioData release];
		portfolioData = array;
		[portfolioTableView reloadData];
	}

	foliofilename = [sheet filename];
	[foliofilename retain];
}



-(IBAction)getExchangeRates:(id)sender{
	exchangerateHKDtoUSD = @"http://download.finance.yahoo.com/d/quotes.csv?s=HKD=X&f=l1";
	
	NSURL *url = [NSURL URLWithString:exchangerateHKDtoUSD];
	NSError    *error = nil;
	exchangerateHKDtoUSD =	[NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
	NSLog(@"%@",exchangerateHKDtoUSD);
	[exchangerateHKDtoUSD retain];

}



-(IBAction)getPrices:(id)sender{
	
	[progress setHidden:FALSE];


	[progress startAnimation:nil]; //Start progress animation spinner.
	int i;

	for (i = 0; i < [portfolioData count] ; i= i + 1){

		float paidPriceFloat ;
		float lastPriceFloat ;
		float lastPriceFloatOld;
		float performanceFloat ;
		float totalProfitFloat ;
		float change;
		
		lastPriceFloatOld = (float) [[[portfolioData objectAtIndex:i] valueForKey:@"lastprice"] floatValue];
		
		int quantityInt = [[[portfolioData objectAtIndex:i] valueForKey:@"quantity"] intValue];
		NSString *codeTMP = [[portfolioData objectAtIndex:i] valueForKey:@"code"];
		NSString *pricepaidTMP = [[portfolioData objectAtIndex:i] valueForKey:@"pricepaid"];
		
		//First we create the NSURLRequest that we're going to send to the server...
		NSString *urlString = @"http://download.finance.yahoo.com/d/quotes.csv?s=###&f=l1";     //Create an NSString called urlString containing the URL we want to access.

		urlString = [urlString stringByReplacingOccurrencesOfString:@"###" withString:codeTMP ];

		NSURL *url = [NSURL URLWithString:urlString];
		NSError    *error = nil;
		NSString *priceFromYahoo = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
		
		[[portfolioData objectAtIndex:i] setObject:priceFromYahoo forKey:@"lastprice"];
		
		paidPriceFloat = (float) [pricepaidTMP floatValue];
		lastPriceFloat = (float) [priceFromYahoo floatValue];
		performanceFloat = lastPriceFloat - paidPriceFloat ;
		totalProfitFloat = performanceFloat *  quantityInt;
		
		change = lastPriceFloat - lastPriceFloatOld;
 
		NSLog(@"lastPriceFloatOld %f", lastPriceFloatOld);				  

		
		[[portfolioData objectAtIndex:i] setObject:[[NSDate  date]  descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone:nil  locale:nil] forKey:@"lastupdate"];
		[[portfolioData objectAtIndex:i] setObject:[NSString stringWithFormat:@"%f", performanceFloat] forKey:@"performance"];
		[[portfolioData objectAtIndex:i] setObject:[NSString stringWithFormat:@"%f", totalProfitFloat] forKey:@"totalprofit"];
		[[portfolioData objectAtIndex:i] setObject:[NSString stringWithFormat:@"%f", (lastPriceFloat - [[[portfolioData objectAtIndex:i] valueForKey:@"lastprice"] floatValue])] forKey:@"change"];
		[[portfolioData objectAtIndex:i] setObject:[NSString stringWithFormat:@"%f", change] forKey:@"change"];

		
		
		

		//[NSColor colorWithCalibratedRed: 0.9 green: 0.9 blue:1 alpha:1.0]];

	}
	
	


	
	
	[portfolioTableView reloadData];
	[progress stopAnimation:nil]; //Stop progress animation spinner.

}




- (IBAction)doAddCode:(id)sender{
	

	
	//create temp dictionary to store this entry in
	NSMutableDictionary *tmpDataEntry;
	//allocate memory to the dict 
	tmpDataEntry = [[NSMutableDictionary alloc] init];

	[tmpDataEntry setObject:[companyCode stringValue] forKey:@"code"];
	[tmpDataEntry setObject:[pricePaid stringValue] forKey:@"pricepaid"];
	[tmpDataEntry setObject:[quantity stringValue] forKey:@"quantity"];
	[tmpDataEntry setObject:[currenciesBuy titleOfSelectedItem] forKey:@"currency"];
	
	//add tmpDataEntry to mData NSMutableArray
	[portfolioData addObject:tmpDataEntry]; 

	NSSortDescriptor *tcinSorter = [[NSSortDescriptor alloc] initWithKey:@"CODE" ascending:YES];
	[portfolioData sortUsingDescriptors: [ NSArray arrayWithObject: tcinSorter ] ];

	[portfolioTableView reloadData];
}



- (void)tableView:(NSTableView *)inTableView
  willDisplayCell:(id)inCell
   forTableColumn:(NSTableColumn *)inTableColumn
			  row:(int)inRow
{
	NSDictionary *dict = [portfolioData objectAtIndex:inRow];

	if ([[inTableColumn identifier] isEqualToString:@"change"])
	{
		if ([[dict objectForKey:@"change"] floatValue] > 0 )
		{
			// Make the price text bold if it's free
			[inCell setBackgroundColor:[NSColor greenColor]];
		}
		else if ([[dict objectForKey:@"change"] floatValue] < 0 )
		{
			// Make the price text bold if it's free
			[inCell setBackgroundColor:[NSColor redColor]];
		}
		else
		{
			// Otherwise, just use regular system font
			[inCell setBackgroundColor:[NSColor blueColor]];}
	}

	if ([[inTableColumn identifier] isEqualToString:@"totalprofit"])
	{
		if ([[dict objectForKey:@"totalprofit"] floatValue] > 0 )
		{
			// Make the price text bold if it's free
			[inCell setBackgroundColor:[NSColor greenColor]];
		}
		else if ([[dict objectForKey:@"totalprofit"] floatValue] < 0 )
		{
			// Make the price text bold if it's free
			[inCell setBackgroundColor:[NSColor redColor]];
		}
		else
		{
			// Otherwise, just use regular system font
			[inCell setBackgroundColor:[NSColor blueColor]];
			

			
		}
	}
}


- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [portfolioData count];
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    //column identifiers should be the same as the dicionary keys you wish to display
    //you can also store metadata in here as well (file paths, alias data, attributed vs. non-attributed representations...)
	
    return [[portfolioData objectAtIndex:row] objectForKey:[tableColumn identifier]]; 
}


//Editor Controls
- (IBAction)removeSelectedRowFromTable:(id)sender{
	[portfolioData removeObjectAtIndex:[portfolioTableView selectedRow]];
	[portfolioTableView reloadData];
	
}

- (void)tableView:(NSTableView *)tableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
    id theRecord;
    
    NSParameterAssert(rowIndex >= 0 && rowIndex < [portfolioData count]);
    theRecord = [portfolioData objectAtIndex:rowIndex];
    [theRecord setObject:anObject forKey:[aTableColumn identifier]];
	

	
    return;
}



@end
