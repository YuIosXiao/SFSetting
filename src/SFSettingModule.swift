//
//  SFSettingModule.swift
//  Surf
//
//  Created by yarshure on 15/12/23.
//  Copyright © 2015年 yarshure. All rights reserved.
//

import Foundation

import SwiftyJSON
import AxLogger
import SFSocket
extension String{
    func delLastN(_ n:Int) ->String{
        
        let i = self.index(self.endIndex, offsetBy: 0 - n)
        let d = self.substring(to: i)
        return d
        
    }
}
class SFSettingModule {
    //static let setting = SFSettingModule()
    static var config:String = ""
     static let setting:SFSettingModule =  SFSettingModule()
//    static let setting:SFSettingModule = {
//        let configName = readConfig()
//        
//        var urlContain = groupContainerURL.appendingPathComponent(configName!)
//        print("config url:\(urlContain.path!)")
//        return SFSettingModule(path: urlContain.path!)
//    }()
    let httpProxyModeSocket = false
    var httpProxyEnable = true
    var httpsProxyEnable = true
    var socksProxyEnable = false
    var udprelayer = true
    //var hosts:[DNSRecord] = []//
    //var proxy:[String:SFProxy] = [:]
    //var general:General?
    var rule:SFRule?
    
    var configFileData = Date()
    var method:Int32 = -1
    var level:AxLoggerLevel = .Info
    var adBlockRules:[String:String] = [:]
    var dnsCache:[DNSCache] = []
    init() {
//        if let path = Bundle.main.path(forResource:".adblock", ofType: nil){
//            do{
//               let x = try NSString.init(contentsOfFile: path, encoding: NSUTF8StringEncoding)
//                let lines = x.components(separatedBy: "\n")
//                for line in lines {
//                    let x = line.components(separatedBy: "#")
//                    if x.count == 2 {
//                        adBlockRules[x.first!] = x.last!
//                    }else {
//                        NSLog("%@ line error", line)
//                    }
//                }
//            }catch let e as NSError {
//                NSLog("read adbloc error %@", e.description)
//            }
//            
//        }
       
    }
    func addDNSCacheRecord(_ r:DNSCache) {
        dnsCache.append(r)
    }
    func searchIPAddress(_ ip:String) ->String? {
        for r in dnsCache {
            for i in r.ips {
                if ip == i {
                    return r.domain
                }
            }
        }
        return nil
    }
    func searchDomain(_ d:String) ->String? {
        //带点search
        let dest = d.delLastN(1)
        if let r = findRuleByString(dest, useragent: "") {
            if r.result.policy == .Reject {
                //对于raw tcp , 之间返回127.0.0.1 可以做去广告
                AxLogger.log("DNS-request \(d):127.0.0.1", level: .Warning)
                return "127.0.0.1"
            }
        }
        
        for r in dnsCache {
            if r.domain == d {
                if let i = r.ips.first{
                    return i
                }
            }
        }
        return nil
    }
    //这个是给DNS 转发用的，做cache
    func queryDomain(_ domain:String) ->String? {
        //用户设置的host 不代.
        if let r = rule {
            for item in r.hosts {
                if item.name == domain {
                    if let ip = item.ip() {
                        return ip
                    }
                }
            }
        }

        return nil
    }
  

    func config(_ path:String){
        

        //var  fn = ProxyGroupSettings.share.config
        
        AxLogger.log("Read Config From :\(path)", level: .Info)
        if  fm.fileExists(atPath:path) {
            rule = SFRule.init(path: path, loadRule: true)
            rule!.config()
            rule!.configInfo()
            if let g = rule!.general {
                let level = loglevel(g.loglevel)
                AxLogger.log("log level :\(level.description) ",level: .Info)
                //AxLogger.logleve = level
            }
            AxLogger.log("Config load Finished ",level: .Info)
        }else {
            let u = fm.containerURL(forSecurityApplicationGroupIdentifier: SFSystem.shared.groupIdentifier)!
            AxLogger.log("Config File Don't exist \(u.path) ",level: .Info)
            AxLogger.log("Config File Don't exist \(path) ",level: .Info)
        }
        
    }

