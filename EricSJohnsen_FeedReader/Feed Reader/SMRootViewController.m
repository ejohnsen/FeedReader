//
//  SMRootViewController.m
//  Feed Reader
//
//  Created by Eric Johnsen on 11/24/12.
//  Copyright (c) 2012 Eric S. Johnsen. All rights reserved.
//

#import "SMRootViewController.h"
#import "SMDetailViewController.h"
#import "SMFeedItem.h"

@implementation SMRootViewController

@synthesize dateFormatter;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize twoYearsAgo;

// On-demand initializer for read-only property.
- (NSDateFormatter *)dateFormatter {
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return dateFormatter;
}

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {

    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Attempt to load this application's persistently stored data.
    // See fetchedResultsController (line 92)
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    // We're only storing and displaying stories from the past two years.
    // Calculate two years ago from today's date.
    NSDate *today = [NSDate date];
    NSCalendar *greg = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:-2];
    self.twoYearsAgo = [greg dateByAddingComponents:offsetComponents toDate:today options:0];
    
    // Set our navigation bar's title and give it a little style.
    self.title = @"The Technology Edge";
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    // Define the back button leading BACK TO THIS controller.
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backBarButtonItem];
}

- (void)viewDidUnload {

    [super viewDidUnload];

    self.navigationItem.backBarButtonItem = nil;
    self.twoYearsAgo = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // The style delivered to us in the feed's content sets the width of the content to 
    // the width of an iPhone screen in portrait orientation. Therefore, we only support 
    // portrait orientation.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Core Data support

- (NSFetchedResultsController *)fetchedResultsController {
    
    // If we don't already have an initialized fetched results controller, create it.
    if (fetchedResultsController == nil) {
        // Set our search parameters.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SMFeedItem" 
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        // Organize the results with the most recent articles at the top of the list.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        fetchRequest.sortDescriptors = sortDescriptors;
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                            managedObjectContext:managedObjectContext 
                                              sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController = aFetchedResultsController;
    }
    return fetchedResultsController;
}

// This is where we trim out feed items that are have publish dates greater than
// two years form today's date.
- (void)updateContext:(NSNotification *)note {
    
    NSManagedObjectContext *mainContext = self.managedObjectContext;
    [mainContext mergeChangesFromContextDidSaveNotification:note];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SMFeedItem" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pubDate < %@", self.twoYearsAgo];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *oldFeedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    SMFeedItem *feedItem;
    for (feedItem in oldFeedItems) {
        [self.managedObjectContext deleteObject:feedItem];
    }
    
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    // We've now updated our data store, reload our table data to reflect any changes.
    [self.tableView reloadData];
}

// This notification is posted by our custom operation.
- (void)mergeChanges:(NSNotification *)note {
    
    NSManagedObjectContext *mainContext = self.managedObjectContext;
    if (note.object == mainContext) {
        // We don't need to merge changes saved in the main context.
        return;
    }
    
    [self performSelectorOnMainThread:@selector(updateContext:) 
                           withObject:note 
                        waitUntilDone:YES];
}

#pragma mark - 
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // The number of rows is equal to the number of feed items we have in our persistent store.
    NSInteger numRows = 0;
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numRows = [sectionInfo numberOfObjects];
    }
    return numRows;
}

// Since we only want to display a feed item's title and publish date, we are using
// a basic UITableViewCellStyle provided by Apple.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Reuse cells if possible. This is important as we're pulling up to 50 items from the feed.
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) { /* If we weren't about to dequeue a cell.. */
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Give the cell a little bit of style.
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0];
    }

    SMFeedItem *feedItem = (SMFeedItem *)[fetchedResultsController objectAtIndexPath:indexPath];
    
    // Use the properties of this feed item to set the appropriate title and publish date.
    cell.textLabel.text = feedItem.itemTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:feedItem.pubDate]];
    
    return cell;
}

#pragma mark - 
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Create a new detail view controller and assign it the appropriate feed item so it
    // can display the item's content.
    SMDetailViewController *detailViewController = [[SMDetailViewController alloc] init];
    detailViewController.feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Push this detail VC onto our navigation stack. We defined the back button in our viewDidLoad: method.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
