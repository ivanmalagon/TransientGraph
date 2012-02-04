//
//  Accel.m
//  ViewTut

#import "Accel.h"
#import <math.h>

// defines
#define kFrequency 60.0f
#define kWindow 0.083

@implementation Accel

@synthesize Values = values;

- (id)init {
    self = [super init];
    if (self)
    {
    	UIAccelerometer* accel = [UIAccelerometer sharedAccelerometer];
        accel.delegate = self;
        accel.updateInterval = 1.0f / kFrequency;
        
        playing = NO;
        values = [[NSMutableArray alloc] initWithObjects:nil];
        filter = [[Filter alloc] initWithSampleRate:kFrequency cutoffFrequency:5.0];
        startTime = 0;
        prevX = 0;
        prevY = 0;
        prevZ = 0;
        inTransientZp = NO;
        inTransientZm = NO;
        inWindowZp = NO;
        inWindowZm = NO;
        windowZBeginning = 0.0;
    }
    return self;
}

#pragma mark - Memory methods

- (void)releaseValues
{
    int numValues = [values count];
    
    for (int i = 0; i < numValues; i++)
    {
        NSArray *array = (NSArray*)[values objectAtIndex:i];
        int count = [array count];
        
        for (int j = 0; j < count; j++)
        {
            id obj = [array objectAtIndex:j];
            
            [obj release];
            obj = nil;
        }
        
        [array release];
        array = nil;
    }
    
    [values removeAllObjects];
}

- (void)dealloc
{
    [filter release];
    filter = nil;
    
    [self releaseValues];
    [values release];
    values = nil;
    
    
    
    
    [super dealloc];
}



#pragma mark - Class methods
- (void)play
{
    playing = YES;
    startTime = 0;
    [self releaseValues];
}

- (void)stop
{
    playing = NO;
}

#pragma mark - UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer
		didAccelerate:(UIAcceleration *)acceleration
{
    if (playing)
    {
        // Get the beginning timestamp
        if (startTime <= 0)
        {
            startTime = acceleration.timestamp;
            prevTime = acceleration.timestamp;
        }
        
        double offset = acceleration.timestamp - startTime;
        
        NSNumber *x, *y, *z, *timeStamp;
        
        [filter addAcceleration:acceleration];
        
        x = [NSNumber numberWithDouble:filter.x];
        y = [NSNumber numberWithDouble:filter.y];
        z = [NSNumber numberWithDouble:filter.z];
        timeStamp = [NSNumber numberWithDouble:offset];
        
        
        NSMutableArray *tempValues = [[NSMutableArray alloc] initWithObjects:nil];
        [tempValues addObject:x];
        [tempValues addObject:y];
        [tempValues addObject:z];
        [tempValues addObject:timeStamp];
        
        [values addObject:tempValues];
        
        prevX = filter.x;
        prevY = filter.y;
        prevZ = filter.z;
        prevTime = acceleration.timestamp;
        
        [x retain];
        [y retain];
        [z retain];
        [timeStamp retain];
    }
}



@end
