//
//  FacebookHelper.swift
//  Budget
//
//  Created by Vadik on 13/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import FBSDKLoginKit

class FacebookHelper {
    static func loadUserData(onLabel label: UILabel, andImage image: UIImageView) {
        GraphRequest.init(graphPath: "me", parameters: ["fields" : "picture, name"]).start(completionHandler: { (connection, result, error) in
            if let result = result as? NSDictionary {
                label.text = result["name"] as? String
                
                if let picture = result["picture"] as? NSDictionary,
                    let data = picture["data"] as? NSDictionary,
                    let urlStr = data["url"] as? String,
                    let url = URL.init(string: urlStr) {
                    do {
                        let data = try Data.init(contentsOf: url)
                        image.image = UIImage.init(data: data)
                    } catch {
                        
                    }
                }
            }
        })
    }
}
