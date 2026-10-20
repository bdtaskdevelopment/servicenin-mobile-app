//
//  FlutterInputDataModel.swift
//  Runner
//
//  Created by Mausum Nandy on 6/14/21.
//

import Foundation


class FlutterInputDataModel: Codable {
    let initializer: Initializer?
    let customerInfoInitializer: CustomerInfoInitializer?
    let sslcemiTransactionInitializer: SslcemiTransactionInitializer?
    let sslcShipmentInfoInitializer: SslcShipmentInfoInitializer?
    let sslcProductInitializer: SslcProductInitializer?
    let sslcAdditionalInitializer: SslcAdditionalInitializer?
    
    enum CodingKeys: String, CodingKey {
        case initializer = "initializer"
        case customerInfoInitializer = "customerInfoInitializer"
        case sslcemiTransactionInitializer = "sslcemiTransactionInitializer"
        case sslcShipmentInfoInitializer = "sslcShipmentInfoInitializer"
        case sslcProductInitializer = "sslcProductInitializer"
        case sslcAdditionalInitializer = "sslcAdditionalInitializer"
    }
    
    init(initializer: Initializer?, customerInfoInitializer: CustomerInfoInitializer?, sslcemiTransactionInitializer: SslcemiTransactionInitializer?, sslcShipmentInfoInitializer: SslcShipmentInfoInitializer?, sslcProductInitializer: SslcProductInitializer?, sslcAdditionalInitializer: SslcAdditionalInitializer?) {
        self.initializer = initializer
        self.customerInfoInitializer = customerInfoInitializer
        self.sslcemiTransactionInitializer = sslcemiTransactionInitializer
        self.sslcShipmentInfoInitializer = sslcShipmentInfoInitializer
        self.sslcProductInitializer = sslcProductInitializer
        self.sslcAdditionalInitializer = sslcAdditionalInitializer
    }
}

// MARK: - CustomerInfoInitializer
class CustomerInfoInitializer: Codable {
    let customerName: String?
    let customerEmail: String?
    let customerAddress1: String?
    let customerAddress2: String?
    let customerCity: String?
    let customerState: String?
    let customerPostCode: String?
    let customerCountry: String?
    let customerPhone: String?
    let customerFax: String?
    var userRefer: String?
    enum CodingKeys: String, CodingKey {
        case customerName = "customerName"
        case customerEmail = "customerEmail"
        case customerAddress1 = "customerAddress1"
        case customerAddress2 = "customerAddress2"
        case customerCity = "customerCity"
        case customerState = "customerState"
        case customerPostCode = "customerPostCode"
        case customerCountry = "customerCountry"
        case customerPhone = "customerPhone"
        case customerFax = "customerFax"
    }
    
    init(customerName: String?, customerEmail: String?, customerAddress1: String?, customerAddress2: String?, customerCity: String?, customerState: String?, customerPostCode: String?, customerCountry: String?, customerPhone: String?, customerFax: String?) {
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerAddress1 = customerAddress1
        self.customerAddress2 = customerAddress2
        self.customerCity = customerCity
        self.customerState = customerState
        self.customerPostCode = customerPostCode
        self.customerCountry = customerCountry
        self.customerPhone = customerPhone
        self.customerFax = customerFax
    }
}

// MARK: - Initializer
class Initializer: Codable {
    let storeId: String?
    let storePasswd: String?
    let totalAmount: Double?
    let currency: String?
    let tranId: String?
    let productCategory: String?
    let ipnUrl: String?
    let multiCardName: String?
    let allowedBin: String?
    let sdkType: String?
    let billNumber:String?
    let language: String?
    
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case storePasswd = "store_passwd"
        case totalAmount = "total_amount"
        case currency = "currency"
        case tranId = "tran_id"
        case productCategory = "product_category"
        case ipnUrl = "ipn_url"
        case multiCardName = "multi_card_name"
        case allowedBin = "allowed_bin"
        case sdkType = "sdkType"
        case billNumber = "bill_number"
        case language = "language"
    }
    
    init(storeId: String?, storePasswd: String?, totalAmount: Double?, currency: String?, tranId: String?, productCategory: String?, ipnUrl: String?, multiCardName: String?, allowedBin: String?, sdkType: String?,billNumber:String?, language: String?) {
        self.storeId = storeId
        self.storePasswd = storePasswd
        self.totalAmount = totalAmount
        self.currency = currency
        self.tranId = tranId
        self.productCategory = productCategory
        self.ipnUrl = ipnUrl
        self.multiCardName = multiCardName
        self.allowedBin = allowedBin
        self.sdkType = sdkType
        self.billNumber = billNumber
        self.language = language
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.storeId, forKey: .storeId)
        try container.encode(self.storePasswd, forKey: .storePasswd)
        try container.encode(self.totalAmount, forKey: .totalAmount)
        try container.encode(self.currency, forKey: .currency)
        try container.encode(self.tranId, forKey: .tranId)
        try container.encode(self.productCategory, forKey: .productCategory)
        try container.encode(self.ipnUrl, forKey: .ipnUrl)
        try container.encode(self.multiCardName, forKey: .multiCardName)
        try container.encode(self.allowedBin, forKey: .allowedBin)
        try container.encode(self.billNumber, forKey: .billNumber)
        try container.encode(self.language, forKey: .language)
    }
}

