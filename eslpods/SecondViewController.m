//
//  SecondViewController.m
//  eslpods
//
//  Created by 椛島優 on 2015/11/27.
//  Copyright © 2015年 椛島優. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property MPMediaItemCollection *mediaItemCollection;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)unWindtoSecondScene:(UIStoryboardSegue *)unwindSegue{
    
}
- (IBAction)SelectMusicTap:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc]init];
    
    picker.delegate = self;
    
    picker.allowsPickingMultipleItems = YES;        // 複数選択可
    
    [self presentViewController:picker animated:YES completion:nil];

}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
     //キャンセルで曲選択を終わる
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection       //曲選択後
{
   
    self.mediaItemCollection=mediaItemCollection;
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"SecondToMultiSegue" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Segueの特定
    if ( [[segue identifier] isEqualToString:@"SecondToMultiSegue"] ) {
        MultiViewController *multiViewController = [segue destinationViewController];
        //ここで遷移先ビューのクラスの変数receiveStringに値を渡している
        multiViewController.mediaItemCollection = self.mediaItemCollection;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
