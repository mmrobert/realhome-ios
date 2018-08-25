//
//  LanguageProperty.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-23.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation

struct LanguageProperty {
    
    static var filterStr = "Filter"
    static var listStr = "List"
    
    static var residentialStr = "Residential"
    static var commercialStr = "Commercial"
    static var noSavedFavoritesStr = "No saved favorite."
    static var listingIDStr = "Listing ID"
    static var bedsStr = "Beds"
    static var bathsStr = "Baths"
    static var areaStr = "Area"
    static var bldgTypeStr = "Bldg Type"
    
    static var noRecommendationStr = "No Recommendation."
    static var noPostStr = "No Post."
    static var noServiceStr = "No Service."
    
    static var forSaleStr = "For sale"
    static var forRentStr = "For rent"
    static var forSaleOrRentStr = "For Sale Or Rent"
    
    static var generalDescriptionStr = "General Description"
    static var roomsStr = "Rooms"
    
    // for apartment
    static var listedDateStr = "Listed Date"
    static var listedDaysStr = "Listed Days"
    
    static var bedRoomsStr = "Bed Rooms"
    static var bathRoomsStr = "Bath Rooms"
    static var squareFootageStr = "Square Footage"
    static var floorLevelStr = "Floor Level"
    static var unitNoStr = "Unit No."
    static var propertyTaxStr = "Property Tax"
    static var maintenanceFeesStr = "Maintenance Fees"
    static var parkingTypeStr = "Parking Type"
    static var parkingSpacesStr = "Parking Spaces"
    static var heatingTypeStr = "Heating Type"
    static var coolingTypeStr = "Cooling Type"
    static var bldgAmenitiesStr = "Bldg Amenities"
    static var propertyMgmtStr = "Property Mgmt"
    static var brokerageStr = "Brokerage"
    static var emailToBrokerStr = "Email to Brokerage"
    
    // for house
    static var storeysStr = "Storeys"
    static var agesStr = "Ages"
    static var landSizeStr = "Land Size"
    static var basementStr = "Basement"
    static var swimmingPoolStr = "Swimming Pool"
    
    // for commercial
    static var propertyTypeStr = "Property Type"
    static var floorAreaStr = "Floor Area"
    static var parkingStr = "Parking"
    static var areaSizeStr = "Area/Size"
    static var areaUnitStr = "(unit: square foot)"
    
    static var priceRangeStr = "Price Range"
    static var priceUnitStr = "(unit: dollar)"
    static var minStr = "Min"
    static var maxStr = "Max"
    static var garageStr = "Garage"
    static var openHouseStr = "Open House"
    
  // all and other
    static var allStr = "All"
    static var otherStr = "Other"
    
  // bldg type
    static var houseStr = "House"
    static var detachedHouseStr = "Detached House"
    static var semiDetachedHouseStr = "Semi-Detached House"
    static var rowTownhouseStr = "Row / Townhouse"
    static var condoApartmentStr = "Condo / Apartment"
    static var duplexStr = "Duplex"
    static var triplexStr = "Triplex"
    static var fourplexStr = "Fourplex"
    static var gardenHomeStr = "Garden Home"
    static var mobileHomeStr = "Mobile Home"
    static var manufacturedHomeStr = "Manufactured Home"
    static var recreationalCottageStr = "Recreational / Cottage"
    
   // property type for commercial
    static var businessStr = "Business"
    static var retailStr = "Retail"
    static var officeStr = "Office"
    static var industrialStr = "Industrial"
    static var hospitalityStr = "Hospitality"
    static var institutionalStr = "Institutional"
    static var agricultureStr = "Agriculture"
    static var vacantLandStr = "Vacant Land"
    
   // basement
    static var finishedStr = "Finished"
    static var unfinishedStr = "Unfinished"
    static var noneStr = "None"
    static var partialStr = "Partial"
    static var separated_entranceStr = "Separated Entrance"
    static var walk_outStr = "Walk-Out"
    static var crawl_spaceStr = "Crawl Space"
    static var walk_upStr = "Walk-Up"
    static var slabStr = "Slab"
    
    static var listingPropNotExistStr = "This listing property does not exist anymore."
    
