//
//  firebaseNodesCreation.swift
//  RealHome
//
//  Created by boqian cheng on 2017-12-24.
//  Copyright © 2017 boqiancheng. All rights reserved.
//
//    firRoot:
//        agentGroup1:
//                 title: "agentGroup1",
//                 agents:
//                     title: "agents"
//                     emailCode(agent1):
//                         email:
//                         name:
//                         nickname:
//                 buyers:
//                     title: "buyers"
//                     emailCode(buyer1):
//                         email:
//                         name:
//                         nickname:
//                 messages:
//                     title: "messages"
//                     emailCode(Agent1):
//                         email: "email"
//                         emailCode(Buyer1):
//                            email: "email"
//                            msgUID:
//                               id:
//                               senderemail:
//                               message:
//                 recommendations:
//                     title: "recommendations"
//                     emailCode(Agent1):
//                         email: "email"
//                         recommUID:
//                               id:
//                               message:
//                 posts:
//                     title: "posts"
//                     emailCode(Agent1):
//                         email: "email"
//                         postUID:
//                               id:
//                               message:
//                 services:
//                     title: "services"
//                     emailCode(Agent1):
//                         email: "email"
//                         serviceUID:
//                               id:
//                               message:
//

import Foundation
import Firebase

class FirebaseNodesCreation {
    
    static let firDBInstance: Database = Database.database()
    static let firebaseRoot = Database.database().reference()
    
    // to prevent other creating this object by accident, because is private init()
    
    private init() {
        
    }
    
    class func getFirDBInstance() -> Database {
        return FirebaseNodesCreation.firDBInstance
    }
    
    class func createAgentGroup(agentGroupID: String) -> DatabaseReference {
        let agentRef = FirebaseNodesCreation.firebaseRoot.child(agentGroupID)
        let value = ["title" : agentGroupID]
        agentRef.setValue(value)
        return agentRef
    }
    
    class func getAgentGroup(agentGroupID: String) -> DatabaseReference {
        let agentRef = FirebaseNodesCreation.firebaseRoot.child(agentGroupID)
        return agentRef
    }
    
    class func createSubNode(parentNode: DatabaseReference, node: String) -> DatabaseReference {
        let nodeRef = parentNode.child(node)
        let value = ["title" : node]
        nodeRef.setValue(value)
        return nodeRef
    }
    
    class func getSubNode(parentNode: DatabaseReference, node: String) -> DatabaseReference {
        let nodeRef = parentNode.child(node)
        return nodeRef
    }
    
    class func decodeEmail(email: String) -> String {
        var decoded: String = ""
        for codeUnit in email.utf8 {
            decoded = decoded + "\(codeUnit)"
        }
        return decoded
    }
    
    class func className() -> String {
        return String(describing: FirebaseNodesCreation.self)
      //  return String(describing: AuthorizationVC.self)
    }
}
