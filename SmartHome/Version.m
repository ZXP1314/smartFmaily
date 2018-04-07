//
//  Version.m
//  SmartHome
//
//  Created by zhaona on 2018/2/9.
//  Copyright © 2018年 Brustar. All rights reserved.
//

#import "Version.h"

@implementation Version

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.versionStr forKey:@"versionStr"];
    [aCoder encodeObject:self.isforce forKey:@"isforce"];
    [aCoder encodeObject:self.contentsStr forKey:@"contentsStr"];
    
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super init]) {
        self.isforce = [aDecoder decodeObjectForKey:@"isforce"];
        self.versionStr = [aDecoder decodeObjectForKey:@"versionStr"];
        self.contentsStr = [aDecoder decodeObjectForKey:@"contentsStr"];
    }
    return self;
}
@end
