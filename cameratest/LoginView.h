//
//  LoginView.h
//  CameraTest
//
//  Created by Aditya Narayan on 1/19/16.
//  Copyright © 2016 Aditya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;

@property (weak, nonatomic) IBOutlet UITextField *signupFullname;
@property (weak, nonatomic) IBOutlet UITextField *signupUsername;
@property (weak, nonatomic) IBOutlet UITextField *signupPassword;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *signupActivityIndicator;

@end
