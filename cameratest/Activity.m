//
//  Activity.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/12/16.
//
//

#import "Activity.h"

@implementation Activity

- (NSString*)description{
  return [NSString stringWithFormat:@"%@ by %@", _activityType, _activityAuthor];
}

@end
