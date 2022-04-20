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
            postData.appendString("Content-Disposition:form-data; name=\"\(key)\"")
            
            if value is String {
                let paramValue = value as! String
                postData.appendString("\r\n\r\n\(paramValue)\r\n")
            } else if value is UIImage {
                let uiImage = value as! UIImage
                let imageData = uiImage.jpegData(compressionQuality: 0.9)!
                let fileName = UUID().uuidString
                postData.appendString("; filename=\"\(fileName)\"\r\n"
                                      + "Content-Type: image/jpeg\r\n\r\n")
                postData.append(imageData)
                postData.appendString("\r\n")
            }
            
        }
        postData.appendString("--\(boundary)--\r\n")
        httpBody = postData
        setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    }
    
}
