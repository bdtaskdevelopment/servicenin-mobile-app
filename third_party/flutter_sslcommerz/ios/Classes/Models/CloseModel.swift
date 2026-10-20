//
//  CloseModel.swift
//  flutter_sslcommerz
//
//  Created by Abu Sayed Chowdhury on 16/10/22.
//

import Foundation
class ClosedModel : Codable{
    let status, message:String
    init(status:String,message:String){
        self.status = status
        self.message = message
    }
    enum CodingKeys:String,CodingKey {
        case status,message
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.message, forKey: .message)
    }
}
