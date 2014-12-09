//
//  RecipeCollectionViewController.m
//  RecipeFinder
//
//  Created by Thilagawathy Duraisamy on 8/12/2014.
//  Copyright (c) 2014 Thilagawathy Duraisamy. All rights reserved.
//

#import "RecipeCollectionViewController.h"
#import "RecipeCollectionViewCell.h"

// Unit of measurement
typedef enum unitType {of=1 , grams , milliliters , slices } measuresOfUnit;

@interface RecipeCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *ingredient;
@property (strong, nonatomic) NSMutableDictionary *recipe;

@property (nonatomic , strong) UILabel *label;
@property (nonatomic, strong) NSString *errorLog;

@end


@implementation RecipeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    // [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"RecipeCell"];//]  @"RecipeCell"];
    
    
    //initalization
     self.ingredient = [[NSMutableArray alloc] init];
    self.recipe = [[NSMutableDictionary alloc] init];
    
    
    // Do any additional setup after loading the view.
    // Reading fridge items from the file
    NSString *fridgeFilePath = [[NSBundle mainBundle] pathForResource:@"Fridge" ofType:@"csv"];
    NSError *fileError;
    NSArray *contentOfFridgeFile = [[NSString stringWithContentsOfFile:fridgeFilePath encoding:NSUTF8StringEncoding error:&fileError] componentsSeparatedByString:@"\n"];
    
    if (!fileError) {
    
        [self readingFromFridgeItemFile:contentOfFridgeFile];
    }
    else
    {
        NSLog(@"Fridge.csv file not found");
        self.errorLog = @"Fridge.csv file not found";
    }
    
    [self readingFromRecipeFile];
    
    [self.collectionView reloadData];
        
    
}


// Reading fridge items from JSON file format

-(void) readingFromFridgeItemFile:(NSArray *)contentOfFile
{
  
    for (NSString *line in contentOfFile)
    {
        NSMutableDictionary *items = [[NSMutableDictionary alloc]init];
                                      
        NSArray *content = [line componentsSeparatedByString:@","];
        NSString *temp = content[1];
        int s = [ temp intValue];
        int m = 0;
        temp = content[2];
        if ( [temp isEqualToString:@"slices" ] )
            m = slices;
        else if ([temp isEqualToString:@"grams" ])
            m= grams;
        else if ([temp isEqualToString:@"ml" ])
            m= milliliters;
        else if ([temp isEqualToString:@"of" ] )
            m = of; // for individual items
        
        items = [NSMutableDictionary dictionaryWithObjectsAndKeys:content[0],@"Items",
                 [NSNumber numberWithInt:s],@"Quantity",
                 [NSNumber numberWithInt:m],@"Unit",
                 content[3], @"Date", nil];
        
        
        [self.ingredient addObject:items];
    }
}


// Reading recipes from Fridge.csv file

-(void) readingFromRecipeFile
{
    NSError *fileError;

    // Reading all the recipes from the file
    NSString *recipeFilePath = [[NSBundle mainBundle] pathForResource:@"Recipes" ofType:@"json"];
    NSData *contentOfRecipeFile = [[NSData alloc] initWithContentsOfFile:recipeFilePath];
    self.recipe = [NSJSONSerialization JSONObjectWithData:contentOfRecipeFile options:kNilOptions error:&fileError];
    
    if (!fileError) {
        
         // Check for expiry date and remove it from the fridge
        [self checkExpiryDate];
    }
    else
    {
        NSLog(@"Recipes.json file not found");
        self.errorLog = @"Fridge.csv file not found";
    }

}

- (void) checkExpiryDate
{
    
    NSDate *todayDate = [NSDate date];
    NSComparisonResult compDateResult;
    
    // Pickup expiry date from fridge item
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    for (NSDictionary *fridgeItems in self.ingredient) {
        
        NSString *exDate = [fridgeItems objectForKey:@"Date"];
        
        NSDate *expiryDate = [dateFormatter dateFromString:exDate];

        compDateResult = [todayDate compare:expiryDate];
    
        if  (compDateResult == NSOrderedDescending){
              [self.ingredient removeObject:fridgeItems];
        }
    }
}

- (NSString *) checkRecentExpiryDate
{
    
    NSDate *todayDate = [NSDate date];
    
    // Pickup expiry date from fridge item
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *latestDate;
    NSTimeInterval noOfDays =100; // just a bench mark
    NSString *item;
    
    for (NSDictionary *fridgeItems in self.ingredient) {
        
        NSString *exDate = [fridgeItems objectForKey:@"Date"];
        NSDate *expiryDate = [dateFormatter dateFromString:exDate];

        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *diff = [cal components:NSCalendarUnitDay fromDate:todayDate toDate:expiryDate options:0];
        
        NSInteger Days = diff.day;
        
        if (Days < noOfDays ) {
            latestDate = expiryDate;
            noOfDays = Days;
            item =  [fridgeItems objectForKey:@"Items"];
           
        }

    }
    return item;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.recipe count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    RecipeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecipeCell" forIndexPath:indexPath];
    
    // Configure the cell
    cell.label.text = NULL;
    if (!self.errorLog) {
        if ([self.recipe count] == 0 )
            cell.label.text = @"Order Takeout";
        else{
            for (NSDictionary *recipeCollection in self.recipe) {
                
                NSString *item = [self checkRecentExpiryDate];
                NSArray *findItem = [recipeCollection valueForKey:@"ingredients"];
                NSArray *keyIngr = [findItem valueForKey:@"item"];
            
                for (NSString *check in keyIngr) {
                    if ([check  isEqualToString:item]) {
                        item = [recipeCollection valueForKey:@"name"];
                        cell.label.text = item;
                    }
                }
            }
        }
    }
    else
        cell.label.text = self.errorLog;
    
    return cell;
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
