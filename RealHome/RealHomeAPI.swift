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
    case login(paras: [String:Any])
    case register(paras: [String:Any])
    case updateAgentCode(paras: [String:Any])
    case updateAgentCodeNickname(paras: [String:Any])
    case logout(paras: [String:Any])
    case getUUID(paras: [String:Any])
    case resetPassword(paras: [String:Any])
    case propsFilter(paras: [String:Any])
    case propsMultiIDs(paras: [String:Any])
    case propSingleID(paras: [String:Any])
    case creaAPI(paras: [String:Any])
    case creaEmailBroker(paras: [String:Any])
    case applyTheCode(paras: [String:Any])
    
    static func url(_ route: TargetType) -> String {
        return route.baseURL.appendingPathComponent(route.path).absoluteString
        
     //   let parameterH: [String:Any] = ["a": "a"]
     //   return netWorkProvider.endpoint(.residential(paras: parameterH)).urlRequest?.description ?? "net url"
    }
    
    static func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
}

extension RealHomeAPI: TargetType {
    
    public var baseURL: URL {
        switch self {
        case .creaAPI( _):
            return URL(string: "http://analytics.crea.ca/LogEvents.svc")!
        default:
            return URL(string: Server)!
        }
    }
    
    public var path: String {
        switch self {
        case .login( _):
            return "/residential.ashx"
        case .register( _):
            return "/residential.ashx"
        case .updateAgentCode( _):
            return "/residential.ashx"
        case .updateAgentCodeNickname( _):
            return "/residential.ashx"
        case .logout( _):
            return "/residential.ashx"
        case .getUUID( _):
            return "/residential.ashx"
        case .resetPassword( _):
            return "/residential.ashx"
        case .propsFilter( _):
            return "/residential.ashx"
        case .propsMultiIDs( _):
            return "/residential.ashx"
        case .propSingleID( _):
            return "/residential.ashx"
        case .creaAPI( _):
            return "/LogEvents"
        case .creaEmailBroker( _):
            return "/residential.ashx"
        case .applyTheCode( _):
            return "/residential.ashx"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login( _):
            return .get
        case .register( _):
            return .get
        case .updateAgentCode( _):
            return .get
        case .updateAgentCodeNickname( _):
            return .get
        case .logout( _):
            return .get
        case .getUUID( _):
            return .get
        case .resetPassword( _):
            return .get
        case .propsFilter( _):
            return .get
        case .propsMultiIDs( _):
            return .get
        case .propSingleID( _):
            return .get
        case .creaAPI( _):
            return .get
        case .creaEmailBroker( _):
            return .get
        case .applyTheCode( _):
            return .get
        }
    }
    
//  return .requestCompositeParameters(bodyParameters: ["op": op], bodyEncoding: JSONEncoding.default, urlParameters: ["kk": op])
    public var task: Task {
        switch self {
        case .login(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .register(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .updateAgentCode(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .updateAgentCodeNickname(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .logout(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .getUUID(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .resetPassword(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .propsFilter(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .propsMultiIDs(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .propSingleID(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .creaAPI(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .creaEmailBroker(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        case .applyTheCode(let paras):
            return .requestParameters(parameters: paras, encoding: URLEncoding.default)
        }
    }
    
    public var validate: Bool {
        return false
    }
    
    public var sampleData: Data {
        switch self {
        case .propsFilter(let paras):
            let op = paras["op"] as? String
            return "[{\"Operation\": \"\(String(describing: op))\"}]".data(using: String.Encoding.utf8)!
        default:
            return "RealHome test.".data(using: String.Encoding.utf8)!
        }
    }
    
    public var headers: [String: String]? {
        return nil
    }
}

