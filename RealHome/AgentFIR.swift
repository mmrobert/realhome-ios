//
//  Agent.swift
//  RealHome
//
//  Created by boqian cheng on 2017-12-21.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import Marshal

struct AgentFIR: Unmarshaling {
    
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var nickName: String?
    public var phone: String?
    public var photo: String?
    
    
    init(object: MarshaledObject) {
        email = try? object.value(for: "email")
        firstName = try? object.value(for: "firstName")
        lastName = try? object.value(for: "lastName")
        nickName = try? object.value(for: "nickName")
        phone = try? object.value(for: "phone")
        photo = try? object.value(for: "photo")
    }
    
    init() {
        
    }
}

extension AgentFIR: Marshaling {
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

