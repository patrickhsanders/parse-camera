//
//  ViewController.m
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import "CollectionViewCell.h"
#import "LoginView.h"

@interface ViewController ()

@property (nonatomic, strong) Image* currentlySelectedImage;
@property (nonatomic, strong) LoginView* loginView;
@end

@implementation ViewController


- (void)viewDidLoad
{
  [super viewDidLoad];
  _dao = [DataAccess sharedManager];

  _loginView = [[[NSBundle mainBundle] loadNibNamed:@"LoginCreate" owner:self options:nil] objectAtIndex:0];
  _loginView.frame = self.view.frame;
  _loginView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:_loginView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(loggedInNotification:)
                                               name:@"LoginSuccessWithData"
                                             object:nil];
  
  
  [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
  self.collectionView.backgroundColor = [UIColor clearColor];
  
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  [flowLayout setItemSize:CGSizeMake(250, 250)];
  [flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
  [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
  [self loadData];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestViewRefresh:) name:@"requestViewRefresh" object:nil];
  

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(void)loadData
{
  [self.tableView reloadData];
  
}


- (IBAction)edit:(id)sender{
  if([self.tableView isEditing]){
    [sender setTitle:@"Edit"];
  }else{
    [sender setTitle:@"Done"];
  } [sender setTitle:@" "];
  [self.tableView setEditing:![self.tableView isEditing]];
}

- (IBAction)takePicture:(id)sender{
  
  if([self.popController isPopoverVisible]){
    [self.popController dismissPopoverAnimated:YES];
    self.popController = nil;
    return;
  }
  
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  
  if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
  }else
  {
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  }
  
  [imagePicker setAllowsEditing:TRUE];
  [imagePicker setDelegate:self];
  self.popController = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
  [self.popController setDelegate:self];
  [self.popController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  
  
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
  [self.popController dismissPopoverAnimated:YES];
  self.popController = nil;
  
  UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
  [self.imageView setImage:image];
  [_dao addImage:image];
}

- (void)uploadDone:(NSError *)error
{
  if(error != nil){
    NSLog(@"Error: %@", error);
  }else
  {
    NSLog(@"File Uploaded");
    [self loadData];
  }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_currentlySelectedImage.activities count];
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
  
  if(!cell){
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
  }
  
  Activity *activity = [_currentlySelectedImage.activities objectAtIndex:indexPath.row];
//  Activity *activity = [_tableData objectAtIndex:indexPath.row];
  
  NSString *outputString;
  if([activity.activityType isEqualToString:@"comment"]){
    outputString = [NSString stringWithFormat:@"%@ commented: \"%@\"",activity.activityAuthor.realName,activity.commentText];
  } else {
    outputString = [NSString stringWithFormat:@"%@ liked this.",activity.activityAuthor.realName];
  }
  [[cell textLabel] setText:outputString];
  return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
//  Image *image = [_dao.images objectAtIndex:indexPath.row];
//  _imageView.image = image.imageOriginal;
}


- (void) tableView: (UITableView *)tableView  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self loadData];
}

- (void)requestViewRefresh:(NSNotification*)notification{
  [self.tableView reloadData];
  [self.collectionView reloadData];
  if(self.imageView.image == nil && _dao.images != nil && [_dao.images count] != 0){
    _currentlySelectedImage = [_dao.images objectAtIndex:0];
    self.imageView.image = [[_dao.images objectAtIndex:0] imageOriginal];
    _commentCount.text = [NSString stringWithFormat:@"%lu",_currentlySelectedImage.numberOfComments];
    _likeCount.text = [NSString stringWithFormat:@"%lu",_currentlySelectedImage.numberOfLikes];
  }
}

#pragma mark Collection view methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return [_dao.images count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(250, 175);
}

- (CollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
  
  Image *image = [_dao.images objectAtIndex:indexPath.row];
  [[cell mainImage] setImage:image.imageOriginal];
  [[cell avatarImage] setImage:image.user.avatarImage];
  [[cell userFullName] setText:[NSString stringWithFormat:@"%@ 💙:%lu 💬:%lu",[image user], [image numberOfLikes], [image numberOfComments]]];

  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  _currentlySelectedImage = [_dao.images objectAtIndex:indexPath.row];
  _imageView.image = _currentlySelectedImage.imageOriginal;
  _commentCount.text = [NSString stringWithFormat:@"%lu",_currentlySelectedImage.numberOfComments];
  _likeCount.text = [NSString stringWithFormat:@"%lu",_currentlySelectedImage.numberOfLikes];
  _tableData = _currentlySelectedImage.activities;
  [_tableView reloadData];
}

#pragma mark Methods to add activities to images
- (IBAction)likeButtonPressed:(id)sender {
  _likeCount.text = [NSString stringWithFormat:@"%lu",_currentlySelectedImage.numberOfLikes + 1];
  [_dao likeImage:_currentlySelectedImage];
  NSLog(@"You liked it!");
}

- (IBAction)breakpoint:(id)sender {
  
  NSLog(@"Something");
}

- (IBAction)commentCreated:(id)sender {
  NSString *comment = ((UITextField *)sender).text;
  _commentCount.text = [NSString stringWithFormat:@"%lu",_currentlySelectedImage.numberOfComments + 1];
  [_dao commentOnImage:_currentlySelectedImage withComment:comment];
  NSLog(@"You commented on it!");
}

- (void)loggedInNotification:(NSNotification*) notification{
  [self.loginView removeFromSuperview];
}


@end
