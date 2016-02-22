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
@property NSString * msgStr;
@property BOOL songTitleFlag;
@property ESLpod *mypod;
@property (weak, nonatomic) IBOutlet UILabel *ConnecedtLabel;
@end

@implementation StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.StPlayer=[[StreamingPlayer alloc]init];
     self.myMulti=[[MultipeerHost alloc]init];
    self.myMulti.delegate=self;
    [self.myMulti startClient];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLabeltoCon)
                                                 name:@"conn"
                                               object:self.myMulti];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLabeltoDiscon)
                                                 name:@"disconn"
                                               object:self.myMulti];
    //feed back
    _mypod=[[ESLpod alloc]init];
    [_mypod audioSession];
    [_mypod feed];
    [_mypod bufferSet];
    ESLpod *mypod=[[ESLpod alloc]init];
    [mypod audioSession];
    [mypod feed];
    [mypod bufferSet];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)recvDataPacket:(NSData *)data{
     _msgStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if ([_msgStr isEqual:@"sta"]) {
        [self.StPlayer start];
        self.songTitleFlag=YES;
        NSLog(@"STREAMING START!!");
    }else if(self.songTitleFlag){
        NSLog(_msgStr);
        self.songTitleFlag=NO;
    }else{
        [self.StPlayer recvAudio:data];
    }
    
}
- (IBAction)returnBtnTap:(id)sender {
    [self.myMulti stopClient];
    [self.myMulti disconnect];
}
-(void)changeLabeltoDiscon{
    dispatch_async(
                   dispatch_get_main_queue(),
                   ^{
                       // ここに実行したいコード
                      self.ConnecedtLabel.text=@"未接続";
                   }
                   );
}
-(void)changeLabeltoCon{
    dispatch_async(
                   dispatch_get_main_queue(),
                   ^{
                       // ここに実行したいコード
                       self.ConnecedtLabel.text=@"接続済み";
                   }
                   );
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
