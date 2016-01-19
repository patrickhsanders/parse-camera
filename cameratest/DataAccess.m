//
//  DataAccess.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import "DataAccess.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation DataAccess

+ (id)sharedManager {
  static DataAccess *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

-(instancetype)init {
  if (self = [super init]) {
    _parse = [[ParseAccess alloc] init];
    
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(loggedInNotification:)
                                               name:@"LoginSuccess"
                                             object:nil];
    
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(logoutNotification:)
                                               name:@"LogoutSuccess"
                                            object:nil];
  }
  return self;
}

#pragma mark Login / Signup etc

- (void)loginWithUsername:(NSString*)username withPassword:(NSString*)password{
  [_parse login:username withPassword:password];
}

- (void)loginWithFacebook{
  [_parse loginWithFacebook];
}

- (void)signupWithUsername:(NSString*)username withPassword:(NSString*)password withFullName:(NSString*)fullName{
  [_parse signup:username withPassword:password withAvatar:[UIImage imageNamed:@"default-avatar.jpeg"] withFullName:fullName];
}


#pragma mark Image access and modification methods

- (void)getImages{
//  [_parse getImagesWithLimit:3];
}

- (void)addImage:(UIImage*)image{
  NSString *temporaryObjectId = [_parse addImageWithImage:image];
  Image *image2 = [[Image alloc] init];
  image2.imageId = temporaryObjectId;
  image2.imageOriginal = image;
  image2.user = _currentUser;
  image2.likes = 0;
  image2.comments = 0;
  [_images insertObject:image2 atIndex:0];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)deleteImage:(Image*)image{
  // Create a pointer to an object of class Point with id dlkj83d
  // [_parse deleteImageWithId:image.imageId];
  // remove from table view
}

- (void)getActivitiesForImage:(Image*)image{
  //not implemented
}

- (void)updateActivitiesCountForImage:(Image*)image{
  [_parse getActivityCountForImageById:image.imageId];
  //update display or something on notification
}

- (void)likeImage:(Image*)image{
  [_parse likeImageWithId:image.imageId];
  image.numberOfLikes += 1;
  Activity *activity = [[Activity alloc] init];
  activity.imageId = image.imageId;
  activity.activityAuthor = _currentUser;
  activity.activityType = @"like";
  [image.activities insertObject:activity atIndex:0];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)commentOnImage:(Image*)image withComment:(NSString*)comment{
  [_parse commentImageWithId:image.imageId withComment:comment];
  image.numberOfComments += 1;
  Activity *activity = [[Activity alloc] init];
  activity.imageId = image.imageId;
  activity.activityAuthor = _currentUser;
  activity.activityType = @"comment";
  activity.commentText = comment;
  
  [image.activities insertObject:activity atIndex:0];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}


#pragma mark Notification handlers for events from Data Source

- (void)loggedInNotification:(NSNotification*)notification{
  _currentUser = [_parse getCurrentUser];
  _images = [[NSMutableArray alloc] init];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveImageNotification:) name:@"receiveImageNotification" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNumberOfLikes:) name:@"receiveNumberOfLikes" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNumberOfComments:) name:@"receiveNumberOfComments" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveActivity:) name:@"receiveActivity" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveImageAvailable:) name:@"receiveImageAvailable" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replaceTemporaryObjectId:) name:@"replaceTemporaryObjectId" object:nil];
  [_parse getImagesWithLimit:100];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessWithData" object:self];
  
}
- (void)logoutNotification:(NSNotification*)notification{
  _images = nil;
  NSLog(@"Logout");
}

- (void)receiveImageNotification:(NSNotification*)notification{
  Image *image = [[Image alloc] init];
  image.imageId = [notification.userInfo valueForKey:@"imageId"];
  image.imageOwner = [notification.userInfo valueForKey:@"imageOwner"];
  image.imageOriginal = [notification.userInfo valueForKey:@"imageOriginal"];
  image.createdDate = [notification.userInfo valueForKey:@"createdDate"];
  [_images addObject:image];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)receiveActivity:(NSNotification*)notification{
  for (Image *image in _images) {
    if(image.activities == nil){
      image.activities = [[NSMutableArray alloc] init];
    }
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      [image.activities addObject:notification.userInfo[@"activity"]];
    }
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)receiveNumberOfLikes:(NSNotification*)notification{
  NSLog(@"likes: %ld image: %@", [notification.userInfo[@"likes"] integerValue],notification.userInfo[@"imageId"]);
  for (Image *image in _images) {
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      image.numberOfLikes = [notification.userInfo[@"likes"] integerValue];
    }
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)receiveNumberOfComments:(NSNotification*)notification{
  NSLog(@"comments: %ld image: %@", [notification.userInfo[@"comments"] integerValue],notification.userInfo[@"imageId"]);
  for (Image *image in _images) {
    if([notification.userInfo[@"imageId"] isEqualToString:image.imageId]){
      image.numberOfComments = [notification.userInfo[@"comments"] integerValue];
    }
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)receiveImageAvailable:(NSNotification*)notification{
  Image *image = [_parse.objectStore objectForKey:notification.userInfo[@"resourceLocator"]];
  [_images addObject:image];  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
}

- (void)replaceTemporaryObjectId:(NSNotification*)notification{
  for (Image *image in _images) {
    if([image.imageId isEqualToString:notification.userInfo[@"temporaryIdentifier"]]){
      image.imageId = notification.userInfo[@"permanentIdentifier"];
    }
  }
}

@end
