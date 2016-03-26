//
//  GiphyClient.swift
//  Talkie
//
//  Created by Abdul-Wasai Wasim on 3/7/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import Foundation

//CITE: VIRTUAL TOURIST
class GiphyClient {
    
    private static let session = NSURLSession.sharedSession()
    
    class func getGifs(searchWord: String, completionHandler: (images:[String], error: NSError?)->Void)->NSURLSessionTask {

        let url = NSURL(string: "https://api.giphy.com/v1/gifs/search?q=\(searchWord)&api_key=dc6zaTOxFJmzC")
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                return completionHandler(images: [], error: error)
            }
            
            parseJSONData(data!, completionHandler: { (result, error) -> Void in
             
                guard let dictionary = result as? NSDictionary else {
                    return
                }
                guard let imageDictionary = dictionary["data"] else {
                    return
                }
                var images = [String]()
                for i in 0..<imageDictionary.count {
                    let string = imageDictionary[i]!["images"]!!["original"]!!["url"] as! String
                    images.append(string)
                }
                completionHandler(images: images, error: error)

            })
            
        }
        task.resume()
        return task
    }
    
    static func parseJSONData(data: NSData, completionHandler: (result: AnyObject!, error: NSError?)-> Void){
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        }catch{
            let userInfo = [NSLocalizedDescriptionKey: "\(data)"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONData", code: 1, userInfo: userInfo))
        }
        completionHandler(result: parsedResult, error: nil)
    }
}