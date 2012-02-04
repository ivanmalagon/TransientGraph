//
//  LineChart.m
//  ViewTut

#import "LineChart.h"

@interface LineChart()

- (void)initialSteps;

@end

@implementation LineChart

@synthesize Values = _values;

int const XCoord = 0;
int const YCoord = 1;
int const ZCoord = 2;



#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialSteps];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialSteps];
    }
    return self;
}

- (void)handlePinch:(UIGestureRecognizer*)sender
{
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    UIGestureRecognizerState state = [(UIPinchGestureRecognizer*)sender state];
    
    if (state == UIGestureRecognizerStateBegan)
        lastScale = 1.0;
    
    double scale = 1.0 + (factor - lastScale);
    lastScale = factor;
    
    double currentWidth = rightTime - leftTime;
    double newWidth = currentWidth / scale;
    
    double diff = (currentWidth - newWidth) / 2.0;
    
    if (leftTime <= 0.0)
    {
        leftTime = 0.0;
        rightTime = leftTime + newWidth;
        
    }
    else if (rightTime >= wholeTime)
    {
        leftTime = wholeTime - newWidth;
        rightTime = wholeTime;
    }
    else
    {
        leftTime += diff;
        rightTime = leftTime + newWidth;
    }
    
    
    if ((rightTime - leftTime) >= wholeTime)
    {
        rightTime = wholeTime;
        leftTime = 0.0;
    }
    
    [self setNeedsDisplay];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint translate = [sender translationInView:self];
    UIGestureRecognizerState state = [(UIPinchGestureRecognizer*)sender state];
    
    if (state == UIGestureRecognizerStateBegan)
        lastPan = 0.0f;
    
    double traslation = translate.x - lastPan;
    lastPan = translate.x;
    
    // Translation is in points. Let's convert it to seconds
    
    double secs = -(((rightTime - leftTime) * traslation) / chartWidth);
    
    BOOL move = YES;
    if (secs > 0)
    {
        if ((rightTime + secs) >= wholeTime)
        {
            secs = wholeTime - rightTime;
            rightTime = wholeTime;
            leftTime += secs;
            move = NO;
        }
    }
    else
    {
        if ((leftTime + secs) <= 0.0)
        {
            secs = leftTime;
            leftTime = 0.0;
            rightTime -= secs;
            move = NO;
        }
    }
    
    if (move)
    {
        leftTime += secs;
        rightTime += secs;
    }
    
    [self setNeedsDisplay];
}

- (void)createGestureRecognizers
{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinch];
    [pinch release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
    [panGesture release];
}



// For initializing members
- (void)initialSteps
{
    _values = nil;
    drawX = YES;
    drawY = YES;
    drawZ = YES;
    xColor = [[UIColor colorWithRed:0.87f green:0.08f blue:0.0f alpha:0.8f] retain];
    yColor = [[UIColor colorWithRed:154.0f/255.0f green:163.0f/255.0f blue:31.0f/255.0f alpha:0.8f] retain];
    zColor = [[UIColor colorWithRed:15.0f/255.0f green:121.0f/255.0f blue:145.0f/255.0f alpha:0.8f] retain];
    xOffset = 16.0f;
    yOffset = 20.0f;
    chartWidth = self.bounds.size.width - xOffset;
    chartHeight = self.bounds.size.height - yOffset;
    lastScale = 1.0;
    lastPan = 1.0;
    topValue = 2.0;
    bottomValue = -2.0;
    transformedValues = [[NSMutableArray alloc] initWithObjects: nil];
    
    [self createGestureRecognizers];
    [self setNeedsDisplay];
}

- (void)addValues:(NSMutableArray*)newValues
{
    _values = newValues;
    
    // Get the last timestamp value
    if ([_values count] > 0)
    {
        NSArray *lastCoord = [_values objectAtIndex:([_values count] - 1)];
        rightTime = [(NSNumber*)[lastCoord objectAtIndex:3] doubleValue];
    }
    else
        rightTime = 0.0;
    
    leftTime = 0.0;
    wholeTime = rightTime;
    lastScale = 1.0;
}

