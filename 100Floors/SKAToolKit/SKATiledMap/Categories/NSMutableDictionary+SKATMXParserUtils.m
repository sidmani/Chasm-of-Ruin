//
//  NSMutableDictionary+SKATMXParserUtils.m
//  SKAToolKitExample
//
//  Copyright (c) 2015 Sprite Kit Alliance
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "NSMutableDictionary+SKATMXParserUtils.h"

NSString *const kBase64 = @"base64";
NSString *const kCompression = @"compression";
NSString *const kData = @"data";
NSString *const kDrawOrder = @"draworder";
NSString *const kEncoding = @"encoding";
NSString *const kHeight = @"height";
NSString *const kId = @"id";
NSString *const kImage = @"image";
NSString *const kImageHeight = @"imageheight";
NSString *const kImageWidth = @"imagewidth";
NSString *const kLayer = @"layer";
NSString *const kLayers = @"layers";
NSString *const kMap = @"map";
NSString *const kMargin = @"margin";
NSString *const kName = @"name";
NSString *const kObject = @"object";
NSString *const kObjectGroup = @"objectgroup";
NSString *const kObjects = @"objects";
NSString *const kOpacity = @"opacity";
NSString *const kOrientation = @"orientation";
NSString *const kProperties = @"properties";
NSString *const kProperty = @"property";
NSString *const kRenderOrder = @"left-up";
NSString *const kRotation = @"rotation";
NSString *const kSource = @"source";
NSString *const kSpacing = @"spacing";
NSString *const kTile = @"tile";
NSString *const kTileHeight = @"tileheight";
NSString *const kTileLayer = @"tilelayer";
NSString *const kTileProperties = @"tileproperties";
NSString *const kTiles = @"tiles";
NSString *const kTileset = @"tileset";
NSString *const kTilesets = @"tilesets";
NSString *const kTileWidth = @"tilewidth";
NSString *const kTopDown = @"topdown";
NSString *const kType = @"type";
NSString *const kValue = @"value";
NSString *const kVersion = @"version";
NSString *const kVisible = @"visible";
NSString *const kWidth = @"width";
NSString *const kX = @"x";
NSString *const kY = @"y";
NSString *const kZlib = @"zlib";

@implementation NSMutableDictionary (SKATMXParserUtils)

#pragma mark - Public
- (void)cleanseMap
{
    [self cleanseProperties];
}

- (void)cleanseTileset
{
    [self cleanseMargin];
    [self cleanseSpacing];
    [self cleanseProperties];
}

- (void)cleanseLayer
{
    [self cleanseX];
    [self cleanseY];
    [self cleanseVisible];
    [self cleanseOpacity];
    [self cleanseType];
}

- (void)cleanseObjectGroup
{
    [self cleanseWidth];
    [self cleanseHeight];
    [self cleanseX];
    [self cleanseY];
    [self cleanseVisible];
    [self cleanseType];
    [self cleanseOpacity];
    [self cleanseDrawOrder];
}

- (void)cleanseObject
{
    [self cleanseName];
    [self cleanseType];
    [self cleanseRotation];
    [self cleanseVisible];
}

#pragma mark - Private
- (void)cleanseProperties
{
    if(!self[kProperties])
    {
        self[kProperties] = [[NSDictionary alloc] init];
    }
}

- (void)cleanseWidth
{
    if(!self[kWidth])
    {
        self[kWidth] = @0;
    }
}

- (void)cleanseHeight
{
    if(!self[kHeight])
    {
        self[kHeight] = @0;
    }
}

- (void)cleanseX
{
    if(!self[kX])
    {
        self[kX] = @0;
    }
}

- (void)cleanseY
{
    if(!self[kY])
    {
        self[kY] = @0;
    }
}

- (void)cleanseVisible
{
    if(!self[kVisible])
    {
        self[kVisible] = @YES;
    }
}

- (void)cleanseType
{
    if(!self[kType])
    {
        self[kType] = kTileLayer;
    }
}

- (void)cleanseOpacity
{
    if(!self[kOpacity])
    {
        self[kOpacity] = @1;
    }
}

- (void)cleanseMargin
{
    if(!self[kMargin])
    {
        self[kMargin] = @0;
    }
}

- (void)cleanseSpacing
{
    if(!self[kSpacing])
    {
        self[kSpacing] = @0;
    }
}

- (void)cleanseDrawOrder
{
    if(!self[kDrawOrder])
    {
        self[kDrawOrder] = kTopDown;
    }
}

- (void)cleanseName
{
    if(!self[kName])
    {
        self[kName] = @"";
    }
}

- (void)cleanseRotation
{
    if(!self[kRotation])
    {
        self[kRotation] = @0;
    }
}

@end