//
//  OVWay.m
//  Flyover
//
//  Created by Frank Budszuhn on 15.02.14.
//

#import "FOWay.h"

@implementation FOWay

@synthesize tags=_tags, osmId=_osmId, nodes=_nodes;

- (instancetype) initWithId: (NSNumber *) osmId nodes: (NSArray *) nodes tags: (NSDictionary *) tags
{
    self = [self init];
    if (self)
    {
        _tags = tags;
        _osmId = osmId;
        _nodes = nodes;
    }
    
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"id=%@, %lu tags, %lu nodes", _osmId, (unsigned long)[_tags count], (unsigned long)[_nodes count]];
}
- (BOOL)isEqual:(id)other
{
    FOWay *anotherWay = other;
    return anotherWay && [_osmId isEqual: anotherWay.osmId];
}

- (NSUInteger)hash
{
    return [_osmId hash];
}


@end
