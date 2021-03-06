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
    
    
    public func get_items_all(completionHandlerItemsAll: @escaping (_ success:Bool,_ objects:[items_structure]) -> Void){
        var items: [items_structure] = []
        
        
        if (ServerAPI.settings.internet()){
            
            AF.request(ServerAPI.settings.url(method: "search", dev: true)+"&shop_id=\(ServerAPI.settings.shop_id)").responseJSON { (response) in
                if (response.value != nil) {
                    let json = JSON(response.value!)
                    let json_string_cache = json.rawString()
                    
                    
                    
                    if (json.count == 0) {
                        DispatchQueue.main.async {
                            completionHandlerItemsAll(false, [])
                        }
                        return
                    }
                    
                    
                    ServerAPI.cache.cache_items(value: json_string_cache!, name: "items_all")
                    
                    
                    for i in 0...json.count - 1 {
                        let item_AF = json[i]
                        
                        let price_AF = Float(item_AF["discount"].int!) / 100
                        let discount_AF = item_AF["price"].float! * price_AF
                        let discount_final = item_AF["price"].float! - discount_AF
                        let final = discount_final
                        
                        let parameter_AF = item_AF["specification"]
                        var parameters : [parameters_structure] = []
                        
                        if (parameter_AF.count > 0){
                            for k in 0...parameter_AF.count - 1 {
                                let parameter_single = parameter_AF[k]
//                                print(item_AF)
                                let name = parameter_single["name"].string!
                                let value = parameter_single["value"].string!
                                parameters.append(parameters_structure(id: item_AF["id"].int!, name: name, value: value))
                            }
                        }
                        
                        var images : [String] = []
                        for k in 0...item_AF["images"].count-1{
                            images.append(item_AF["images"][k].string!)
                        }
                        
                        items.append(items_structure(id: item_AF["id"].int!,
                                                     title: item_AF["name"].string!,
                                                     price: String(format:"%.2f", item_AF["price"].float!),
                                                     text: item_AF["description"].string!,
                                                     thubnail: item_AF["preview_image"].string!,
                                                     price_float: item_AF["price"].float!,
                                                     all_images: images,
                                                     parameters: parameters,
                                                     type: item_AF["type"].string!,
                                                     quanity: "\(item_AF["unit_type"].int!)",
                                                     discount: String(format:"%.2f", final),
                                                     discount_value: item_AF["discount"].int!,
                                                     discount_present: "-\(item_AF["discount"].int!)%",
                                                     rating: item_AF["rating"].int!,
                                                     amount: item_AF["quantity"].int!))
                        
                    }
                    
                    DispatchQueue.main.async {
                        completionHandlerItemsAll(true, items)
                    }
                    
                }
            }
            
        }else{
            let json_cached = ServerAPI.cache.cache_read(name: "items_all")
            
            if (json_cached != "none"){
                
                let json = JSON.init(parseJSON: json_cached)
                
                if (json.count == 0) {
                    DispatchQueue.main.async {
                        completionHandlerItemsAll(false, [])
                    }
                    return
                }
                
                
                for i in 0...json.count - 1 {
                    let item_AF = json[i]
                    
                    let price_AF = Float(item_AF["discount"].int!) / 100
                    let discount_AF = item_AF["price"].float! * price_AF
                    let discount_final = item_AF["price"].float! - discount_AF
                    let final = discount_final
                    
                    
                    
                    let parameter_AF = item_AF["specification"]
                    var parameters : [parameters_structure] = []
                    
                    if (parameter_AF.count > 0){
                        for k in 0...parameter_AF.count - 1 {
                            let parameter_single = parameter_AF[k]
                            let name = parameter_single["name"].string!
                            let value = parameter_single["value"].string!
                            parameters.append(parameters_structure(id: item_AF["id"].int!, name: name, value: value))
                        }
                    }
                    
                    var images : [String] = []
                    for k in 0...item_AF["images"].count-1{
                        images.append(item_AF["images"][k].string!)
                    }
                    
                    items.append(items_structure(id: item_AF["id"].int!,
                                                 title: item_AF["name"].string!,
                                                 price: String(format:"%.2f", item_AF["price"].float!),
                                                 text: item_AF["description"].string!,
                                                 thubnail: item_AF["preview_image"].string!,
                                                 price_float: item_AF["price"].float!,
                                                 all_images: images,
                                                 parameters: parameters,
                                                 type: item_AF["type"].string!,
                                                 quanity: "\(item_AF["unit_type"].int!)",
                                                 discount: String(format:"%.2f", final),
                                                 discount_value: item_AF["discount"].int!,
                                                 discount_present: "-\(item_AF["discount"].int!)%",
                                                 rating: item_AF["rating"].int!,
                                                 amount: item_AF["quantity"].int!))
                    
                }
                
                DispatchQueue.main.async {
                    completionHandlerItemsAll(true, items)
                }
                
            }else{
                
                DispatchQueue.main.async {
                    completionHandlerItemsAll(false, [])
                }
                
            }
        }
        
        
    }
    
    public func get_items(completionHandlerItems: @escaping (_ success:Bool,_ objects:[items_main_cateroties]) -> Void){
        
        var items: [items_main_cateroties] = []
        //        check internet connection
        
        if (ServerAPI.settings.internet()){
            
            AF.request(ServerAPI.settings.url(method: "items", dev: true)).responseJSON { (response) in
                if (response.value != nil) {
                    let json = JSON(response.value!)
                    let json_string_cache = json.rawString()
                    
                    if (json.count == 0) {
                        DispatchQueue.main.async {
                            completionHandlerItems(false, [])
                        }
                        return
                    }
                    
                    ServerAPI.cache.cache_items(value: json_string_cache!, name: "items_main")
                    
                    for i in 0...json.count - 1 {
                        let object = json[i]
                        let name = object["name"].string!
                        
                        let category_id = object["category_id"].int!
                        
                        
                        var list : [items_structure] = []
                        
                        
                        for j in 0...object["items"].count - 1  {
                            let item_AF = object["items"][j]
                            //                        math discount
                            let price_AF = Float(item_AF["discount"].int!) / 100
                            let discount_AF = item_AF["price"].float! * price_AF
                            let discount_final = item_AF["price"].float! - discount_AF
                            let final = discount_final
                            
                            let parameter_AF = item_AF["specification"]
                            var parameters : [parameters_structure] = []
                            
                            if (parameter_AF.count > 0){
                                for k in 0...parameter_AF.count - 1 {
                                    let parameter_single = parameter_AF[k]
                                    let name = parameter_single["name"].string!
                                    let value = parameter_single["value"].string!
                                    parameters.append(parameters_structure(id: item_AF["id"].int!, name: name, value: value))
                                }
                            }
                            
                            
                            var images : [String] = []
                            for k in 0...item_AF["images"].count-1{
                                images.append(item_AF["images"][k].string!)
                            }
                            
                            //                        add all items in list
                            list.append(items_structure(id: item_AF["id"].int!,
                                                        title: item_AF["name"].string!,
                                                        price: String(format:"%.2f", item_AF["price"].float!),
                                                        text: item_AF["description"].string!,
                                                        thubnail: item_AF["preview_image"].string!,
                                                        price_float: item_AF["price"].float!,
                                                        all_images: images,
                                                        parameters: parameters,
                                                        type: item_AF["type"].string!,
                                                        quanity: "\(item_AF["unit_type"].int!)",
                                                        discount: String(format:"%.2f", final),
                                                        discount_value: item_AF["discount"].int!,
                                                        discount_present: "-\(item_AF["discount"].int!)%",
                                                        rating: item_AF["rating"].int!,
                                                        amount: item_AF["quantity"].int!))
                            
                        }
                        //                    add object to main view with attachment
                        ServerAPI.items.objectWillChange.send()
                        items.append(items_main_cateroties(id: category_id, items: list, name: name))
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
            
        }else{
            let json_cached = ServerAPI.cache.cache_read(name: "items_main")
            
            if (json_cached != "none"){
                
                let json = JSON.init(parseJSON: json_cached)
                
                
                if (json.count == 0) {
                    DispatchQueue.main.async {
                        completionHandlerItems(false, [])
                    }
                    return
                }
                
                for i in 0...json.count - 1 {
                    let object = json[i]
                    let name = object["name"].string!
                    
                    let category_id = object["category_id"].int!
                    
                    
                    var list : [items_structure] = []
                    
                    for j in 0...object["items"].count - 1  {
                        let item_AF = object["items"][j]
                        //                        math discount
                        let price_AF = Float(item_AF["discount"].int!) / 100
                        let discount_AF = item_AF["price"].float! * price_AF
                        let discount_final = item_AF["price"].float! - discount_AF
                        let final = discount_final
                        
                        let parameter_AF = item_AF["specification"]
                        var parameters : [parameters_structure] = []
                        
                        if (parameter_AF.count > 0){
                            for k in 0...parameter_AF.count - 1 {
                                let parameter_single = parameter_AF[k]
                                let name = parameter_single["name"].string!
                                let value = parameter_single["value"].string!
                                parameters.append(parameters_structure(id: item_AF["id"].int!, name: name, value: value))
                            }
                        }
                        
                        var images : [String] = []
                        for k in 0...item_AF["images"].count-1{
                            images.append(item_AF["images"][k].string!)
                        }
                        
                        //                        add all items in list
                        list.append(items_structure(id: item_AF["id"].int!,
                                                    title: item_AF["name"].string!,
                                                    price: String(format:"%.2f", item_AF["price"].float!),
                                                    text: item_AF["description"].string!,
                                                    thubnail: item_AF["preview_image"].string!,
                                                    price_float: item_AF["price"].float!,
                                                    all_images: images,
                                                    parameters: parameters,
                                                    type: item_AF["type"].string!,
                                                    quanity: "\(item_AF["unit_type"].int!)",
                                                    discount: String(format:"%.2f", final),
                                                    discount_value: item_AF["discount"].int!,
                                                    discount_present: "-\(item_AF["discount"].int!)%",
                                                    rating: item_AF["rating"].int!,
                                                    amount: item_AF["quantity"].int!))
                        
                    }
                    //                    add object to main view with attachment
                    ServerAPI.items.objectWillChange.send()
                    items.append(items_main_cateroties(id: category_id, items: list, name: name))
                }
                
                DispatchQueue.main.async {
                    completionHandlerItems(true, items)
                }
                
                
            }else{
                
                DispatchQueue.main.async {
                    completionHandlerItems(false, [])
                }
                
            }
        }
        
    }
    
    public func subcategories(id: Int, completionHandlerSubcategories: @escaping (_ success:Bool,_ objects:[items_main_cateroties]) -> Void){
        
        var items: [items_main_cateroties] = []
        
        AF.request(ServerAPI.settings.url(method: "subcategories", dev: true), method: .get , parameters: ["id" : id, "shop_id": ServerAPI.settings.shop_id]).responseJSON { (response) in
            
            
            if (response.value != nil && response.response?.statusCode == 200) {
                
                let json = JSON(response.value!)
                
                if (json.count == 0) {
                    DispatchQueue.main.async {
                        completionHandlerSubcategories(false, [])
                    }
                    return
                }
                
                
                for i in 0...json.count - 1 {
                    let object = json[i]
                    let name = object["name"].string!
                    var list : [items_structure] = []
                    
                    for j in 0...object["items"].count - 1  {
                        
                        let item_AF = object["items"][j]
                        //                        math discount
                        let price_AF = Float(item_AF["discount"].int!) / 100
                        let discount_AF = item_AF["price"].float! * price_AF
                        let discount_final = item_AF["price"].float! - discount_AF
                        let final = discount_final
                        
                        let parameter_AF = item_AF["specification"]
                        var parameters : [parameters_structure] = []
                        
                        if (parameter_AF.count > 0){
                            for k in 0...parameter_AF.count - 1 {
                                let parameter_single = parameter_AF[k]
                                let name = parameter_single["name"].string!
                                let value = parameter_single["value"].string!
                                parameters.append(parameters_structure(id: item_AF["id"].int!, name: name, value: value))
                            }
                        }
                        
                        
                        var images : [String] = []
                        for k in 0...item_AF["images"].count-1{
                            images.append(item_AF["images"][k].string!)
                        }
                        
                        //                        add all items in list
                        list.append(items_structure(id: item_AF["id"].int!,
                                                    title: item_AF["name"].string!,
                                                    price: String(format:"%.2f", item_AF["price"].float!),
                                                    text: item_AF["description"].string!,
                                                    thubnail: item_AF["preview_image"].string!,
                                                    price_float: item_AF["price"].float!,
                                                    all_images: images,
                                                    parameters: parameters,
                                                    type: item_AF["type"].string!,
                                                    quanity: "\(item_AF["unit_type"].int!)",
                                                    discount: String(format:"%.2f", final),
                                                    discount_value: item_AF["discount"].int!,
                                                    discount_present: "-\(item_AF["discount"].int!)%",
                                                    rating: item_AF["rating"].int!,
                                                    amount: item_AF["quantity"].int!))
                        
                    }
                    //                    add object to main view with attachment
                    ServerAPI.items.objectWillChange.send()
                    items.append(items_main_cateroties(id: i, items: list, name: name))
                }
                
                
                DispatchQueue.main.async {
                    completionHandlerSubcategories(true, items)
                }
                
            }
        }
        
    }
    
    public func get_item(id: Int,completionHandlerItem: @escaping (_ success:Bool,_ object: items_structure) -> Void){
        
        AF.request(ServerAPI.settings.url(method: "item", dev: true), method: .get , parameters: ["id" : id]).responseJSON { (response) in
            if (response.value != nil && response.response?.statusCode == 200) {
                
                var object : items_structure = items_structure()
                let json = JSON(response.value!)
                
                
                
                if (json.count == 0) {
                    DispatchQueue.main.async {
                        completionHandlerItem(false, items_structure())
                    }
                    return
                }
                
                
                
                let item_AF = json[0]
                //                        math discount
                let price_AF = Float(item_AF["discount"].int!) / 100
                let discount_AF = item_AF["price"].float! * price_AF
                let discount_final = item_AF["price"].float! - discount_AF
                let final = discount_final
                
                let parameter_AF = item_AF["specification"]
                var parameters : [parameters_structure] = []
                
                if (parameter_AF.count > 0){
                    for k in 0...parameter_AF.count - 1 {
                        let parameter_single = parameter_AF[k]
                        let name = parameter_single["name"].string!
                        let value = parameter_single["value"].string!
                        parameters.append(parameters_structure(id: item_AF["id"].int!, name: name, value: value))
                    }
                }
                
                
                var images : [String] = []
                for k in 0...item_AF["images"].count-1{
                    images.append(item_AF["images"][k].string!)
                }
                
                //                        add all items in list
                object = items_structure(id: item_AF["id"].int!,
                                         title: item_AF["name"].string!,
                                         price: String(format:"%.2f", item_AF["price"].float!),
                                         text: item_AF["description"].string!,
                                         thubnail: item_AF["preview_image"].string!,
                                         price_float: item_AF["price"].float!,
                                         all_images: images,
                                         parameters: parameters,
                                         type: item_AF["type"].string!,
                                         quanity: "\(item_AF["unit_type"].int!)",
                                         discount: String(format:"%.2f", final),
                                         discount_value: item_AF["discount"].int!,
                                         discount_present: "-\(item_AF["discount"].int!)%",
                                         rating: item_AF["rating"].int!,
                                         amount: item_AF["quantity"].int!)
                
                
                //                    add object to main view with attachment
                ServerAPI.items.objectWillChange.send()
                
                DispatchQueue.main.async {
                    completionHandlerItem(true, object)
                }
                
                
            }
        }
    }
    
    public func get_catalog(completionHandlerCatalog: @escaping (_ success:Bool,_ object: [categories_local_structure]) -> Void){
        
        
        AF.request(ServerAPI.settings.url(method: "categories", dev: true), method: .get).responseJSON { (response) in
            if (response.value != nil && response.response?.statusCode == 200) {
                
                var object : [categories_local_structure] = []
                let json = JSON(response.value!)
                
                
                
                if (json.count == 0) {
                    DispatchQueue.main.async {
                        completionHandlerCatalog(false, object)
                    }
                    return
                }
                
                
                for i in 0...json.count - 1 {
                    object.append(categories_local_structure(id: json[i]["id"].int!,
                                                             name: json[i]["name"].string!,
                                                             image: json[i]["image"].string!))
                }
                
                DispatchQueue.main.async {
                    completionHandlerCatalog(true, object)
                }
                
                
            }
        }
    }
}
