//
//  TransientGraphViewController.m
//  TransientGraph


#import "TransientGraphViewController.h"

@implementation TransientGraphViewController

@synthesize xButton;
@synthesize yButton;
@synthesize zButton;
@synthesize actionButton;
@synthesize lineChart;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    xLit = YES;
    yLit = YES;
    zLit = YES;
    buttonRole = Record;
    
    accel = [[Accel alloc] init];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [accel release];
    accel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - My methods

- (void)refreshButton:(UIButton*)button
{
    // TO DO: create a color to rule'em all
    //        for that color, beware of memory leaks
    //        change text color
    
    if ([button tag] == 1)
    {
        if (xLit)
        {
            [button setBackgroundColor:[UIColor colorWithRed:0.87f green:0.08f blue:0.0f alpha:1.0f]];
        }
        else
            [button setBackgroundColor:[UIColor darkGrayColor]];
    }
    else if ([button tag] == 2)
    {
        if (yLit)
        {
            [button setBackgroundColor:[UIColor colorWithRed:154.0f/255.0f green:163.0f/255.0f blue:31.0f/255.0f alpha:1.0f]];
        }
        else
            [button setBackgroundColor:[UIColor darkGrayColor]];
    }
    else if ([button tag] == 3)
    {
        if (zLit)
        {
            [button setBackgroundColor:[UIColor colorWithRed:15.0f/255.0f green:121.0f/255.0f blue:145.0f/255.0f alpha:1.0f]];
        }
        else
            [button setBackgroundColor:[UIColor darkGrayColor]];
    }
    
    
    [button setNeedsDisplay];
    [lineChart setVisibleX:xLit andY:yLit andZ:zLit];
    
    
}


#pragma mark - Actions

- (IBAction) buttonClicked:(id)sender
{
    // Perhaps this could be better, using an array and treating all buttons equal but I feel kind of lazy tonight
    if ([sender tag] == 1)
    {
        xLit = !xLit;
        [self refreshButton:self.xButton];
    }
    else if ([sender tag] == 2)
    {
        yLit = !yLit;
        [self refreshButton:self.yButton];
    }
    else if ([sender tag] == 3)
    {
        zLit = !zLit;
        [self refreshButton:self.zButton];
    }
}

- (IBAction) actionClicked:(id)sender
{
    if (buttonRole == Record)
        [self play:0];
    else
        [self stop:0];

}

- (void) play:(id)sender
{
    [accel play];
    buttonRole = Stop;
    [actionButton setBackgroundColor:[UIColor blackColor]];
    [actionButton setTitle:@"STOP" forState:UIControlStateNormal]; // Hammer time!
}

- (void) stop:(id)sender
{
    [accel stop];
    [lineChart addValues:accel.Values];
    [lineChart draw];
    buttonRole = Record;
    [actionButton setBackgroundColor:[UIColor colorWithRed:0.87f green:0.08f blue:0.0f alpha:1.0f]];
    [actionButton setTitle:@"RECORD" forState:UIControlStateNormal]; // Hammer time!
}

@end
