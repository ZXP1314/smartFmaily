//
//  IPadMenuController.m
//  SmartHome
//
//  Created by Brustar on 2017/5/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IPadMenuController.h"
#import "SQLManager.h"
#import "LeftMenuCell.h"
#import "LightController.h"
#import "Device.h"

@interface IPadMenuController ()

@end

static NSString *const leftMenuCell = @"leftMenuCell";

@implementation IPadMenuController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.typeID != light) {
        Device *device = [self.types objectAtIndex:0];
        [[DeviceInfo defaultManager] setRoomID:self.roomID];
        [self showDetailViewController:[DeviceInfo calcController:device.hTypeId] sender:self];
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }else{
        NSArray *ts = [self lights];
        NSMutableArray *temp = [NSMutableArray new];
        if (ts.count >0) {
            [temp addObjectsFromArray:ts];
        }
        Device *device = nil;
        if (temp.count >0) {
            device = temp[0];
        }
        
        long UITypeOfLight = 0;
        if ([device.typeName isEqualToString:@"射灯"]) {
            UITypeOfLight = 1;
        }else if ([device.typeName isEqualToString:@"灯带"]) {
            UITypeOfLight = 2;
        }else if ([device.typeName isEqualToString:@"调色灯"]) {
            UITypeOfLight = 3;
        }
        
        NSArray *arr = [SQLManager devicesWithCatalogID:UITypeOfLight room:self.roomID];
        for (id obj in arr) {
            [temp insertObject:obj atIndex:1];
        }
        self.types = temp;
        //[self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.s
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-frm_left_nol"]]];
    if (self.typeID == light) {
        self.types = [self lights];
    }else{
        self.types = [SQLManager typeName:self.typeID byRoom:self.roomID];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor blackColor];
    
    UINib *cellNib = [UINib nibWithNibName:@"LeftMenuCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:leftMenuCell];
}

-(NSArray *)lights
{
    NSMutableArray *types = [[NSMutableArray alloc] init];
    //NSArray *uitypes=@[@"射灯",@"灯带",@"调色灯"];
    
    NSMutableArray *uitypes = [NSMutableArray new];
    [uitypes addObjectsFromArray:[SQLManager getUITypeOfLightByRoomID:self.roomID]];
    
    int i = 0;
    for (NSString *name in uitypes) {
        Device *d = [Device new];
        d.typeName = name;
        d.hTypeId = ++i;
        d.rID = d.hTypeId;
        
        [types addObject:d];
    }
    return types;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *temp = [NSMutableArray new];
    
    NSArray *ts;
    if (self.typeID == light) {
        ts = [self lights];
    }else{
        ts = [SQLManager typeName:self.typeID byRoom:self.roomID];
    }
    Device *device = [self.types objectAtIndex:indexPath.row];
    
    if (device.hTypeId >0 && device.hTypeId<10) {
        [temp addObjectsFromArray:ts];
        
        long UITypeOfLight = 0;
        if ([device.typeName isEqualToString:@"射灯"]) {
            UITypeOfLight = 1;
        }else if ([device.typeName isEqualToString:@"灯带"]) {
            UITypeOfLight = 2;
        }else if ([device.typeName isEqualToString:@"调色灯"]) {
            UITypeOfLight = 3;
        }
        NSArray *arr = [SQLManager devicesWithCatalogID:UITypeOfLight room:self.roomID];
        for (id obj in arr) {
            [temp insertObject:obj atIndex:device.rID];
        }
        self.types = temp;
        [self.tableView reloadData];
    }else if(device.hTypeId>=10){
        //多媒体或智能单品
        [[DeviceInfo defaultManager] setRoomID:self.roomID];
        [[DeviceInfo defaultManager] setDeviceType:(int)device.hTypeId];
        [self showDetailViewController:[DeviceInfo calcController:device.hTypeId] sender:self];
    }
    
    if (device.eID>0) {
        //split delegate
        LightController *control = (LightController *)[DeviceInfo calcController:light];
        control.deviceid = [NSString stringWithFormat:@"%d", device.eID];
        
        [self showDetailViewController:control sender:self];
        [control visibleUI:device];
    }
}

//设置表头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 64.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.types.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:leftMenuCell forIndexPath:indexPath];
    
    Device *device = [self.types objectAtIndex:indexPath.row];
    cell.lbl.text = device.typeName?device.typeName:device.name;
    if (device.typeName) {
        cell.lbl.textColor = [UIColor whiteColor];
        cell.cellBG.image = [UIImage imageNamed:@"left_menu_normal"];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_nol"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_prd"]];
    }else{
        cell.lbl.textColor = [UIColor grayColor];
        cell.cellBG.image = [UIImage imageNamed:@"left_sub_normal"];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_nol"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_prd"]];
    }
    cell.backgroundView.backgroundColor = [UIColor blackColor];
    return cell;
}

@end