- (UIColor*)getColor:(int)coordinate
{
    if (coordinate == XCoord)
        return xColor;
    else if (coordinate == YCoord)
        return yColor;
    else if (coordinate == ZCoord)
        return zColor;
    else
        return [UIColor blackColor];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float w, h, keyFontHeight, miniFontHeight, unitHeight;
    
    w = rect.size.width;
    h = rect.size.height;
    
    keyFontHeight = 12.0f;
    miniFontHeight = 9.0f;
    unitHeight = chartHeight * 0.25f;
    
    // Horizontal lines positions
    float hlp[] = { h - 0.5f, yOffset + chartHeight * 0.75f - 0.5f, yOffset + chartHeight * 0.25f - 0.5f, yOffset};
    
    
    CGRect bounds = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform accTransform;
    CGContextSelectFont(context, "Helvetica Neue", keyFontHeight, kCGEncodingMacRoman);
    
    // Turn the coordinates upside-down. Mandatory when drawing text.
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    // First, we draw the text invisible for measuring its size
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowTextAtPoint(context, 0.0f, 0.0f, "seconds", 7);
    CGPoint end = CGContextGetTextPosition(context);
    float secKeyWidth = end.x;
    
    // Preparing for drawing real text
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    
    // Center the text and draw it
    CGPoint secKeyOrigin = CGPointMake(xOffset + ((chartWidth - secKeyWidth) / 2.0f), 0.0f);
    CGContextShowTextAtPoint(context, secKeyOrigin.x, secKeyOrigin.y, "seconds", 7);
    
    // Trace text
    NSString *combinedString = [NSString stringWithFormat: @"%c : %c", (leftTime > 0.0) ? @"<" : @"|", (rightTime < wholeTime) ? ">" : "|"];
    char *cadena = (char*)[combinedString UTF8String];
    
    CGContextShowTextAtPoint(context, 0.0, 0.0, cadena, strlen(cadena));
    
    // Horizontal lines text
    CGContextSelectFont(context, "Helvetica Neue", miniFontHeight, kCGEncodingMacRoman);
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.5f);
    CGContextShowTextAtPoint(context, xOffset, hlp[0] - miniFontHeight, "2", 1);
    CGContextShowTextAtPoint(context, xOffset, hlp[1] - miniFontHeight, "1", 1);
    CGContextShowTextAtPoint(context, xOffset, hlp[2] + 2.0f, "-1", 2);
    CGContextShowTextAtPoint(context, xOffset, hlp[3] + 2.0f, "-2", 2);
    
    
    
    CGContextSelectFont(context, "Helvetica Neue", keyFontHeight, kCGEncodingMacRoman);
    // Measure text
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowTextAtPoint(context, 0.0f, 0.0f, "accelerometer", 13);
    end = CGContextGetTextPosition(context);
    
    float accelKeyWidth = end.x;
    
    // Preparing for drawing real text
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    
    // I'll write the text rotated for the accelerometer key
    accTransform = CGAffineTransformMakeRotation(M_PI_2); // 90 degrees.
    CGContextSetTextMatrix(context, accTransform);
    
    // Center the text
    CGPoint accelKeyOrigin = CGPointMake(keyFontHeight, yOffset + ((chartHeight - accelKeyWidth) / 2.0f));
    CGContextShowTextAtPoint(context, accelKeyOrigin.x, accelKeyOrigin.y, "accelerometer", 13);
    
    // Now we'll draw the horizontal lines
    //CGContextSetShouldAntialias(context, NO);
    
    // Center line
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0f);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, xOffset, yOffset + chartHeight / 2.0f);
    CGContextAddLineToPoint(context, w, yOffset + chartHeight / 2.0f);
    CGContextStrokePath(context);
    
    // +2 line
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    float dashes[] = { 2.0f, 2.0f };
    CGContextSetLineDash(context, 0.0f, dashes, sizeof(dashes) / sizeof(float));
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, xOffset, h - 0.5f);
    CGContextAddLineToPoint(context, w, h -0.5f);
    CGContextStrokePath(context);    
    
    // +1 line
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, xOffset, yOffset + chartHeight * 0.75f - 0.5f);
    CGContextAddLineToPoint(context, w, yOffset + chartHeight * 0.75f - 0.5f);
    CGContextStrokePath(context); 
    
    // -1 line
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, xOffset, yOffset + chartHeight * 0.25f - 0.5f);
    CGContextAddLineToPoint(context, w, yOffset + chartHeight * 0.25f - 0.5f);
    CGContextStrokePath(context);
    
    // - 2 line
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, xOffset, yOffset - 0.5f);
    CGContextAddLineToPoint(context, w, yOffset - 0.5f);
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0.0f, NULL, 0);
    
    // Draw value lines
    if (_values != nil)
    {
        [self transformValues];
        
        for (int j = 0; j < 3; j++)
        {
            int arrayCount = [transformedValues count];
            
            bool doTheDo = YES;
            
            if ((j == 0) && !drawX)
                doTheDo = NO;
            else if ((j == 1) && !drawY)
                doTheDo = NO;
            else if ((j == 2) && !drawZ)
                doTheDo = NO;
            
            if (doTheDo)
            {
                CGContextSetStrokeColorWithColor(context, [self getColor:j].CGColor);
                
                CGContextSetLineWidth(context, 2.0f);
                CGContextBeginPath(context);
                //CGContextMoveToPoint(context, 0.0f, yOffset + chartHeight / 2.0f);
                
                float y = 0.0f;
                float x = 0.0f;
                
                for (int i = 0; i < arrayCount; i++)
                {
                    NSNumber* number = nil;
                    NSArray* coords = [transformedValues objectAtIndex:i];
                    
                    number = [coords objectAtIndex:j];
                    y = [number floatValue];
                    number = [coords objectAtIndex:3];
                    x = [number floatValue];
                    
                    if (i == 0)
                        CGContextMoveToPoint(context, x, y);
                    else
                        CGContextAddLineToPoint(context, x, y);
                    
                }
                CGContextStrokePath(context);
            }
        }
    }
}

