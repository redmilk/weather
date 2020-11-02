//
//  MKMapView+Ext.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 31.10.2020.
//

import Foundation
import CoreLocation
import MapKit

extension MKMapView {
    func overlay(coord: CLLocationCoordinate2D) -> Overlay {
        let offset = 0.25
        let coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: coord.latitude - offset,
                                   longitude: coord.longitude - offset),
            CLLocationCoordinate2D(latitude: coord.latitude + offset,
                                   longitude: coord.longitude + offset)
        ]
        
        let points = coordinates.map { MKMapPoint($0) }
        let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
        let mapRectUnion: (MKMapRect, MKMapRect) -> MKMapRect = { $0.union($1) }
        let fittingRect = rects.reduce(MKMapRect.null, mapRectUnion)
        return Overlay(icon: "icon", coordinate: coord, boundingMapRect: fittingRect)
    }
    
    class Overlay: NSObject, MKOverlay {
        var coordinate: CLLocationCoordinate2D
        var boundingMapRect: MKMapRect
        let icon: String
        
        init(icon: String, coordinate: CLLocationCoordinate2D, boundingMapRect: MKMapRect) {
            self.coordinate = coordinate
            self.boundingMapRect = boundingMapRect
            self.icon = icon
        }
    }
    
    class OverlayView: MKOverlayRenderer {
        var overlayIcon: String
        
        init(overlay: MKOverlay, overlayIcon: String) {
            self.overlayIcon = overlayIcon
            super.init(overlay: overlay)
        }
        
        public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
            let imageReference = Helper.imageFromText(
                text: overlayIcon,
                font: UIFont(name: "Flaticon", size: 32.0)!
            ).cgImage
            let theMapRect = overlay.boundingMapRect
            let theRect = rect(for: theMapRect)
            
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0.0, y: -theRect.size.height)
            context.draw(imageReference!, in: theRect)
        }
    }
}
