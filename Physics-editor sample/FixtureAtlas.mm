//
//  XMLParser.m
//  testXML
//
//  Created by Alexander Alemayhu on 02.12.11.
//  Copyright (c) 2011 Flexnor. All rights reserved.
//

#import "FixtureAtlas.h"
#import "ccMacros.h"

@interface FixtureAtlas()
-(NSData *) getXMLFile:(NSString *)xmlFile;
@end

@implementation FixtureAtlas

+(FixtureAtlas *) withFile:(NSString *) xmlFile{
    
    return [[[self alloc] initWithFile:xmlFile] autorelease];
}

-(id) initWithFile:(NSString *) xmlFile{
    
    if (self = [super init]) {
        
        NSAssert1(xmlFile != nil, @"Invalid file: %@", xmlFile);
        
        NSData *data = [self getXMLFile:xmlFile];
        parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];  
    }
    
    return self;
}

-(NSData *) getXMLFile:(NSString *)xmlFile {
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:xmlFile];    
    NSData *xmlData = [NSData dataWithContentsOfFile:filePath];
    
    return xmlData;
}

-(void) createFixturesWithBody:(b2Body *)body 
                     assetName:(NSString *)name 
                         width:(float)w 
                        height:(float)h 
                    fixtureDef:(b2FixtureDef *)params{
    
    vindex = 0;
    pathWasFound = NO;
    pathDoesExist = NO;
    shouldGetPolygon = NO;
    shouldGetVertex = NO;
    
    //Should we use a custom fixture?
    static b2FixtureDef *DEFAULT_FIXTURE = new b2FixtureDef();            
    fd = params == NULL ? DEFAULT_FIXTURE : params;
    
    theBody = body;
    bodyWidth = w;
    bodyHeight = h;
    //Create a new shape
    shape = new b2PolygonShape();
    
    //Set asset file to look for
    assetName = name;    
    [parser parse];        
}


#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    if (!pathWasFound) {
        NSString *msg = [NSString stringWithFormat:@"%@ was not found", assetName];
        [NSException raise:@"Missing file." format:msg, nil];
    }    
    
    //Did we use all the vertices?
    if (vindex > 0) {
        shape->Set(verts, vindex);
        fd->shape = shape;
        theBody->CreateFixture(fd);
        vindex = 0;
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"asset"]) {        
        NSString *relativePath = [attributeDict objectForKey:@"relativePath"];      
        //Confirm existence of file name
        if ([relativePath isEqualToString:assetName]) {
            pathDoesExist = pathWasFound = YES;            
        }else{
            shouldGetVertex = pathDoesExist = NO;
            if (vindex > 0) { shouldGetPolygon = YES; }
            else { shouldGetPolygon = NO; }
        }
    }
    
    if ([elementName isEqualToString:@"polygon"] && pathDoesExist) {    
        if (vindex > 0) { shouldGetPolygon = YES; }
        if (shouldGetVertex == NO) { shouldGetVertex = YES; }
    }else if ([elementName isEqualToString:@"vertex"] && shouldGetVertex) {
        
        CGFloat x = [[attributeDict objectForKey:@"x"] floatValue];
        CGFloat y = [[attributeDict objectForKey:@"y"] floatValue];
        
        x *= bodyWidth / 100.0f;
        y *= bodyHeight / 100.0f;
        
        verts[vindex].x = x - (bodyWidth / 2);
        verts[vindex].y = y - (bodyHeight / 2);
        
        shouldGetPolygon = NO;
        vindex++;        
    }      
    
    if (vindex > 0 && shouldGetPolygon) {
        
        shape->Set(verts, vindex);
        fd->shape = shape;
        theBody->CreateFixture(fd);
        vindex = 0;
    }
}

@end
