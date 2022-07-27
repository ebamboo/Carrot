//
//  BrowserTestOCViewController.m
//  Carrot
//
//  Created by ebamboo on 2022/7/25.
//

#import "BrowserTestOCViewController.h"
#import "Carrot-Swift.h"

@interface BrowserTestOCViewController ()

@property (nonatomic, retain) NSArray *itemList;

@end

@implementation BrowserTestOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Browser OC";
    
    NSMutableArray *tempList = [NSMutableArray array];
    
    for (NSString *name in @[@"pingfen-yes", @"01", @"02", @"03"]) {
        OCMediaBrowserItemModel *model = [OCMediaBrowserItemModel new];
        model.image = [UIImage imageNamed:name];
        [tempList addObject:model];
    }
    
    for (NSString *url in @[@"http://1257982215.vod2.myqcloud.com/dcd3428cvodcq1257982215/8c6ec7b4387702293313409297/Sb2hYSuZFmEA.mp4", @"http://1257982215.vod2.myqcloud.com/dcd3428cvodcq1257982215/940cbaf7387702293313791287/xSxS1l5Uv3gA.mp4", @"http://1257982215.vod2.myqcloud.com/dcd3428cvodcq1257982215/914c35f5387702293313633992/dGevkJOtPHgA.mp4"]) {
        OCMediaBrowserItemModel *model = [OCMediaBrowserItemModel new];
        model.videoUrl = url;
        [tempList addObject:model];
    }
    
    
    for (NSString *url in @[@"https://gitee.com/ebamboo/Assets/raw/master/BBPictureBrowser/jpeg/01.jpeg", @"https://gitee.com/ebamboo/Assets/raw/master/BBPictureBrowser/gif/02.gif"]) {
        OCMediaBrowserItemModel *model = [OCMediaBrowserItemModel new];
        model.imageUrl = url;
        [tempList addObject:model];
    }
    
    _itemList = [tempList copy];
    
}

- (IBAction)testAction:(id)sender {
    
    OCMediaBrowser *browser = [OCMediaBrowser new];
    browser.oc_itemList = _itemList;
    browser.oc_onDidShowMedia = ^(NSInteger index, MediaBrowserTopBar * _Nonnull topBar, MediaBrowserBottomBar * _Nonnull bottomBar) {
        NSLog(@"index========%@", @(index));
        topBar.indexLabel.text = @"index";
        bottomBar.titleLabel.text = @"oc ok";
        bottomBar.detailLabel.text = @"哈哈哈";
    };
    [browser oc_openOn:self.navigationController.view at:2];
    
}

@end
