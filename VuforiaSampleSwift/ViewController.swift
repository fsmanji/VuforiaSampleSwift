//
//  ViewController.swift
//  VuforiaSample
//
//  Created by Yoshihiro Kato on 2016/07/02.
//  Copyright © 2016年 Yoshihiro Kato. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let vuforiaLicenseKey = "AdVIJLb/////AAAAGT4gw8wDc0sto/vikM/XeppmDYBQ4IH6Yj9S7KrtpYpMK/P//kKojvhD5OLAQfVOBUKnzf88NiRzdAFtZf0Q4t/11/Yv3OUHQwJpFx/vkIoA9TKJiACteL+se0oSQjzbP5dV15qFvfq3+LVvtxG0I6FJ0ceh/JKMTsPp1ysLstjTR4+d+45qJaZ69bVzAiVaUSadAy9SCFOA2OSBuPp5e3C5gG7PlBQyZxjLAbRP8CxBG2ujMSMeVtvC0A1A3IF3hQ8MW0f5VmuY7r3i2GvLBZ4LTpoFwXOFlHAechT9lzPi4mOyK/873YYwUzaBr8tc3tbXQlD7kPgeKx5J8NYSId79WK2bKSdCIMaqi1JP1rMf"
    
    // If you have customized target xml file, e.g. if you use ObjectScanner to create one, you should 
    // put it in copied resources and put the name here.
    // Here I just use the sample 'Image Target' file.
    let vuforiaDataSetFile = "StonesAndChips.xml"
    
    var vuforiaManager: VuforiaManager? = nil
    
    let boxMaterial = SCNMaterial()
    
    let redFlagImageMaterial = SCNMaterial()
    
    let redpinImageMaterial = SCNMaterial()
    
    fileprivate var lastSceneName: String? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load image assets
        redFlagImageMaterial.diffuse.contents = UIImage(named:"red_anchor")
        redpinImageMaterial.diffuse.contents = UIImage(named:"red_pin")
        
        prepare()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try vuforiaManager?.stop()
        }catch let error {
            print("\(error)")
        }
    }
}

private extension ViewController {
    func prepare() {
        vuforiaManager = VuforiaManager(licenseKey: vuforiaLicenseKey, dataSetFile: vuforiaDataSetFile)
        if let manager = vuforiaManager {
            manager.delegate = self
            manager.eaglView.sceneSource = self
            manager.eaglView.delegate = self
            manager.eaglView.setupRenderer()
            self.view = manager.eaglView
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didRecieveWillResignActiveNotification),
                                       name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(didRecieveDidBecomeActiveNotification),
                                       name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        vuforiaManager?.prepare(with: .portrait)
    }
    
    func pause() {
        do {
            try vuforiaManager?.pause()
        }catch let error {
            print("\(error)")
        }
    }
    
    func resume() {
        do {
            try vuforiaManager?.resume()
        }catch let error {
            print("\(error)")
        }
    }
}

extension ViewController {
    func didRecieveWillResignActiveNotification(_ notification: Notification) {
        pause()
    }
    
    func didRecieveDidBecomeActiveNotification(_ notification: Notification) {
        resume()
    }
}

extension ViewController: VuforiaManagerDelegate {
    func vuforiaManagerDidFinishPreparing(_ manager: VuforiaManager!) {
        print("did finish preparing\n")
        
        do {
            try vuforiaManager?.start()
            vuforiaManager?.setContinuousAutofocusEnabled(true)
        }catch let error {
            print("\(error)")
        }
    }
    
    func vuforiaManager(_ manager: VuforiaManager!, didFailToPreparingWithError error: Error!) {
        print("did faid to preparing \(error)\n")
    }
    
    func vuforiaManager(_ manager: VuforiaManager!, didUpdateWith state: VuforiaState!) {
        for index in 0 ..< state.numberOfTrackableResults {
            let result = state.trackableResult(at: index)
            let trackerableName = result?.trackable.name
            //print("\(trackerableName)")
            if trackerableName == "stones" {
                boxMaterial.diffuse.contents = UIColor.red
                
                if lastSceneName != "stones" {
                    manager.eaglView.setNeedsChangeSceneWithUserInfo(["scene" : "stones"])
                    lastSceneName = "stones"
                }
            }else {
                boxMaterial.diffuse.contents = UIColor.blue
                
                if lastSceneName != "chips" {
                    manager.eaglView.setNeedsChangeSceneWithUserInfo(["scene" : "chips"])
                    lastSceneName = "chips"
                }
            }
            
        }
    }
}

extension ViewController: VuforiaEAGLViewSceneSource, VuforiaEAGLViewDelegate {

    func scene(for view: VuforiaEAGLView!, userInfo: [String : Any]?) -> SCNScene! {
        guard let userInfo = userInfo else {
            print("default scene")
            return createStonesScene(with: view)
        }
        
        if let sceneName = userInfo["scene"] as? String , sceneName == "stones" {
            print("stones scene")
            //return createStonesScene(with: view)
            return testScene()
        }else {
            print("chips scene")
            return createChipsScene(with: view)
        }
        
    }
    
