//
//  ViewController.m
//  SimpleTextureDemo
//
//  Created by zhichang.he on 2019/2/21.
//  Copyright © 2019年 zhichang.he. All rights reserved.
//

#import "ViewController.h"
#import "Demo1ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click:(id)sender {
    Class objClass = [Demo1ViewController class];
    UIViewController *vc = [[objClass alloc] init];
    [self presentViewController:vc animated:NO completion:nil];
}

@end
