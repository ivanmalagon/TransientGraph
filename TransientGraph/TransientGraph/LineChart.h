//
//  LineChart.h
//  TransientGraph

#import <UIKit/UIKit.h>


@interface LineChart : UIView {
    
    NSMutableArray *_values;
    NSMutableArray *transformedValues;
    BOOL drawX;
    BOOL drawY;
    BOOL drawZ;
    UIColor* xColor;
    UIColor* yColor;
    UIColor* zColor;
    double leftTime;
    double rightTime;
    double wholeTime;
    double topValue;
    double bottomValue;
    double xOffset;
    double yOffset;
    double chartWidth;
    double chartHeight;
    double lastScale;
    double lastPan;
    
}


- (void)draw;
- (void)addValues:(NSMutableArray*)newValues;
- (void)transformValues;
- (void)setVisibleX:(BOOL)x andY:(BOOL)y andZ:(BOOL)z;

@property (nonatomic, retain) NSMutableArray *Values;

@end