//
//  OSMNode.m
//  Flyover
//
//  Created by Frank Budszuhn on 08.02.14.
//

#import "FONode.h"

@implementation FONode

@synthesize tags=_tags, coordinate=_coordinate, osmId=_osmId;

- (instancetype) initWithId: (NSNumber *) osmId coordinate: (CLLocationCoordinate2D) coordinate tags: (NSDictionary *) tags
{
    self = [self init];
    if (self)
    {
        _tags = tags;
        _osmId = osmId;
        _coordinate = coordinate;
    }
    
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"id=%@, lat=%f, lon=%f, %d tags", _osmId, _coordinate.latitude, _coordinate.longitude, [_tags count]];
}

// fallback implementation for MapKit, so a node can be used as a MapKit annotation
- (NSString *) title
{
    return [_tags valueForKey:@"name"] ? [_tags valueForKey:@"name"] : [_osmId stringValue];
}

- (BOOL)isEqual:(id)other
{
    FONode *anotherNode = other;
    return anotherNode && [_osmId isEqual: anotherNode.osmId];
}

- (NSUInteger)hash
{
    return [_osmId hash];
}


@end
