//
//  FOQuery.m
//  Flyover API
//
//  Created by Frank Budszuhn on 08.02.14.
//

#import <AFNetworking/AFNetworking.h>
#import "FOQueryManager.h"
#import "FONode.h"
#import "FOWay.h"
#import "FORelation.h"

@interface FOQueryManager ()

@property (nonatomic, strong) NSString *serverUrl;
@property (nonatomic) OVQueryLanguage queryLanguage;
@property (nonatomic, weak) id <FOQueryDelegate> delegate;

@end

@implementation FOQueryManager

+ (FOQueryManager *) managerWithServer: (NSString *) serverUrl queryLanguage: (OVQueryLanguage) queryLanguage delegate: (id <FOQueryDelegate>) delegate
{
    FOQueryManager *queryManager = [[FOQueryManager alloc] init];
    queryManager.serverUrl = serverUrl;
    queryManager.queryLanguage = queryLanguage;
    queryManager.delegate = delegate;
    
    return queryManager;
}


- (void) performQuery: (NSString *) queryString forBoundingBox: (FOBoundingBox) boundingBox
       success:(void (^)(NSArray *nodes, NSArray *ways, NSArray *relations))success
       failure:(void (^)(NSError *error))failure
{
    NSString *bboxStr = [self boundingBoxString:boundingBox language:_queryLanguage];
    queryString = [queryString stringByReplacingOccurrencesOfString:@"{{bbox}}" withString:bboxStr];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:_serverUrl parameters:@{@"data": queryString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self processResult:responseObject success:success];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // failure block may be nil
        if (failure)
            failure(error);
    }];
}


- (NSString *) boundingBoxString: (FOBoundingBox) boundingBox language: (OVQueryLanguage) language
{
    if (language == OVQueryLanguageXML)
    {
        return [NSString stringWithFormat:@"e=\"%f\" n=\"%f\" s=\"%f\" w=\"%f\"", boundingBox.southEast.longitude, boundingBox.northWest.latitude, boundingBox.southEast.latitude, boundingBox.northWest.longitude];
    }
    else
    {
        return [NSString stringWithFormat:@"%f,%f,%f,%f", boundingBox.southEast.latitude, boundingBox.northWest.longitude, boundingBox.northWest.latitude, boundingBox.southEast.longitude];
    }
}


- (void) processResult: (NSDictionary *) responseObject
               success:(void (^)(NSArray *nodes, NSArray *ways, NSArray *relations))success
{
    NSArray *elements = [responseObject valueForKey:@"elements"];
    NSMutableDictionary *nodeDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *relationArray = [NSMutableArray array];
    NSMutableArray *tempWayArray = [NSMutableArray array];
    
    for (NSDictionary *element in elements)
    {
        NSString *type = [element valueForKey:@"type"];
        
        if ([type isEqualToString:@"node"])
        {
            id <OSMNode> node = [self nodeForElement: element];            
            [nodeDictionary setObject:node forKey:[node.osmId stringValue]];
        }
        else if ([type isEqualToString:@"way"])
        {
            [tempWayArray addObject: [self wayForElement: element]];
        }
        else if ([type isEqualToString:@"relation"])
        {
            [relationArray addObject: [self relationForElement: element]];
        }
        else
        {
            [NSException raise:@"UnknownElementType" format: @"Unknown element type: %@", type];
        }
    }
    
    // now resolve nodes inside ways
    NSMutableArray *finalWayArray = [NSMutableArray arrayWithCapacity: [tempWayArray count]];
    for (id <OSMWay> way in tempWayArray)
    {
        NSMutableArray *resolvedNodes = [NSMutableArray arrayWithCapacity: [way.nodes count]];
        for (NSNumber *osmId in way.nodes)
        {
            [resolvedNodes addObject: [nodeDictionary valueForKey: [osmId stringValue]]];
        }

        [finalWayArray addObject: [self wayForWay: way andNodes: resolvedNodes]];
    }
    
    success([nodeDictionary allValues], [finalWayArray copy], [relationArray copy]);
}


- (id <OSMNode>) nodeForElement: (NSDictionary *) element
{
    NSNumber *osmId = [element valueForKey:@"id"];
    double latitude = [[element valueForKey:@"lat"] doubleValue];
    double longitude = [[element valueForKey:@"lon"] doubleValue];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
    NSDictionary *tags = [element valueForKey:@"tags"];
    
    if ([_delegate respondsToSelector:@selector(nodeWithOsmId:coordinate:tags:)])
    {
        return [_delegate nodeWithOsmId: osmId coordinate: coord tags: tags];
    }
    else
    {
        return [[FONode alloc] initWithId:osmId coordinate:coord tags:tags];
    }
}

- (id <OSMWay>) wayForElement: (NSDictionary *) element
{
    NSNumber *osmId = [element valueForKey:@"id"];
    NSDictionary *tags = [element valueForKey:@"tags"];
    NSArray *nodes = [element valueForKey:@"nodes"];
    
    if ([_delegate respondsToSelector:@selector(wayWithOsmId:nodes:tags:)])
    {
        return [_delegate wayWithOsmId:osmId nodes:nodes tags:tags];
    }
    else
    {
        return [[FOWay alloc] initWithId:osmId nodes:nodes tags:tags];
    }
}

- (id <OSMWay>) wayForWay: (id <OSMWay>) way andNodes: (NSArray *) nodes
{
    if ([_delegate respondsToSelector:@selector(wayWithOsmId:nodes:tags:)])
    {
        return [_delegate wayWithOsmId:way.osmId nodes:nodes tags:way.tags];
    }
    else
    {
        return [[FOWay alloc] initWithId:way.osmId nodes:nodes tags:way.tags];
    }
}

- (id <OSMRelation>) relationForElement: (NSDictionary *) element
{
    NSNumber *osmId = [element valueForKey:@"id"];
    NSDictionary *tags = [element valueForKey:@"tags"];
    NSArray *members = [element valueForKey:@"members"];

    if ([_delegate respondsToSelector:@selector(relationWithOsmId:members:tags:)])
    {
        return [_delegate relationWithOsmId:osmId members:members tags:tags];
    }
    else
    {
        return [[FORelation alloc] initWithId:osmId members:members tags:tags];
    }
}



@end
