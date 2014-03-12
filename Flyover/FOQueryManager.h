//
//  FOQuery.h
//  Flyover API
//
//  Created by Frank Budszuhn on 08.02.14.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define OVERPASS_SERVER_DE     @"http://overpass-api.de/api/interpreter"
#define OVERPASS_SERVER_RU     @"http://overpass.osm.rambler.ru/cgi/interpreter"
#define OVERPASS_SERVER_FR     @"http://api.openstreetmap.fr/oapi/interpreter"


// Overpass API does allow for different query languages
typedef NS_ENUM(NSInteger, OVQueryLanguage) {
    OVQueryLanguageQL,
    OVQueryLanguageXML
};

// we don't want a dependency on MapKit, so we define our own bounding box
struct FOBoundingBox {
    CLLocationCoordinate2D northWest;
    CLLocationCoordinate2D southEast;
};

typedef struct FOBoundingBox FOBoundingBox;

CG_INLINE FOBoundingBox
FOBoundingBoxMake(CLLocationDegrees north, CLLocationDegrees west, CLLocationDegrees south, CLLocationDegrees east)
{
    FOBoundingBox bbox;
    bbox.northWest.latitude = north;
    bbox.northWest.longitude = west;
    bbox.southEast.latitude = south;
    bbox.southEast.longitude = east;
    return bbox;
}

CG_INLINE FOBoundingBox
FOBoundingBoxMakeFromCoordinates(CLLocationCoordinate2D northWest, CLLocationCoordinate2D southEast)
{
    FOBoundingBox bbox;
    bbox.northWest = northWest;
    bbox.southEast = southEast;
    return bbox;
}


// protocol definitions for basic OSM types. Roll your own classes if you like

@protocol OSMNode <NSObject>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSNumber *osmId;
@property (nonatomic, readonly) NSDictionary *tags;
- (instancetype) initWithId: (NSNumber *) osmId coordinate: (CLLocationCoordinate2D) coordinate tags: (NSDictionary *) tags;
@end

@protocol OSMWay <NSObject>

@property (nonatomic, readonly) NSNumber *osmId;
@property (nonatomic, readonly) NSDictionary *tags;
@property (nonatomic, readonly) NSArray *nodes;
- (instancetype) initWithId: (NSNumber *) osmId nodes: (NSArray *) nodes tags: (NSDictionary *) tags;
@end

@protocol OSMRelation <NSObject>
@property (nonatomic, readonly) NSNumber *osmId;
@property (nonatomic, readonly) NSDictionary *tags;
@property (nonatomic, readonly) NSArray *members;

- (instancetype) initWithId: (NSNumber *) osmId members: (NSArray *) members tags: (NSDictionary *) tags;
@end



// if you don't implement and set the delegate, you'll get FONode, FOWay and FORelation instances

@protocol FOQueryDelegate <NSObject>


@optional
- (id <OSMNode>) nodeWithOsmId: (NSNumber *) osmId coordinate: (CLLocationCoordinate2D) coordinate tags: (NSDictionary *) tags;
- (id <OSMWay>) wayWithOsmId: (NSNumber *) osmId nodes: (NSArray *) nodes tags: (NSDictionary *) tags;
- (id <OSMRelation>) relationWithOsmId: (NSNumber *) osmId members: (NSArray *) members tags: (NSDictionary *) tags;

@end



@interface FOQueryManager : NSObject


+ (FOQueryManager *) managerWithServer: (NSString *) serverUrl queryLanguage: (OVQueryLanguage) queryLanguage delegate: (id <FOQueryDelegate>) delegate;

// if you want the bounding box set to mapRect, insert {{bbox}} for bounding box, as used by http://overpass-turbo.eu
// you *MUST* set json output in your query! Unfortunately XML is the default which will produce errors
// in QL: [out:json] in XML: <osm-script output="json">
- (void) performQuery: (NSString *) queryString forBoundingBox: (FOBoundingBox) boundingBox
       success:(void (^)(NSArray *nodes, NSArray *ways, NSArray *relations))success
       failure:(void (^)(NSError *error))failure;

@end