    fileprivate func createStonesScene(with view: VuforiaEAGLView) -> SCNScene {
        let scene = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        boxMaterial.diffuse.contents = UIColor.lightGray
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.lightGray
        lightNode.position = SCNVector3(x:0, y:10, z:10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let planeNode = SCNNode()
        planeNode.name = "plane"
        planeNode.geometry = SCNPlane(width: 24.7*view.objectScale, height: 17.3*view.objectScale)
        //planeNode.position = SCNVector3Make(0, 0, -1)
        
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.green
        planeMaterial.transparency = 0.6
        planeNode.geometry?.firstMaterial = planeMaterial
        
        planeNode.constraints = [SCNBillboardConstraint()]
        scene.rootNode.addChildNode(planeNode)
        //planeNode.camera = SCNCamera()
        
        
        let boxNode = SCNNode()
        boxNode.name = "box"
        boxNode.geometry = SCNBox(width:1, height:1, length:0.1, chamferRadius:0.5)
        boxNode.geometry?.firstMaterial = redFlagImageMaterial
        boxNode.scale = SCNVector3Make(2.0, 2.0, 2.0)
        //boxNode.rotation = SCNVector4Make(<#T##x: Float##Float#>, <#T##y: Float##Float#>, <#T##z: Float##Float#>, <#T##w: Float##Float#>)
//        boxNode.position = SCNVector3(x:0, y:0, z:-5);
//        boxNode.constraints = [SCNBillboardConstraint()];
//        boxNode.camera = SCNCamera()
        scene.rootNode.addChildNode(boxNode)
        

        return scene
    }
    
    fileprivate func createChipsScene(with view: VuforiaEAGLView) -> SCNScene {
        let scene = SCNScene()
        
        boxMaterial.diffuse.contents = UIColor.lightGray
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.lightGray
        lightNode.position = SCNVector3(x:0, y:10, z:10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let planeNode = SCNNode()
        planeNode.name = "plane"
        planeNode.geometry = SCNPlane(width: 247.0*view.objectScale, height: 173.0*view.objectScale)
        planeNode.position = SCNVector3Make(0, 0, -1)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.red
        planeMaterial.transparency = 0.6
        planeNode.geometry?.firstMaterial = planeMaterial
        scene.rootNode.addChildNode(planeNode)
        
        let boxNode = SCNNode()
        boxNode.name = "box"
        boxNode.geometry = SCNBox(width:1, height:1, length:1, chamferRadius:0.0)
        boxNode.geometry?.firstMaterial = boxMaterial
        scene.rootNode.addChildNode(boxNode)
        
        // Add lables
        let label1 = SCNNode.init(geometry: SCNPlane(width: 0.5, height: 0.5))
        label1.name = "AlienButton1"
        label1.geometry?.firstMaterial = redFlagImageMaterial
        label1.position = SCNVector3Make(0, 0, 1)
        label1.eulerAngles = SCNVector3Make(Float.pi/2, 0, 0)
        
        // set a light for lightening lable1, otherwise it would be very dark
        let light4Label1 = SCNNode()
        light4Label1.light = SCNLight()
        light4Label1.light?.type = .omni
        light4Label1.light?.color = UIColor.lightGray
        light4Label1.position = SCNVector3(x:0, y:-10, z:1)
        scene.rootNode.addChildNode(light4Label1)
        
        let label2 = SCNNode.init(geometry: SCNPlane(width: 0.5, height: 0.5))
        label2.name = "AlienButton2"
        label2.geometry?.firstMaterial = redFlagImageMaterial
        label2.position = SCNVector3Make(1, 0.5, 1)
        label2.eulerAngles = SCNVector3Make(0, 0, -Float.pi/4.0)
        label2.scale = SCNVector3Make(0.5, 0.5, 0.5)
        
        scene.rootNode.addChildNode(label1)
        scene.rootNode.addChildNode(label2)

        
        return scene
    }
    
    fileprivate func testScene()->SCNScene {
        // create a new scene
        let scene = SCNScene()
        
        let side = CGFloat(2.0)
        let quad1 = SCNNode.init(geometry: SCNPlane(width: side/2, height: side/2))
        quad1.name = "green"
        quad1.geometry?.firstMaterial = redpinImageMaterial
        
        let quad2 = SCNNode.init(geometry: SCNPlane(width: side/2, height: side/2))
        quad2.name = "red"
        quad2.geometry?.firstMaterial = redpinImageMaterial
        
        let quad3 = SCNNode.init(geometry: SCNPlane(width: side, height: side))
        quad3.name = "blue"
        quad3.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        scene.rootNode.addChildNode(quad1)
        scene.rootNode.addChildNode(quad2)
        scene.rootNode.addChildNode(quad3)
        
        let rotation = CGFloat(Double.pi) / 4.0
        quad1.position.x = -2
        quad1.position.y = 2
        quad1.position.z = 2
        quad1.eulerAngles.z = Float(rotation)
        
        quad2.position.y = 2
        quad2.position.x = 2
        quad2.position.z = 2
        quad2.eulerAngles.z = Float(-rotation)
        
        // comment out these constraints to verify that they matter
        //quad1.constraints = [SCNBillboardConstraint()]
        //quad2.constraints = [SCNBillboardConstraint()]

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        //cameraNode.constraints = [SCNLookAtConstraint(target: quad1)]
        //quad1.camera = cameraNode.camera
        
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        return scene;
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchDownNode node: SCNNode!) {
        print("touch down \(node.name ?? "")\n")
        //Only change the clicked node's appearance
        if (node.name == "box") {
            node.geometry?.firstMaterial?.transparency = 0.6
        }
        
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchUp node: SCNNode!) {
        print("touch up \(node.name ?? "")\n")
        boxMaterial.transparency = 1.0
    }
    
    func vuforiaEAGLView(_ view: VuforiaEAGLView!, didTouchCancel node: SCNNode!) {
        print("touch cancel \(node.name ?? "")\n")
        boxMaterial.transparency = 1.0
    }
}

