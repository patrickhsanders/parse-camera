//
//  Image.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"

@interface Image : NSObject

@property (nonatomic, strong) NSString *imageId; 
@property (nonatomic, strong) UIImage *imageOriginal;
@property (nonatomic, strong) NSString *imageOwner;
@property (nonatomic, strong) User *user; 
@property (nonatomic, strong) NSDate *createdDate;

@property (nonatomic, strong) NSMutableArray *likes;
@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic) NSUInteger numberOfLikes; // calculated, not stored in parse
@property (nonatomic) NSUInteger numberOfComments; // calculated, not stored in parse

- (instancetype)initWithObjectId:(NSString*)imageId withImage:(UIImage*)image withImageOwner:(User*)user withCreationDate:(NSDate*)date;

@end
