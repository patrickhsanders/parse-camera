//
//  Activity.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/12/16.
//
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Activity : NSObject

@property (nonatomic, strong) NSString *activityId;
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) User *activityAuthor;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSString *activityType;
@property (nonatomic, strong) NSString *commentText;

@end
