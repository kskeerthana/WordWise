//
//  CameraViewController.swift
//  FinalProject
//
//  Created by Nikethana N N on 11/22/23.
//

import UIKit
import Vision
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
         }
        catch
        { print("Fail to enable session") }
    }
    var image: UIImage?
    var recognizedText: String = ""
    
    func presentImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available on this device.")
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let uiImage = info[.originalImage] as? UIImage {
            processImage(uiImage)
        }
    }
    
    private func processImage(_ image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//
//        let request = VNRecognizeTextRequest { [weak self] (request, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//            self.recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
//        }
//
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
//        try? requestHandler.perform([request])
        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { observation -> String? in
                guard let candidate = observation.topCandidates(1).first else { return nil }
                return candidate.confidence > 0.8 ? candidate.string : nil // Adjust confidence threshold as needed
            }.joined(separator: " ")

            DispatchQueue.main.async {
                self.recognizedText = recognizedStrings
            }
        }

        request.recognitionLevel = .accurate // Set recognition level to accurate for better results
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        try? requestHandler.perform([request])
    }

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    @IBAction func btnClicked(_ sender: UIButton) {
        print("Recognized text : \(recognizedText)")
        speak(text: recognizedText)
    }
    @IBAction func imgBtnClicked(_ sender: UIButton) {
        presentImagePicker()
    }

    @IBAction func goToGame(_ sender: UIButton) {
        performSegue(withIdentifier: "GameSegue", sender: nil)
    }
}