    var ipRuleEnable:Bool{
        get {
            if let r = rule {
                return r.ipRuleEnable
            }
            return false
        }
    }
    
    func reSetSettings(_ fileName:String) ->Bool{
//        NSLog("[SFSettingModule] reload rule setting")
//        proxy.removeAll()
//        //guard let configName = readConfig() else  {return false}
//        var urlContain:NSURL
//        if fileName.components(separatedBy: "/").count > 1{
//            //path
//            urlContain = NSURL(string:fileName)!
//        }else  {
//            urlContain = groupContainerURL().appendingPathComponent(fileName)
//        }
//        
//        //let d = NSData(contentsOfFile: urlContain.path!)
//        guard let path = urlContain.path, d = NSData(contentsOfFile: path)   else  {return false}
//        let JSONObject:JSON = JSON(data: d)
//       
//        var  p =  JSONObject["Rule"]
//        rule = SFRule(c: p)
//        p = JSONObject["General"]
//        general = General(c: "xx")
//        self.readProxy(JSONObject)
//        level = SFSettingModule.loglevel(general!.loglevel)
//        NSLog("[SFSettingModule] ")
        return true
    }
//    static func verifySettings(fileName:String) ->Bool {
//         NSLog("[SFSettingModule] verifySettings \(fileName)")
//        
//        let configName = ProxyGroupSettings.defaultConfig
//        
//        let urlContain = groupContainerURL().appendingPathComponent(configName)
//        NSLog("[SFSettingModule] setting url:\(urlContain)")
//        //let d = NSData(contentsOfFile: urlContain.path!)
//        guard let path = urlContain.path, d = NSData(contentsOfFile: path)   else  {return false}
//        let JSONObject:JSON = JSON(data: d)
//        
//        var  p:JSON =  JSONObject["Rule"]
//        let rule:SFRule = SFRule(c: p)
//        //NSLog("[SFSettingModule] rule:\(rule)")
//        p = JSONObject["General"]
//        let general:General = General(c: "test")
//        let proxy = testProxy(JSONObject)
//        //NSLog("[SFSettingModule] proxy:\(proxy)")
//        let level = SFSettingModule.loglevel(general.loglevel)
//        //NSLog("[SFSettingModule] loglevel:\(level.description)")
//        return true
//    
//    }
    
//    func readProxy(config:JSON) {
//       
//        let p =  config["Proxy"]
//        for (name,value) in p {
//            let i = value
//            let px = i["protocol"].stringValue as NSString
//            let proto = px.uppercaseString
//            var type :SFProxyType
//            if proto == "HTTP"{
//                type = .HTTP
//            }else if proto == "HTTPS" {
//                type = .HTTPS
//            }else if proto == "CUSTOM" {
//                type = .SS
//            }else if proto == "SS" {
//                type = .SS
//            }else if proto == "SOCKS5" {
//                type = .SOCKS5
//            }else {
//                type = .LANTERN
//            }
//
//
//            let a = i["host"].stringValue, p = i["port"].stringValue , pass = i["passwd"].stringValue , m = i["method"].stringValue
//            
//            var tlsEnable = false
//            let tls = i["tls"]
//            if tls.error == nil {
//                tlsEnable = tls.boolValue
//            }
//            let sp = SFProxy(name: name, type: type, address: a, port: p, passwd: pass, method: m,tls: tlsEnable)
//            proxy[name.uppercaseString] = sp
//        }
//        
//    }
    
