//
//  sparseFileViewController.m
//  SparseFileCreator
//
//  Created by Randy Pargman on 6/6/15.
//  Copyright (c) 2015 Randy Pargman. All rights reserved.
//

#import "sparseFileViewController.h"


@implementation sparseFileViewController

- (IBAction)stepperValueChanged:(id)sender {
	self.fileSizeInBytesLabel.text = [NSString stringWithFormat:@"%0.3f MiB", self.fileSizeStepper.value];
	[self updateBytesFreeLabel];
}

- (IBAction)stepSizeChanged:(id)sender {
	if (self.segmentController.selectedSegmentIndex ==0) {
		// KiB selected
		self.fileSizeStepper.stepValue = 1.0/1024.0;
	} else if (self.segmentController.selectedSegmentIndex == 1) {
		// MiB selected
		self.fileSizeStepper.stepValue = 1.0;
	} else if (self.segmentController.selectedSegmentIndex == 2) {
		// GiB selected
		self.fileSizeStepper.stepValue = 1024.0;
	}
}

- (IBAction)createButtonPressed:(id)sender {
	NSString *filePath = [self createSparseFile:(self.fileSizeStepper.value *(1024<<10))];
	self.FileListTextView.text = [self.FileListTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@ created\n", filePath]];
	[self updateBytesFreeLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self updateBytesFreeLabel];
}

- (void)updateBytesFreeLabel
{
	uint64_t bytes_free = [self freeDiskspace] - (self.fileSizeStepper.value *(1024<<10));
	uint64_t tebibyte = (1024ll<<30);
	double whole_value;
	double fractional_value;
	// choose the best units to use for display
	if ((bytes_free / tebibyte) > 1) {
		//TiB
		whole_value = (bytes_free/tebibyte);
		fractional_value = ((bytes_free - (whole_value*(1024>>30)))/(1024ll<<30)) + whole_value;
		self.bytesFreeAfter.text = [NSString stringWithFormat:@"%0.3f TiB", fractional_value];
	} else if ((bytes_free/(1024l<<20)) > 1) {
		//GiB
		fractional_value = (double)bytes_free/(double)(1024<<20);
		self.bytesFreeAfter.text = [NSString stringWithFormat:@"%0.3f GiB", fractional_value];
	} else if ((bytes_free/(1024<<10)) > 1) {
		//MiB
		fractional_value = (double)bytes_free/(double)(1024<<10);
		self.bytesFreeAfter.text = [NSString stringWithFormat:@"%0.3f MiB", fractional_value];
	} else {
		fractional_value = (double)bytes_free/(double)1024;
		self.bytesFreeAfter.text = [NSString stringWithFormat:@"%0.3f KiB", fractional_value];
	}
	
}

-(NSString *) createSparseFile:(uint64_t)sizeOfFileInBytes
{
    @try {
		
        NSFileHandle *outputFileHandle;
		NSFileManager *outputFileManager;
		NSMutableData *tinyData;
		NSString *outputFilePath;
		int currentFileNumberSuffix = 1;
		uint64_t diskSpaceFreeOnDevice = 0;
		
		// a tiny byte of data to write at the end of the file
		tinyData = [NSMutableData dataWithBytes:@"!" length:1];
		
        //check whether the output file exist, if not create a new one.
        outputFileManager = [NSFileManager defaultManager];
		
		
		outputFilePath = @"SparseFile0001.bin";
		outputFilePath = [self documentsPathForFileName: outputFilePath]; // save it in the app's Documents folder
		
		// Keep incrementing the number at the end of the filename until we get
		// a file name that doesn't exist yet (so we are not overwriting anything).
		while ([outputFileManager fileExistsAtPath:outputFilePath] == YES && currentFileNumberSuffix < 10000) {
			currentFileNumberSuffix += 1;
			outputFilePath = [NSString stringWithFormat: @"SparseFile%04d.bin", currentFileNumberSuffix];
			outputFilePath = [self documentsPathForFileName: outputFilePath]; // add the documents path
		}
		
		// Create file new ouput file in the documents path
        if ([outputFileManager fileExistsAtPath: outputFilePath ] == NO)
        {
            NSLog (@"Output file does not exist, creating a new one");
            [outputFileManager createFileAtPath: outputFilePath
									   contents: nil
									 attributes: nil];
        }
		else {
			NSLog (@"Could not find a suitable output file name");
			return @"File not created";
			
		}
		
		// Get a file handle to our newly created file
        outputFileHandle  = [NSFileHandle fileHandleForWritingAtPath: outputFilePath];
		
        NSAssert( outputFileHandle != nil, @"Failed to open handle for output file" );
		
		// Make sure there is enough free disk space, and if not, reduce the file size accordingly
		diskSpaceFreeOnDevice = [self freeDiskspace];
		if (sizeOfFileInBytes >= diskSpaceFreeOnDevice) {
			sizeOfFileInBytes = diskSpaceFreeOnDevice - 1;
		}
		
        @try{
            // seek to the end of the requested file size
			
            [outputFileHandle seekToFileOffset: sizeOfFileInBytes];
			
			// write one byte so the file actually gets the size requested.
			// that means that one byte is overwriten.
		    // TODO: figure out if we can
			// read the unallocated that that was at that position in unallocated space
			// and write the same data back out.
			[outputFileHandle writeData: tinyData];
			return outputFilePath;
            
        }
        @catch (NSException *exception) {
            @throw;
        }
        @finally {
            [outputFileHandle closeFile];
        }
    }
    @catch (NSException *exception) {
        @throw;
    }
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
	
    return [documentsPath stringByAppendingPathComponent:name];
}

- (uint64_t)freeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
	
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
	
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);
    }
	
    return totalFreeSpace;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
