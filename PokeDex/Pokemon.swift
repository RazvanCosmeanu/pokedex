//
//  Pokemon.swift
//  PokeDex
//
//  Created by hey on 20/07/2017.
//  Copyright © 2017 hey. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _pokemonURL: String!
    private var _nextEvolutionName: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLevel: String!
    
    var nextEvolutionName: String {
        return _nextEvolutionName ?? ""
    }
    
    var nextEvolutionId: String {
        return _nextEvolutionId ?? ""
    }
    
    var nextEvolutionLevel: String {
        return _nextEvolutionLevel ?? ""
    }
    
    var name: String {
        return _name
    }
    
    var type: String {
        return _type ?? ""
    }
    
    var description: String {
        return _description ?? ""
    }
    
    var nextEvolutionTxt: String {
        return _nextEvolutionTxt ?? ""
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var defense: String {
        return _defense ?? ""
    }
    
    var height: String {
        return _height ?? ""
    }
    
    var weight: String {
        return _weight ?? ""
    }
    
    var attack: String {
        return _attack ?? ""
    }
    
    
    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId!)/"
    }
    
    func downloadPokemonDetail(completed: @escaping DownloadComplete) {
        Alamofire.request(self._pokemonURL).responseJSON { response in
            
            if let dict = response.result.value as? Dictionary<String, Any> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                
                if let types = dict["types"] as? Array<Dictionary<String, Any>> {
                    self._type = types.reduce("", { x, y in
                        if let type1 = x , let type2 = y["name"] as? String {
                            return "\(type1.capitalized)\(type1 == "" ? "" : "/")\(type2.capitalized)"
                        }
                        
                        return ""
                    })
                }
                
                if let descriptionArr = dict["descriptions"] as? Array<Dictionary<String, String>>, descriptionArr.count > 0 {
                    if let url = descriptionArr[0]["resource_uri"] {
                        
                        let descUrl = "\(URL_BASE)\(url)"
                    
                        Alamofire.request(descUrl).responseJSON(completionHandler: { (response) in
                            if let descDict = response.result.value as? Dictionary<String, Any> {
                                if let pokeDescription = descDict["description"] as? String {
                                    self._description = pokeDescription.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                }
                            }
                            completed()
                        })
                    }
                    
                    
                }
                
                else {
                    self._description = ""
                }
                
                if let evolutions = dict["evolutions"] as? Array<Dictionary<String, Any>>, evolutions.count > 0 {
                    
                    if let nextEvo = evolutions[0]["to"] as? String {
                        if nextEvo.range(of: "mega") == nil {
                            self._nextEvolutionName = nextEvo
                            
                            if let uri = evolutions[0]["resource_uri"] as? String {
                                let evoId = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                               .replacingOccurrences(of: "/", with: "")
                                
                                self._nextEvolutionId = evoId
                                
                                if let lvlExist = evolutions[0]["level"] {
                                    if let lvl = lvlExist as? Int {
                                        self._nextEvolutionLevel = "\(lvl)"
                                    }
                                }
                                
                                else {
                                    self._nextEvolutionLevel = ""
                                }
                            }
                            
                        }
                        
                    }
                    
                } else {
                    self._nextEvolutionTxt = ""
                }
            }
            
            completed()
            
        }
    }
}
