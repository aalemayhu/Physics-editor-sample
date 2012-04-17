//
//  HelloWorldLayer.mm
//  Physics-editor sample
//
//  Created by Alexander Alemayhu on 03.04.12.
//  Copyright Flexnor 2012. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"
#import "FixtureAtlas.h"
#import "PhysicsSprite.h"

enum {
	kTagParentNode = 1,
};

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(void) createMenu;
-(void) startTest1;
-(void) startTest2;
@end

//REMINDER: Images that are 32x32 or smaller won't work properly with the FixtureAtlas. 
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
        [self createMenu];
		[self initPhysics];		        
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
	[super dealloc];
}	

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);	
}

-(void) initPhysics
{	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
    //	flags += b2Draw::e_jointBit;
    //	flags += b2Draw::e_aabbBit;
    //	flags += b2Draw::e_pairBit;
    //	flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
    
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) createMenu
{
    CCLayerColor *bgColor = [CCLayerColor layerWithColor:ccc4(0,255,0,128)];
    [self addChild:bgColor z:-100];
    
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
    
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]];
	}];
    
    CCMenuItemLabel *testOne = [CCMenuItemFont itemWithString:@"Tetrominoes" block:^(id sender) {
         [self startTest1]; 
    }];
    
    CCMenuItemLabel *testTwo = [CCMenuItemFont itemWithString:@"Vial test" block:^(id sender) {
        [self startTest2]; 
    }];
	
	CCMenu *menu = [CCMenu menuWithItems: testOne, testTwo, reset, nil];	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];    
	[self addChild: menu z:-1];	
}

-(void) startTest1 {
        
    //Choose one of the tetromino files.
    NSString *img = [NSString stringWithFormat:@"block%d.png", (arc4random()%2)+1];
    PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:img];

    CGSize winSize = [[CCDirector sharedDirector] winSize];    
    CGPoint p = ccp(winSize.width/2, winSize.height - (sprite.contentSize.height * 0.80));
    sprite.position = ccp(p.x, p.y);
    [self addChild:sprite];
    
    //Define our body
    b2BodyDef bodyDef;        
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    bodyDef.userData = sprite;    
    
    //Create the body
    b2Body *body = world->CreateBody(&bodyDef);
    
    //Init the FixtureAltas with the xml file
    FixtureAtlas *fixtureAtlas = [FixtureAtlas withFile:@"test_2.xml"];    
    //Create our fixtures
    [fixtureAtlas createFixturesWithBody:body assetName:img width:sprite.contentSize.width/PTM_RATIO
                                  height:sprite.contentSize.height/PTM_RATIO fixtureDef:NULL];      
    [sprite setPhysicsBody:body];
}

-(void) startTest2 {

    NSString *img = @"test01.png";
    PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:img];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];    
    CGPoint p = ccp(winSize.width/2, (winSize.height/2) - (sprite.contentSize.height/2));

    sprite.position = p;
    [self addChild:sprite z:-10];
    
    //Define our body
    b2BodyDef bodyDef;        
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    bodyDef.userData = sprite;    
    
    //Create the body
    b2Body *body = world->CreateBody(&bodyDef);
    
    FixtureAtlas *fixtureAtlas = [FixtureAtlas withFile:@"bodies.xml"];    
    //Create our fixtures
    [fixtureAtlas createFixturesWithBody:body assetName:img width:sprite.contentSize.width/PTM_RATIO
                                  height:sprite.contentSize.height/PTM_RATIO fixtureDef:NULL];  
    
    [sprite setPhysicsBody:body];
    
    [self schedule:@selector(addballs:) interval:0.5 repeat:60 delay:2.0];
}

-(void) addballs:(ccTime) dt{
        
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint p = ccp(winSize.width - 110, winSize.height-30); 
    
    PhysicsSprite *ball = [PhysicsSprite spriteWithFile:@"ball.png"];
    ball.position = ccp( p.x, p.y);
	[self addChild:ball];
    
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
    
    b2CircleShape circleShape;
    circleShape.m_radius = 0.5/2;
    
    b2FixtureDef fixtureDef;    
    fixtureDef.shape = &circleShape;
	fixtureDef.restitution = 0.5;
    body->CreateFixture(&fixtureDef);
	
	[ball setPhysicsBody:body];
}

@end
