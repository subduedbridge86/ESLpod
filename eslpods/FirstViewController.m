//
//  FirstViewController.m
//  eslpods
//
//  Created by 椛島優 on 2015/11/27.
//  Copyright © 2015年 椛島優. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property MPMediaItemCollection *mediaItemCollection2;
@property NSArray *nameData;
@property NSData *mediaitemData;
@property NSString *name1;
@property long songCount;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;


@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    _mediaitemData=[ud objectForKey:@"_mediaitemData"];
    
    if (_mediaitemData==nil) {
        NSLog(@"a2");
        _continueButton.enabled=NO;
        [_continueButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)unWindtoFirstScene:(UIStoryboardSegue *)unwindSegue{
    _continueButton.enabled=YES;
    [_continueButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
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
    _songCount=0;
    
    self.mediaItemCollection2=mediaItemCollection;
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"FirstToSoloSegue" sender:self];
    
    _mediaitemData = [NSKeyedArchiver archivedDataWithRootObject:_mediaItemCollection2];
    NSUserDefaults *ud4=[NSUserDefaults standardUserDefaults];
    [ud4 setObject:_mediaitemData forKey:@"_mediaitemData"];
    
    _nameData=[[NSArray alloc]init];
    for (int i = 0;i < _mediaItemCollection2.count; i++) {
        MPMediaItem *nameitem1=[_mediaItemCollection2.items objectAtIndex:i];
        _name1=[nameitem1 valueForProperty:MPMediaItemPropertyTitle];
        _nameData=[_nameData arrayByAddingObject:_name1];
    }
    NSUserDefaults *ud3=[NSUserDefaults standardUserDefaults];
    [ud3 setObject:_nameData forKey:@"nameData"];
    NSUserDefaults *ud5=[NSUserDefaults standardUserDefaults];
    [ud5 setFloat:_songCount forKey:@"songCount"];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Segueの特定
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
