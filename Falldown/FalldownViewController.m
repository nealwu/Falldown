//
//  FalldownViewController.m
//  Falldown
//
//  Created by Neal Wu on 3/26/15.
//  Copyright (c) 2015 Neal Wu. All rights reserved.
//

#import "FalldownViewController.h"

const int BRICK_SLOTS = 12;
const int BRICK_VELOCITY = 100;

@interface FalldownViewController () <UICollisionBehaviorDelegate>

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.playerImage = [UIImage imageNamed:@"player"];
    self.brickImage = [UIImage imageNamed:@"brick"];

    self.BRICK_WIDTH = self.view.frame.size.width / BRICK_SLOTS;
    self.BRICK_HEIGHT = self.BRICK_WIDTH * self.brickImage.size.height / self.brickImage.size.width;
    self.PLAYER_WIDTH = self.BRICK_WIDTH * self.playerImage.size.width / self.brickImage.size.width;

    self.player = [[UIImageView alloc] initWithImage:self.playerImage];
    self.player.frame = CGRectMake(0, 0, self.PLAYER_WIDTH, self.PLAYER_WIDTH);
    [self.view addSubview:self.player];

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    self.gravity = [[UIGravityBehavior alloc] init];
    [self.gravity addItem:self.player];

    self.collision = [[UICollisionBehavior alloc] init];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    self.collision.collisionDelegate = self;
    [self.collision addItem:self.player];

    self.brickItemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.brickItemBehavior.resistance = 0;
    self.brickItemBehavior.density = 1e9;

    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collision];
    [self.animator addBehavior:self.brickItemBehavior];

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(generateBricks) userInfo:nil repeats:YES];
    [timer fire];
}

#pragma mark - UICollisionBehaviorDelegate methods

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier {
    UIView *view = (UIView *) item;
    NSString *boundary = (NSString *) identifier;

    if (view == self.player) {
        NSLog(@"YOU LOSE");
    } else {
        NSLog(@"Brick collided with top");
    }

    NSLog(@"Item %@ collided with boundary %@", view, boundary);
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    UIView *view1 = (UIView *) item1;
    UIView *view2 = (UIView *) item2;
    NSLog(@"Item %@ collided with item %@", view1, view2);
    NSLog(@"Items collided together");
}

#pragma mark - Private methods

- (void)generateBricks {
    NSInteger y = self.view.frame.size.height - self.BRICK_HEIGHT;

    for (int i = 0; i < BRICK_SLOTS; i++) {
        UIImageView *brick = [[UIImageView alloc] init];
        brick.frame = CGRectMake(self.view.frame.size.width * i / BRICK_SLOTS, y, self.BRICK_WIDTH, self.BRICK_HEIGHT);
        brick.image = self.brickImage;
        [self.view addSubview:brick];
        [self.collision addItem:brick];
        [self.brickItemBehavior addItem:brick];
        [self.brickItemBehavior addLinearVelocity:CGPointMake(0, -BRICK_VELOCITY) forItem:brick];
    }
}

@end
