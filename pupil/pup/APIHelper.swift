//
//  APIHelper.swift
//  pup
//
//  Created by Miguel Tamayo on 3/19/21.
//

import Alamofire
import SwiftyJSON
import RealmSwift

let config = Realm.Configuration(
  schemaVersion: 0,
  deleteRealmIfMigrationNeeded: true
)

let realmDB = try! Realm(configuration: config)

public class API {
    static func predict(image: UIImage, completion: @escaping (Bool, JSON?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {
            print("could not convert image to image data")
            fatalError()
        }
        
//        AF.upload(multipartFormData: { multipartFormData in
//            multipartFormData.append(imageData, withName: "file", fileName: "file.png", mimeType: "image/png")
//        }, to: "http://100.25.150.145:5000/predict", method: .post).responseJSON { response in
//            if let data = response.data {
//                let json = JSON(data)
//                print("json:", json)
//            }
//        }

        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "file", fileName: "file.png", mimeType: "image/png")
        }, to: "http://100.25.150.145:5000/predict", method: .post).responseJSON { response in
            if let data = response.data {
                let json = JSON(data)
                print("json:", json)
                completion(true, json)
            }
            else {
                completion(false, nil)
            }
        }

        
        
    }
}
