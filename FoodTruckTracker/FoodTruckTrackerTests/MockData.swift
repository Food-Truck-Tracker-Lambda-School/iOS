//
//  MockData.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

let validUserJSON = """
{
  "id": 1,
  "username": "bilbo",
  "roleId": 1,
  "name": null,
  "phoneNumber": null,
  "email": "bagend@shire.me",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJqZWN0IjoxLCJ1c2VybmFtZSI6ImJpbGJvIiwiaWF0IjoxNjAyOTY2MDEwLCJleHAiOjE2MDMwNTI0MTB9.eYb4_8K2RS0I8QMMSfVcIJemPLtt5CiY05_8B1nl9p4"
}
""".data(using: .utf8)!

let validTrucksJSON = """
[
  {
    "id": 1,
    "name": "truck of today",
    "location": "here",
    "departureTime": null,
    "cuisineId": 1,
    "photoId": 1,
    "photoUrl": "https://cdn2.lamag.com/wp-content/uploads/sites/6/2017/03/foodtruck.jpg",
    "ratings": []
  },
  {
    "id": 2,
    "name": "truck of today",
    "location": "here",
    "departureTime": null,
    "cuisineId": 1,
    "photoId": 1,
    "photoUrl": "https://cdn2.lamag.com/wp-content/uploads/sites/6/2017/03/foodtruck.jpg",
    "ratings": []
  },
  {
    "id": 3,
    "name": "truck of today",
    "location": "here",
    "departureTime": null,
    "cuisineId": 1,
    "photoId": 1,
    "photoUrl": "https://cdn2.lamag.com/wp-content/uploads/sites/6/2017/03/foodtruck.jpg",
    "ratings": []
  },
  {
    "id": 4,
    "name": "Norlan's Cuban Cuisine",
    "location": "here",
    "departureTime": null,
    "cuisineId": 4,
    "photoId": 1,
    "photoUrl": "https://cdn2.lamag.com/wp-content/uploads/sites/6/2017/03/foodtruck.jpg",
    "ratings": []
  },
  {
    "id": 5,
    "name": "Norlan’s Taco Truck",
    "location": "here",
    "departureTime": null,
    "cuisineId": 6,
    "photoId": 1,
    "photoUrl": "https://cdn2.lamag.com/wp-content/uploads/sites/6/2017/03/foodtruck.jpg",
    "ratings": []
  }
]
""".data(using: .utf8)!

let validTruckData = """
  {
    "id": 1,
    "name": "truck of today",
    "userId": 1,
    "location": "here",
    "cuisineId": 0,
    "photoId": 1,
    "departureTime": null
  }
""".data(using: .utf8)!

let validOperatorMenu = """
[
    {
      "id": 1,
      "name": "pizza",
      "price": 12.99,
      "description": "delicious"
    },
    {
      "id": 4,
      "name": "orange chicken",
      "price": 15.99,
      "description": "amazing"
    },
]
""".data(using: .utf8)!

let validTruckMenu = """
[
  {
    "id": 1,
    "name": "pizza",
    "price": 12.99,
    "description": "Delicious",
    "photos": [
      {
        "id": 1,
        "url": "http://google.com"
      }
    ],
    "ratings": [
      4,
      2,
      1,
      5
    ]
  }
]
""".data(using: .utf8)!

let validTruckRatings = """
[
  3,
  4,
  2,
  5,
  1
]
""".data(using: .utf8)!

let emptyArray = """
[]
""".data(using: .utf8)!

let validFavorites = """
[
  {
    "id": 4,
    "name": "Norlan's Cuban Cuisine",
    "userId": 10,
    "location": "here",
    "departureTime": null,
    "cuisineId": 4,
    "photoId": 1
  },
  {
    "id": 5,
    "name": "Norlan’s Taco Truck",
    "userId": 10,
    "location": "here",
    "departureTime": null,
    "cuisineId": 6,
    "photoId": 1
  },
  {
    "id": 6,
    "name": "Miami Muffins",
    "userId": 10,
    "location": "here",
    "departureTime": null,
    "cuisineId": 9,
    "photoId": 1
  }
]
""".data(using: .utf8)!
