# SparseFileCreator
Experimental (not validated) iOS 6+ app that allows you to create large sparse files of whatever size you choose, and only the last byte of each file is actually written to by the program.  The rest of the file should contain whatever data happens to be in that unallocated space.

This WILL alter the data on the phone in the following ways:
1) All the space needed to install the app itself will be overwritten (43 KBytes of App + 355 bytes supporting files)
2) One byte at the end of each sparse file will be overwritten with the character "!"

The purpose of this app is to enable the recovery of lost (deleted) data from an iPhone 5s, iPhone 6, and future iPhone models that prevent forensic collection tools from accessing unallocated space directly (and thus, recovering deleted files by carving).  You must have the ability to unlock the phone, push the app over USB (via XCode) and run it.  Once the sparse file is created, extract it with a tool of your choice from the App's /Documents folder and then use a carving tool of your chose (such as bulk_extractor) to recover data.

I wrote this to help out a friend, but unfortunately I do not have a suitable iOS device to test it on (only the simulator).  If you find that it works correctly on an iPhone 5s or iPhone 6 (e.g. you are able to create large files, export those files, and then carve for deleted data).
