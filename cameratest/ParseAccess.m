//
//  ParseAccess.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import "ParseAccess.h"
#import <CommonCrypto/CommonCrypto.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@implementation ParseAccess{
}

- (instancetype)init{
  self = [super init];
  _objectStore = [[NSMutableDictionary alloc] init];
  return self;
}


#pragma mark Get methods

- (User*)getCurrentUser{
  PFUser *parseUser = [PFUser currentUser];
  User *user = [[User alloc] init];
  user.userId = [parseUser objectId];
  if([parseUser objectForKey:@"fullName"]){
    user.realName = [parseUser objectForKey:@"fullName"];
    user.username = [parseUser objectForKey:@"username"];
  } else {
    user.realName = @"You";
    user.username = @"You";
  }
  
  user.avatarImage = [UIImage imageNamed:@"default-avatar.jpeg"];
  return user;
}

- (void)getImagesWithLimit:(NSUInteger) limit{
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  [query whereKeyExists:@"imageOriginal"];
  [query whereKey:@"softDelete" notEqualTo:[NSNumber numberWithBool:YES]];
  [query orderByDescending:@"createdAt"];
  
  if(_offset){
    [query setSkip:_offset];
  }
  [query setLimit:limit];
  _offset += limit;
  
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    for (PFObject *object in objects) {
      [self getImageObject:object];
    }
  }];
}

#pragma mark Fetch image attributes and associated activities

- (void)getImageObject:(PFObject*)objectId{
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  [query includeKey:@"imageOwner"];
  [query getObjectInBackgroundWithId:[objectId objectId] block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    
    PFFile *image = object[@"imageOriginal"];
    [image getDataInBackgroundWithBlock:^(NSData * _Nullable data2, NSError * _Nullable error) {
      
      UIImage *imageForDisplay = [UIImage imageWithData:data2];
      
      PFQuery *userQuery = [PFUser query];
      [userQuery whereKey:@"objectId" equalTo:[object[@"imageOwner"] objectId]];
      [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable error) {
        User *imageOwner = [[User alloc] init];
        imageOwner.userId = [user objectId];
        imageOwner.username = [user objectForKey:@"username"];
        imageOwner.realName = [user objectForKey:@"fullName"];
        
        PFFile *avatar = user[@"avatar"];
        [avatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
          if(!error){
            imageOwner.avatarImage = [UIImage imageWithData:data];
          } else {
            imageOwner.avatarImage = [UIImage imageNamed:@"default-avatar.jpeg"];
          }
          
          Image *returnObject = [[Image alloc] initWithObjectId:[object objectId] withImage:imageForDisplay withImageOwner:imageOwner withCreationDate:[object createdAt]];
          [_objectStore setObject:returnObject forKey:[objectId objectId]];
          
          [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveImageAvailable" object:self userInfo:@{@"resourceLocator":[objectId objectId]}];
          
          [self getActivityCountForImage:object withType:@"like"];
          [self getActivityCountForImage:object withType:@"comment"];
          [self getActivitiesForImage:object];
        }];
      }];
    }];
  }];
}

- (void)getActivitiesForImage:(PFObject*)image{
  PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
  [query whereKey:@"image" equalTo:image];
  [query whereKey:@"softDelete" notEqualTo:[NSNumber numberWithBool:YES]];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    NSUInteger likeCount = 0;
    NSUInteger commentCount = 0;
    
    if(!error && [objects count] > 0){
      for (PFObject *object in objects) {
        Activity *activity = [[Activity alloc] init];
        activity.activityId = [object objectId];
        activity.imageId = [image objectId];
        activity.activityType = [object valueForKey:@"activityType"];
        if([[object valueForKey:@"activityType"] isEqualToString:@"comment"]){
          commentCount++;
          activity.commentText = [object valueForKey:@"commentText"];
        } else { likeCount++; }
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:[object[@"activityAuthor"] objectId]];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          
          PFUser *parseUser = object;
          activity.activityAuthor = [[User alloc] init];
          activity.activityAuthor.userId = [parseUser objectId];
          activity.activityAuthor.username = [parseUser objectForKey:@"username"];
          activity.activityAuthor.realName = [parseUser objectForKey:@"fullName"];
          
          PFFile *avatar = parseUser[@"avatar"];
          [avatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if(!error){
              activity.activityAuthor.avatarImage = [UIImage imageWithData:data];
            } else {
              activity.activityAuthor.avatarImage = [UIImage imageNamed:@"default-avatar"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveActivity" object:self userInfo:@{@"imageId" : [image objectId], @"activity" : activity}];
          }];
        }];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveNumberOfComments" object:self userInfo:@{@"imageId" : [image objectId], @"comments" : [NSNumber numberWithInt:(int)commentCount]}];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveNumberOfLikes" object:self userInfo: @{@"imageId" : [image objectId], @"likes" : [NSNumber numberWithInt:(int)likeCount]}];
      }
    } else {
      if ([objects count] == 0){
        NSLog(@"No activities for image: %@", [image objectId]);
      }
      if (error) {
        NSLog(@"%@", [error localizedDescription]);
      }
    }
  }];
}

