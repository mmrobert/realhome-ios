//
//  SingletonObjects.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-24.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import UIKit
import Moya
import Alamofire
import RxSwift

let netWorkProvider: RxMoyaProvider = RxMoyaProvider<RealHomeAPI>()
let disposeBag = DisposeBag()

let noteCenter = NotificationCenter.default

