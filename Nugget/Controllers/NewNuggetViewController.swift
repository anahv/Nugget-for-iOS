//
//  NewNuggetViewController.swift
//  Nugget
//
//  Created by Ana on 11/06/2020.
//  Copyright © 2020 ana. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class NewNuggetViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let notifications = Notifications()
    let dateToString = DateToString()
    let saveNugget = SaveNugget()
    
    @IBOutlet weak var bellButton: UIBarButtonItem!
    
    var newNugget: Nugget? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if newNugget?.body == nil  {
            textView.becomeFirstResponder()
        }
        navigationController?.navigationBar.isTranslucent = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if newNugget?.body != nil {
            textView.text = newNugget!.body
        }
        
        if newNugget?.image != nil {
            imageView.image = UIImage(data: newNugget!.image!)
        }
        
        textView.delegate = self
        if textView.text.isEmpty {
            bellButton.isEnabled = false
        }
        
        //        textView.alwaysBounceVertical = true
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            print("here lol")
            newNugget!.body = textView.text
            saveNugget.saveNugget()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view will disappear")
        if self.isMovingFromParent {
            if textView.text.isEmpty && imageView.image == nil {
                context.delete(newNugget!)
            }
            else {
                scheduleNotification()
            }
        }
        notifications.notificationCenter.delegate = notifications
        notifications.notificationRequest()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReminderSettingsSegue",
            let destination = segue.destination as? ReminderSettingsViewController {
            destination.selectedNugget = newNugget
        }
    }
    
    
    //MARK: - Disable Reminders button
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let text = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if text.isEmpty {
            bellButton.isEnabled = false
        } else {
            bellButton.isEnabled = true
        }
        return true
    }
    
    
    // MARK: - Camera stuff
    
    @IBOutlet weak var cameraIcon: UIBarButtonItem!
    
    @IBAction func cameraIcon(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take New Photo", style: .default, handler: {
            action in self.openCamera() })
        cameraAction.setValue((UIImage(systemName: "camera")), forKey: "image")
        
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in self.openGallery() })
        galleryAction.setValue((UIImage(systemName: "photo")), forKey: "image")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        print("camera opened")
    }
    
    func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        imageView.image = image
        
        let data = imageView.image?.pngData()
        
        newNugget?.image = data
        if newNugget?.body == nil {
            newNugget?.body = "Image Nugget"
        }
        saveNugget.saveNugget()
    }
    
    // Allow you to save the picture
    @IBAction func save() {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            let successMessage = UIAlertController(title: "Saved", message: "Your image Nugget has been saved to your Photos.", preferredStyle: .alert)
            successMessage.addAction(UIAlertAction(title: "Ok", style: .default))
            present(successMessage, animated: true)
        }
    }
    
    // MARK: - Schedule notifications (rather messy and should be cleaned)
    
    func scheduleNotification() {
        if let body = newNugget?.body, let id = newNugget?.id, let date = newNugget?.date, let frequency = newNugget?.frequency  {
            self.notifications.scheduleNotification(id: id, date: date, body: body, frequency: frequency, image: newNugget?.image)
        }
        else {
            print("There is a nil value in the nugget. \(newNugget?.body) \(newNugget?.id) \(newNugget?.date) \(newNugget?.frequency)")
        }
    }
    
    // Hide keyboard if scorrling upwards
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0)
        {
            textView.resignFirstResponder()
        }
    }
    
}





// MARK: - Unused stuff

//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Heebo-Regular", size: 15)!], for: UIControl.State.normal)

//        self.view.backgroundColor = UIColor(hexString: newNugget!.colour!)
//        textView.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)


// This used to be in the imagepicker thing to make the image part of a string
//        let attributedString = NSMutableAttributedString(string: "before after")
//        let textAttachment = NSTextAttachment()
//        textAttachment.image = image
//        let myCIImage = CIImage(image: image)
//        let oldWidth = image.size.width
//        let scaleFactor = oldWidth / (textView.frame.size.width - 10); // for the padding inside the textView
//        textAttachment.image = UIImage(ciImage: myCIImage!, scale: scaleFactor, orientation: .up)
//        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
//        attributedString.replaceCharacters(in: NSMakeRange(6, 1), with: attrStringWithImage)
//        attributedString.append(attrStringWithImage)
//        textView.attributedText = attributedString;
//        self.view.addSubview(textView)
