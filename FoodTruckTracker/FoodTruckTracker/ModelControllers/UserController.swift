//
//  UserController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation
import UIKit

class UserController {
    
    enum UserType {
        case diner
        case owner
    }
    
    let dataLoader: NetworkDataLoader
    
    var bearer: Bearer?
    var currentUser: User? {
        didSet {
            setUserRole()
        }
    }
    var userRole: UserType?
    
    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }
    
    private let baseURL = URL(string: "https://foodtrucktrackers.herokuapp.com/api/")!
    private lazy var registerURL = baseURL.appendingPathComponent("auth/register")
    private lazy var loginURL = baseURL.appendingPathComponent("auth/login")
    
    private func postRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func signIn(existingAccount: ReturningUser?, newAccount: User?, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request: URLRequest
        var url: URL
        var jsonData: Data
        do {
            if existingAccount != nil {
                jsonData = try JSONEncoder().encode(existingAccount)
                url = loginURL
            } else {
                jsonData = try JSONEncoder().encode(newAccount)
                url = registerURL
            }
            request = postRequest(for: url)
            request.httpBody = jsonData
            dataLoader.dataRequest(with: request) { data, _, error in
                if let error = error {
                    NSLog("Login failed with error: \(error)")
                    completion(.failure(.failedLogin))
                    return
                }
                guard let data = data else {
                    NSLog("Data was not received")
                    completion(.failure(.noData))
                    return
                }
                do {
                    self.currentUser = try JSONDecoder().decode(User.self, from: data)
                    self.bearer = try JSONDecoder().decode(Bearer.self, from: data)
                    completion(.success(true))
                } catch {
                    NSLog("Error decoding bearer: \(error)")
                    completion(.failure(.noToken))
                }
            }
        } catch {
            NSLog("Error encoding user: \(error)")
            completion(.failure(.failedEncoding))
        }
    }
    
    private func setUserRole() {
        switch currentUser?.roleId {
        case 2:
            userRole = .owner
        default:
            userRole = .diner
        }
    }
    
}
