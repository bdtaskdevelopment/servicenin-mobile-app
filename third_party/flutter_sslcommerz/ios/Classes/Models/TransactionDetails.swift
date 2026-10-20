//
//  TransactionDetails.swift
//  flutter_sslcommerze
//
//  Created by Mausum Nandy on 6/23/21.
//

import Foundation
import SSLCommerzSDK
extension TransactionDetails: Encodable{
    
    enum CodingKeys:String,CodingKey {
        case status,sessionkey,tran_date,tran_id,val_id,amount,store_amount,
             bank_tran_id,card_type,card_no,card_issuer,card_brand,card_issuer_country,card_issuer_country_code,currency_type,currency_amount,currency_rate,base_fair,value_a,value_b,value_c,value_d,risk_title,risk_level,apiConnect,validated_on,gw_version
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.sessionkey, forKey: .sessionkey)
        try container.encode(self.tran_date, forKey: .tran_date)
        try container.encode(self.tran_id, forKey: .tran_id)
        try container.encode(self.val_id, forKey: .val_id)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.store_amount, forKey: .store_amount)
        try container.encode(self.bank_tran_id, forKey: .bank_tran_id)
        
        try container.encode(self.card_type, forKey: .card_type)
        try container.encode(self.card_no, forKey: .card_no)
        try container.encode(self.card_issuer, forKey: .card_issuer)
        try container.encode(self.card_brand, forKey: .card_brand)
        try container.encode(self.card_issuer_country, forKey: .card_issuer_country)
        try container.encode(self.currency_amount, forKey: .currency_amount)
        try container.encode(self.base_fair, forKey: .base_fair)
        try container.encode(self.currency_rate, forKey: .currency_rate)
        try container.encode(self.value_a, forKey: .value_a)
        try container.encode(self.value_b, forKey: .value_b)
        try container.encode(self.value_c, forKey: .value_c)
        try container.encode(self.value_d, forKey: .value_d)
        try container.encode(self.risk_title, forKey: .risk_title)
        try container.encode(self.risk_level, forKey: .risk_level)
        try container.encode(self.apiConnect, forKey: .apiConnect)
        try container.encode(self.validated_on, forKey: .validated_on)
        try container.encode(self.gw_version, forKey: .gw_version)
    }
    
    
}
