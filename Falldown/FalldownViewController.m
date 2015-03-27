//
//  FalldownViewController.m
//  Falldown
//
//  Created by Neal Wu on 3/26/15.
//  Copyright (c) 2015 Neal Wu. All rights reserved.
//

#import "FalldownViewController.h"

const int BRICK_SLOTS = 12;
const int MIN_BRICKS = 4;
const int MAX_BRICKS = 11;
const int BRICK_VELOCITY = 100;
const int PLAYER_VELOCITY = 50;
const int CHANGE_PERCENTAGE = 20;

@interface FalldownViewController () <UICollisionBehaviorDelegate>

@property (assign, nonatomic) CGFloat SCREEN_WIDTH;
@property (assign, nonatomic) CGFloat SCREEN_HEIGHT;

@property (assign, nonatomic) CGFloat BRICK_WIDTH;
@property (assign, nonatomic) CGFloat BRICK_HEIGHT;
@property (assign, nonatomic) CGFloat PLAYER_WIDTH;

@property (strong, nonatomic) UIImage *playerImage;
@property (strong, nonatomic) UIImage *brickImage;

@property (strong, nonatomic) UIImageView *player;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravity;
@property (strong, nonatomic) UICollisionBehavior *collision;

@property (strong, nonatomic) UIDynamicItemBehavior *playerItemBehavior;
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

    self.SCREEN_WIDTH = self.view.frame.size.width;
    self.SCREEN_HEIGHT = self.view.frame.size.height;
    self.BRICK_WIDTH = self.SCREEN_WIDTH / BRICK_SLOTS;
    self.BRICK_HEIGHT = self.BRICK_WIDTH * self.brickImage.size.height / self.brickImage.size.width;
    self.PLAYER_WIDTH = self.BRICK_WIDTH * self.playerImage.size.width / self.brickImage.size.width;

    self.player = [[UIImageView alloc] initWithImage:self.playerImage];
    self.player.frame = CGRectMake(0, 1, self.PLAYER_WIDTH, self.PLAYER_WIDTH);
    [self.view addSubview:self.player];

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    self.gravity = [[UIGravityBehavior alloc] init];
    [self.gravity addItem:self.player];

    self.collision = [[UICollisionBehavior alloc] init];
    [self.collision addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(self.SCREEN_WIDTH, 0)];
    [self.collision addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(0, self.SCREEN_HEIGHT) toPoint:CGPointMake(self.SCREEN_WIDTH, self.SCREEN_HEIGHT)];
    [self.collision addBoundaryWithIdentifier:@"left" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, self.SCREEN_HEIGHT)];
    [self.collision addBoundaryWithIdentifier:@"right" fromPoint:CGPointMake(self.SCREEN_WIDTH, 0) toPoint:CGPointMake(self.SCREEN_WIDTH, self.SCREEN_HEIGHT)];
    self.collision.collisionDelegate = self;
    [self.collision addItem:self.player];

    self.playerItemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.playerItemBehavior.resistance = 0;
    [self.playerItemBehavior addItem:self.player];

    self.brickItemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.brickItemBehavior.resistance = 0;
    self.brickItemBehavior.density = 1e9;

    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collision];
    [self.animator addBehavior:self.brickItemBehavior];

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(generateBricks) userInfo:nil repeats:YES];
    [timer fire];
}

#pragma mark - UICollisionBehaviorDelegate methods

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    UIView *view = (UIView *) item;
    NSString *boundary = (NSString *) identifier;

    if (view == self.player) {
        NSLog(@"You collided with %@", boundary);

        if ([boundary isEqualToString:@"top"]) {
            [self.gravity removeItem:view];
            [self.collision removeItem:view];
            [view removeFromSuperview];
        }
    } else {
        if ([boundary isEqualToString:@"top"]) {
            [self.brickItemBehavior removeItem:view];
            [self.collision removeItem:view];
            [view removeFromSuperview];
        }
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    UIView *view1 = (UIView *) item1;
    UIView *view2 = (UIView *) item2;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Stop velocity and add velocity in the appropriate direction
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Stop velocity
}

#pragma mark - Private methods

- (NSArray *)randomBooleans:(int)length {
    NSMutableArray *booleans = [NSMutableArray array];

    for (int i = 0; i < length; i++) {
        [booleans addObject:@(arc4random_uniform(2) == 0)];
    }

    return booleans;
}

- (NSArray *)randomBricks:(int)length {
    NSArray *bricks;
    int numBricks;

    do {
        bricks = [self randomBooleans:length];
        numBricks = 0;

        for (NSNumber *brick in bricks) {
            if ([brick boolValue]) {
                numBricks++;
            }
        }
    } while (numBricks < MIN_BRICKS || numBricks > MAX_BRICKS);

    return bricks;
}

- (void)generateBricks {
    CGFloat y = self.SCREEN_HEIGHT - self.BRICK_HEIGHT;
    NSArray *bricks = [self randomBricks:BRICK_SLOTS];

    for (int i = 0; i < BRICK_SLOTS; i++) {
        if ([bricks[i] boolValue]) {
            UIImageView *brick = [[UIImageView alloc] init];
            brick.frame = CGRectMake(self.SCREEN_WIDTH * i / BRICK_SLOTS, y, self.BRICK_WIDTH, self.BRICK_HEIGHT);
            brick.image = self.brickImage;
            [self.view addSubview:brick];
            [self.collision addItem:brick];
            [self.brickItemBehavior addItem:brick];
            [self.brickItemBehavior addLinearVelocity:CGPointMake(0, -BRICK_VELOCITY) forItem:brick];
        }
    }
}

@end
