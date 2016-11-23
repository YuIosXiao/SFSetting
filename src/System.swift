//
//  System.swift
//  SFSetting
//
//  Created by 孔祥波 on 23/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

import Foundation

let fm = FileManager.default
var configMacFn = ""
var kProxyGroupFile = ""
let  applicationDocumentsDirectory: URL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.yarshuremac.test" in the application's documents Application Support directory.
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
}()
func  groupContainerURL() ->URL {

    return URL.init(fileURLWithPath: SFSystem.shared.groupIdentifier)
}
class SFSystem {
    static var shared = SFSystem()
    public var groupIdentifier:String = ""
}
