//
//  IOManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "Scene.h"
#import "PrintObject.h"

#define FileHashDefaultChunkSizeForReadingData 1024*8

@interface IOManager : NSObject

+ (NSString *)realScenePath;
+ (NSString *)planeScenePath;
+ (NSString *) scenesPath;
+ (NSString *)deviceTimerPath;
+ (NSString *) favoritePath;
+ (NSString *) sqlitePath;
//+ (NSString *) httpAddr;
+ (NSString *) tcpAddr;
+ (NSString *) httpsAddr;
+ (NSString *) SmartHomehttpAddr;

+ (int) tcpPort;
+ (int) C4Port;
+ (int) crestronPort;

+ (id)getUserDefaultForKey:(NSString *)key;

+ (void) writeScene:(NSString *)sceneFile string:(NSString *)sceneData;
+ (void) writeDeviceTimer:(NSString *)timerFile timer:(id)timerData;
+ (void) writeScene:(NSString *)sceneFile dictionary:(NSDictionary *)sceneData;
+ (void) writeScene:(NSString *)sceneFile scene:(id)sceneData;
+ (void) writeJpg:(UIImage *)jpg path:(NSString *)jpgPath;
+ (void) writePng:(UIImage *)png path:(NSString *)pngPath;
+ (BOOL) createTempFile;
+ (BOOL) createFile:(NSString *)filePath;
+ (void) removeFile:(NSString *)file;
+ (void) removeTempFile;
+ (void) writeUserdefault:(id)object forKey:(NSString *)key;
+ (NSString *) fileMD5:(NSString*)path;
+ (NSString *) md5JsonByScenes:(NSString *)master;
+ (NSString *)sceneShortcutsPath;
+ (NSString *)sceneNonShortcutsPath;
+ (NSString *)familyRoomStatusPath;
+ (NSString *)FirstVCPath;

@end
