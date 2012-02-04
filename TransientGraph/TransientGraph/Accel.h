//
//  NDAccel.h
//  ViewTut

#import <Foundation/Foundation.h>
#import "Filter.h"

@interface Accel : NSObject <UIAccelerometerDelegate>
{
    NSMutableArray* values;
    BOOL playing;
    Filter* filter;
    double startTime;
    double prevTime;
    double prevX;
    double prevY;
    double prevZ;
    BOOL inTransientZp;
    BOOL inTransientZm;
    BOOL inWindowZp;
    BOOL inWindowZm;
    double windowZBeginning;
}

- (void)play;
- (void)stop;

@property (nonatomic, readonly) NSMutableArray* Values;

@end