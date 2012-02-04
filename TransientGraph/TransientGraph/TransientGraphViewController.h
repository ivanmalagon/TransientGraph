//
//  TransientGraphViewController.h
//  TransientGraph

#import <UIKit/UIKit.h>
#import "LineChart.h"
#import "Accel.h"

typedef enum
{
    Record,
    Stop
} ButtonRole;

@interface TransientGraphViewController : UIViewController {
    UIButton* xButton;
    UIButton* yButton;
    UIButton* zButton;
    UIButton* actionButton;
    LineChart* lineChart;
    BOOL xLit;
    BOOL yLit;
    BOOL zLit;
    Accel *accel;
    ButtonRole buttonRole;
    
}

@property (nonatomic, retain) IBOutlet UIButton* xButton;
@property (nonatomic, retain) IBOutlet UIButton* yButton;
@property (nonatomic, retain) IBOutlet UIButton* zButton;
@property (nonatomic, retain) IBOutlet UIButton* actionButton;
@property (nonatomic, retain) IBOutlet LineChart* lineChart;

- (IBAction) buttonClicked:(id)sender;
- (IBAction) actionClicked:(id)sender;
- (void) play:(id)sender;
- (void) stop:(id)sender;
- (void)refreshButton:(UIButton*)button;

@end
