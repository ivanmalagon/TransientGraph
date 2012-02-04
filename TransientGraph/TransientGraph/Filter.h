//
//  Filter.h
//  TransientGraph
//
//  Based in AccelerometerFilter in Apple's AccelerometerGraph example.
//  I've only implemented high-pass filtering since I'm only interested
//  in transients

#import <Foundation/Foundation.h>


@interface Filter : NSObject
{
    UIAccelerationValue x, y, z;
    UIAccelerationValue lastX, lastY, lastZ;
    double filterConstant;
}

-(void)addAcceleration:(UIAcceleration*)accel;
-(id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

@property(nonatomic, readonly) UIAccelerationValue x;
@property(nonatomic, readonly) UIAccelerationValue y;
@property(nonatomic, readonly) UIAccelerationValue z;

@end