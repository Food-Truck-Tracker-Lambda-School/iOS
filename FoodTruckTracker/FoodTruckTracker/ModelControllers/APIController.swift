//
//  APIController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import UIKit
import CoreData

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
    private lazy var trucksURL = baseURL.appendingPathComponent("trucks/")
    private lazy var dinerURL = baseURL.appendingPathComponent("diner/")
    private lazy var ownerURL = baseURL.appendingPathComponent("operator/")
    
    // MARK: - Functions - Public
    
        // MARK: - User Functions - Register/Login, Diner Favorites, Owner Trucks
    
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
                    self.getFavorites { _ in }
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
    
    /// use getFavorites to update favorites (for diner) or owned trucks (for owner), also called in signIn
    /// - Parameter completion: fetches favorites or owned trucks from server and syncs with CoreData
    func getFavorites(completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer,
              let userRole = userRole else { return }
        var path: String
        var url: URL
        switch userRole {
        case .owner:
            url = ownerURL
            path = "\(bearer.id)/trucks"
        default:
            url = dinerURL
            path = "\(bearer.id)/favorites"
        }
        guard let request = getRequest(url: url, urlPathComponent: path) else {
            completion(.failure(.otherError))
            return
        }
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
                try self.syncTrucksWithCoreData(trucks: trucks)
                completion(.success(true))
            } catch {
                NSLog("Error decoding truck data: \(error)")
                completion(.failure(.failedDecoding))
            }
        }
    }
    
        // MARK: - Truck Functions - GET Requests
    
    /// Use fetchAllTrucks to fetch an array of all trucks from the server
    /// - Parameter completion: returns an array of trucks
    func fetchAllTrucks(completion: @escaping (Result<[TruckListing], NetworkError>) -> Void) {
        guard let request = getRequest(url: trucksURL, urlPathComponent: nil) else {
            completion(.failure(.otherError))
            return
        }
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
    
    /// use fetchTruckRatings to fetch an array [Int] of ratings for a particular truck
    /// - Parameters:
    ///   - truckId: TruckListing.identifier or TruckRepresentation.identifier
    ///   - completion: returns [Int] - all the ratings for a truck
    func fetchTruckRatings(truckId: Int, completion: @escaping (Result<[Int], NetworkError>) -> Void) {
        let path = "\(truckId)/ratings"
        guard let request = getRequest(url: trucksURL, urlPathComponent: path) else {
            completion(.failure(.otherError))
            return
        }
        dataLoader.dataRequest(with: request) { data, response, error in
            if let error = error {
                NSLog("Error receiving rating data: \(error)")
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
                NSLog("No data received from fetchTruckRatings")
                completion(.failure(.noData))
                return
            }
            do {
                let ratings = try JSONDecoder().decode([Int].self, from: data)
                completion(.success(ratings))
            } catch {
                NSLog("Error decoding rating data: \(error)")
                completion(.failure(.failedDecoding))
            }
        }
    }
    
    /// use fetchTruckMenu to fetch the menu for a particular truck
    /// - Parameters:
    ///   - truckId: TruckListing.identifier or TruckRepresentation.identifier
    ///   - completion: returns [MenuItem] for a truck, including any photo data and ratings for each item
    func fetchTruckMenu(truckId: Int, completion: @escaping (Result<[MenuItem], NetworkError>) -> Void) {
        let path = "\(truckId)/menu"
        guard let request = getRequest(url: trucksURL, urlPathComponent: path) else {
            completion(.failure(.otherError))
            return
        }
        dataLoader.dataRequest(with: request) { data, response, error in
            if let error = error {
                NSLog("Error receiving menu data: \(error)")
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
                NSLog("No data received from fetchTruckMenu")
                completion(.failure(.noData))
                return
            }
            do {
                let menu = try JSONDecoder().decode([MenuItem].self, from: data)
                completion(.success(menu))
            } catch {
                NSLog("Error decoding menu data: \(error)")
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
    
    /// Sets up a get request using a url and an optional urlPathComponent
    /// - Parameters:
    ///   - url: accepts a url
    ///   - urlPathComponent: optional String to add a urlPathComponent
    /// - Returns: returns a get request after applying the bearer token, path component, and JSON extension
    private func getRequest(url: URL, urlPathComponent: String?) -> URLRequest? {
        guard let bearer = bearer else { return nil }
        var urlPath = url
        if let path = urlPathComponent {
            urlPath = url.appendingPathComponent(path)
        }
        let requestURL = urlPath.appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
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
    
    /// called in getDinerFavorites and getOwnerTrucks to sync favorites with CoreData
    /// - Parameter trucks: accepts an array [TruckListing]
    /// - Throws: CoreDataStack.shared.save is a throwing function
    private func syncTrucksWithCoreData(trucks: [TruckListing]) throws {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        let identifiersToFetch = trucks.compactMap({ $0.identifier })
        let listingsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, trucks))
        var trucksToCreate = listingsByID
        let fetchRequest: NSFetchRequest<Truck> = Truck.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        context.performAndWait {
            do {
                let existingTrucks = try context.fetch(fetchRequest)
                for truck in existingTrucks {
                    let id = Int(truck.identifier)
                    guard let listing = listingsByID[id] else { continue }
                    update(truck: truck, listing: listing)
                    trucksToCreate.removeValue(forKey: id)
                }
                for listing in trucksToCreate.values {
                    let representation = convertListingToRepresentation(listing: listing)
                    Truck(truckRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching trucks for IDs: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: context)
    }
    
    /// called in syncTrucksWithCoreData to update an existing truck
    /// - Parameters:
    ///   - truck: accepts a truck from the array of existing trucks
    ///   - listing: accepts a listing from the array of truck listings
    private func update(truck: Truck, listing: TruckListing) {
        truck.name = listing.name
        truck.cuisine = listing.cuisine
        truck.imageString = listing.imageString
    }
    
    /// called in syncTrucksWithCoreData to convert a listing to a representation
    /// - Parameter listing: accepts a listing from the array of truck listings
    /// - Returns: returns a TruckRepresentation that can be used to create a Truck for CoreData
    private func convertListingToRepresentation(listing: TruckListing) -> TruckRepresentation {
        let identifier = listing.identifier
        let name = listing.name
        let cuisine = listing.cuisine
        let imageString = listing.imageString
        return TruckRepresentation(identifier: identifier, name: name, cuisine: cuisine, imageString: imageString)
    }
    
}
