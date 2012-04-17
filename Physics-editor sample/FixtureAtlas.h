//
//  FixtureAtlas.h
//  testXML
//
//  Created by Alexander Alemayhu on 02.12.11.
//  Copyright (c) 2011 Flexnor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"

@interface FixtureAtlas : NSObject <NSXMLParserDelegate>{
    
    NSXMLParser *parser;
    NSString *assetName;
    
    b2Body *theBody;
    b2FixtureDef *fd;
    b2PolygonShape *shape;
    b2Vec2 verts[b2_maxPolygonVertices];
    
    int vindex;    
    float bodyWidth;
    float bodyHeight;
    
    BOOL shouldGetPolygon;
    BOOL shouldGetVertex;
    BOOL pathDoesExist;
    BOOL pathWasFound;
}

+(FixtureAtlas *) withFile:(NSString *) xmlFile;
-(id) initWithFile:(NSString *)xmlFile;

-(void) createFixturesWithBody:(b2Body *) body assetName:(NSString *) name width:(float)w height:(float)h fixtureDef:(b2FixtureDef *)params;

@end
