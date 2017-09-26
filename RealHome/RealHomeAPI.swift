//
//  RealHomeAPI.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-24.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import Moya

public enum RealHomeAPI {
    case index
    case show(id: String)
}

extension RealHomeAPI: TargetType {
    
    public var baseURL: URL {
        return URL(string: Server)!
    }
    
    public var path: String {
        switch self {
        case .index:
            return ""
        case .show(let id):
            return "/\(id)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .index, .show:
            return .get
        }
    }
    
    public var sampleData: Data {
        return "RealHome test.".data(using: String.Encoding.utf8)!
        
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var headers: [String: String]? {
        return nil
    }
}


