//
//  URLRequest+Extension.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/20.
//

import UIKit

extension URLRequest {
    
    mutating func createMultipartFormData(parameters: [String: Any]) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var postData = Data()
        
        for (key, value) in parameters {
            postData.appendString("--\(boundary)\r\n")
            postData.appendString("Content-Disposition:form-data; name=\"\(key)\";")
            
            switch value {
            case let value as String:
                postData.appendString("\r\n\r\n\(value)\r\n")
            case let value as UIImage:
                let imageData = value.jpegData(compressionQuality: 0.9)!
                let fileName = UUID().uuidString
                postData.appendString("filename=\"\(fileName)\"\r\n")
                postData.appendString("Content-Type: image/jpeg\r\n\r\n")
                postData.append(imageData)
                postData.appendString("\r\n")
            default:
                break
            }
        }
        postData.appendString("--\(boundary)--\r\n")
        httpBody = postData
        setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    }
    
}