- (void)transformValues
{
    double realWidth = rightTime - leftTime;
    double realHeight = topValue - bottomValue;
    double timeScale = chartWidth / realWidth;
    double valueScale = chartHeight / realHeight;
    double origin = yOffset + (chartHeight / 2.0);
    double temp = 0.0;
    
    // Reset previously transformed values
    [transformedValues removeAllObjects];
    
    int numValues = 0;
    numValues = [_values count];
    
    for (int i = 0; i < numValues; i++)
    {
        NSNumber *numberForX = nil;
        NSNumber *numberForY = nil;
        NSNumber *numberForZ = nil;
        NSNumber *numberForTime = nil;
        NSNumber *number = nil;
        NSArray *coords = [_values objectAtIndex:i];
        
        // Time
        number = [coords objectAtIndex:3];
        temp = [number doubleValue];
        temp -= leftTime;
        temp *= timeScale;
        temp += xOffset;
        numberForTime = [NSNumber numberWithDouble:temp];
        [numberForTime retain];
        
        // X
        number = [coords objectAtIndex:0];
        temp = [number doubleValue];
        temp *= valueScale;
        temp += origin;
        numberForX = [NSNumber numberWithDouble:temp];
        [numberForX retain];
        
        // Y
        number = [coords objectAtIndex:1];
        temp = [number doubleValue];
        temp *= valueScale;
        temp += origin;
        numberForY = [NSNumber numberWithDouble:temp];
        [numberForY retain];
        
        // Z
        number = [coords objectAtIndex:2];
        temp = [number doubleValue];
        temp *= valueScale;
        temp += origin;
        numberForZ = [NSNumber numberWithDouble:temp];
        [numberForZ retain];
        
        // Create copied item
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:numberForX, numberForY, numberForZ, numberForTime, nil];
        [transformedValues addObject:array];
        
        
        
    }
    
}

- (void)draw
{
    [self setNeedsDisplay];
}

- (void)setVisibleX:(BOOL)x andY:(BOOL)y andZ:(BOOL)z
{
    drawX = x;
    drawY = y;
    drawZ = z;
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [xColor release];
    [yColor release];
    [zColor release];
    [super dealloc];
}

@end
