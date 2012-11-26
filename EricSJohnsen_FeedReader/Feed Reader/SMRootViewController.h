//
//  SMRootViewController.h
//  Feed Reader
//
//  Created by Eric Johnsen on 11/24/12.
//  Copyright (c) 2012 Eric S. Johnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMRootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    NSDate *twoYearsAgo;
}

@property (strong, nonatomic, readonly) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSDate *twoYearsAgo;

@end
