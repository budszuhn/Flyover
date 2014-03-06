//
//  OSMNode.h
//  Flyover
//
//  Created by Frank Budszuhn on 08.02.14.
//

#import <Foundation/Foundation.h>
#import "FOQueryManager.h"

// FONode is duck-typing as an MkAnnotaion. So you can use it in MapKit.

@interface FONode : NSObject <OSMNode>

@end
