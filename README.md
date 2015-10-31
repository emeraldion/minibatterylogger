# minibatterylogger

MiniBatteryLogger is a Mac OS X application that monitors your laptop’s battery, traces the graph of
charge and current over time, compares your battery with other users, logs relevant power events and
alerts you with Growl notifications.

Since I am no longer maintaining this project, I am releasing it as open source so people can still
fork it and add support for new models and recent OSs.

# Targets

* **MiniBatteryLogger** - A Cocoa application that charts battery stats
* **Migration Agent** - An agent that migrates battery data stored in an earlier format
* **TestBench** - A test bench for the utilities provided by this project
* **batterystat** - A commandline utility that displays battery info
* **battd** - A daemon that transmits battery data over TCP/IP
* **Widget Plugin** - A Dashboard widget plugin that provides data for the **MiniBatteryStatus** widget
* **Test** - Runs tests
* **Snapshots Merger** - Merges battery snapshots
* **Snapshots Viewer** - Visualizes battery snapshots

## Caveats

This project was last compiled on Xcode 2.x on Mac OS X 10.4, and may require significant changes to work on latest Xcode and Mac OS X versions.

# License

[MIT](http://opensource.org/licenses/MIT)

Copyright (c) Claudio Procida 2006, 2015
