//
//  Image.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import "Image.h"

@implementation Image

-(NSString*)description{
  return [NSString stringWithFormat:@"\n Image ID: %@ \n Image Owner: %@ \nActivities: %@", _imageId, _imageOwner, _activities];
}

- (instancetype)initWithObjectId:(NSString*)imageId withImage:(UIImage*)image withImageOwner:(User*)user withCreationDate:(NSDate*)date{
  self = [super init];
  
  _imageId = imageId;
  _imageOriginal = image;
  _user = user;
  _createdDate = date;
  
  return self;
}


@end
