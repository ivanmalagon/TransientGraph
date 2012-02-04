//
//  Filter.m
//  ViewTut

#import "Filter.h"


@implementation Filter

@synthesize x, y, z;

-(void)addAcceleration:(UIAcceleration*)accel
{
	double alpha = filterConstant;
	
	x = alpha * (x + accel.x - lastX);
	y = alpha * (y + accel.y - lastY);
	z = alpha * (z + accel.z - lastZ);
       
	lastX = accel.x;
	lastY = accel.y;
	lastZ = accel.z;
}

double Norm(double x, double y, double z)
{
	return sqrt(x * x + y * y + z * z);
}

double Clamp(double v, double min, double max)
{
	if(v > max)
		return max;
	else if(v < min)
		return min;
	else
		return v;
}

-(id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	self = [super init];
	if(self != nil)
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = RC / (dt + RC);
	}
	return self;
}



@end