    static func testProxy(_ config:JSON) ->[String:SFProxy]?{
        var proxy:[String:SFProxy] = [:]
        let p =  config["Proxy"]
        if p.error != nil {
            return nil
        }
        
        for (name,value) in p {
            let i = value
            if i["protocol"].error != nil {
                return nil
            }
            let px = i["protocol"].stringValue as NSString
            let proto = px.uppercased
            var type :SFProxyType
            if proto == "HTTP"{
                type = .HTTP
            }else if proto == "HTTPS" {
                type = .HTTPS
            }else if proto == "CUSTOM" {
                type = .SS
            }else if proto == "SS" {
                type = .SS
            }else if proto == "SOCKS5" {
                type = .SOCKS5
            }else {
                type = .LANTERN
            }
            
            var tlsEnable = false
            let a = i["host"].stringValue, p = i["port"].stringValue , pass = i["passwd"].stringValue , m = i["method"].stringValue
            if i["host"].error != nil || i["port"].error != nil {
                return nil
            }
            let tls = i["tls"]
            if tls.error != nil {
                tlsEnable = tls.boolValue
            }
            let sp = SFProxy(name: name, type: type, address: a, port: p, passwd: pass, method: m,tls: tlsEnable)
            if sp.serverAddress.characters.count == 0 || sp.serverPort.characters.count == 0 {
                return nil
            }
            proxy[name] = sp
        }
        return proxy
    }
    func proxyByName(_ name:String) -> SFProxy?{
        
        let up = name.uppercased()
        if up == "DIRECT"  {
            return nil
        }
        if up == "REJECT" {
            return nil
        }
        if let p = ProxyGroupSettings.share.findProxy(name) {
            return p 
        }
        
        if up == "RANDOM" {
            return randomProxy()
        }
        return nil
//        if proxy.keys.contains(up) {
//            return proxy[up]
//        }else {
//            if let p = proxy.first {
//                return p.1
//            }else {
//                return nil
//            }
//        }
      
    }
    func randomProxy() ->SFProxy?{
        let p = ProxyGroupSettings.share.findProxy("any")
        return p
//        let count = Int(proxy.count)
//        let r = Int(arc4random())%count
//        //let proxyNAme = (proxy.keys)[r]
//        let firstKey = Array(proxy.keys)[r]
//        return proxy[firstKey]!
    }
    func findIPFromCache(_ hostName:String) ->String?{
        let  request_atyp:SOCKS5HostType = hostName.validateIpAddr()
        if  request_atyp  == .IPV4{
            return hostName
        }
        if let r = rule {
            for item in r.hosts {
                if item.name == hostName {
                    if let ip = item.ip() {
                        return ip
                    }
                }
            }
        }
        return nil
    }
    func getIPFromDNS(_ hostName:String) ->String? {
        //see here http://stackoverflow.com/questions/25890533/how-can-i-get-a-real-ip-address-from-dns-query-in-swift
        let  request_atyp:SOCKS5HostType = hostName.validateIpAddr()
        if  request_atyp  == .IPV4{
            return hostName
        }
        if let r = rule {
            for item in r.hosts {
                if item.name == hostName {
                    if let ip = item.ip() {
                        return ip
                    }
                }
            }
        }
        let host = CFHostCreateWithName(nil,hostName as CFString).takeRetainedValue()
        //NSLog("getIPFromDNS %@", hostName)
        let d = Date()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses.firstObject as? Data {
            var hostname = [CChar](repeating: 0, count: Int(256))
            let p = theAddress as Data
            let value = p.withUnsafeBytes { (ptr: UnsafePointer<sockaddr>)  in
                return ptr
            }
            if getnameinfo(UnsafePointer(value), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let numAddress = String(cString:hostname)
                let d2 = Date()
                _ =  String(format:" DNS request use %.2f",d2.timeIntervalSince(d))
                //debugLog(hostName + " " + numAddress + s)
                return numAddress
                
            }
        }

        return nil
    }


