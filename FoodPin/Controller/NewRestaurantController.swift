//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by wyn on 2020/4/7.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class NewRestaurantController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var restaurant: RestaurantMO!
    
    @IBOutlet var nameTextField: RoundedTextField! {
        didSet{
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    @IBOutlet var typeTextField: RoundedTextField! {
        didSet{
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    @IBOutlet var addressTextField: RoundedTextField! {
        didSet{
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    @IBOutlet var phoneTextField: RoundedTextField! {
        didSet{
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    @IBOutlet var descriptionTextView: UITextView! {
        didSet{
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 5.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var saveButton: UIButton!
    @IBAction func saveButtonTapped(sender: UIBarButtonItem){

        if nameTextField.text == "" || typeTextField.text == "" || addressTextField.text == "" || phoneTextField.text == "" || descriptionTextView.text == "" {
            let alertController = UIAlertController(title: NSLocalizedString("Oops", comment: "Oops"), message: NSLocalizedString("We can't proceed because one of fields is blank. Please note that all fields are required", comment: "We can't proceed because one of fields is blank. Please note that all fields are required"), preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: "OK"), style: UIAlertAction.Style.default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }else{
            print("Name: \(nameTextField.text ?? "")")
            print("Type: \(typeTextField.text ?? "")")
            print("Location: \(addressTextField.text ?? "")")
            print("Phone: \(phoneTextField.text ?? "")")
            print("Description: \(descriptionTextView.text ?? "")")
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
                restaurant.name = nameTextField.text
                restaurant.type = typeTextField.text
                restaurant.location = addressTextField.text
                restaurant.phone = phoneTextField.text
                restaurant.summary = descriptionTextView.text
                restaurant.isVisited = false
                
                if let restaurantImage = photoImageView.image {
                    restaurant.image = restaurantImage.pngData()
                }
                
                print("Saving data to context ...")
                appDelegate.saveContext()
            }
            
            saveRecordToCloud(restaurant: restaurant)
            
            dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        
        let leadingConstraint = NSLayoutConstraint(item: photoImageView as Any, attribute: .leading, relatedBy: .equal, toItem: photoImageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView as Any, attribute: .trailing, relatedBy: .equal, toItem: photoImageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: photoImageView as Any, attribute: .top, relatedBy: .equal, toItem: photoImageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: photoImageView as Any, attribute: .bottom, relatedBy: .equal, toItem: photoImageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let photoSourceRequestController = UIAlertController(title: "",message: NSLocalizedString("Choose your photo source", comment: "Choose your photo source"), preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"),style: .default, handler: {
                (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self


                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo library", comment: "Photo library"), style: .default, handler: {
                (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self

                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Gotu-Regular", size: 35.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60),
                NSAttributedString.Key.font: customFont]
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
    func saveRecordToCloud(restaurant:RestaurantMO) -> Void {
        
        // The data prepared for saving
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.summary, forKey: "description")
        record.setValue(restaurant.phone, forKey: "phone")
        
        let imageData = restaurant.image! as Data
        
        // Adjust image size
        let originalImage = UIImage(data: imageData)!
        let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
        let scaledImage = UIImage(data: imageData, scale: scalingFactor)!
        
        // Saving image into local side for using temporarily
        let imageFilePath = NSTemporaryDirectory() + restaurant.name!
        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        try? scaledImage.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
        
        // Create image asset for uploading
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKey: "image")
        
        // Reading public iCloud database
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        // Saving data to iCloud
        publicDatabase.save(record, completionHandler: { (record, error) -> Void in
            // Delete temporary data
            try? FileManager.default.removeItem(at: imageFileURL)
        })
    }
}
