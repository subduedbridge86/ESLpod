//
//  StreamViewController.m
//  eslpods
//
//  Created by 椛島優 on 2015/11/27.
//  Copyright © 2015年 椛島優. All rights reserved.
//

#import "StreamViewController.h"

@interface StreamViewController ()
@property StreamingPlayer * StPlayer;
@property MultipeerHost * myMulti;
@end

@implementation StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.StPlayer=[[StreamingPlayer alloc]init];
    [self.StPlayer start];
     self.myMulti=[[MultipeerHost alloc]init];
    self.myMulti.delegate=self;
    [self.myMulti startClient];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)recvDataPacket:(NSData *)data{
    [self.StPlayer recvAudio:data];
    
}
- (IBAction)returnBtnTap:(id)sender {
    [self.myMulti stopClient];
    [self.myMulti disconnect];
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
