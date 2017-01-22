//
//  ViewController.m
//  GesturePassWordDemo
//
//  Created by 高磊 on 2017/1/20.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"


/**
 *  颜色16进制
 */
#define UICOLOR_FROM_RGB_OxFF(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UICOLOR_FROM_RGB_OxFF_ALPHA(rgbValue,al)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//按钮的数量
static NSInteger const kPassWordNumber = 9;
//列数
static NSInteger const kVerticalNumber = 3;
//行数
static NSInteger const kHorizontalNumber = 3;
//按钮宽高
static CGFloat const kBtnWidth = 32.0;

static NSInteger const kTag = 10000;

@interface ViewController ()

//初始化的按钮
@property (nonatomic,strong) NSMutableArray *nomalPasswords;
//手势描绘的按钮数组
@property (nonatomic,strong) NSMutableArray *addPasswords;
//移动过程中的路径
@property (nonatomic,assign) CGPoint endPoint;
//密码正确或者常规绘画时的颜色
@property (nonatomic,strong) UIColor *rightLineColor;
//密码错误时的颜色
@property (nonatomic,strong) UIColor *errorLineColor;
//画线用的view
@property (nonatomic,strong) UIImageView *drawLineImageView;
//是否手势完成
@property (nonatomic,assign) BOOL drawPasswordOver;
//提示
@property (nonatomic,strong) UILabel *tipsLable;

@property (nonatomic,strong) UISwitch *pSwitch;

//默认密码或者设置后的密码
@property (nonatomic,copy) NSString *passWord;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.nomalPasswords = [[NSMutableArray alloc] initWithCapacity:kPassWordNumber];
        
        self.drawPasswordOver = NO;
        
        self.passWord = @"12589";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.drawLineImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_drawLineImageView];
    
    [self.view addSubview:self.tipsLable];
    [self.view addSubview:self.pSwitch];
    
    //第一个按钮的x坐标 / 按钮列向间的距离 4.0为 kVerticalNumber + 1
    CGFloat kBtnX = (kScreenWidth - (kVerticalNumber * kBtnWidth)) / 4.0;
    
    //按钮横向间的间距
    CGFloat kBtnPading_Y = kBtnX + 20 + kBtnWidth;

    //此处将九宫格列为 3 * 3的格式
    for (int i = 0; i < kHorizontalNumber; i ++)
    {
        for (int j = 0; j < kVerticalNumber; j ++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            //三种状态 分别代表默认 错误 和密码正确的时候（或者是在滑动过程中）
            [btn setImage:[UIImage imageNamed:@"password_nomal"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"password_error"] forState:UIControlStateSelected];
            [btn setImage:[UIImage imageNamed:@"password_hight"] forState:UIControlStateHighlighted];
            //屏蔽触控事件 view 的touch事件才能接收
            btn.userInteractionEnabled = NO;
            btn.tag = kTag + i * kVerticalNumber + j + 1;
            
            [self.view addSubview:btn];
            
            [btn setFrame:CGRectMake(kBtnX *(j + 1) + j * kBtnWidth, kScreenHeight/4.0 + kBtnPading_Y * i, kBtnWidth, kBtnWidth)];
            
            [self.nomalPasswords addObject:btn];
        }
    }
}



#pragma mark == touch 事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.drawPasswordOver)
    {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    if (touch)
    {
        for (UIButton *button in self.nomalPasswords)
        {
            CGPoint point = [touch locationInView:button];
            //判断当前点击的点是否在button 的view范围内
            if ([button pointInside:point withEvent:event])
            {
                
                //此处设置画线的终点 是为了保证在点击按钮不动的时候 因为终点坐标初始为（0,0）所以线就到左上角去了
                if (self.endPoint.x ==0 && self.endPoint.y ==0)
                {
                    self.endPoint = button.center;
                }
                
                [self.addPasswords addObject:button];
        
                button.highlighted = YES;
                
                break;
            }
        }
    }
    
    self.drawLineImageView.image = [self imageWithColor:self.rightLineColor];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.drawPasswordOver)
    {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    if (touch)
    {
        //移动过程中不断的几率当前的坐标
        self.endPoint = [touch locationInView:self.drawLineImageView];
        
        for (UIButton *button in self.nomalPasswords)
        {
            CGPoint point = [touch locationInView:button];
            if ([button pointInside:point withEvent:event])
            {
                //判断该按钮是否已经被手势划过
                BOOL haveAdd = NO;
                
                for (UIButton *btn in self.addPasswords)
                {
                    if (button == btn)
                    {
                        haveAdd = YES;
                        break;
                    }
                }

                if (!haveAdd)
                {
                    [self.addPasswords addObject:button];
                    
                    button.highlighted = YES;
                    
                    break;
                }
            }
        }
    }
    
    self.drawLineImageView.image = [self imageWithColor:self.rightLineColor];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.drawPasswordOver)
    {
        return;
    }

    UITouch *touch = [touches anyObject];
    
    if (touch)
    {
        if (self.addPasswords.count == 0)
        {
            return;
        }
        else{
            
            //手势移动结束的时候 将最后一个按钮的中心设为终点坐标
            UIButton *btn = [self.addPasswords lastObject];
            
            self.endPoint = btn.center;
        }
    }
    
    self.drawLineImageView.image = [self imageWithColor:self.rightLineColor];
    
    self.drawPasswordOver = YES;
    
    //验证密码
    if (!self.pSwitch.isOn)
    {
        [self validatePassword];
    }
    //设置密码
    else
    {
        if (self.passWord.length == 0)
        {
            self.passWord = [self getPassword];
            
            [self cleanPassword];
        }
        else
        {
            NSString *nextPassword = [self getPassword];
            
            if (![self.passWord isEqualToString:nextPassword])
            {
                [self errorPasswordTip];
            }
            else
            {
                //下一步操作
                
                TestViewController *testVc = [[TestViewController alloc] init];
                [self.navigationController pushViewController:testVc animated:YES];
            }
        }
    }
}

