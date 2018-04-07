//
//  DeliveryAddressViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/28.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "HttpManager.h"
#import "Address.h"
#import "DeliveryAddressCell.h"
#import "DeliveryAddressSettingViewController.h"

@interface DeliveryAddressViewController : CustomViewController<HttpDelegate, UITableViewDelegate, UITableViewDataSource,  DeliveryAddressCellDelegate>
@property(nonatomic, strong) NSMutableArray *addressArray;
@property (weak, nonatomic) IBOutlet UITableView *addressTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressTableViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AddressButtonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AddressTableViewBottom;

- (IBAction)addBtnClicked:(id)sender;
@end
