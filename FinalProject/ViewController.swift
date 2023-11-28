//
//  ViewController.swift
//  FinalProject
//
//  Created by Nikethana N N on 11/22/23.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController {
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

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Choose the desired language
        utterance.rate = 0.5 // Adjust the speech rate as needed
        synthesizer.speak(utterance)
    }

    @IBAction func btnClicked(_ sender: UIButton) {
        let textToSpeak = "Hello, World! This is a test." // Replace with your desired text
        speak(text: textToSpeak)
    }
    func recognizeText(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Error recognizing text: \(error)")
                completion(nil)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }

            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: " ")

            completion(recognizedText)
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        try? requestHandler.perform([textRecognitionRequest])
    }
}

