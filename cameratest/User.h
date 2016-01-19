//
//  User.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/11/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *realName;
@property (nonatomic, strong) UIImage *avatarImage;

@end
