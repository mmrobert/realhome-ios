//
//  Message.swift
//  RealHome
//
//  Created by boqian cheng on 2017-12-21.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import Marshal

struct MessageFIR: Unmarshaling {
    
    var timeStamp: String?
    var senderEmail: String?
    var receiverEmail: String?
    var textMsg: String?
    var imgURL: String?
    
    
    init(object: MarshaledObject) {
        timeStamp = try? object.value(for: "timeStamp")
        senderEmail = try? object.value(for: "senderEmail")
        receiverEmail = try? object.value(for: "receiverEmail")
        textMsg = try? object.value(for: "textMsg")
        imgURL = try? object.value(for: "imgURL")
    }
}

extension MessageFIR: Marshaling {
    func marshaled() -> [String:Any] {
        return [
            "timeStamp" : timeStamp ?? "",
            "senderEmail" : senderEmail ?? "",
            "receiverEmail" : receiverEmail ?? "",
            "textMsg" : textMsg ?? "",
            "imgURL" : imgURL ?? ""
        ]
    }
}

