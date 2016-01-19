//
//  LoginView.m
//  CameraTest
//
//  Created by Aditya Narayan on 1/19/16.
//  Copyright © 2016 Aditya. All rights reserved.
//

#import "LoginView.h"
#import "DataAccess.h"

@implementation LoginView

- (IBAction)attemptLogin:(id)sender {
  [self.loginActivityIndicator startAnimating];
  self.loginActivityIndicator.alpha = 1;
  DataAccess *dao = [DataAccess sharedManager];
//  [dao loginWithUsername:self.username.text withPassword:self.password.text];
  [dao loginWithUsername:self.username.text withPassword:self.password.text];

  NSLog(@"Attempt login");
}

- (IBAction)attemptSignup:(id)sender {
  [self.signupActivityIndicator startAnimating];
  self.signupActivityIndicator.alpha = 1;
  DataAccess *dao = [DataAccess sharedManager];
  //  [dao loginWithUsername:self.username.text withPassword:self.password.text];
  [dao signupWithUsername:self.signupUsername.text withPassword:self.signupPassword.text withFullName:self.signupFullname.text];

}

- (IBAction)facebookLogin:(id)sender {
  DataAccess *dao = [DataAccess sharedManager];
  [dao loginWithFacebook];
}


@end