    func findRuleByStringDB(_ hostname:String, useragent:String)->SFRuleResult {
       
        
        var  ruler:SFRuler
        
        
        
        if let rule = rule , let r = rule.keyword(hostname) {
            ruler = r
        }else {
            //dmainSuffix test
            //移除前面, need deep dest
            if let x  = rule?.findRuleDB(hostname) {
                ruler = x
            }else {
                
                if let ip = findIPFromCache(hostname) {
                    //AxLogger.log("\(hostname):\(ip) and find ip base rule", level:.Debug)
                    
                    ruler = findIPRuler(ip)
                    //debugLog(String.init(format:"######## %@ DNS %@ rule:%@", hostname,ip,ruler.proxyName))
                    //ruler.name
                }else {
                    ruler = rule!.finalRuler
                }
            }
            
        }
        
        let result:SFRuleResult = SFRuleResult.init(request: hostname,r: ruler)
        return result
    }
    func findRuleByString(_ hostname:String, useragent:String)->SFRuleResult? {
        //hostname or ip string
        
        var  ruler:SFRuler
        var ipaddr:String = ""
        if !useragent.isEmpty {
            if let r = rule {
                var decodeAgent:String
                if let d = useragent.removingPercentEncoding {
                    decodeAgent = d
                }else {
                    decodeAgent = useragent
                }
                if let ruler = r.agent(decodeAgent){
                    
                    //ruler.proxyName = j["Proxy"].stringValue
                    //ruler.configPolicy(ruler.proxyName)
                    //ruler.type = .AGENT
                    let result:SFRuleResult = SFRuleResult.init(request: hostname,r: ruler)
                    return result
                }

            }
            
        }
        //调整顺序
        if  hostname.validateIpAddr( ) == .IPV4{
            return findIPRuleResult(hostname, host: "")
        }
        
        if let r = findRule(hostname) {
            ruler = r
        }else {
            //dmainSuffix test
            //移除前面, need deep dest
            if let x  = rule!.keyword(hostname) {
               ruler = x
            }else {
                
                if let ip = findIPFromCache(hostname) {
                     //AxLogger.log("\(hostname):\(ip) and find ip base rule", level:.Debug)
                    //host
                    AxLogger.log(String.init(format:"%@ DNS %@", hostname,ip),level: .Debug)
                    ruler = findIPRuler(ip)
                    ipaddr = ip
                    //ruler.name
                }else {
                    AxLogger.log("now send async dns request \(hostname)",level: .Debug)
                    //ruler = rule!.finalRuler
                    return nil
                }
            }

        }
 
        let result:SFRuleResult = SFRuleResult.init(request: hostname,r: ruler)
        result.ipAddr = ipaddr
        return result
    }

    
    func findIPRuler(_ ip:String) ->  SFRuler{
       
        var  ruler:SFRuler = SFRuler()
        
        
        if let r = rule {
            if ip.isEmpty {
                return r.finalRuler
            }
            
            if let x = r.ipcidr(ip) {
                ruler.name = x.name
                ruler.proxyName = x.proxyName
                
                ruler.type = .ipcidr
            }else {
                if let ru = r.geoIPRule(ip){
                   
                    return ru
                }else {
                    ruler = r.finalRuler
                }
            }
            return ruler
        }else  {
            AxLogger.log("Don't find config, all FINAL DIRECT",level: .Info)
            ruler.type = .final
            ruler.proxyName = "DIRECT"
            return ruler
        }
        
        
    }
    func findIPRuleResult(_ ip:String,host:String) ->  SFRuleResult{
        let  ruler:SFRuler = findIPRuler(ip)
        let result:SFRuleResult = SFRuleResult.init(request: ip,r: ruler)
        result.ipAddr = ip
        return result
    }
    func findRule(_ hostname:String) ->SFRuler? {
        // a.b.c.d.f
        
        let list = hostname.components(separatedBy: ".")
        for i in 0 ..< list.count-1 {
            var s = list[i]
            for j in i+1 ..< list.count {
                s = s + "." + list[j]
            }
            if let r = rule {
                if let ruler = r.dmainSuffix(s){
                    //let ruler:SFRuler = SFRuler()
                    //ruler.name = s
                    //ruler.proxyName = j["Proxy"].stringValue
                    //ruler.policy = .
                    //ruler.configPolicy(ruler.proxyName)
                    //ruler.type = .DOMAINSUFFIX
                    return ruler
                }
            }
            
        }
        return nil
        //return rule.final
    }
    func loglevel(_ levelStr:String) -> AxLoggerLevel {
        
        var level:AxLoggerLevel = .Info
        let l = levelStr.lowercased()
        
        switch l {
        case "error": level = .Error
        case "warning": level = .Warning
        case "info": level = .Info
        case "notify": level = .Notify
        case "trace": level = .Trace
        case "verbose": level = .Verbose
        case "debug": level = .Debug
        default:
            break
        }
        return level
    }
    func test(){
        //NSLog("\(proxy)")
        rule!.test()
        testrule()
    }
    func testrule(){

        
    }
}
