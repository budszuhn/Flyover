//
//  FOQuery.m
//  Flyover API
//
//  Created by Frank Budszuhn on 08.02.14.
//

#import <AFNetworking/AFNetworking.h>
#import "FOQuery.h"
#import "FONode.h"
#import "FOWay.h"
#import "FORelation.h"

@interface FOQuery ()

@property (nonatomic, strong) NSString *serverUrl;
@property (nonatomic) OVQueryLanguage queryLanguage;
@property (nonatomic, weak) id <FOQueryDelegate> delegate;

@end

@implementation FOQuery

+ (FOQuery *) queryWithServer: (NSString *) serverUrl queryLanguage: (OVQueryLanguage) queryLanguage delegate: (id <FOQueryDelegate>) delegate
{
    FOQuery *query = [[FOQuery alloc] init];
    query.serverUrl = serverUrl;
    query.queryLanguage = queryLanguage;
    query.delegate = delegate;
    
    return query;
}


- (void) queryString: (NSString *) queryString forBoundingBox: (FOBoundingBox) boundingBox
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
    NSMutableArray *nodeArray = [NSMutableArray array];
    NSMutableArray *wayArray = [NSMutableArray array];
    NSMutableArray *relationArray = [NSMutableArray array];
    
    for (NSDictionary *element in elements)
    {
        NSString *type = [element valueForKey:@"type"];
        
        if ([type isEqualToString:@"node"])
        {
            [nodeArray addObject: [self nodeForElement: element]];
        }
        else if ([type isEqualToString:@"way"])
        {
            [wayArray addObject: [self wayForElement: element]];
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
    
    success([nodeArray copy], [wayArray copy], [relationArray copy]);
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