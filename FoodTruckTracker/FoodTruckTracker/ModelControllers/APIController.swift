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
    let defaults = UserDefaults.standard

    var bearer: Bearer? {
        didSet {
            print(bearer as Any)
        }
    }

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
    
    private let baseURL = URL(string: "https://foodtrucktrackers.herokuapp.com/api")!
    private lazy var registerURL = baseURL.appendingPathComponent("auth/register")
    private lazy var loginURL = baseURL.appendingPathComponent("auth/login")
    private lazy var trucksURL = baseURL.appendingPathComponent("trucks")
    private lazy var dinerURL = baseURL.appendingPathComponent("diner")
    private lazy var ownerURL = baseURL.appendingPathComponent("operator")
    private lazy var photoURL = baseURL.appendingPathComponent("photos")
    
    // MARK: - Functions - Public
    
    // MARK: - User Functions - Register/Login, Diner Favorites/Owner Trucks, Post Rating
    
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
            dataLoader.dataRequest(with: request) { data, response, error in
                if let error = error {
                    NSLog("Login failed with error: \(error)")
                    completion(.failure(.failedLogin))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   !(200...210 ~= response.statusCode) {
                    NSLog("Error: failed response")
                    completion(.failure(.failedResponse))
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
                    self.checkLastUser()
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
                response.statusCode != 200 {
                NSLog("Error: failed response \(response)")
                completion(.failure(.failedResponse))
                return
            }
            guard let data = data,
                  !data.isEmpty else {
                NSLog("No data received from getFavorites")
                completion(.failure(.noData))
                return
            }
            do {
                var trucks: [TruckListing] = []
                if let _trucks = try? JSONDecoder().decode([TruckListing].self, from: data) {
                    trucks = _trucks
                }
                if !trucks.isEmpty {
                    try self.syncTrucksWithCoreData(trucks: trucks)
                }
                completion(.success(true))
            } catch {
                NSLog("Error decoding truck data: \(error)")
                completion(.failure(.failedDecoding))
            }
        }
    }
    
    /// adds truck to diner favorites by sending to server and updating CoreData; userRole must be diner
    /// - Parameter truckId: accepts TruckListing.identifier
    func addTruckToFavorites(truckId: Int) {
        guard let bearer = bearer,
              userRole == .diner else { return }
        let data = ["truckId": truckId]
        let url = dinerURL.appendingPathComponent("\(bearer.id)/favorites")
        postDataTask(url: url, postData: data) { result in
            switch result {
            case .success(true):
                self.getFavorites { _ in }
            default:
                NSLog("Failed to add truck to favorites")
            }
        }
    }
    
    /// Diners - removes truck from favorites, Owners - deletes truck from server; does not address CoreData
    /// - Parameter truckId: accepts TruckRepresentation.identifier
    /// - Parameter completion: use completion to delete truck from CoreData in TableViewController
    func removeTruck(truckId: Int, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer else { return }
        var url: URL
        switch userRole {
        case .owner:
            url = ownerURL.appendingPathComponent("\(bearer.id)/trucks/\(truckId)")
        default:
            url = dinerURL.appendingPathComponent("\(bearer.id)/favorites/\(truckId)")
        }
        deleteDataTask(url: url) { result in
            switch result {
            case .success(true):
                completion(.success(true))
            default:
                NSLog("Failed to remove truck")
                completion(.failure(.otherError))
            }
        }
    }
    
    /// posts a rating to either a TruckListing or a MenuItem
    /// - Parameters:
    ///   - rating: accepts an integer between 1 and 5
    ///   - truckId: accepts TruckListing.identifier
    ///   - itemId: accepts optional MenuItem.id, set to nil for truck ratings
    ///   - completion: completion provided for any necessary UI updates
    func postRating(ratingInt: Int, truckId: Int, itemId: Int?, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer,
              userRole == .diner,
              1...5 ~= ratingInt else { return }
        var url = trucksURL
        let rating = Rating(userId: bearer.id, rating: ratingInt)
        if let itemId = itemId {
            url = url.appendingPathComponent("\(truckId)/menu/\(itemId)/ratings")
        } else {
            url = url.appendingPathComponent("\(truckId)/ratings")
        }
        postDataTask(url: url, postData: rating) { result in
            switch result {
            case .success(true):
                completion(.success(true))
            default:
                NSLog("Failed to post rating")
                completion(.failure(.otherError))
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
                response.statusCode != 200 {
                NSLog("Error: failed response \(response)")
                completion(.failure(.failedResponse))
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
    
    /// uses coordinates and a radius in miles to fetch local trucks
    /// - Parameters:
    ///   - latitude: accepts a String for latitude coordinate
    ///   - longitude: accepts a String for longitude coordinate
    ///   - radius: accepts a radius in miles
    ///   - completion: returns an array of [TruckListing]
    func fetchLocalTrucks(latitude: String, longitude: String, radius: Int, completion: @escaping (Result<[TruckListing], NetworkError>) -> Void) {
        let url = trucksURL
        let radiusString = String(radius)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [URLQueryItem(name: "latitude", value: latitude),
                                     URLQueryItem(name: "longitude", value: longitude),
                                     URLQueryItem(name: "radius", value: radiusString)]
        guard let bearer = bearer,
              let requestURL = urlComponents?.url else { return }
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
                response.statusCode != 200 {
                NSLog("Error: failed response \(response)")
                completion(.failure(.failedResponse))
                return
            }
            guard let data = data else {
                NSLog("No data received from fetchLocalTrucks")
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
    
    /// use fetchRatings to fetch an array [Int] of ratings for a particular truck or menu item
    /// - Parameters:
    ///   - truckId: TruckListing.identifier or TruckRepresentation.identifier
    ///   - itemId: optional MenuItem.id, set to nil for truck ratings
    ///   - completion: returns [Int] - all the ratings for a truck
    func fetchRatings(truckId: Int, itemId: Int?, completion: @escaping (Result<[Int], NetworkError>) -> Void) {
        var path: String
        if let itemId = itemId {
            path = "\(truckId)/menu/\(itemId)/ratings"
        } else {
            path = "\(truckId)/ratings"
        }
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
                response.statusCode != 200 {
                NSLog("Error: failed response \(response)")
                completion(.failure(.failedResponse))
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
                response.statusCode != 200 {
                NSLog("Error: failed response \(response)")
                completion(.failure(.failedResponse))
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
    
    // MARK: - Truck Functions - POST Requests
    
    /// creates a new truck; only for owners
    /// - Parameters:
    ///   - truck: accepts a TruckListing - initialize using only name, location, and cuisineId
    ///   - completion: successful result fetches and syncs users trucks
    func createTruck(truck: TruckListing, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer,
              userRole == .owner else { return }
        let url = ownerURL.appendingPathComponent("\(bearer.id)/trucks")
        let context = CoreDataStack.shared.container.newBackgroundContext()
        postDataTask(url: url, postData: truck) { result in
            switch result {
            case .success(true):
                if let truckRep = self.convertListingToRepresentation(listing: truck) {
                    Truck(truckRepresentation: truckRep, context: context)
                }
                completion(.success(true))
            case .failure(.failedEncoding):
                completion(.failure(.failedEncoding))
            case .failure(.failedResponse):
                completion(.failure(.failedResponse))
            default:
                completion(.failure(.tryAgain))
            }
        }
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            print("Error fetching trucks for IDs: \(error)")
        }
    }
    
    /// creates a MenuItem; only for owners
    /// - Parameters:
    ///   - item: accepts a MenuItem - initialize using only name, price, and description
    ///   - truckId: accepts a TruckListing.identifier or TruckRepresentation.identifier
    ///   - completion: successful result returns the updated menu
    func createMenuItem(item: MenuItem, truckId: Int, completion: @escaping (Result<[MenuItem], NetworkError>) -> Void) {
        guard let bearer = bearer,
              userRole == .owner else { return }
        let url = ownerURL.appendingPathComponent("\(bearer.id)/trucks/\(truckId)/menu")
        postDataTask(url: url, postData: item) { result in
            switch result {
            case .success(true):
                self.fetchTruckMenu(truckId: truckId) { results in
                    switch results {
                    case .success(let menu):
                        completion(.success(menu))
                    default:
                        completion(.failure(.otherError))
                    }
                }
            case .failure(.failedEncoding):
                completion(.failure(.failedEncoding))
            case .failure(.failedResponse):
                completion(.failure(.failedResponse))
            default:
                completion(.failure(.tryAgain))
            }
        }
    }
    
    // MARK: - Truck Functions - Delete Menu Item, Edit Truck
    
    /// deletes a MenuItem from a truck's menu; userRole must be owner
    /// - Parameters:
    ///   - item: accepts an item to delete
    ///   - truckId: accepts a TruckListing.identifier or TruckRepresentation.identifier
    /// - Returns: returns the updated menu
    func deleteMenuItem(item: MenuItem, truckId: Int, completion: @escaping (Result<[MenuItem], NetworkError>) -> Void) {
        guard let bearer = bearer,
              userRole == .owner,
              let itemId = item.id else { return }
        let url = ownerURL.appendingPathComponent("\(bearer.id)/trucks/\(truckId)/menu/\(itemId)")
        deleteDataTask(url: url) { result in
            switch result {
            case .success(true):
                self.fetchTruckMenu(truckId: truckId) { results in
                    switch results {
                    case .success(let menu):
                        completion(.success(menu))
                    default:
                        completion(.failure(.otherError))
                    }
                }
            default:
                completion(.failure(.tryAgain))
            }
        }
    }
    
    /// a PUT request that edits a truck in the server and updates CoreData
    /// - Parameters:
    ///   - truckId: accept TruckListing.identifier
    ///   - newTruckInfo: accepts a TruckListing containing new info, identifier must match truckId
    ///   - completion: successful result update both the server and CoreData
    func editTruck(truckId: Int, newTruckInfo: TruckListing, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer,
              userRole == .owner,
              truckId == newTruckInfo.identifier else { return }
        let url = ownerURL.appendingPathComponent("\(bearer.id)/trucks/\(truckId)")
        var request = URLRequest(url: url)
        do {
            let jsonData = try JSONEncoder().encode(newTruckInfo)
            request.httpBody = jsonData
            request.httpMethod = HTTPMethod.put.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
            dataLoader.dataRequest(with: request) { _, response, error in
                if let error = error {
                    NSLog("PUT failed with error: \(error)")
                    completion(.failure(.otherError))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   !(200...210 ~= response.statusCode) {
                    NSLog("Error: failed response")
                    completion(.failure(.failedResponse))
                    return
                }
                self.getFavorites { _ in }
                completion(.success(true))
            }
        } catch {
            NSLog("Error encoding data: \(error)")
            completion(.failure(.failedEncoding))
        }
    }
    
    // MARK: - Image Functions
    
    /// posts an image to the server, collects the photoId and photoUrl, and updates the TruckListing or MenuItem
    /// - Parameters:
    ///   - photoData: accepts photo Data
    ///   - truckId: accepts TruckListing.identifier
    ///   - itemId: accepts optional MenuItem.id, set to nil when adding an image to a TruckListing
    ///   - completion: calls updateTruckWithPhoto or updateMenuItemWithPhoto to update server
    func postImage(photoData: Data, truckId: Int, itemId: Int?, completion: @escaping (Result<Photo, NetworkError>) -> Void) {
        guard let bearer = bearer,
              userRole == .owner else { return }
        let postData = PhotoData(userId: bearer.id, file: photoData)
        var request = postRequest(for: photoURL)
        var jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(postData)
            request.httpBody = jsonData
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
            dataLoader.dataRequest(with: request) { data, response, error in
                if let error = error {
                    NSLog("Post failed with error: \(error)")
                    completion(.failure(.otherError))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   !(200...210 ~= response.statusCode) {
                    NSLog("Error: failed response")
                    completion(.failure(.failedResponse))
                    return
                }
                guard let data = data else {
                    NSLog("Data was not received")
                    completion(.failure(.noData))
                    return
                }
                do {
                    let photo = try JSONDecoder().decode(Photo.self, from: data)
                    if let itemId = itemId {
                        self.updateMenuItemWithPhoto(photo: photo, truckId: truckId, itemId: itemId) { _ in
                            completion(.success(photo))
                        }
                    } else {
                        self.updateTruckWithPhoto(photo: photo, truckId: truckId) { _ in
                            completion(.success(photo))
                        }
                    }
                } catch {
                    NSLog("Error decoding photo: \(error)")
                    completion(.failure(.failedDecoding))
                }
            }
        } catch {
            NSLog("Error encoding data: \(error)")
            completion(.failure(.failedEncoding))
        }
    }
    
    /// fetches an image using a urlString
    /// - Parameters:
    ///   - urlString: accepts a String for URL
    ///   - completion: returns UIImage
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
    
    /// performs a POST data task, using generics to accept any Codable data struct
    /// - Parameters:
    ///   - url: accepts a url
    ///   - postData: accepts any codable data type
    ///   - completion: result is either success or a network error
    private func postDataTask<PostData: Codable>(url: URL, postData: PostData, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer else { return }
        var request = URLRequest(url: url)
        var jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(postData)
            request.httpBody = jsonData
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
            dataLoader.dataRequest(with: request) { _, response, error in
                if let error = error {
                    NSLog("Post failed with error: \(error)")
                    completion(.failure(.otherError))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   !(200...210 ~= response.statusCode) {
                    NSLog("Error: failed response")
                    completion(.failure(.failedResponse))
                    return
                }
                completion(.success(true))
            }
        } catch {
            NSLog("Error encoding data: \(error)")
            completion(.failure(.failedEncoding))
        }
    }
    
    /// performs a DELETE data task
    /// - Parameters:
    ///   - url: accepts a url
    ///   - completion: result is either success or a network error
    private func deleteDataTask(url: URL, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        dataLoader.dataRequest(with: request) { _, response, error in
            if let error = error {
                NSLog("Delete failed with error: \(error)")
                completion(.failure(.otherError))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 204 else {
                completion(.failure(.failedResponse))
                return
            }
            completion(.success(true))
        }
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
        var request = URLRequest(url: urlPath)
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
    
    /// called in getFavorites to sync favorites with CoreData
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
                    guard let representation = convertListingToRepresentation(listing: listing) else { continue }
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
        guard let cuisine = listing.cuisine else { return }
        truck.name = listing.name
        truck.cuisine = cuisine
        truck.imageString = listing.imageString
    }
    
    /// called in syncTrucksWithCoreData to convert a listing to a representation
    /// - Parameter listing: accepts a listing from the array of truck listings
    /// - Returns: returns a TruckRepresentation that can be used to create a Truck for CoreData
    private func convertListingToRepresentation(listing: TruckListing) -> TruckRepresentation? {
        guard let identifier = listing.identifier,
              let cuisine = listing.cuisine else { return nil }
        let name = listing.name
        let imageString = listing.imageString ?? ""
        return TruckRepresentation(identifier: identifier, name: name, cuisine: cuisine, imageString: imageString)
    }
    
    /// checks current user against last user on the device, and clears CoreData if it is a different user
    private func checkLastUser() {
        guard let bearer = bearer else { return }
        let userId = bearer.id
        let moc = CoreDataStack.shared.mainContext
        if userId != defaults.integer(forKey: "userId") {
            let fetchRequest: NSFetchRequest<Truck> = Truck.fetchRequest()
            if let trucks = try? CoreDataStack.shared.mainContext.fetch(fetchRequest) {
                for truck in trucks {
                    moc.delete(truck)
                }
                do {
                    try moc.save()
                } catch {
                    moc.reset()
                    NSLog("Error saving managed object context: \(error)")
                }
            }
            defaults.set(userId, forKey: "userId")
        }
    }
    
    /// called in postImage if the image is for a TruckListing, sends the photoId and photoUrl to the server, updates CoreData
    /// - Parameters:
    ///   - photo: accepts a Photo from the completion of postImage
    ///   - truckId: accepts TruckListing.identifier
    ///   - completion: successful completion updates TruckListing in server and Truck in CoreData
    private func updateTruckWithPhoto(photo: Photo, truckId: Int, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer,
              userRole == .owner else { return }
        let url = ownerURL.appendingPathComponent("\(bearer.id)/trucks/\(truckId)")
        var request = URLRequest(url: url)
        do {
            let jsonData = try JSONEncoder().encode(photo)
            request.httpBody = jsonData
            request.httpMethod = HTTPMethod.put.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
            dataLoader.dataRequest(with: request) { _, response, error in
                if let error = error {
                    NSLog("PUT failed with error: \(error)")
                    completion(.failure(.otherError))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   !(200...210 ~= response.statusCode) {
                    NSLog("Error: failed response")
                    completion(.failure(.failedResponse))
                    return
                }
                self.getFavorites { _ in }
                completion(.success(true))
            }
        } catch {
            NSLog("Error encoding data: \(error)")
            completion(.failure(.failedEncoding))
        }
    }
    
    /// called in postImage if the image os for a MenuItem, sends the photoId and photoUrl to the server
    /// - Parameters:
    ///   - photo: accepts a Photo from the completion of postImage
    ///   - truckId: accepts TruckListing.identifier
    ///   - itemId: accepts MenuItem.id
    ///   - completion: updates MenuItem in server
    private func updateMenuItemWithPhoto(photo: Photo, truckId: Int, itemId: Int, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let bearer = bearer,
              userRole == .owner else { return }
        let url = ownerURL.appendingPathComponent("\(bearer.id)/trucks/\(truckId)/menu/\(itemId)/photos")
        postDataTask(url: url, postData: photo) { result in
            switch result {
            case .success(true):
                completion(.success(true))
            default:
                completion(.failure(.tryAgain))
            }
        }
    }
    
}
