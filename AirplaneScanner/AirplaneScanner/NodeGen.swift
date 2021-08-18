//
//  NodeGen.swift
//  PlaneScanner
//
//  Created by Eric Ciarla on 8/12/21.
//

import Foundation
import UIKit
import ARCL
import CoreLocation

public class NodeGen {
    public func buildLayerNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                               altitude: CLLocationDistance, image: UIImage, tag: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let node = LocationAnnotationNode(location: location, image: image)
        node.tag = tag
        return node
    }
    
    public func genNodes(planes: [(String,String,String,String,String,String,String,String,String)]) -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []
        for i in planes {
            let altF = Measurement(value: Double(i.6)!, unit: UnitLength.feet)
            let altM = altF.converted(to: UnitLength.meters)
            let lat = Double(i.4)!
            let lon = Double(i.5)!
            let tag = i.2 + " | " + i.1 + "\n" + i.3 + "kts | " + i.6 + "ft | " + i.7 + "mi"
            let image = UIImage(named: "pin")!
            let plane = self.buildLayerNode(latitude: lat, longitude: lon, altitude: altM.value, image: image, tag: tag)
            nodes.append(plane)
        }
        return nodes
    }    
}
