//
//  NSURL+SGUtils.m
//  Singular
//
//  Created by delphine on 19-02-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import "NSURL+SGUtils.h"


@implementation NSURL (SGUtils)

+ (NSURL *)URLWithFormat:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);

	NSString *theString = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
	
	return [NSURL URLWithString:theString];
}

@end
