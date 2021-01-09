//
//  File.swift
//  
//
//  Created by Michael on 07.01.2021.
//

import Foundation
import Alamofire
import SwiftUI
import SwiftyJSON
import SystemConfiguration


//TODO - Write Cache Policy

public class Items: ObservableObject, Identifiable {
    public var id: Int = 0
    
    
    
    public func get_items(completionHandlerItems: @escaping (_ success:Bool,_ objects:[items_main_cateroties]) -> Void){
        
        var items: [items_main_cateroties] = []
//        check internet connection
        
        if (ServerAPI.settings.internet()){
            print("internet")
        }else{
            print("non internet")
        }
//        get all items
        AF.request(ServerAPI.settings.url(method: "m-items")).responseJSON { (response) in
            if (response.value != nil) {
                let json = JSON(response.value!)
//                let json_string_cache = json.rawString()
                
                if (json.count == 0) { return }
                
                for i in 0...json.count - 1 {
                    let object = json[i]
                    let name = object["Name"].string!
                    var list : [items_structure] = []
                    
                    for j in 0...object["Items"].count - 1  {
                        let item_AF = object["Items"][j]
//                        math discount
                        let price_AF = Float(item_AF["Discount"].int!) / 100
                        let discount_AF = item_AF["Price"].float! * price_AF
                        let discount_final = item_AF["Price"].float! - discount_AF
                        let final = discount_final
                        
                        let parameter_AF = item_AF["Specifications"]
                        var parameters : [parameters_structure] = []
                        
                        if (parameter_AF.count > 0){
                            for k in 0...parameter_AF.count - 1 {
                                let parameter_single = parameter_AF[k]
                                let name = parameter_single["name"].string!
                                let value = parameter_single["value"].string!
                                parameters.append(parameters_structure(id: item_AF["ID"].int!, name: name, value: value))
                            }
                        }
                       
                        
                        var quanity : String = ""
                        if (item_AF["Quantity"].count > 0){
                            quanity = "\(item_AF["Quantity"][0]["value"].int!)"
                        }
                        
//                        add all items in list
                        list.append(items_structure(id: item_AF["ID"].int!,
                                                    title: item_AF["Name"].string!,
                                                    price: String(format:"%.2f", item_AF["Price"].float!),
                                                    text: item_AF["Description"].string!,
                                                    thubnail: item_AF["Image"][0].string!,
                                                    price_float: item_AF["Price"].float!,
                                                    all_images: [],
                                                    parameters: parameters,
                                                    type: item_AF["Type"].string!,
                                                    quanity: quanity,
                                                    discount: String(format:"%.2f", final),
                                                    discount_value: item_AF["Discount"].int!,
                                                    discount_present: "-\(item_AF["Discount"].int!)%",
                                                    ItemRating: 5))
                        
                    }
//                    add object to main view with attachment
                    ServerAPI.items.objectWillChange.send()
                    items.append(items_main_cateroties(id: i, items: list, name: name))
                }
//                End add to items list and foreach
                if (ServerAPI.settings.debug){
                    print(items)
                }
                
                DispatchQueue.main.async {
                    completionHandlerItems(true, items)
                }
            }
        }
    }
}