    static func setLang(Lang: String) {
        if Lang == englishStr {
            filterStr = "Filter"
            listStr = "List"
            
            residentialStr = "Residential"
            commercialStr = "Commercial"
            noSavedFavoritesStr = "No saved favorites."
            listingIDStr = "Listing ID"
            bedsStr = "Beds"
            bathsStr = "Baths"
            areaStr = "Area"
            bldgTypeStr = "Bldg Type"
            
            noRecommendationStr = "No Recommendation."
            noPostStr = "No Post."
            noServiceStr = "No Service."
            
            forSaleStr = "For sale"
            forRentStr = "For rent"
            forSaleOrRentStr = "For Sale Or Rent"
            
            generalDescriptionStr = "General Description"
            roomsStr = "Rooms"
            
            // for apartment
            listedDateStr = "Listed Date"
            listedDaysStr = "Listed Days"
            
            bedRoomsStr = "Bed Rooms"
            bathRoomsStr = "Bath Rooms"
            squareFootageStr = "Square Footage"
            floorLevelStr = "Floor Level"
            unitNoStr = "Unit No."
            propertyTaxStr = "Property Tax"
            maintenanceFeesStr = "Maintenance Fees"
            parkingTypeStr = "Parking Type"
            parkingSpacesStr = "Parking Spaces"
            heatingTypeStr = "Heating Type"
            coolingTypeStr = "Cooling Type"
            bldgAmenitiesStr = "Bldg Amenities"
            propertyMgmtStr = "Property Mgmt"
            brokerageStr = "Brokerage"
            emailToBrokerStr = "Email to Brokerage"
            
            // for house
            storeysStr = "Storeys"
            agesStr = "Ages"
            landSizeStr = "Land Size"
            basementStr = "Basement"
            swimmingPoolStr = "Swimming Pool"
            
            // for commercial
            propertyTypeStr = "Property Type"
            floorAreaStr = "Floor Area"
            parkingStr = "Parking"
            areaSizeStr = "Area/Size"
            areaUnitStr = "(unit: square foot)"
            
            priceRangeStr = "Price Range"
            priceUnitStr = "(unit: dollar)"
            minStr = "Min"
            maxStr = "Max"
            garageStr = "Garage"
            openHouseStr = "Open House"
            
          // all and other
            allStr = "All"
            otherStr = "Other"
            
          // bldg type
            houseStr = "House"
            detachedHouseStr = "Detached House"
            semiDetachedHouseStr = "Semi-Detached House"
            rowTownhouseStr = "Row / Townhouse"
            condoApartmentStr = "Condo / Apartment"
            duplexStr = "Duplex"
            triplexStr = "Triplex"
            fourplexStr = "Fourplex"
            gardenHomeStr = "Garden Home"
            mobileHomeStr = "Mobile Home"
            manufacturedHomeStr = "Manufactured Home"
            recreationalCottageStr = "Recreational / Cottage"
            
          // property type for commercial
            businessStr = "Business"
            retailStr = "Retail"
            officeStr = "Office"
            industrialStr = "Industrial"
            hospitalityStr = "Hospitality"
            institutionalStr = "Institutional"
            agricultureStr = "Agriculture"
            vacantLandStr = "Vacant Land"
            
          // basement
            finishedStr = "Finished"
            unfinishedStr = "Unfinished"
            noneStr = "None"
            partialStr = "Partial"
            separated_entranceStr = "Separated Entrance"
            walk_outStr = "Walk-Out"
            crawl_spaceStr = "Crawl Space"
            walk_upStr = "Walk-Up"
            slabStr = "Slab"
            
            listingPropNotExistStr = "This listing property does not exist anymore."
            
        } else if Lang == chineseStr {
            filterStr = "搜索设置"
            listStr = "列表"
            
            residentialStr = "住宅"
            commercialStr = "商业"
            noSavedFavoritesStr = "您没有收藏。"
            listingIDStr = "房源编号"
            bedsStr = "卧室"
            bathsStr = "卫生间"
            areaStr = "面积"
            bldgTypeStr = "楼类型"
            
            noRecommendationStr = "没有推荐。"
            noPostStr = "没有文章。"
            noServiceStr = "没有服务。"
            
            forSaleStr = "出售"
            forRentStr = "出租"
            forSaleOrRentStr = "出售或出租"
            
            generalDescriptionStr = "简介"
            roomsStr = "房间"
            
            // for apartment
            listedDateStr = "上市日期"
            listedDaysStr = "上市天数"
            
            bedRoomsStr = "卧房"
            bathRoomsStr = "卫生间"
            squareFootageStr = "平方英尺"
            floorLevelStr = "楼层"
            unitNoStr = "单元号"
            propertyTaxStr = "地产税"
            maintenanceFeesStr = "管理费"
            parkingTypeStr = "车库类型"
            parkingSpacesStr = "停车位"
            heatingTypeStr = "供暖"
            coolingTypeStr = "空调"
            bldgAmenitiesStr = "建筑设施"
            propertyMgmtStr = "物业管理者"
            brokerageStr = "经纪"
            emailToBrokerStr = "电邮给经纪"
            
            // for house
            storeysStr = "楼层数"
            agesStr = "房龄"
            landSizeStr = "土地大小"
            basementStr = "地下室"
            swimmingPoolStr = "游泳池"
            
            // for commercial
            propertyTypeStr = "物业类型"
            floorAreaStr = "楼层面积"
            parkingStr = "停车位"
            areaSizeStr = "面积"
            areaUnitStr = "(单位: 平方英尺)"
            
            priceRangeStr = "价格区间"
            priceUnitStr = "(单位: dollar)"
            minStr = "最小"
            maxStr = "最大"
            garageStr = "车库"
            openHouseStr = "开放"
            
          // all and other
            allStr = "所有"
            otherStr = "其它"
            
          // bldg type
            houseStr = "独立屋"
            detachedHouseStr = "独立屋"
            semiDetachedHouseStr = "半独立屋"
            rowTownhouseStr = "排屋 / 镇屋"
            condoApartmentStr = "公寓"
            duplexStr = "双复式"
            triplexStr = "三复式"
            fourplexStr = "四复式"
            gardenHomeStr = "花园房"
            mobileHomeStr = "移动房"
            manufacturedHomeStr = "组装房"
            recreationalCottageStr = "休闲屋 / 度假屋"
            
          // property type for commercial
            businessStr = "商业"
            retailStr = "零售"
            officeStr = "办公室"
            industrialStr = "工业"
            hospitalityStr = "酒店业"
            institutionalStr = "机构"
            agricultureStr = "农业"
            vacantLandStr = "空地"
            
          // basement
            finishedStr = "完成"
            unfinishedStr = "没完成"
            noneStr = "无"
            partialStr = "部分"
            separated_entranceStr = "独立进出"
            walk_outStr = "走出式"
            crawl_spaceStr = "小空间"
            walk_upStr = "步行式"
            slabStr = "板式"
            
            listingPropNotExistStr = "本物业不再存在。"
        }
    }
    
