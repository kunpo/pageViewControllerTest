//
//  SubViewController.m
//  page
//
//  Created by kemp on 2019/6/27.
//  Copyright © 2019 kemp. All rights reserved.
//

#import "SubViewController.h"

@interface SubViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation SubViewController

+ (instancetype)creat {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SubViewController *vc = [board instantiateViewControllerWithIdentifier:@"SubViewController"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.label.text = self.title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


@end
