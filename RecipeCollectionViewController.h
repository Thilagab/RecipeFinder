//
//  RecipeCollectionViewController.h
//  RecipeFinder
//
//  Created by Thilagawathy Duraisamy on 8/12/2014.
//  Copyright (c) 2014 Thilagawathy Duraisamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeCollectionViewController : UICollectionViewController<UICollectionViewDataSource , UICollectionViewDelegateFlowLayout>

-(void) readingFromFridgeItemFile: (NSArray *) contentOfFile;
-(void) readingFromRecipeFile;
-(void) checkExpiryDate;
- (NSString *) checkRecentExpiryDate;

@end
