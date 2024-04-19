//
//  APIClient.swift
//  MR_Mapping_iOS
//
//  Created by 棚橋柊太 on 2024/04/16.
//

import Foundation

let baseURL = "https://mr-mapping-88ceb7c2955d.herokuapp.com"

class APIClient {
    static let shared = APIClient()
    
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let loginURL = URL(string: "\(baseURL)/login/")!
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = jsonResponse["token"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure(NSError(domain: "LoginError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "LoginError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
            }
        }.resume()
    }
    
    func register(username: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let registerURL = URL(string: "\(baseURL)/users/")!
        var request = URLRequest(url: registerURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["username": username, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let _ = data {
                completion(.success(()))
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchRooms(completion: @escaping (Result<[Room], Error>) -> Void) {
        let roomsURL = URL(string: "\(baseURL)/rooms/")!
        var request = URLRequest(url: roomsURL)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let rooms = jsonResponse.compactMap { (roomDict: [String: Any]) -> Room? in
                        guard let id = roomDict["id"] as? Int,
                              let name = roomDict["name"] as? String,
                              let x = roomDict["x"] as? Int,
                              let y = roomDict["y"] as? Int else {
                            return nil
                        }
                        return Room(id: id, name: name, x: x, y: y)
                    }
                    completion(.success(rooms))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func postNavi(depRoomId: Int, arrRoomId: Int, userId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let naviURL = URL(string: "\(baseURL)/navi/create/")!
        var request = URLRequest(url: naviURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "dep_room": depRoomId,
            "arr_room": arrRoomId,
            "user": userId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let _ = data {
                completion(.success(()))
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchNavis(completion: @escaping (Result<[Navi], Error>) -> Void) {
        let navisURL = URL(string: "\(baseURL)/navis/")!
        var request = URLRequest(url: navisURL)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let navis = try decoder.decode([Navi].self, from: data)
                    completion(.success(navis))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
}
