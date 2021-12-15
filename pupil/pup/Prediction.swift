//
//  Prediction.swift
//  pup
//
//  Created by Miguel Tamayo on 3/19/21.
//

import RealmSwift

class Prediction: Object {
    @objc dynamic var date: String = ""
    @objc dynamic var prediction: String = ""
//    init(date: String, prediction: String) {
//        self.date = date
//        self.prediction = prediction
//    }
}
