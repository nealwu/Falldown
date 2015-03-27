//
//  FalldownViewController.m
//  Falldown
//
//  Created by Neal Wu on 3/26/15.
//  Copyright (c) 2015 Neal Wu. All rights reserved.
//

#import "FalldownViewController.h"

const int BRICK_SLOTS = 12;

@interface FalldownViewController ()

@property (assign, nonatomic) NSInteger BRICK_WIDTH;
@property (assign, nonatomic) NSInteger BRICK_HEIGHT;
@property (assign, nonatomic) NSInteger PLAYER_WIDTH;

@property (strong, nonatomic) UIImage *playerImage;
@property (strong, nonatomic) UIImage *brickImage;

@property (strong, nonatomic) UIImageView *player;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravity;
@property (strong, nonatomic) UICollisionBehavior *collision;

@property (strong, nonatomic) UIDynamicItemBehavior *brickItemBehavior;

@end

@implementation FalldownViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playerImage = [UIImage imageNamed:@"player"];
    self.brickImage = [UIImage imageNamed:@"brick"];

    self.BRICK_WIDTH = [UIScreen mainScreen].bounds.size.width / BRICK_SLOTS;
    self.BRICK_HEIGHT = self.BRICK_WIDTH * self.brickImage.size.height / self.brickImage.size.width;
    self.PLAYER_WIDTH = self.BRICK_WIDTH * self.playerImage.size.width / self.brickImage.size.width;

    self.player = [[UIImageView alloc] initWithImage:self.playerImage];
    self.player.frame = CGRectMake(0, 0, self.PLAYER_WIDTH, self.PLAYER_WIDTH);
    [self.view addSubview:self.player];

    UIImageView *brick = [[UIImageView alloc] initWithImage:self.brickImage];
    brick.frame = CGRectMake(0, 10 * self.PLAYER_WIDTH, self.BRICK_WIDTH, self.BRICK_HEIGHT);
    [self.view addSubview:brick];

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    self.gravity = [[UIGravityBehavior alloc] init];
    [self.gravity addItem:self.player];

    self.collision = [[UICollisionBehavior alloc] init];
    [self.collision addItem:self.player];
    [self.collision addItem:brick];

    self.brickItemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.brickItemBehavior.resistance = 0;
    self.brickItemBehavior.density = 1e12;
    [self.brickItemBehavior addItem:brick];
    [self.brickItemBehavior addLinearVelocity:CGPointMake(0, -100) forItem:brick];

    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collision];
    [self.animator addBehavior:self.brickItemBehavior];
}

@end
