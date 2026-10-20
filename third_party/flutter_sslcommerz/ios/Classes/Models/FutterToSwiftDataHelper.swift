//
//  FutterToSwiftDataHelper.swift
//  Runner
//
//  Created by Mausum Nandy on 6/14/21.
//

import Foundation
import SSLCommerzSDK

class FutterToSwiftDataHelper {
    private init(){}
    private(set) var integrationInformation: IntegrationInformation!
    private(set) var emiInformation: EMIInformation?
    private(set) var customerInformation: CustomerInformation?
    private(set) var shipmentInformation: ShipmentInformation?
    private(set) var productInformation: ProductInformation?
    private(set) var additionalInformation: AdditionalInformation?
    public init (flutterData: FlutterInputDataModel){
        self.integrationInformation = IntegrationInformation(storeID: flutterData.initializer?.storeId ?? "", storePassword: flutterData.initializer?.storePasswd ?? "", totalAmount: Double(flutterData.initializer?.totalAmount ?? 0), currency: flutterData.initializer?.currency ?? "", transactionId: flutterData.initializer?.tranId ?? "", productCategory: flutterData.initializer?.productCategory ?? "")
        if let ipnUrl = flutterData.initializer?.ipnUrl{
            integrationInformation.ipnURL = ipnUrl
        }
        if let multiCardName = flutterData.initializer?.multiCardName{
            integrationInformation.multiCardName = multiCardName
        }
        if let allowedBIN = flutterData.initializer?.allowedBin{
            integrationInformation.allowedBIN = allowedBIN
        }
        if let language = flutterData.initializer?.language{
           integrationInformation.language = language
        }
        
        if let customer = flutterData.customerInfoInitializer{
            self.customerInformation = CustomerInformation(customerName: customer.customerName ?? "", customerEmail: customer.customerEmail ?? "", customerAddressOne: customer.customerAddress1 ?? "", customerCity: customer.customerCity ?? "", customerPostCode: customer.customerPostCode ?? "", customerCountry: customer.customerCountry ?? "BD", customerPhone: customer.customerPhone ?? "")
        }
       
        if let additional = flutterData.sslcAdditionalInitializer{
            self.additionalInformation = AdditionalInformation()
            self.additionalInformation?.paramA = additional.valueA
            self.additionalInformation?.paramB = additional.valueB
            self.additionalInformation?.paramC = additional.valueC
            self.additionalInformation?.paramD = additional.valueD
            self.additionalInformation?.campaignCode = additional.campaignCode
            self.additionalInformation?.invoiceId = additional.invoiceCode
            self.additionalInformation?.noOffer = additional.noOffer == 0 ? .withDiscountOffer : .NoDiscountOffer
           
            
            
        }
        if let emiInfo = flutterData.sslcemiTransactionInitializer{
            self.emiInformation = EMIInformation(emiOption: EMIOptions(rawValue: emiInfo.emiOptions!) ?? .NoEMI)
            self.emiInformation?.emiMaximumInstallmentOption = emiInfo.emiMaxListOptions as NSNumber?
            self.emiInformation?.emiSelectedInstallmentOption = emiInfo.emiSelectedInst as NSNumber?
        }
        if let shipment = flutterData.sslcShipmentInfoInitializer{
            self.shipmentInformation = ShipmentInformation(shippingMethod: shipment.shipmentMethod ?? "", numberOfItem: Int(shipment.numOfItems ?? 0), shippingName: shipment.shipmentDetails?.shipName ?? "", shippingAddressOne: shipment.shipmentDetails?.shipAddress1 ?? "", shippingAddressTwo: shipment.shipAddress2 ?? "", shippingCity: shipment.shipmentDetails?.shipCity ?? "", shippingPostCode: shipment.shipmentDetails?.shipPostCode ?? "", shippingCountry: shipment.shipmentDetails?.shipCountry ?? "")
        }
        if let product = flutterData.sslcProductInitializer{
            if let discountAmount = product.discountAmount{
                self.productInformation = ProductInformation(discountAmount:discountAmount)
            }
            if product.general != nil{
                self.productInformation = ProductInformation(productName: product.productName ?? "", productCategory: product.productCategory ?? "", productProfile: ProductProfileOptions.General.profile)
            }
            if product.nonPhysicalGoods != nil{
                self.productInformation = ProductInformation(productName: product.productName ?? "", productCategory: product.productCategory ?? "", productProfile: ProductProfileOptions.NonPhysicalGoods.profile)
            }
            if product.physicalGoods != nil{
                self.productInformation = ProductInformation(productName: product.productName ?? "", productCategory: product.productCategory ?? "", productProfile: ProductProfileOptions.PhysicalGoods.profile)
            }
            if let ticket =  product.airlinesTicket{
                self.productInformation = ProductInformation(productName: product.productName ?? "", productCategory: product.productCategory ?? "", productProfile: ProductProfileOptions.AirlineTickets(hoursTillDeparture: ticket.hoursTillDeparture ?? "", flightType: ticket.flightType ?? "", pnr: ticket.pnr ?? "", journeyFromTo: ticket.journeyFromTo ?? "", thirdPartyBooking: ticket.thirdPartyBooking?.lowercased() == "yes" ? true :false).profile)
            }
            if let travelVertical =  product.travelVertical{
                self.productInformation = ProductInformation(productName: product.productName ?? "", productCategory: product.productCategory ?? "", productProfile: ProductProfileOptions.TravelVertical(hotelName: travelVertical.hotelName ?? "", lengthOfStay: travelVertical.lengthOfStay ?? "", checkInTime: travelVertical.checkInTime ?? "", hotelCity: travelVertical.hotelCity ?? "").profile)
            }
            if let telecomVertical =  product.telecomVertical{
                self.productInformation = ProductInformation(productName: product.productName ?? "", productCategory: product.productCategory ?? "", productProfile: ProductProfileOptions.TelecomVertical(productType: telecomVertical.productType ?? "", topupNumber: telecomVertical.topUpNumber ?? "", countryTopup: telecomVertical.countryTopUp ?? "").profile)
            }
            if self.productInformation != nil{
                self.productInformation?.productAmount =
                    NSNumber(value: product.productAmount ?? 0.0)

                self.productInformation?.vat = NSNumber(value: product.vat ?? 0.0)
                self.productInformation?.discountAmount = NSNumber(value: product.discountAmount ?? 0.0)
                self.productInformation?.convenienceFee = NSNumber(value: product.convenienceFee ?? 0.0)
                
                if let carts = product.cart{
                    self.productInformation?.cart = []
                    carts.forEach { cart in
                        self.productInformation?.cart?.append(CartItem(product: cart.product, quantity: cart.quantity, amount: cart.amount))
                    }
                }
            }
        }
    }
}
