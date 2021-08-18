//
//  ViewController.swift
//  PlaneScanner
//
//  Created by Eric Ciarla on 8/11/21.
//

import UIKit
import ARCL
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, LNTouchDelegate  {
     
    let locationManager = CLLocationManager()
    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        self.sceneLocationView.locationNodeTouchDelegate = self
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    func predictNextCoord(lat0: String, lon0: String, speed: String, heading: String, dtime: Double) -> (String, String) {
        let pi = Double.pi
        let Rt = 3964.037911746
        let vel = Double(speed)! * 1.15078
        let x = vel * sin(Double(heading)!*pi/180) * dtime / 3600
        let y = vel * cos(Double(heading)!*pi/180) * dtime / 3600
        let lat = Double(lat0)! + 180 / pi * y / Rt
        let lon = Double(lon0)! + 180 / pi / sin(Double(lat0)!*pi/180) * x / Rt
        return (String(lat),String(lon))
    }
    
    func annotationNodeTouched(node: AnnotationNode) {
        if let node = node.parent as? LocationNode {
            let coords = "\(node.location.coordinate.latitude.short)° \(node.location.coordinate.longitude.short)°"
            let altitude = "\(node.location.altitude.short)m"
            let tag = node.tag ?? ""
            //print (" Annotation node (tag)")
            let bottomLabel = UILabel()
            view.addSubview(bottomLabel)
            var result:[String] = []
            tag.enumerateLines { (line, _) -> () in
                result.append(line)
            }
            print(tag)
            let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .bold)]
            let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .regular)]
            let boldStringPart = NSMutableAttributedString(string: String(result[0]), attributes:attributsBold)
            let attributedString = NSMutableAttributedString(string: String(result[1]), attributes:attributsNormal)
            let newString = NSMutableAttributedString()
            newString.append(boldStringPart)
            newString.append(NSAttributedString(string: "\n"))
            newString.append(attributedString)
            bottomLabel.attributedText = newString
            bottomLabel.textAlignment = .center
            bottomLabel.textColor = UIColor.black
            bottomLabel.layer.cornerRadius = 10
            bottomLabel.numberOfLines = 2
            bottomLabel.layer.backgroundColor = UIColor.white.cgColor
            bottomLabel.translatesAutoresizingMaskIntoConstraints = false
            bottomLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 725).isActive = true
            bottomLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 90).isActive = true
            bottomLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10).isActive = true
            bottomLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90).isActive = true
            self.delayWithSeconds(10){
                bottomLabel.removeFromSuperview()
            }
        }
    }
    
    public func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func locationNodeTouched(node: LocationNode) {
        let coords = "\(node.location.coordinate.latitude.short)° \(node.location.coordinate.longitude.short)°"
        let altitude = "\(node.location.altitude.short)m"
        let tag = node.tag ?? ""
        print(" Location node at \(coords), \(altitude) - \(tag)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nodeGen = NodeGen()
        
        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            
            var currentLoc: CLLocation!
            currentLoc = self.locationManager.location
            // Json request
            let headers = [
                "x-rapidapi-key": "",
                "x-rapidapi-host": ""
            ]
            
            let request = NSMutableURLRequest(url: NSURL(string: "https://adsbexchange-com1.p.rapidapi.com/json/lat/" + String(currentLoc.coordinate.latitude) + "/lon/" + String(currentLoc.coordinate.longitude) + "/dist/15/")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    let httpResponse = response as? HTTPURLResponse
           
                    struct Root : Codable {
                        let ac : [PlaneData]
                    }
                    struct PlaneData: Codable {
                        let postime: String
                        let type: String
                        let call: String
                        let spd: String
                        let lat: String
                        let lon: String
                        let alt: String
                        let dst: String
                        let trak: String
                    }
                    //print(httpResponse)
                    //print(data!)
                    
                    do {
                        let result = try JSONDecoder().decode(Root.self, from: data!)
                        var filtered_result = result.ac.filter { $0.spd != "0" }
                        filtered_result = filtered_result.filter { $0.alt != "" }
                        var ret = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_1 = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_2 = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_3 = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_4 = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_5 = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_6 = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_7 = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_8 = [(String,String,String,String,String,String,String,String, String)]()
                        var ret_9 = [(String,String,String,String,String,String,String,String, String)]()
        
                        for i in filtered_result {
                            let t_after = ((NSDate().timeIntervalSince1970*1000) - Double(i.postime)!)/1000
                            print(String(t_after) + " " + i.call)
                            let predCoord = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after)
                            let predCoord1 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 0.5)
                            let predCoord2 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 1)
                            let predCoord3 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 1.5)
                            let predCoord4 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 2)
                            let predCoord5 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 2.5)
                            let predCoord6 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 3)
                            let predCoord7 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 3.5)
                            let predCoord8 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 4)
                            let predCoord9 = self.predictNextCoord(lat0:i.lat, lon0: i.lon, speed: i.spd, heading: i.trak, dtime: t_after + 4.5)
                            ret.append((i.postime,i.type,i.call,i.spd,predCoord.0,predCoord.1,i.alt,i.dst,i.trak))
                            ret_1.append((i.postime,i.type,i.call,i.spd,predCoord1.0,predCoord1.1,i.alt,i.dst,i.trak))
                            ret_2.append((i.postime,i.type,i.call,i.spd,predCoord2.0,predCoord2.1,i.alt,i.dst,i.trak))
                            ret_3.append((i.postime,i.type,i.call,i.spd,predCoord3.0,predCoord3.1,i.alt,i.dst,i.trak))
                            ret_4.append((i.postime,i.type,i.call,i.spd,predCoord4.0,predCoord4.1,i.alt,i.dst,i.trak))
                            ret_5.append((i.postime,i.type,i.call,i.spd,predCoord5.0,predCoord5.1,i.alt,i.dst,i.trak))
                            ret_6.append((i.postime,i.type,i.call,i.spd,predCoord6.0,predCoord6.1,i.alt,i.dst,i.trak))
                            ret_7.append((i.postime,i.type,i.call,i.spd,predCoord7.0,predCoord7.1,i.alt,i.dst,i.trak))
                            ret_8.append((i.postime,i.type,i.call,i.spd,predCoord8.0,predCoord8.1,i.alt,i.dst,i.trak))
                            ret_9.append((i.postime,i.type,i.call,i.spd,predCoord8.0,predCoord8.1,i.alt,i.dst,i.trak))
                        }
                        
                        let nodes = nodeGen.genNodes(planes: ret)
                        let nodes_1 = nodeGen.genNodes(planes: ret_1)
                        let nodes_2 = nodeGen.genNodes(planes: ret_2)
                        let nodes_3 = nodeGen.genNodes(planes: ret_3)
                        let nodes_4 = nodeGen.genNodes(planes: ret_4)
                        let nodes_5 = nodeGen.genNodes(planes: ret_5)
                        let nodes_6 = nodeGen.genNodes(planes: ret_6)
                        let nodes_7 = nodeGen.genNodes(planes: ret_7)
                        let nodes_8 = nodeGen.genNodes(planes: ret_8)
                        let nodes_9 = nodeGen.genNodes(planes: ret_9)
                        nodes.forEach {
                            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                        }
                        self.delayWithSeconds(0.5){
                            self.sceneLocationView.removeLocationNodes(locationNodes: nodes)
                            nodes_1.forEach {
                                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                            }
                            self.delayWithSeconds(0.5){
                                self.sceneLocationView.removeLocationNodes(locationNodes: nodes_1)
                                nodes_2.forEach {
                                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                                }
                                self.delayWithSeconds(0.5){
                                    self.sceneLocationView.removeLocationNodes(locationNodes: nodes_2)
                                    nodes_3.forEach {
                                        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                                    }
                                    self.delayWithSeconds(0.5){
                                        self.sceneLocationView.removeLocationNodes(locationNodes: nodes_3)
                                        nodes_4.forEach {
                                            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                                        }
                                        self.delayWithSeconds(0.5){
                                            self.sceneLocationView.removeLocationNodes(locationNodes: nodes_4)
                                            nodes_5.forEach {
                                                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                                            }
                                            self.delayWithSeconds(0.5){
                                                self.sceneLocationView.removeLocationNodes(locationNodes: nodes_5)
                                                nodes_6.forEach {
                                                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                                                }
                                                self.delayWithSeconds(0.5){
                                                    self.sceneLocationView.removeLocationNodes(locationNodes: nodes_6)
                                                    nodes_7.forEach {
                                                        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                                                    }
                                                    self.delayWithSeconds(0.5){
                                                        self.sceneLocationView.removeLocationNodes(locationNodes: nodes_7)
                                                        nodes_8.forEach {
                                                            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                                                        }
                                                        self.delayWithSeconds(0.5){
                                                            self.sceneLocationView.removeLocationNodes(locationNodes: nodes_8)
                                                            self.sceneLocationView.removeLocationNodes(locationNodes: nodes_7)
                                                            nodes_9.forEach {
                                                                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
                                                            }
                                                            self.delayWithSeconds(0.40){
                                                                self.sceneLocationView.removeLocationNodes(locationNodes: nodes_9)
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
         
                        }
                    } catch let error {
                        print("json error: \(error)")
                    }
                    
                }
            })
            
            dataTask.resume()
            
            
        }
        
    }
    
}

