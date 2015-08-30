CMLogTracer is an iOS application used to browse and search logs generated by SCCM (Microsoft System Center Configuration Manager http://www.microsoft.com/en-us/server-cloud/products/system-center-2012-r2-configuration-manager/).

As a sysadmin, I have to do a lot of SCCM troubleshooting.  SCCM logs are notoriously difficult to read in a simple text editor, which is why Microsoft ships the product with a log viewing tool called CMTrace.  Using CMLogTracer, I was able to open those same logs from cloud storage, or directly from other applications like my email client.

Logs are imported into the application, parsed and modeled using CoreData.  You can import and store as many logs as your device storage accomodate.

Dependencies
============

CMLogTracer integrates the Dropbox Chooser (https://www.dropbox.com/developers/dropins/chooser/ios) to allow users to search and import logs that are store in their Dropbox accounts.

The application also uses iRate (https://github.com/nicklockwood/iRate) to allow users to easily rate the applications after using it for a while.

All dependencies can be installed using CocoaPods.