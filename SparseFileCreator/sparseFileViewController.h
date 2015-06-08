//
//  sparseFileViewController.h
//  SparseFileCreator
//
//  Created by Randy Pargman on 6/6/15.
//  Copyright (c) 2015 Randy Pargman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sparseFileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *fileSizeInBytesLabel;
@property (weak, nonatomic) IBOutlet UIStepper *fileSizeStepper;
- (IBAction)stepperValueChanged:(id)sender;
- (IBAction)createButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;

- (IBAction)stepSizeChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bytesFreeAfter;
@property (weak, nonatomic) IBOutlet UITextView *FileListTextView;

@end
