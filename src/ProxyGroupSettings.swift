//
//  ProxyGroupSettings.swift
//  Surf
//
//  Created by 孔祥波 on 16/4/5.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation
import SwiftyJSON
import SFSocket
import AxLogger
class ProxyGroupSettings {
    static let share:ProxyGroupSettings = {
        return ProxyGroupSettings()
    }()
    //var defaults:NSUserDefaults?// =
    var editing:Bool = false
    static let defaultConfig = ".surf"
    var historyEnable:Bool = false
    
    var disableWidget:Bool = false
    var showCountry:Bool = true
    var widgetProxyCount:Int = 3
    var selectIndex:Int = 0
    var config:String = "surf.conf"
    var saveDBIng:Bool = false
    var selectedProxy:SFProxy? {
        if proxys.count > 0 {
            if selectIndex >= proxys.count {
                return proxys.first!
            }
            return proxys[selectIndex]
        }
        return nil
    }
    func changeIndex(_ src:Int,dest:Int){
        let r = proxys.remove(at: src)
        proxys.insert(r, at: dest)
        try! save()
    }
    func iCloudSyncEnabled() ->Bool{
        return UserDefaults.standard.bool(forKey: "icloudsync");
    }
    func saveiCloudSync(_ t:Bool) {
        UserDefaults.standard.set(t, forKey:"icloudsync" )
    }
    func writeCountry(_ config:String,county:String){
        guard let defaults = UserDefaults(suiteName:SFSystem.shared.groupIdentifier) else {return }
        defaults.set(county , forKey: config)
        defaults.synchronize()
    }
    func readCountry(_ config:String) ->String?{
        guard let defaults = UserDefaults(suiteName:SFSystem.shared.groupIdentifier) else {return nil}
        
        return defaults.object(forKey: config)  as? String
    }
    var proxys:[SFProxy] = []
    func findProxy(_ proxyName:String) ->SFProxy? {
        
        
        
        if proxys.count > 0  {
            
            
            var proxy:SFProxy?
            if selectIndex < proxys.count {
                let p =  proxys[selectIndex]
                if p.proxyName == proxyName{
                    return p
                }else {
                    proxy = p
                }
                
            }
            var proxy2:SFProxy?
            for item in proxys {
                if item.proxyName == proxyName {
                    proxy2 =  item
                    break
                }
            }
            if let p = proxy2 {
                return p
            }else {
                if let p = proxy {
                    return p
                }
            }
            
        }
            //let index = 0//self.selectIndex
//             let bId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
//            if bId == "com.yarshure.Surf" {
//            }else {
//                
//            }
        
            
        if proxys.count > 0 {
            return proxys.first!
        }
            
    
        return nil
    }
    func cutCount() ->Int{
        if proxys.count <= 3{
            return proxys.count
        }
        return 3
    }
    func removeProxy(_ Index:Int) {
        proxys.remove(at: Index)
        do {
            try save()
        }catch let e as NSError{
            print("proxy group save error \(e)")
        }
    }
    init () {
       loadProxyFromFile()
    }
    func loadProxyFromConf() {
         let url = groupContainerURL().appendingPathComponent(configMacFn)
        if fm.fileExists(atPath: url.path) {
            
            var  content = ""
            do {
                content = try String.init(contentsOf: url, encoding: .utf8)

            }catch let error {
                AxLogger.log("read config failure \(error.localizedDescription)", level: .Error)
                return
            }
            let x = content.components(separatedBy: "=")
            var proxyFound:Bool = false
            editing = true
            for line in x {
                if line.hasPrefix("[Proxy]"){
                    proxyFound  = true
                    continue
                }
                if proxyFound {
                    let x = line.components(separatedBy: "=")
                    if x.count == 2 {
                        //found record
                        if let p = SFProxy.createProxyWithLine(line: x.last!, pname: x.first!){
                            proxys.append(p)
                        }
                    }else {
                        proxyFound = false
                    }
                }
            }
            editing = false
        }
        
    }
    func loadProxyFromFile() {
        if proxys.count > 0 {
            proxys.removeAll()
        }
//        if bId == MacTunnelIden{
//            loadProxyFromConf()
//            return
//        }
        let url = groupContainerURL().appendingPathComponent(kProxyGroupFile)
        if fm.fileExists(atPath: url.path) {
            let data = try! Data.init(contentsOf: url)
            let jsonOjbect = JSON.init(data: data )
            if jsonOjbect.error == nil {
                readProxy(jsonOjbect)
                if jsonOjbect["selectIndex"].error == nil {
                    selectIndex = jsonOjbect["selectIndex"].intValue
                }
                if jsonOjbect["config"].error == nil {
                    config = jsonOjbect["config"].stringValue
                }
                if jsonOjbect["historyEnable"].error == nil {
                    historyEnable = jsonOjbect["historyEnable"].boolValue
                }
                if jsonOjbect["disableWidget"].error == nil {
                    disableWidget = jsonOjbect["disableWidget"].boolValue
                }
                if jsonOjbect["widgetProxyCount"].error == nil {
                    widgetProxyCount = jsonOjbect["widgetProxyCount"].intValue
                }
                if jsonOjbect["showCountry"].error == nil {
                    showCountry = jsonOjbect["showCountry"].boolValue
                }else {
                    //showCountry = true
                }
            }
            
        }
    }
    func readProxy(_ config:JSON) {
        
        let p =  config["Proxys"]
        for (name,value) in p {
            let bId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
            if bId == "com.yarshure.Surf" {
                let proxy = SFProxy.map(name, value: value)
                proxys.append(proxy)
            }else {
                let proxy = SFProxy.map(name, value: value)
                if proxy.enable {
                    proxys.append(proxy)
                }
 
            }
            
        }
        
    }
    
    
    func addProxy(_ proxy:SFProxy) -> Bool {
        
        var found = false
        
        var index  = 0
        for idx in 0 ..< proxys.count {
            let p = proxys[idx]
            if p.serverAddress == proxy.serverAddress && p.serverPort == proxy.serverPort {
                found = true
                index = idx
                break
            }
        }
        if found {
            proxys.remove(at: index)
            proxys.insert(proxy, at: index)
        }else {
            proxys.append(proxy)
            
        }
        try! save()
        return true
    }
    func removeProxyAtIndex(_ index:Int){
        proxys.remove(at: index)
    }
    func save() throws {//save to group dir
        var result:[AnyObject] = []
        for p in proxys{
            let o = p.resp()
            //print(o)
            result.append(o as AnyObject)

        }
        
        var  x:[String:AnyObject] = [:]
        x["Proxys"] = result as AnyObject?
        x["selectIndex"] = NSNumber.init(value: selectIndex)
        x["widgetProxyCount"] = NSNumber.init(value: widgetProxyCount)
        x["config"] = config as AnyObject?
        x["historyEnable"] = NSNumber.init(value:  historyEnable)
        x["showCountry"] = NSNumber.init(value:  showCountry)
        if widgetProxyCount > 0  {
            x["disableWidget"] = NSNumber.init(value:  true)
        }else {
             x["disableWidget"] = NSNumber.init(value:  false)
        }
        
        let j = JSON(x)
        var data:Data
        do {
            try data = j.rawData()
        }catch let error as NSError {
            //AxLogger.log("ruleResultData error \(error.localizedDescription)")
            //let x = error.localizedDescription
            //data = error.localizedDescription.dataUsingEncoding(NSUTF8StringEncoding)!// NSData()
            throw error
        }
         let url = groupContainerURL().appendingPathComponent(kProxyGroupFile)
        do {
            try data.write(to:url, options: .atomic)
        } catch let error as NSError{
            throw error
        }
        

         let p = applicationDocumentsDirectory.appendingPathComponent(config)
    
         let u = groupContainerURL().appendingPathComponent("surf.conf")
        do {
            if fm.fileExists(atPath: u.path) {
                try fm.removeItem(atPath: u.path)
            }
            if fm.fileExists(atPath: p.path) {
                try fm.copyItem(atPath: p.path, toPath: u.path)
            }
            
        }catch let e as NSError {
            print("copy config file error \(e)")
        }
        
    }
    func importFromFile(){
        
    }
    func exportToFile(){
        
    }
    
}
