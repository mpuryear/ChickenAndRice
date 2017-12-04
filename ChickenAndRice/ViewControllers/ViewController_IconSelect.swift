//
//  ViewController_IconSelect.swift
//  ChickenAndRice
//
//  Created by Bryan Carvalheira on 12/3/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController_IconSelect: UIViewController {
    
    @IBOutlet weak var catButton: UIButton!
    @IBOutlet weak var send_iconButton: UIButton!
    @IBOutlet weak var Chicken_and_riceButton: UIButton!
    @IBOutlet weak var chickenButton: UIButton!
    
    @IBAction func didTapCat(_ sender: Any) {
        print("didTapCatIcon")
        var image : UIImage
        let path = Bundle.main.path(forResource: "cat", ofType: "png")
        
        var thumbnail : Data
        // change the thumbnail now
        thumbnail = (NSData.init(contentsOfFile: path!) as Data?)!
        image = UIImage(imageLiteralResourceName: "cat" + ".png")
        
        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        Model_User.current_user.thumbnail = thumbnail
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
        print("got to the end of send icon")
    }
    
    @IBAction func didTapSend_Icon(_ sender: Any) {
        print("didTapSendIcon")
        var image : UIImage
        let path = Bundle.main.path(forResource: "send_icon", ofType: "png")
        
        var thumbnail : Data
        // change the thumbnail now
        thumbnail = (NSData.init(contentsOfFile: path!) as Data?)!
        image = UIImage(imageLiteralResourceName: "send_icon" + ".png")
        
        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        Model_User.current_user.thumbnail = thumbnail
        // code breaks here
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
        print("got to the end of send icon")
    }
    
    @IBAction func didTapChickenAndRice(_ sender: Any) {
        print("didTapSendIcon")
        var image : UIImage
        let path = Bundle.main.path(forResource: "chicken_and_rice", ofType: "jpeg")
        
        var thumbnail : Data
        // change the thumbnail now
        thumbnail = (NSData.init(contentsOfFile: path!) as Data?)!
        image = UIImage(imageLiteralResourceName: "chicken_and_rice" + ".jpeg")
        
        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        Model_User.current_user.thumbnail = thumbnail
        // code breaks here
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
        print("got to the end of chicken and rice")
    }
    
    
    @IBAction func didTapChicken(_ sender: Any) {
        print("didTapSendIcon")
        var image : UIImage
        let path = Bundle.main.path(forResource: "chicken", ofType: "png")
        
        var thumbnail : Data
        // change the thumbnail now
        thumbnail = (NSData.init(contentsOfFile: path!) as Data?)!
        image = UIImage(imageLiteralResourceName: "chicken" + ".png")
        
        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        Model_User.current_user.thumbnail = thumbnail
        // code breaks here
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
        print("got to the end of chicken")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // image 1
        var image1 : UIImage
        image1 = UIImage(imageLiteralResourceName: "cat" + ".png")
        image1 = resizeImage(image: image1, targetSize: CGSize(width: 32, height: 32))
        
        catButton.setTitle("", for: .normal)
        catButton.setBackgroundImage(image1, for: .normal)
        // image 2
        var image2 : UIImage
        image2 = UIImage(imageLiteralResourceName: "send_icon" + ".png")
        image2 = resizeImage(image: image2, targetSize: CGSize(width: 32, height: 32))
        
        send_iconButton.setTitle("", for: .normal)
        send_iconButton.setBackgroundImage(image2, for: .normal)
        //image 3
        var image3 : UIImage
        image3 = UIImage(imageLiteralResourceName: "chicken_and_rice" + ".jpeg")
        image3 = resizeImage(image: image3, targetSize: CGSize(width: 32, height: 32))
        
        Chicken_and_riceButton.setTitle("", for: .normal)
        Chicken_and_riceButton.setBackgroundImage(image3, for: .normal)
        //button 4
        var image4 : UIImage
        image4 = UIImage(imageLiteralResourceName: "chicken" + ".png")
        image4 = resizeImage(image: image4, targetSize: CGSize(width: 32, height: 32))
        
        chickenButton.setTitle("", for: .normal)
        chickenButton.setBackgroundImage(image4, for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
