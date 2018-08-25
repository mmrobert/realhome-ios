//
//  DataObjectInTree.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-12.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation

struct Location {
    
    var latitude: String?
    var longitude: String?
}

class DataObjectInTree {
    let name: String
    var children: [DataObjectInTree]
    var location: Location?
    
    init(name : String, children: [DataObjectInTree], location: Location?) {
        self.name = name
        self.children = children
        self.location = location
    }
    
    convenience init(name : String) {
        self.init(name: name, children: [DataObjectInTree](), location: nil)
    }
    
    convenience init(name : String, children: [DataObjectInTree]) {
        self.init(name: name, children: children, location: nil)
    }
    
    func addChild(_ child : DataObjectInTree) {
        self.children.append(child)
    }
    
    func removeChild(_ child : DataObjectInTree) {
        self.children = self.children.filter( {$0 !== child})
    }
}

extension DataObjectInTree {
    
    static func cityDataInit() -> [DataObjectInTree] {
        
        let Ajax = DataObjectInTree(name: "Ajax")
        let Aurora = DataObjectInTree(name: "Aurora")
        let Barrie = DataObjectInTree(name: "Barrie")
        let Brampton = DataObjectInTree(name: "Brampton")
        let Brantford = DataObjectInTree(name: "Brantford")
        let Brockville = DataObjectInTree(name: "Brockville")
        let Burlington = DataObjectInTree(name: "Burlington")
        let Cambridge = DataObjectInTree(name: "Cambridge")
        let Cornwall = DataObjectInTree(name: "Cornwall")
        let Guelph = DataObjectInTree(name: "Guelph")
        let Halton_Hills = DataObjectInTree(name: "Halton Hills")
        let Hamilton = DataObjectInTree(name: "Hamilton")
        let Innisfil = DataObjectInTree(name: "Innisfil")
        let Kingston = DataObjectInTree(name: "Kingston")
        let Kitchener = DataObjectInTree(name: "Kitchener")
        let London = DataObjectInTree(name: "London")
        let Markham = DataObjectInTree(name: "Markham")
        let Milton = DataObjectInTree(name: "Milton")
        let Mississauga = DataObjectInTree(name: "Mississauga")
        let Newmarket = DataObjectInTree(name: "Newmarket")
        let Niagara_Falls = DataObjectInTree(name: "Niagara Falls")
        let Niagara_on_the_Lake = DataObjectInTree(name: "Niagara-on-the-Lake")
        let North_Bay = DataObjectInTree(name: "North Bay")
        let North_York = DataObjectInTree(name: "North York")
        let Oakville = DataObjectInTree(name: "Oakville")
        let Oshawa = DataObjectInTree(name: "Oshawa")
        let Ottawa = DataObjectInTree(name: "Ottawa")
        let Pickering = DataObjectInTree(name: "Pickering")
        let Prince_Edward = DataObjectInTree(name: "Prince Edward")
        let Richmond_Hill = DataObjectInTree(name: "Richmond Hill")
        let Scarborough = DataObjectInTree(name: "Scarborough")
        let Thunder_Bay = DataObjectInTree(name: "Thunder Bay")
        let Toronto = DataObjectInTree(name: "Toronto")
        let Vaughan = DataObjectInTree(name: "Vaughan")
        let Waterloo = DataObjectInTree(name: "Waterloo")
        let Whitby = DataObjectInTree(name: "Whitby")
        let Whitchurch_Stouffville = DataObjectInTree(name: "Whitchurch-Stouffville")
        let Windsor = DataObjectInTree(name: "Windsor")
        
        Ajax.location = Location(latitude: "43.8501200", longitude: "-79.0328800")
        Aurora.location = Location(latitude: "44.006481", longitude: "-79.450394")
        Barrie.location = Location(latitude: "44.389355", longitude: "-79.690331")
        Brampton.location = Location(latitude: "43.683334", longitude: "-79.766670")
        Brantford.location = Location(latitude: "43.1334000", longitude: "-80.2663600")
        Brockville.location = Location(latitude: "44.5913200", longitude: "-75.6870500")
        Burlington.location = Location(latitude: "43.3862100", longitude: "-79.8371300")
        Cambridge.location = Location(latitude: "43.3601000", longitude: "-80.3126900")
        Cornwall.location = Location(latitude: "45.0180900", longitude: "-74.7281500")
        Guelph.location = Location(latitude: "43.5459400", longitude: "-80.2559900")
        Halton_Hills.location = Location(latitude: "43.650204", longitude: "-79.903625")
        Hamilton.location = Location(latitude: "43.2501100", longitude: "-79.8496300")
        Innisfil.location = Location(latitude: "44.3001100", longitude: "-79.6496400")
        Kingston.location = Location(latitude: "44.2297600", longitude: "-76.4809800")
        Kitchener.location = Location(latitude: "43.4253700", longitude: "-80.5112000")
        London.location = Location(latitude: "42.9833900", longitude: "-81.2330400")
        Markham.location = Location(latitude: "43.8668200", longitude: "-79.2663000")
        Milton.location = Location(latitude: "43.5168100", longitude: "-79.8829400")
        Mississauga.location = Location(latitude: "43.5789000", longitude: "-79.6583000")
        Newmarket.location = Location(latitude: "44.0501100", longitude: "-79.4663100")
        Niagara_Falls.location = Location(latitude: "43.1001200", longitude: "-79.0662700")
        Niagara_on_the_Lake.location = Location(latitude: "43.2501200", longitude: "-79.0662700")
        North_Bay.location = Location(latitude: "46.3168000", longitude: "-79.4663300")
        North_York.location = Location(latitude: "43.761539", longitude: "-79.411079")
        Oakville.location = Location(latitude: "43.4501100", longitude: "-79.6829200")
        Oshawa.location = Location(latitude: "43.9001200", longitude: "-78.8495700")
        Ottawa.location = Location(latitude: "45.4111700", longitude: "-75.6981200")
        Pickering.location = Location(latitude: "43.9001200", longitude: "-79.1328900")
        Prince_Edward.location = Location(latitude: "44.0001200", longitude: "-77.2494600")
        Richmond_Hill.location = Location(latitude: "43.887501", longitude: "-79.428406")
        Scarborough.location = Location(latitude: "43.778393", longitude: "-79.222809")
        Thunder_Bay.location = Location(latitude: "48.3820200", longitude: "-89.2501800")
        Toronto.location = Location(latitude: "43.7001100", longitude: "-79.4163000")
        Vaughan.location = Location(latitude: "43.8361000", longitude: "-79.4982700")
        Waterloo.location = Location(latitude: "43.4668000", longitude: "-80.5163900")
        Whitby.location = Location(latitude: "43.897545", longitude: "-78.942932")
        Whitchurch_Stouffville.location = Location(latitude: "44.0001200", longitude: "-79.3163000")
        Windsor.location = Location(latitude: "42.317432", longitude: "-83.026772")
        
        let Ontario = DataObjectInTree(name: "Ontario", children: [Toronto, Richmond_Hill, North_York, Markham, Mississauga, Brampton, Burlington, Oakville, Oshawa, Aurora, Newmarket, Ajax, Barrie, Brantford, Brockville, Cambridge, Cornwall, Guelph, Halton_Hills, Hamilton, Innisfil, Kingston, Kitchener, London, Milton, Niagara_Falls, Niagara_on_the_Lake, North_Bay, Ottawa, Pickering, Prince_Edward, Scarborough, Thunder_Bay, Vaughan, Waterloo, Whitby, Whitchurch_Stouffville, Windsor])
        
        let Abbotsford = DataObjectInTree(name: "Abbotsford")
        let Armstrong = DataObjectInTree(name: "Armstrong")
        let Burnaby = DataObjectInTree(name: "Burnaby")
        let Campbell_River = DataObjectInTree(name: "Campbell River")
        let Castlegar = DataObjectInTree(name: "Castlegar")
        let Chilliwack = DataObjectInTree(name: "Chilliwack")
        let Colwood = DataObjectInTree(name: "Colwood")
        let Coquitlam = DataObjectInTree(name: "Coquitlam")
        let Duncan = DataObjectInTree(name: "Duncan")
        let Fort_St_John = DataObjectInTree(name: "Fort St. John")
        let Grand_Forks = DataObjectInTree(name: "Grand Forks")
        let Greenwood = DataObjectInTree(name: "Greenwood")
        let Kimberley = DataObjectInTree(name: "Kimberley")
        let Langley = DataObjectInTree(name: "Langley")
        let Maple_Ridge = DataObjectInTree(name: "Maple Ridge")
        let Merritt = DataObjectInTree(name: "Merritt")
        let Nelson = DataObjectInTree(name: "Nelson")
        let New_Westminster = DataObjectInTree(name: "New Westminster")
        let North_Vancouver = DataObjectInTree(name: "North Vancouver")
        let Parksville = DataObjectInTree(name: "Parksville")
        let Port_Alberni = DataObjectInTree(name: "Port Alberni")
        let Port_Moody = DataObjectInTree(name: "Port Moody")
        let Prince_George = DataObjectInTree(name: "Prince George")
        let Richmond = DataObjectInTree(name: "Richmond")
        let Rossland = DataObjectInTree(name: "Rossland")
        let Surrey = DataObjectInTree(name: "Surrey")
        let Terrace = DataObjectInTree(name: "Terrace")
        let Vancouver = DataObjectInTree(name: "Vancouver")
        let Victoria = DataObjectInTree(name: "Victoria")
        let West_Vancouver = DataObjectInTree(name: "West Vancouver")
        let White_Rock = DataObjectInTree(name: "White Rock")
        let Williams_Lake = DataObjectInTree(name: "Williams Lake")
        
        Abbotsford.location = Location(latitude: "49.0579800", longitude: "-122.2525700")
        Armstrong.location = Location(latitude: "50.4497900", longitude: "-119.2023500")
        Burnaby.location = Location(latitude: "49.2663600", longitude: "-122.9526300")
        Campbell_River.location = Location(latitude: "50.0163400", longitude: "-125.2445900")
        Castlegar.location = Location(latitude: "49.2998400", longitude: "-117.6689400")
        Chilliwack.location = Location(latitude: "49.1663800", longitude: "-121.9525700")
        Colwood.location = Location(latitude: "48.4329300", longitude: "-123.4859100")
        Coquitlam.location = Location(latitude: "49.2829700", longitude: "-122.7526200")
        Duncan.location = Location(latitude: "48.7829300", longitude: "-123.7026600")
        Fort_St_John.location = Location(latitude: "56.2498800", longitude: "-120.8529200")
        Grand_Forks.location = Location(latitude: "49.0330900", longitude: "-118.435600")
        Greenwood.location = Location(latitude: "44.9741300", longitude: "-64.931690")
        Kimberley.location = Location(latitude: "49.670710", longitude: "-115.977600")
        Langley.location = Location(latitude: "49.101070", longitude: "-122.658830")
        Maple_Ridge.location = Location(latitude: "49.219390", longitude: "-122.601930")
        Merritt.location = Location(latitude: "50.112250", longitude: "-120.794200")
        Nelson.location = Location(latitude: "49.499850", longitude: "-117.285530")
        New_Westminster.location = Location(latitude: "49.206780", longitude: "-122.910920")
        North_Vancouver.location = Location(latitude: "49.316360", longitude: "-123.069340")
        Parksville.location = Location(latitude: "49.319470", longitude: "-124.315750")
        Port_Alberni.location = Location(latitude: "49.241330", longitude: "-124.802800")
        Port_Moody.location = Location(latitude: "49.282970", longitude: "-122.852630")
        Prince_George.location = Location(latitude: "53.916600", longitude: "-122.753010")
        Richmond.location = Location(latitude: "49.170030", longitude: "-123.136830")
        Rossland.location = Location(latitude: "49.083130", longitude: "-117.802240")
        Surrey.location = Location(latitude: "49.106350", longitude: "-122.825090")
        Terrace.location = Location(latitude: "54.516340", longitude: "-128.603450")
        Vancouver.location = Location(latitude: "49.249660", longitude: "-123.119340")
        Victoria.location = Location(latitude: "48.432940", longitude: "-123.369300")
        West_Vancouver.location = Location(latitude: "49.366720", longitude: "-123.166520")
        White_Rock.location = Location(latitude: "49.016360", longitude: "-122.802600")
        Williams_Lake.location = Location(latitude: "52.141530", longitude: "-122.144510")
        
        let British_Columbia = DataObjectInTree(name: "British Columbia", children: [Vancouver, Burnaby, Coquitlam, New_Westminster, North_Vancouver, Richmond, Surrey, Victoria, West_Vancouver, Abbotsford, Armstrong, Campbell_River, Castlegar, Chilliwack, Colwood, Duncan, Fort_St_John, Grand_Forks, Greenwood, Kimberley, Langley, Maple_Ridge, Merritt, Nelson, Parksville, Port_Alberni, Port_Moody, Prince_George, Rossland, Terrace, White_Rock, Williams_Lake])
        
        let Calgary = DataObjectInTree(name: "Calgary")
        let Edmonton = DataObjectInTree(name: "Edmonton")
        
        Calgary.location = Location(latitude: "51.050110", longitude: "-114.085290")
        Edmonton.location = Location(latitude: "53.550140", longitude: "-113.468710")
        
        let Alberta = DataObjectInTree(name: "Alberta", children: [Calgary, Edmonton])
        
        let Dieppe = DataObjectInTree(name: "Dieppe")
        let Edmundston = DataObjectInTree(name: "Edmundston")
        let Fredericton = DataObjectInTree(name: "Fredericton")
        let Miramichi = DataObjectInTree(name: "Miramichi")
        let Moncton = DataObjectInTree(name: "Moncton")
        let Saint_John = DataObjectInTree(name: "Saint John")
        
        Dieppe.location = Location(latitude: "46.078440", longitude: "-64.687350")
        Edmundston.location = Location(latitude: "47.373700", longitude: "-68.325120")
        Fredericton.location = Location(latitude: "45.945410", longitude: "-66.665580")
        Miramichi.location = Location(latitude: "47.028950", longitude: "-65.501860")
        Moncton.location = Location(latitude: "46.094540", longitude: "-64.796500")
        Saint_John.location = Location(latitude: "45.272710", longitude: "-66.067660")
        
        let New_Brunswick = DataObjectInTree(name: "New Brunswick", children: [Dieppe, Edmundston, Fredericton, Miramichi, Moncton, Saint_John])
        
        let Bay_Roberts = DataObjectInTree(name: "Bay Roberts")
        let Clarenville_Shoal_Harbour = DataObjectInTree(name: "Clarenville-Shoal Harbour")
        let Conception_Bay_South = DataObjectInTree(name: "Conception Bay South")
        let Corner_Brook = DataObjectInTree(name: "Corner Brook")
        let Labrador_City = DataObjectInTree(name: "Labrador City")
        let Marystown = DataObjectInTree(name: "Marystown")
        let Mount_Pearl = DataObjectInTree(name: "Mount Pearl")
        let Stephenville = DataObjectInTree(name: "Stephenville")
        let St_Johns = DataObjectInTree(name: "St. John's")
        let Torbay = DataObjectInTree(name: "Torbay")
        
        Bay_Roberts.location = Location(latitude: "47.599890", longitude: "-53.264780")
        Clarenville_Shoal_Harbour.location = Location(latitude: "48.180500", longitude: "-53.969820")
        Conception_Bay_South.location = Location(latitude: "47.499890", longitude: "-52.998060")
        Corner_Brook.location = Location(latitude: "48.950010", longitude: "-57.952020")
        Labrador_City.location = Location(latitude: "52.946260", longitude: "-66.911370")
        Marystown.location = Location(latitude: "47.166630", longitude: "-55.148290")
        Mount_Pearl.location = Location(latitude: "47.516590", longitude: "-52.781350")
        Stephenville.location = Location(latitude: "48.550010", longitude: "-58.581800")
        St_Johns.location = Location(latitude: "47.564940", longitude: "-52.709310")
        Torbay.location = Location(latitude: "47.666590", longitude: "-52.731350")
        
        let Newfoundland_and_Labrador = DataObjectInTree(name: "Newfoundland & Labrador", children: [Bay_Roberts, Clarenville_Shoal_Harbour, Conception_Bay_South, Corner_Brook, Labrador_City, Marystown, Mount_Pearl, Stephenville, St_Johns, Torbay])
        
        let Halifax = DataObjectInTree(name: "Halifax")
        let Cape_Breton = DataObjectInTree(name: "Cape Breton")
        let Chester = DataObjectInTree(name: "Chester")
        let Lunenburg = DataObjectInTree(name: "Lunenburg")
        let Pictou = DataObjectInTree(name: "Pictou")
        let Truro = DataObjectInTree(name: "Truro")
        let Yarmouth = DataObjectInTree(name: "Yarmouth")
        
        Halifax.location = Location(latitude: "44.645330", longitude: "-63.572390")
        Cape_Breton.location = Location(latitude: "46.208330", longitude: "-64.749220")
        Chester.location = Location(latitude: "44.542250", longitude: "-64.238910")
        Lunenburg.location = Location(latitude: "44.378470", longitude: "-64.316580")
        Pictou.location = Location(latitude: "45.678750", longitude: "-62.709360")
        Truro.location = Location(latitude: "45.366850", longitude: "-63.265380")
        Yarmouth.location = Location(latitude: "43.833450", longitude: "-66.115570")
        
        let Nova_Scotia = DataObjectInTree(name: "Nova Scotia", children: [Halifax, Cape_Breton, Chester, Lunenburg, Pictou, Truro, Yarmouth])
        
        let Charlottetown = DataObjectInTree(name: "Charlottetown")
        let Cornwall_P = DataObjectInTree(name: "Cornwall")
        let Summerside = DataObjectInTree(name: "Summerside")
        
        Charlottetown.location = Location(latitude: "46.2389900", longitude: "-63.1341400")
        Cornwall_P.location = Location(latitude: "46.2265200", longitude: "-63.2180900")
        Summerside.location = Location(latitude: "46.3959300", longitude: "-63.7876200")
        
        let Prince_Edward_Island = DataObjectInTree(name: "Prince Edward Island", children: [Charlottetown, Cornwall_P, Summerside])
        
        return [Ontario, British_Columbia, Alberta, New_Brunswick, Newfoundland_and_Labrador, Nova_Scotia, Prince_Edward_Island]
    }
    
 // following is sample data
    static func defaultTreeRootChildren() -> [DataObjectInTree] {
        let phone1 = DataObjectInTree(name: "Phone 1")
        let phone2 = DataObjectInTree(name: "Phone 2")
        let phones = DataObjectInTree(name: "Phones", children: [phone1, phone2])
        
        let notebook1 = DataObjectInTree(name: "Notebook 1")
        let notebook2 = DataObjectInTree(name: "Notebook 2")
        
        let computer1 = DataObjectInTree(name: "Computer 1", children: [notebook1, notebook2])
        let computer2 = DataObjectInTree(name: "Computer 2")
        let computers = DataObjectInTree(name: "Computers", children: [computer1, computer2])
        
        let cars = DataObjectInTree(name: "Cars")
        let bikes = DataObjectInTree(name: "Bikes")
        
        return [phones, computers, cars, bikes]
    }
}

