//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCLocalNotificationManager.h"
#import "DCEvent+DC.h"
#import "DCTime.h"
#import "DCTimeRange.h"
#import "DCCalendarManager.h"
#import "DCMainProxy.h"

@implementation DCLocalNotificationManager

static  const NSString * kEventId = @"EventID";

+ (void)scheduleNotificationWithItem:(DCEvent *)item interval:(int)minutesBefore
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];

    localNotif.fireDate = [item.startDate dateByAddingTimeInterval:-(minutesBefore * 60.f)];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    NSString *alertBody = [NSString
                           stringWithFormat:@"%@ in %i minutes.\nPlace: %@",
                           item.name,
                           minutesBefore,
                           item.place];
    
    localNotif.alertBody = alertBody;
    
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventId  forKey:kEventId];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [DCCalendarManager addEventWithItem:item];
}

+ (void)cancelLocalNotificationWithId:(NSNumber *)eventID
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *events = [app scheduledLocalNotifications];
    for (UILocalNotification *event in events) {
        if ([event.userInfo[kEventId] integerValue] == [eventID integerValue]) {
            [app cancelLocalNotification: event];
        }
    }
    NSArray* event = [[DCMainProxy sharedProxy] eventsWithIDs:@[eventID]];
    [DCCalendarManager removeEventOfItem:event.lastObject];
}

@end