// MARK: - SslcAdditionalInitializer
class SslcAdditionalInitializer: Codable {
    let valueA: String?
    let valueB: String?
    let valueC: String?
    let valueD: String?
    let campaignCode: String?
    let invoiceCode: String?
    let noOffer: Int?
    let billNumber: String?
    let userRefer: String?
  

    enum CodingKeys: String, CodingKey {
        case valueA = "valueA"
        case valueB = "valueB"
        case valueC = "valueC"
        case valueD = "valueD"
        case campaignCode = "campaign_code"
        case invoiceCode = "invoice_id"
        case noOffer = "no_offer"
        case billNumber = "bill_number"
        case userRefer = "user_refer"
       //case extras = "extras"
    }

    init(valueA: String?, valueB: String?, valueC: String?, valueD: String?,
         campaignCode: String?, invoiceCode: String?, noOffer: Int?,
         billNumber: String?, userRefer: String?) {
        self.valueA = valueA
        self.valueB = valueB
        self.valueC = valueC
        self.valueD = valueD
        self.campaignCode = campaignCode
        self.invoiceCode = invoiceCode
        self.noOffer = noOffer
        self.billNumber = billNumber
        self.userRefer = userRefer
       
    }
}


// MARK: - SslcProductInitializer
class SslcProductInitializer: Codable {
    let productName: String?
    let productCategory: String?
    
    let cart: [Cart]?
    let productAmount: Double?
    let vat: Double?
    let discountAmount: Double?
    let convenienceFee: Double?
    let airlinesTicket: ComAirlinesTicket?
    let general: ComGeneral?
    let physicalGoods: ComPhysicalGoods?
    let nonPhysicalGoods: ComNonPhysicalGoods?
        let telecomVertical: ComTelecomVertical?
        let travelVertical: ComTravelVertical?
    
    enum CodingKeys: String, CodingKey {
        case productName = "productName"
        case productCategory = "productCategory"
        case cart = "cart"
        case productAmount = "productAmount"
        case vat = "vat"
        case discountAmount = "discountAmount"
        case convenienceFee = "convenienceFee"
        case airlinesTicket = "airlinesTicket"
        case general = "general"
        case physicalGoods = "physicalGoods"
        case nonPhysicalGoods = "nonPhysicalGoods"
        case telecomVertical = "telecomVertical"
        case travelVertical = "travelVertical"
    }
    //airlinesTicket: JSONNull?, general: General?, physicalGoods: JSONNull?, nonPhysicalGoods: JSONNull?, telecomVertical: JSONNull?, travelVertical: JSONNull?
    init(productName: String?, productCategory: String?, cart: [Cart]?, productAmount: Double?, vat: Double?, discountAmount: Double?, convenienceFee: Double?,airlinesTicket: ComAirlinesTicket?, general: ComGeneral?, physicalGoods: ComPhysicalGoods?, nonPhysicalGoods: ComNonPhysicalGoods?, telecomVertical: ComTelecomVertical?,travelVertical: ComTravelVertical?) {
        self.productName = productName
        self.productCategory = productCategory
        self.cart = cart
        self.productAmount = productAmount
        self.vat = vat
        self.discountAmount = discountAmount
        self.convenienceFee = convenienceFee
        self.airlinesTicket = airlinesTicket
        self.general = general
        self.physicalGoods = physicalGoods
        self.nonPhysicalGoods = nonPhysicalGoods
        self.telecomVertical = telecomVertical
        self.travelVertical = travelVertical
    }
}

class Cart: Codable{
    
    let product: String
    let  quantity: String
    let  amount: String
    
    enum CodingKeys: String, CodingKey {
        case product = "product"
        case quantity = "quantity"
        case amount = "amount"
    }
    
    @objc public init(product: String, quantity: String, amount: String) {
        self.product = product
        self.quantity = quantity
        self.amount = amount
    }
}
// MARK: - General
class ComGeneral: Codable {
    let general: String?
    let productProfile: String?
    
    enum CodingKeys: String, CodingKey {
        case general = "general"
        case productProfile = "productProfile"
    }
    
    init(general: String?, productProfile: String?) {
        self.general = general
        self.productProfile = productProfile
    }
}

