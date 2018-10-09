//
//  ViewController.m
//  crashfix
//
//  Created by allen on 2018/10/8.
//  Copyright © 2018 allen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *testBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_testBtn addTarget:self action:@selector(clickTestbtn) forControlEvents:(UIControlEventTouchUpInside)];
}


@end
