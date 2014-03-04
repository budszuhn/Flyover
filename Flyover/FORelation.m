//
//  OVRelation.m
//  Flyover
//
//  Created by Frank Budszuhn on 15.02.14.
//

#import "FORelation.h"

@implementation FORelation

@synthesize osmId=_osmId, tags=_tags, members=_members;

- (instancetype) initWithId: (NSNumber *) osmId members: (NSArray *) members tags: (NSDictionary *) tags
{
    self = [self init];
    if (self)
    {
        _tags = tags;
        _osmId = osmId;
        _members = members;
    }
    
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"id=%@, %d tags, %d members", _osmId, [_tags count], [_members count]];
}

- (BOOL)isEqual:(id)other
{
    FORelation *anotherRelation = other;
    return anotherRelation && [_osmId isEqual: anotherRelation.osmId];
}

- (NSUInteger)hash
{
    return [_osmId hash];
}


@end
