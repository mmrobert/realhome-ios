//
//  Buyer.swift
//  RealHome
//
//  Created by boqian cheng on 2017-12-21.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import Marshal

struct BuyerFIR: Unmarshaling {
    
    var email: String?
    var firstName: String?
    var lastName: String?
    var nickName: String?
    var phone: String?
    var photo: String?
    
    
    init(object: MarshaledObject) {
        email = try? object.value(for: "email")
        firstName = try? object.value(for: "firstName")
        lastName = try? object.value(for: "lastName")
        nickName = try? object.value(for: "nickName")
        phone = try? object.value(for: "phone")
        photo = try? object.value(for: "photo")
    }
}

extension BuyerFIR: Marshaling {
    func marshaled() -> [String:Any] {
        return [
            "email" : email ?? "",
            "firstName" : firstName ?? "",
            "lastName" : lastName ?? "",
            "nickName" : nickName ?? "",
            "phone" : phone ?? "",
            "photo" : photo ?? ""
        ]
    }
}

