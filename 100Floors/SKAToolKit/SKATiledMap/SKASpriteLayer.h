//
//  SKASpriteLayer.h
//  SKATMXParser
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

#import <SpriteKit/SpriteKit.h>
#import "SKASprite.h"

@interface SKASpriteLayer : SKNode

// TODO these can be a struct {{x: NSInteger, y: NSInteger}, {width: NSInteger,
// height: NSInteger}}
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger width;

@property (nonatomic) float opacity;
@property (nonatomic) BOOL visible;

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSArray *collisionSprites;

/**
 two dementional array of SKASprites and NSNull
 */
@property (nonatomic, strong) NSArray *sprites;

- (SKASprite *)spriteForIndexX:(NSInteger)x indexY:(NSInteger)y;

@end