- (void)getActivityCountForImage:(PFObject*)image withType:(NSString*)type{
  PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
  [query whereKey:@"image" equalTo:image];
  [query whereKey:@"activityType" equalTo:type];
  [query whereKey:@"softDelete" notEqualTo:[NSNumber numberWithBool:YES]];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
    if(!error){
      if ([type isEqualToString:@"comment"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveNumberOfComments" object:self userInfo:@{@"imageId" : [image objectId], @"comments" : [NSNumber numberWithInt:number]}];
      } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveNumberOfLikes" object:self userInfo: @{@"imageId" : [image objectId], @"likes" : [NSNumber numberWithInt:number]}];
      }
    } else {
      NSLog(@"%@",[error localizedDescription]);
    }
  }];
}

- (void)getActivityCountForImageById:(NSString*)imageId{
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  [query getObjectInBackgroundWithId:imageId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    if(!error){
      [self getActivityCountForImage:object withType:@"comment"];
      [self getActivityCountForImage:object withType:@"like"];
    }
  }];
}

#pragma mark Image manipulation methods

- (NSString*)addImage:(Image*)image{
  __block NSString *temporaryObjectId = [self md5HexDigest];
  NSData *imageData = UIImagePNGRepresentation(image.imageOriginal);
  PFFile *imageFile = [PFFile fileWithName:@"file.png" data:imageData];
  [imageFile saveInBackground];
  
  PFObject *parseImage = [PFObject objectWithClassName:@"Image"];
  [parseImage setObject:imageFile forKey:@"imageOriginal"];
  [parseImage setObject:[PFUser currentUser] forKey:@"imageOwner"];
  [parseImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    if(succeeded){
      NSLog(@"SUCCEEDED UPLOAD");
      
      [[NSNotificationCenter defaultCenter] postNotificationName:@"requestViewRefresh" object:self];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"replaceTemporaryObjectId" object:self userInfo:@{@"temporaryIdentifier" : temporaryObjectId,
                                                                                                                    @"permanentIdentifier" :[parseImage objectId]}];
    }
  }];
  return temporaryObjectId;
}

- (NSString*)addImageWithImage:(UIImage*)image{
  Image *imageObject = [[Image alloc] init];
  imageObject.imageOriginal = image;
  return [self addImage:imageObject];
}

- (void)deleteImage:(Image*)image{
// hard delete
//  PFQuery *parseActivity = [PFQuery queryWithClassName:@"Image"];
//  [parseActivity getObjectInBackgroundWithId:image.imageId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
//    if(!error){
//      [object deleteInBackground];
//      NSLog(@"Image Deleted");
//    }
//  }];
  
  //soft delete
  PFObject *point = [PFObject objectWithoutDataWithClassName:@"Image" objectId:image.imageId];
  [point setObject:[NSNumber numberWithBool:YES] forKey:@"softDelete"];
  [point saveInBackground];
}

- (void)deleteImageWithId:(NSString *)imageId{
  Image *image = [[Image alloc] init];
  image.imageId = imageId;
  [self deleteImage:image];
}

#pragma mark Activity manipulation methods

