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
    let profileButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
         }
        catch
        { print("Fail to enable session") }
        
        // Configure the button
        profileButton.setTitle("PP", for: .normal) // Set the text for the button
        profileButton.titleLabel?.font = UIFont.systemFont(ofSize: 24) // Adjust the font size as needed

        profileButton.backgroundColor = .lightGray // Or any color you prefer
        profileButton.setTitleColor(.black, for: .normal) // Set the text color
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)

        // Add the button to the view hierarchy
        view.addSubview(profileButton)

        // Disable autoresizing masks and set constraints
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            profileButton.widthAnchor.constraint(equalToConstant: 60), // Increased width
            profileButton.heightAnchor.constraint(equalToConstant: 60)  // Increased height
        ])

        // Make the button circular
        profileButton.layer.cornerRadius = 30 // Half of width or height
        profileButton.clipsToBounds = true
    }
    var image: UIImage?
    var recognizedText: String = ""
    
    @objc func profileButtonTapped() {
        // Handle the button tap
        print("Profile button tapped")
        let profileVC = ProfileViewController()
        profileVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a transparent background
        self.present(profileVC, animated: true, completion: nil)
        }
    
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
