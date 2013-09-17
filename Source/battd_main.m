//
//  battd_main.m
//  MiniBatteryLogger
//
//  Created by delphine on 31-03-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "BatteryServer.h"
#include <signal.h>
#include <getopt.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/param.h>
#include <syslog.h>
#include <mach-o/dyld.h>
#import <Foundation/Foundation.h>

#define BATTD_SERVER_NAME @"battd 1.3"

extern NSString *MBLRemoteBatteryMonitoringServiceType;
extern int MBLRemoteBatteryMonitoringPort;

extern char ** environ;

const char *battd_pidfile_path = "/var/tmp/battd.pid";
static NSString *BattdPIDFilePath = @"/var/tmp/battd.pid";

char *progname;

static void sighand(int sig);

int main(const int argc, const char **argv)
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if ( (argc >= 2) && (strcmp(argv[1], "-daemon") == 0) )
	{
        optind = 2;
		
        // ... process any post-daemonization arguments ...
		
        // ... run as a daemon ...
		signal(SIGHUP,  sighand);
		signal(SIGINT,  sighand);
		signal(SIGQUIT, sighand);
		signal(SIGILL,  sighand);
		signal(SIGBUS,  sighand);
		signal(SIGSEGV, sighand);
		signal(SIGTERM, sighand);
		
		// Child process
		NSRunLoop * rl = [NSRunLoop currentRunLoop];
		BatteryServer *batteryserver = [[BatteryServer alloc] init];
		[batteryserver setServerName:BATTD_SERVER_NAME];
		NSError * startError = nil;
		[batteryserver setType:MBLRemoteBatteryMonitoringServiceType];
		[batteryserver setPort:MBLRemoteBatteryMonitoringPort];
		if (![batteryserver start:&startError])
		{
			NSLog(@"Error starting server: %@", startError);
		}
		else
		{
			//NSLog(@"Starting server on port %d", [batteryserver port]);
		}
		[rl run];
    }
	else
	{
        char **     args;
        char        execPath[PATH_MAX];
        uint32_t    execPathSize;
		
        // ... process any pre-daemonization arguments ...

		// Check if a battd instance is already running
		if ([[NSFileManager defaultManager] fileExistsAtPath:BattdPIDFilePath])
		{
			// Get contents of pid file as string
			NSString *pid_str = [[NSString alloc] initWithContentsOfFile:BattdPIDFilePath];
			// Get pid_t value
			pid_t daemon_pid = (pid_t)[pid_str intValue];
			// We should check if the process whose pid is daemond_pid is still active
			NSLog(@"A battd instance is already running (pid #%d). Aborting", (int)daemon_pid);
			
			// Cleanup
			[pid_str release];
			
			[pool release];
			exit(0);
		}
		
        // Calculate our new arguments, dropping any arguments that
        // have already been processed (that is, before optind) and
        // inserting the special flag that tells us that we've
        // already daemonized.
        //
        // Note that we allocate and copy one extra argument so that
        // args, like argv, is terminated by a NULL.
        //
        // We get the real path to our executable using
        // _NSGetExecutablePath because argv[0] might be a relative
        // path, and daemon chdirs to the root directory.  In a real
        // product you could probably substitute a hard-wired absolute
        // path.
		
        execPathSize = sizeof(execPath);
        (void) _NSGetExecutablePath(execPath, &execPathSize);
		
        args = malloc((argc - optind + 1) * sizeof(char *));
        args[0] = execPath;
        args[1] = "-daemon";
        memcpy(
			   &args[2],
			   &argv[optind],
			   (argc - optind + 1) * sizeof(char *)
			   );
		
        // Daemonize ourself.
		
		//(void) daemon(0, 0);
		pid_t pid;
		if ((pid = fork()) > 0)
		{
			[[[NSNumber numberWithInt:pid] stringValue] writeToFile:BattdPIDFilePath atomically:YES];
			NSLog(@"+%d battd daemon running", (int)pid);
		}
		else if (pid < 0)
		{
			NSLog(@"*** Critical *** : couldn't fork");
		}
		else
		{					
			// exec ourself.
			
			(void) execve(execPath, args, environ);
		}
    }
	
	[pool release];
    return EXIT_SUCCESS;
}


static void sighand(int sig)
{
	(void)unlink(battd_pidfile_path);
	fprintf(stderr, "%s: killed with signal %d\n", progname, sig);
	exit(0);
}