//开关控制
- (void)switchClick:(UISwitch *)pswitch
{
    if (pswitch.isOn)
    {
        _tipsLable.text = @"设置密码";
        
        self.passWord = @"";
    }
    else
    {
        _tipsLable.text = @"验证密码";
        
        self.passWord = @"12589";
    }
    
    [self cleanPassword];
}

#pragma mark == private method
//根据颜色绘制图片
- (UIImage *)imageWithColor:(UIColor *)color{
    UIImage *image = nil;
    
    if (self.addPasswords.count > 0)
    {
        UIButton * startButton = self.addPasswords[0];
    
        UIGraphicsBeginImageContext(self.drawLineImageView.bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, 5);
        
        CGContextMoveToPoint(context, startButton.center.x, startButton.center.y);
        
        for (UIButton *button in self.addPasswords)
        {
            CGPoint point = button.center;
            CGContextAddLineToPoint(context, point.x, point.y);
            CGContextMoveToPoint(context, point.x, point.y);
        }
        
        CGContextAddLineToPoint(context, self.endPoint.x, self.endPoint.y);
        
        CGContextStrokePath(context);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return nil;
}


- (NSString *)getPassword
{
    NSString *resultPassword = @"";
    
    for (UIButton *btn in self.addPasswords)
    {
        resultPassword = [NSString stringWithFormat:@"%@%ld",resultPassword,btn.tag - kTag];
    }
    return resultPassword;
}

    //清除信息
- (void)cleanPassword
{
    for (UIButton *btn in self.addPasswords)
    {
        btn.selected = NO;
        btn.highlighted = NO;
    }
    
    self.drawLineImageView.image = nil;
    self.drawPasswordOver = NO;
    [self.addPasswords removeAllObjects];
    self.endPoint = CGPointZero;
}

//验证密码是否正确
- (void)validatePassword
{
    NSString *password = [self getPassword];
    if (![self.passWord isEqualToString:password])
    {
        for (UIButton *btn in self.addPasswords)
        {
            btn.selected = YES;
            btn.highlighted = NO;
        }
        self.drawLineImageView.image = [self imageWithColor:self.errorLineColor];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"密码错误，请重新输入" preferredStyle:UIAlertControllerStyleAlert];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [self cleanPassword];
            
        }];
        
        // Add the actions.
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        //其他操作
        TestViewController *testVc = [[TestViewController alloc] init];
        [self.navigationController pushViewController:testVc animated:YES];
    }
}

//两次密码错误提示
- (void)errorPasswordTip
{
    for (UIButton *btn in self.addPasswords)
    {
        btn.selected = YES;
        btn.highlighted = NO;
    }
    self.drawLineImageView.image = [self imageWithColor:self.errorLineColor];
    
    self.passWord = @"";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"两次密码不一致，请重新输入" preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self cleanPassword];
        
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark == 懒加载
- (void)setPassWord:(NSString *)passWord
{
    if (_passWord != passWord)
    {
        _passWord = [passWord copy];
    }
}

- (NSMutableArray *)nomalPasswords
{
    if (nil == _nomalPasswords)
    {
        _nomalPasswords = [[NSMutableArray alloc] init];
    }
    return _nomalPasswords;
}

- (NSMutableArray *)addPasswords
{
    if (nil == _addPasswords)
    {
        _addPasswords = [[NSMutableArray alloc] init];
    }
    return _addPasswords;
}

- (UIImageView *)drawLineImageView
{
    if (nil == _drawLineImageView)
    {
        _drawLineImageView = [[UIImageView alloc] init];
    }
    return _drawLineImageView;
}

- (UILabel *)tipsLable
{
    if (nil == _tipsLable)
    {
        _tipsLable = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 60 - 100, 70, 100, 30)];
        _tipsLable.text = @"验证密码";
    }
    return _tipsLable;
}

- (UISwitch *)pSwitch
{
    if (nil == _pSwitch)
    {
        _pSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 70, 50, 30)];
        [_pSwitch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _pSwitch;
}

- (UIColor *)rightLineColor
{
    if (nil == _rightLineColor)
    {
        _rightLineColor = UICOLOR_FROM_RGB_OxFF(0x56abe4);
    }
    return _rightLineColor;
}

- (UIColor *)errorLineColor
{
    if (nil == _errorLineColor)
    {
        _errorLineColor = UICOLOR_FROM_RGB_OxFF(0xeb4f38);
    }
    return _errorLineColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
