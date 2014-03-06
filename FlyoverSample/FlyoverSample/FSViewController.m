//
//  FSViewController.m
//  FlyoverSample
//
//  Created by Frank Budszuhn on 05.03.14.
//

#import <MapKit/MapKit.h>
#import "FSViewController.h"
#import "FOFlyover.h"

@interface FSViewController () <MKMapViewDelegate>

@property (strong, nonatomic) FOQueryManager *queryManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation FSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // the query object can be re-used
    self.queryManager = [FOQueryManager managerWithServer:OVERPASS_SERVER_DE queryLanguage:OVQueryLanguageQL delegate:nil];
    
    // ich steh auf Berlin ;-)
    self.mapView.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(52.51737, 13.4013), 3000, 3000);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKMapRect mapRect = mapView.visibleMapRect;
    // for simplicity we just want to have nodes and ignore any failures
    
    CLLocationCoordinate2D nw = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D se = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)) );
    
    CLLocation *l1 = [[CLLocation alloc] initWithLatitude:nw.latitude longitude:nw.longitude];
    CLLocation *l2 = [[CLLocation alloc] initWithLatitude:se.latitude longitude:se.longitude];
    
    // just do a query when map diagonal is less than 10km
    // we don't want the query result to get too large
    if ([l1 distanceFromLocation: l2] < 10000)
    {
        FOBoundingBox bbox = FOBoundingBoxMakeFromCoordinates(nw, se);
        
        // Flyover will replace {{bbox}} with coordinates
        [self.queryManager performQuery: @"[out:json]; (node ['shop'='bakery'] ({{bbox}})); out;" forBoundingBox:bbox success:^(NSArray *nodes, NSArray *ways, NSArray *relations) {
            
            // nodes are duck-typed as MkAnnotations. Just throw them on the map.
            [mapView addAnnotations: nodes];
            
        } failure: nil];
        
        
    }
}



@end