- (void)addActivity:(Activity*)activity{
  
  PFQuery *image = [PFQuery queryWithClassName:@"Image"];
  [image getObjectInBackgroundWithId:activity.imageId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    PFObject *parseActivity = [PFObject objectWithClassName:@"Activity"];
    [parseActivity setObject:[PFUser currentUser] forKey:@"activityAuthor"];
    [parseActivity setObject:object forKey:@"image"];
    [parseActivity setObject:activity.activityType forKey:@"activityType"];
    if ([activity.activityType isEqualToString:@"comment"]) {
      [parseActivity setObject:activity.commentText forKey:@"commentText"];
    }
    [parseActivity saveEventually];
    NSLog(@"%@", [activity.activityType isEqualToString:@"comment"] ? @"Commented!" : @"Liked!");
  }];
}

- (void)likeImageWithId:(NSString*)imageId{
  Activity *activity = [[Activity alloc] init];
  activity.activityType = @"like";
  activity.imageId = imageId;
  [self addActivity:activity];
}

- (void)commentImageWithId:(NSString*)imageId withComment:(NSString*)commentText{
  Activity *activity = [[Activity alloc] init];
  activity.activityType = @"comment";
  activity.commentText = commentText;
  activity.imageId = imageId;
  [self addActivity:activity];
}

- (void)removeActivity:(Activity*)activity{
  //hard delete
//  PFQuery *parseActivity = [PFQuery queryWithClassName:@"Activity"];
//  [parseActivity getObjectInBackgroundWithId:activity.activityId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
//    if(!error){
//      [object deleteInBackground];
//      NSLog(@"Deleted");
//    }
//  }];
  
  //soft delete
  PFObject *point = [PFObject objectWithoutDataWithClassName:@"Activity" objectId:activity.activityId];
  [point setObject:[NSNumber numberWithBool:YES] forKey:@"softDelete"];
  [point saveInBackground];
}

- (void) removeActivityWithId:(NSString*)activityId{
  Activity *activity = [[Activity alloc] init];
  activity.activityId = activityId;
  [self removeActivity:activity];
}

#pragma mark Login/Logout methods

- (void)login:(NSString*)username withPassword:(NSString*)password{
  PFUser *currentUser = [PFUser currentUser];
  if(currentUser){
    [self logout];
  }
  
  [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
    if(user){
      NSLog(@"Logged in");
      [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:self userInfo:@{@"update" : @"loginSuccess"}];
    } else {
      NSLog(@"Login fail %@", [error localizedDescription]);
    }
  }];
}

- (void)loginWithFacebook{

  [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile"] block:^(PFUser *user, NSError *error) {
    if (!user) {
      NSLog(@"Uh oh. The user cancelled the Facebook login.");
    } else if (user.isNew) {
      NSLog(@"User signed up and logged in through Facebook!");
      [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:self userInfo:@{@"update" : @"loginSuccess"}];
    } else {
      NSLog(@"User %@ logged in through Facebook!",[PFUser currentUser]);
      [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:self userInfo:@{@"update" : @"loginSuccess"}];
    }
  }];
}

- (void)logout{
  [PFUser logOut]; //synchronous
  [[NSNotificationCenter defaultCenter] postNotificationName:@"LogoutSuccess" object:self userInfo:@{@"update" : @"loginSuccess"}];
}

- (void)signup:(NSString*)username withPassword:(NSString*)password withAvatar:(UIImage*)avatar withFullName:(NSString*)fullName{
  NSData *imageData = UIImagePNGRepresentation(avatar);
  PFFile *avatarImage = [PFFile fileWithName:@"avatar.png" data:imageData];
  [avatarImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    if(succeeded){
      PFUser *user = [PFUser user];
      user.username = username;
      user.password = password;
      user[@"fullName"] = fullName;
      user[@"avatar"] = avatarImage;
      [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
          NSLog(@"Signup success");
          [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:self userInfo:@{@"update" : @"loginSuccess"}];
        }
      }];
    }
  }];
}

#pragma mark Utility methods
//unused at the moment
- (NSString*)md5HexDigest{
  NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
  NSString *input = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
  const char* str = [input UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, (unsigned int)strlen(str), result);
  NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
  for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
    [ret appendFormat:@"%02x",result[i]];
  }
  return ret;
}

@end