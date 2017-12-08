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
    
    @IBOutlet weak var jigglyButton: UIButton!
    @IBOutlet weak var cakeButton: UIButton!
    @IBOutlet weak var digimonButton: UIButton!
    @IBOutlet weak var beybladeButton: UIButton!
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
    @IBAction func didTapJiggly(_ sender: Any) {
        print("didTapJiggly")
        var image : UIImage
        let path = Bundle.main.path(forResource: "jiggly", ofType: "png")
        
        var thumbnail : Data
        // change the thumbnail now
        thumbnail = (NSData.init(contentsOfFile: path!) as Data?)!
        image = UIImage(imageLiteralResourceName: "jiggly" + ".png")
        
        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        Model_User.current_user.thumbnail = thumbnail
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
        print("got to the end of jiggly")
    }
    @IBAction func didTapCake(_ sender: Any) {
        print("didTapCake")
        var image : UIImage
        let path = Bundle.main.path(forResource: "cake", ofType: "jpg")
        
        var thumbnail : Data
        // change the thumbnail now
        thumbnail = (NSData.init(contentsOfFile: path!) as Data?)!
        image = UIImage(imageLiteralResourceName: "cake" + ".jpg")
        
        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        Model_User.current_user.thumbnail = thumbnail
        // code breaks here
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
        print("got to the end of cake")
    }
    
    @IBAction func didTapDigimon(_ sender: Any) {
        print("didTapDigimon")
        var image : UIImage
        let path = Bundle.main.path(forResource: "agumon", ofType: "png")
        
        var thumbnail : Data
        // change the thumbnail now
        thumbnail = (NSData.init(contentsOfFile: path!) as Data?)!
        image = UIImage(imageLiteralResourceName: "agumon" + ".png")
        
        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        Model_User.current_user.thumbnail = thumbnail
        // code breaks here
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
        print("got to the end of digi")
    }
    
    @IBAction func didTapBeyblade(_ sender: Any) {
        print("didTapBeyblade")
        var image : UIImage
        let path = Bundle.main.path(forResource: "beyblade", ofType: "jpg")
        
        var thumbnail : Data
        // change the thumbnail now
        thumbnail = (NSData.init(contentsOfFile: path!) as Data?)!
        image = UIImage(imageLiteralResourceName: "beyblade" + ".jpg")
        
        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        Model_User.current_user.thumbnail = thumbnail
        // code breaks here
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
        print("got to the end of blade")
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

        //image 5
        var image5 : UIImage
        image5 = UIImage(imageLiteralResourceName: "jiggly" + ".png")
        image5 = resizeImage(image: image5, targetSize: CGSize(width: 32, height: 32))
        
        jigglyButton.setTitle("", for: .normal)
        jigglyButton.setBackgroundImage(image5, for: .normal)
        
        //image 6
        var image6 : UIImage
        image6 = UIImage(imageLiteralResourceName: "cake" + ".jpg")
        image6 = resizeImage(image: image6, targetSize: CGSize(width: 32, height: 32))
        
        cakeButton.setTitle("", for: .normal)
        cakeButton.setBackgroundImage(image6, for: .normal)
        
        //image 7
        var image7 : UIImage
        image7 = UIImage(imageLiteralResourceName: "agumon" + ".png")
        image7 = resizeImage(image: image7, targetSize: CGSize(width: 32, height: 32))
        
        digimonButton.setTitle("", for: .normal)
        digimonButton.setBackgroundImage(image7, for: .normal)
        
        //image 8
        var image8 : UIImage
        image8 = UIImage(imageLiteralResourceName: "beyblade" + ".jpg")
        image8 = resizeImage(image: image8, targetSize: CGSize(width: 32, height: 32))
        
        beybladeButton.setTitle("", for: .normal)
        beybladeButton.setBackgroundImage(image8, for: .normal)


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