    static func getAptDataCaptions() -> [String] {
        return [LanguageProperty.listingIDStr, LanguageProperty.listedDateStr, LanguageProperty.listedDaysStr, LanguageProperty.bldgTypeStr, LanguageProperty.bedRoomsStr, LanguageProperty.bathRoomsStr, LanguageProperty.squareFootageStr, LanguageProperty.floorLevelStr, LanguageProperty.unitNoStr, LanguageProperty.propertyTaxStr, LanguageProperty.maintenanceFeesStr, LanguageProperty.parkingTypeStr, LanguageProperty.parkingSpacesStr, LanguageProperty.heatingTypeStr, LanguageProperty.coolingTypeStr, LanguageProperty.bldgAmenitiesStr, LanguageProperty.propertyMgmtStr]
    }
    
    static func getPlexDataCaptions() -> [String] {
        return [LanguageProperty.listingIDStr, LanguageProperty.listedDateStr, LanguageProperty.listedDaysStr, LanguageProperty.bldgTypeStr, LanguageProperty.bedRoomsStr, LanguageProperty.bathRoomsStr, LanguageProperty.squareFootageStr, LanguageProperty.storeysStr, LanguageProperty.agesStr, LanguageProperty.landSizeStr, LanguageProperty.propertyTaxStr, LanguageProperty.parkingTypeStr, LanguageProperty.parkingSpacesStr, LanguageProperty.heatingTypeStr, LanguageProperty.coolingTypeStr, LanguageProperty.basementStr, LanguageProperty.swimmingPoolStr]
    }
    
    static func getHouseDataCaptions() -> [String] {
        return [LanguageProperty.listingIDStr, LanguageProperty.listedDateStr, LanguageProperty.listedDaysStr, LanguageProperty.bldgTypeStr, LanguageProperty.bedRoomsStr, LanguageProperty.bathRoomsStr, LanguageProperty.squareFootageStr, LanguageProperty.storeysStr, LanguageProperty.agesStr, LanguageProperty.landSizeStr, LanguageProperty.propertyTaxStr, LanguageProperty.parkingTypeStr, LanguageProperty.parkingSpacesStr, LanguageProperty.heatingTypeStr, LanguageProperty.coolingTypeStr, LanguageProperty.basementStr, LanguageProperty.swimmingPoolStr]
    }
    
    static func getCommDataCaptions() -> [String] {
        return [LanguageProperty.listingIDStr, LanguageProperty.listedDateStr, LanguageProperty.listedDaysStr, LanguageProperty.propertyTypeStr, LanguageProperty.floorAreaStr, LanguageProperty.propertyTaxStr, LanguageProperty.landSizeStr, LanguageProperty.parkingStr]
    }
}

