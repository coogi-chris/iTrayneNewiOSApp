//
//  MapView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/15/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable{
    
    @Binding var annotations: [TrainerAnnotation]
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @EnvironmentObject var locationStore:LocationStore
    
    var onTapPoint:OnTapAnnotationCallBack
    
    public typealias OnTapAnnotationCallBack = (TrainerAnnotation?)->Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        self.zoomToUserLocation(mapView:mapView)
        self.addAnnotionations(view: mapView)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        if annotations.count != (view.annotations.count - 1) {
            //print(annotations.count, view.annotations.count)
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    
    func addAnnotionations(view: MKMapView) {

    }
    
    func zoomToUserLocation(mapView:MKMapView) {
        if let location = self.locationStore.lastLocation {
            let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 700, longitudinalMeters: 700)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation {
                if let trainerAnnotation = annotation as? TrainerAnnotation {
                    self.parent.onTapPoint(trainerAnnotation)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            guard !annotation.isKind(of: MKUserLocation.self) else {
                // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
                return nil
            }
            
            let reuseIdentifier = NSStringFromClass(TrainerAnnotation.self)
            
            guard let anno = annotation as? TrainerAnnotation else {
                return MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }

            
            let annotationView: MKAnnotationView = MKAnnotationView(annotation: anno, reuseIdentifier: reuseIdentifier)
            
            let mco = MapCalloutView(buttonView: .constant(AnyView(ProfileView(trainerId: .constant(""), showProfile: .constant(true), showAppointment: .constant(false)))))
    
            let child = UIHostingController(rootView: mco)
            annotationView.translatesAutoresizingMaskIntoConstraints = false
            annotationView.detailCalloutAccessoryView = child.view
            annotationView.canShowCallout = true
            
            let img = UIImage(named: "annotation")
            annotationView.image = resizeImage(image: img!, targetSize: CGSize(width: 40, height: 40))
            
            return annotationView
            
        }

        
        
        private func setupTrainerAnnotationView(for annotation: TrainerAnnotation, on mapView: MKMapView) -> MKAnnotationView {
            let reuseIdentifier = NSStringFromClass(TrainerAnnotation.self)
            let flagAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
            
            flagAnnotationView.annotation = annotation
            flagAnnotationView.canShowCallout = false
            
                
            // Provide the annotation view's image.
            let image = UIImage(named: "avatar")
            flagAnnotationView.image = image
    
            
            // Offset the flag annotation so that the flag pole rests on the map coordinate.
            let offset = CGPoint(x: image?.size.width ?? 0 / 2, y: -(image?.size.height ?? 0 / 2) )
            flagAnnotationView.centerOffset = offset
            
            return flagAnnotationView
        }
        
    }
    

}

class TrainerAnnotationView : MKAnnotationView {

}

class TrainerAnnotation: NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 37.779_379, longitude: -122.418_433)
    
    var profile:Profile? = nil
    
    // Required if you set the annotation view's `canShowCallout` property to `true`
    //var title: String? = NSLocalizedString("SAN_FRANCISCO_TITLE", comment: "SF annotation")
//
//    // This property defined by `MKAnnotation` is not required.
//    var subtitle: String? = NSLocalizedString("SAN_FRANCISCO_SUBTITLE", comment: "SF annotation")
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        //MapView()
//    }
//}


func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return newImage
}
