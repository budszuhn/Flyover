Flyover
=======

Flyover is an Objective-C wrapper for the Overpass API

Usage
-----

Important: you *MUST* set json output in your query! Unfortunately XML is the default which will produce errors!

In QL it is:

	[out:json]
	
In XML it's:	

	<osm-script output="json">
	
	
Here's a simple example to query bakeries:

        FOBoundingBox bbox = FOBoundingBoxMakeFromCoordinates(nw, se);
        FOQuery *q = [FOQuery queryWithServer:OVERPASS_SERVER_DE queryLanguage:OVQueryLanguageQL delegate:nil];
        
        // Flyover will replace {{bbox}} with coordinates
        [q queryString: @"[out:json]; (node ['shop'='bakery'] ({{bbox}})); out;" forBoundingBox:bbox success:^(NSArray *nodes, NSArray *ways, NSArray *relations) {
            
            // nodes are duck-typed as MkAnnotations. Just throw them on a map.
            [mapView addAnnotations: nodes];
            
        } failure: nil];
	
Dependencies
------------
Flyover uses [AFNetworking](https://github.com/AFNetworking/AFNetworking) as the network layer. You'll need a current version (AFNetworking 2.0).
