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
const int BRICK_VELOCITY = 200;
const int DOWN_VELOCITY = 400;
const int PLAYER_VELOCITY = 200;
const int BRICK_PROBABILITY = 75;
const double BRICK_GENERATION_PERIOD = 0.5;

@interface FalldownViewController () <UICollisionBehaviorDelegate>

@property (assign, nonatomic) CGFloat SCREEN_WIDTH;
@property (assign, nonatomic) CGFloat SCREEN_HEIGHT;

@property (assign, nonatomic) CGFloat BRICK_WIDTH;
@property (assign, nonatomic) CGFloat BRICK_HEIGHT;
@property (assign, nonatomic) CGFloat PLAYER_WIDTH;
@property (assign, nonatomic) CGFloat PLAYER_HEIGHT;

@property (strong, nonatomic) UIImage *playerImage;
@property (strong, nonatomic) UIImage *brickImage;

@property (strong, nonatomic) UIImageView *player;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravity;
@property (strong, nonatomic) UICollisionBehavior *collision;

@property (strong, nonatomic) UIDynamicItemBehavior *playerItemBehavior;
@property (strong, nonatomic) UIDynamicItemBehavior *brickItemBehavior;

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) NSInteger score;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

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
    self.PLAYER_HEIGHT = self.PLAYER_WIDTH * self.playerImage.size.height / self.playerImage.size.width;

    self.player = [[UIImageView alloc] initWithImage:self.playerImage];
    self.player.frame = CGRectMake(0, 1, self.PLAYER_WIDTH, self.PLAYER_HEIGHT);
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
    self.playerItemBehavior.friction = 0;
    self.playerItemBehavior.allowsRotation = NO;
    [self.playerItemBehavior addItem:self.player];
//    [self.playerItemBehavior addLinearVelocity:CGPointMake(0, DOWN_VELOCITY) forItem:self.player];

    self.brickItemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.brickItemBehavior.resistance = 0;
    self.brickItemBehavior.density = 1e9;

    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collision];
    [self.animator addBehavior:self.playerItemBehavior];
    [self.animator addBehavior:self.brickItemBehavior];

    self.score = 0;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:BRICK_GENERATION_PERIOD target:self selector:@selector(generateBricks) userInfo:nil repeats:YES];
    [self.timer fire];
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
            [self onLost];
        }
    } else {
        if ([boundary isEqualToString:@"top"]) {
            [self.brickItemBehavior removeItem:view];
            [self.collision removeItem:view];
            [view removeFromSuperview];
        }
    }
}
/*
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p {
    UIView *view1 = (UIView *) item1;
    UIView *view2 = (UIView *) item2;

    if (view1.alpha == 0 || view2.alpha == 0) {
        NSLog(@"Passed through!");
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p {
    NSLog(@"Began collision");
    CGPoint velocity = [self.playerItemBehavior linearVelocityForItem:self.player];
    [self.playerItemBehavior addLinearVelocity:CGPointMake(0, -velocity.y) forItem:self.player];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    NSLog(@"Ended collision");
    CGPoint velocity = [self.playerItemBehavior linearVelocityForItem:self.player];
    [self.playerItemBehavior addLinearVelocity:CGPointMake(0, -velocity.y + DOWN_VELOCITY) forItem:self.player];
}
*/
#pragma mark - Touch methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Stop velocity and add velocity in the appropriate direction
    CGPoint velocity = [self.playerItemBehavior linearVelocityForItem:self.player];
    velocity = CGPointMake(-velocity.x, 0);
    UITouch *touch = [touches anyObject];

    if ([touch locationInView:self.view].x < self.SCREEN_WIDTH / 2) {
        velocity.x -= PLAYER_VELOCITY;
    } else {
        velocity.x += PLAYER_VELOCITY;
    }

    [self.playerItemBehavior addLinearVelocity:velocity forItem:self.player];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Stop velocity
    CGPoint velocity = [self.playerItemBehavior linearVelocityForItem:self.player];
    velocity = CGPointMake(-velocity.x, 0);
    [self.playerItemBehavior addLinearVelocity:velocity forItem:self.player];
}

#pragma mark - Private methods

- (NSArray *)randomBooleans:(int)length {
    NSMutableArray *booleans = [NSMutableArray array];

    for (int i = 0; i < length; i++) {
        [booleans addObject:@(arc4random_uniform(100) < BRICK_PROBABILITY)];
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
            brick.frame = CGRectMake(i * self.SCREEN_WIDTH / BRICK_SLOTS, y, (i + 1) * self.SCREEN_WIDTH / BRICK_SLOTS - i * self.SCREEN_WIDTH / BRICK_SLOTS, self.BRICK_HEIGHT);
            brick.image = self.brickImage;
            [self.view addSubview:brick];
            [self.collision addItem:brick];
            [self.brickItemBehavior addItem:brick];
            [self.brickItemBehavior addLinearVelocity:CGPointMake(0, -BRICK_VELOCITY) forItem:brick];
        }
    }

    self.score++;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", self.score];
}

- (void)onLost {
    [self.timer invalidate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *highScore = [defaults objectForKey:@"highScore"];

    if (highScore == nil || self.score > [highScore integerValue]) {
        highScore = @(self.score);
        [defaults setObject:highScore forKey:@"highScore"];
    }

//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You lost!" message:[NSString stringWithFormat:@"You scored %ld points", self.score] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You lost!" message:[NSString stringWithFormat:@"Your score: %ld\nHigh score: %@", self.score, highScore] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Play again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"restartGame" object:nil];
    }];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
