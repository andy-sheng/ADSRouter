//
//  ADSAnnotation.m
//  annotation-demo
//
//  Created by Andy on 2017/9/25.
//  Copyright © 2017年 andy. All rights reserved.
//

#import "ADSAnnotation.h"
#import "ADSRouter.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/ldsyms.h>


static char * const kSectionName = STRINGLIFY(ADS_SECTION_NAME);

NSArray<NSString *>* ADSReadConfiguration(char *sectionName,const struct mach_header *mhp);
static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide)
{
    NSArray *routers = ADSReadConfiguration(kSectionName, mhp);
    for (NSString *router in routers) {
        NSDictionary *routerInfo = [NSJSONSerialization JSONObjectWithData:[router dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        [[ADSRouter sharedRouter] registerRouteWithUrl:routerInfo[@"url"] VC:routerInfo[@"className"]];
    }
}

__attribute__((constructor))
void initProphet() {
    _dyld_register_func_for_add_image(dyld_callback);
}

NSArray<NSString *>* ADSReadConfiguration(char *sectionName,const struct mach_header *mhp)
{
    NSMutableArray *configs = [NSMutableArray array];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    
    unsigned long counter = size/sizeof(void*);
    for(int idx = 0; idx < counter; ++idx){
        char *string = (char*)memory[idx];
        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;
        
        if(str) [configs addObject:str];
    }
    
    return configs;
    
    
}

@implementation ADSAnnotation

@end
