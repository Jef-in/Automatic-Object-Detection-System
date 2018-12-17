//
//  ViewController.swift
//  Machine Learning
//
//  Created by Arun Aravindakshan on 17/12/18.
//  Copyright © 2018 Jefin. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      myView.layer.frame = view.layer.frame
        let captureSession = AVCaptureSession()
      captureSession.sessionPreset = .photo
        
        guard  let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = myView.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
       // let  request = VNCoreMLRequest(model: <#T##VNCoreMLModel#>, completionHandler: <#T##VNRequestCompletionHandler?##VNRequestCompletionHandler?##(VNRequest, Error?) -> Void#>)
        
        //VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
      //  print("Camera was able to capture frame",Date())
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let  request = VNCoreMLRequest(model: model)
        {(finishreq,err) in
            
         //   print(finishreq.results)
          guard  let results = finishreq.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else {return}
           
      
            
            if firstObservation.confidence > 0.5{
           // self.predictionLabel.text = firstObservation as? String
              //  self.label.frame = self.view.frame
              //  self.label.textAlignment = .center
                DispatchQueue.main.async {
                    self.label?.text = "The detected object is : \(firstObservation.identifier )"
                }
       
    print(firstObservation.identifier,firstObservation.confidence)
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}