class ComNonPhysicalGoods : Codable{
    let  nonPhysicalGoods :String?
    let  productProfile:String?
    enum CodingKeys: String, CodingKey {
        case nonPhysicalGoods ,productProfile
    }
    init(nonPhysicalGoods: String?, productProfile: String?) {
        self.nonPhysicalGoods = nonPhysicalGoods
        self.productProfile = productProfile
    }
}
class ComPhysicalGoods : Codable{
    let  physicalGoods :String?
    let  productProfile:String?
    enum CodingKeys: String, CodingKey {
        case physicalGoods ,productProfile
    }
    init(physicalGoods: String?, productProfile: String?) {
        self.physicalGoods = physicalGoods
        self.productProfile = productProfile
    }
}

class ComAirlinesTicket : Codable{
    let productProfile:String?
    let hoursTillDeparture:String?
    let flightType:String?
    let pnr:String?
    let journeyFromTo:String?
    let thirdPartyBooking:String?
    enum CodingKeys: String, CodingKey {
        case productProfile ,hoursTillDeparture,flightType,pnr,journeyFromTo,thirdPartyBooking
    }
    init( productProfile: String?,hoursTillDeparture:String?,flightType:String?,pnr:String?,journeyFromTo:String?,thirdPartyBooking:String?) {
        self.productProfile = productProfile
        self.hoursTillDeparture = hoursTillDeparture
        self.journeyFromTo = journeyFromTo
        self.flightType = flightType
        self.pnr = pnr
        self.thirdPartyBooking = thirdPartyBooking
    }
}

class ComTelecomVertical :Codable{
    let productProfile: String?
    let productType: String?
    let topUpNumber:String?
    let countryTopUp:String?
    enum CodingKeys: String, CodingKey {
        case productProfile ,productType,topUpNumber,countryTopUp
    }
    init(productProfile: String?,productType: String?,topUpNumber:String?,countryTopUp:String?) {
        self.productProfile = productProfile
        self.productType = productType
        self.topUpNumber = topUpNumber
        self.countryTopUp = countryTopUp
    }
}
class ComTravelVertical :Codable{
    let productProfile:String?
    let hotelName:String?
    let lengthOfStay:String?
    let checkInTime:String?
    let hotelCity:String?
    init(productProfile: String?,hotelName: String?,lengthOfStay:String?,checkInTime:String?,hotelCity:String?) {
        self.productProfile = productProfile
        self.hotelName = hotelName
        self.lengthOfStay = lengthOfStay
        self.checkInTime = checkInTime
        self.hotelCity = hotelCity
    }
}

// MARK: - SslcShipmentInfoInitializer
class SslcShipmentInfoInitializer: Codable {
    let shipmentMethod: String?
    let shipAddress2: String?
    let shipState: String?
    let numOfItems: Int?
    let shipmentDetails: ShipmentDetails?
    
    enum CodingKeys: String, CodingKey {
        case shipmentMethod = "shipmentMethod"
        case shipAddress2 = "shipAddress2"
        case shipState = "shipState"
        case numOfItems = "numOfItems"
        case shipmentDetails = "shipmentDetails"
    }
    
    init(shipmentMethod: String?, shipAddress2: String?, shipState: String?, numOfItems: Int?, shipmentDetails: ShipmentDetails?) {
        self.shipmentMethod = shipmentMethod
        self.shipAddress2 = shipAddress2
        self.shipState = shipState
        self.numOfItems = numOfItems
        self.shipmentDetails = shipmentDetails
    }
}

// MARK: - ShipmentDetails
class ShipmentDetails: Codable {
    let shipName: String?
    let shipAddress1: String?
    let shipCity: String?
    let shipPostCode: String?
    let shipCountry: String?
    
    enum CodingKeys: String, CodingKey {
        case shipName = "shipName"
        case shipAddress1 = "shipAddress1"
        case shipCity = "shipCity"
        case shipPostCode = "shipPostCode"
        case shipCountry = "shipCountry"
    }
    
    init(shipName: String?, shipAddress1: String?, shipCity: String?, shipPostCode: String?, shipCountry: String?) {
        self.shipName = shipName
        self.shipAddress1 = shipAddress1
        self.shipCity = shipCity
        self.shipPostCode = shipPostCode
        self.shipCountry = shipCountry
    }
}

// MARK: - SslcemiTransactionInitializer
class SslcemiTransactionInitializer: Codable {
    let emiOptions: Int?
    let emiMaxListOptions: Int?
    let emiSelectedInst: Int?
    
    enum CodingKeys: String, CodingKey {
        case emiOptions = "emi_options"
        case emiMaxListOptions = "emi_max_list_options"
        case emiSelectedInst = "emi_selected_inst"
    }
    
    init(emiOptions: Int?, emiMaxListOptions: Int?, emiSelectedInst: Int?) {
        self.emiOptions = emiOptions
        self.emiMaxListOptions = emiMaxListOptions
        self.emiSelectedInst = emiSelectedInst
    }
}
