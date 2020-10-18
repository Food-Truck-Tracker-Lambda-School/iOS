//
//  APIController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation
import UIKit

class APIController {
    
    // MARK: - Properties - Public
    
    static let shared = APIController()

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
    
    // MARK: - Properties - Private
    
    private let baseURL = URL(string: "https://foodtrucktrackers.herokuapp.com/api/")!
    private lazy var registerURL = baseURL.appendingPathComponent("auth/register")
    private lazy var loginURL = baseURL.appendingPathComponent("auth/login")
    private lazy var trucksURL = baseURL.appendingPathComponent("trucks")
    
    // MARK: - Functions - Public
    
    /// Use signIn function to either login an existing user or register and login a new user; configured to also use MockData for testing
    /// - Parameters:
    ///   - existingAccount: ReturningUser - requires username and password; NOTE: set existingAccount to nil if registering new account
    ///   - newAccount: User - requires username, password, roleId - 1 (diner) or 2 (owner), email; NOTE: set newAccount to nil if logging in existing user
    ///   - completion: sets currentUser, Bearer, and (through a didSet on currentUser) also sets userRole
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
    
    /// Use fetchAllTrucks to fetch an array of all trucks from the server
    /// - Parameter completion: returns an array of trucks
    func fetchAllTrucks(completion: @escaping (Result<[TruckListing], NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        let requestURL = trucksURL.appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        dataLoader.dataRequest(with: request) { data, response, error in
            if let error = error {
                NSLog("Error receiving truck data: \(error)")
                completion(.failure(.tryAgain))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                NSLog("Error: no bearer token")
                completion(.failure(.noToken))
                return
            }
            guard let data = data else {
                NSLog("No data received from fetchAllTrucks")
                completion(.failure(.noData))
                return
            }
            do {
                let trucks = try JSONDecoder().decode([TruckListing].self, from: data)
                completion(.success(trucks))
            } catch {
                NSLog("Error decoding truck data: \(error)")
                completion(.failure(.failedDecoding))
            }
        }
    }
    
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        let imageURL = URL(string: urlString)!
        var request = URLRequest(url: imageURL)
        request.httpMethod = HTTPMethod.get.rawValue
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error receiving image: \(urlString), error: \(error)")
                completion(.failure(.tryAgain))
                return
            }
            guard let data = data else {
                print("No data received from fetchImage")
                completion(.failure(.noData))
                return
            }
            let image = UIImage(data: data)!
                completion(.success(image))
        }
        task.resume()
        }
    
    // MARK: - Functions - Private
    
    /// Called in signIn to set up a post request
    /// - Parameter url: accepts a url
    /// - Returns: returns a post request with a JSON header
    private func postRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /// Called in didSet for currentUser to set UserRole to either diner or owner
    private func setUserRole() {
        switch currentUser?.roleId {
        case 2:
            userRole = .owner
        default:
            userRole = .diner
        }
    }
    
}
