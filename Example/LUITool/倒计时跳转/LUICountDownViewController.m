//
//  LUICountDownViewController.m
//  WAIT
//
//  Created by 六月 on 2022/4/24.
//

#import "LUICountDownViewController.h"

@interface LUICountDownViewController ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) NSInteger countDown;
@property(nonatomic,strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUICountDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [UIApplication sharedApplication].idleTimerDisabled = YES;//屏幕常亮
    
    UIButton *testUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testUrlButton.frame = CGRectMake((WIDTH - 100) / 2, (HEIGHT / 4) - 30, 100, 30);
    testUrlButton.layer.borderWidth = 1;
    testUrlButton.layer.borderColor = UIColor.whiteColor.CGColor;
    testUrlButton.layer.cornerRadius = 4;
    [testUrlButton setTitle:@"测试跳转" forState:UIControlStateNormal];
    testUrlButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [testUrlButton addTarget:self action:@selector(testUrlDDing) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testUrlButton];
    
    [self.view addSubview:self.timeLabel];
}

- (void)testUrlDDing {
    NSString *schemeUrlStr = ODDingTalkScheme;
    NSURL *schemeUrl = [NSURL URLWithString:schemeUrlStr];
    if ([[UIApplication sharedApplication] canOpenURL:schemeUrl]) {
        [[UIApplication sharedApplication] openURL:schemeUrl options:@{} completionHandler:^(BOOL success) {
                                    
        }];
    }
}

- (void)timeCountDown {
    if (self.countDown == 0) {
        self.countDown = arc4random() % 1191 + 10;
        dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);

        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(timer, ^{
            if (self.countDown == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    strongSelf.timeLabel.text = @"0";
                    [strongSelf testUrlDDing];
                });
                dispatch_source_cancel(timer);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    strongSelf.timeLabel.text = [NSString stringWithFormat:@"%ld", (long)self.countDown];
                    self.countDown --;
                });
            }
        });
        dispatch_resume(timer);
    }
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont boldSystemFontOfSize:30];
        _timeLabel.textColor = UIColor.whiteColor;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.frame = CGRectMake((WIDTH - 100) / 2, (HEIGHT - 100) / 2, 100, 100);
    }
    return _timeLabel;
}


@end
