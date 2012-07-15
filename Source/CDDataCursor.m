// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-1998, 2000-2001, 2004-2012 Steve Nygard.

#import "CDDataCursor.h"

@implementation CDDataCursor
{
    NSData *data;
    NSUInteger offset;
}

- (id)initWithData:(NSData *)someData;
{
    return [self initWithData:someData offset:0];
}

- (id)initWithData:(NSData *)someData offset:(NSUInteger)anOffset;
{
    if ((self = [super init])) {
        data = someData;
        offset = anOffset;
    }

    return self;
}

#pragma mark -

- (NSData *)data;
{
    return data;
}

- (const void *)bytes;
{
    return [data bytes];
}

- (NSUInteger)offset;
{
    return offset;
}

- (void)setOffset:(NSUInteger)newOffset;
{
    if (newOffset <= [data length]) {
        offset = newOffset;
    } else {
        [NSException raise:NSRangeException format:@"Trying to seek past end of data."];
    }
}

- (void)advanceByLength:(NSUInteger)length;
{
    [self setOffset:offset + length];
}

- (NSUInteger)remaining;
{
    return [data length] - offset;
}

#pragma mark -

- (uint8_t)readByte;
{
    const uint8_t *ptr;

    ptr = (uint8_t *)[data bytes] + offset;
    offset += 1;

    return *ptr;
}

- (uint16_t)readLittleInt16;
{
    uint16_t result;

    if (offset + sizeof(result) <= [data length]) {
        result = OSReadLittleInt16([data bytes], offset);
        offset += sizeof(result);
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
        result = 0;
    }

    return result;
}

- (uint32_t)readLittleInt32;
{
    uint32_t result;

    if (offset + sizeof(result) <= [data length]) {
        result = OSReadLittleInt32([data bytes], offset);
        offset += sizeof(result);
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
        result = 0;
    }

    return result;
}

- (uint64_t)readLittleInt64;
{
    uint64_t result;

    if (offset + sizeof(result) <= [data length]) {
        result = OSReadLittleInt64([data bytes], offset);
        offset += sizeof(result);
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
        result = 0;
    }

    return result;
}

- (uint16_t)readBigInt16;
{
    uint16_t result;

    if (offset + sizeof(result) <= [data length]) {
        result = OSReadBigInt16([data bytes], offset);
        offset += sizeof(result);
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
        result = 0;
    }

    return result;
}

- (uint32_t)readBigInt32;
{
    uint32_t result;

    if (offset + sizeof(result) <= [data length]) {
        result = OSReadBigInt32([data bytes], offset);
        offset += sizeof(result);
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
        result = 0;
    }

    return result;
}

- (uint64_t)readBigInt64;
{
    uint64_t result;

    if (offset + sizeof(result) <= [data length]) {
        result = OSReadBigInt64([data bytes], offset);
        offset += sizeof(result);
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
        result = 0;
    }

    return result;
}

- (float)readLittleFloat32;
{
    uint32_t val;

    val = [self readLittleInt32];
    return *(float *)&val;
}

- (float)readBigFloat32;
{
    uint32_t val;

    val = [self readBigInt32];
    return *(float *)&val;
}

- (double)readLittleFloat64;
{
    uint32_t v1, v2, *ptr;
    double dval;

    v1 = [self readLittleInt32];
    v2 = [self readLittleInt32];
    ptr = (uint32_t *)&dval;
    *ptr++ = v1;
    *ptr = v2;

    return dval;
}

- (void)appendBytesOfLength:(NSUInteger)length intoData:(NSMutableData *)targetData;
{
    if (offset + length <= [data length]) {
        [targetData appendBytes:(uint8_t *)[data bytes] + offset length:length];
        offset += length;
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
    }
}

- (void)readBytesOfLength:(NSUInteger)length intoBuffer:(void *)buf;
{
    if (offset + length <= [data length]) {
        memcpy(buf, (uint8_t *)[data bytes] + offset, length);
        offset += length;
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
    }
}

- (BOOL)isAtEnd;
{
    return offset >= [data length];
}

- (NSString *)readCString;
{
    return [self readStringOfLength:strlen((const char *)[data bytes] + offset) encoding:NSASCIIStringEncoding];
}

- (NSString *)readStringOfLength:(NSUInteger)length encoding:(NSStringEncoding)encoding;
{
    if (offset + length <= [data length]) {
        NSString *str;

        if (encoding == NSASCIIStringEncoding) {
            char *buf;

            // Jump through some hoops if the length is padded with zero bytes, as in the case of 10.5's Property List Editor and iSync Plug-in Maker.
            buf = malloc(length + 1);
            if (buf == NULL) {
                NSLog(@"Error: malloc() failed.");
                return nil;
            }

            strncpy(buf, (const char *)[data bytes] + offset, length);
            buf[length] = 0;

            str = [[NSString alloc] initWithBytes:buf length:strlen(buf) encoding:encoding];
            offset += length;
            free(buf);
            return str;
        } else {
            str = [[NSString alloc] initWithBytes:(uint8_t *)[data bytes] + offset length:length encoding:encoding];
            offset += length;
            return str;
        }
    } else {
        [NSException raise:NSRangeException format:@"Trying to read past end in %s", __cmd];
    }

    return nil;
}

@end
