//
//  MockData.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

let validUserJSON = """
{
  id: 1,
  username: 'bilbo',
  roleId: '1',
  name: 'gandalf',
  phoneNumber: 3608675309,
  email: 'bagend@shire.me',
  token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJqZWN0IjoxLCJ1c2VybmFtZSI6Im1lcnJ5IiwiaWF0IjoxNjAyODI0NzY1LCJleHAiOjE2MDI5MTExNjV9.72QcurVABMnlGP0COF08bEB05NE_SbzJrfvw7-HKhYo',
}
""".data(using: .utf8)!

let validTrucksJSON = """
[
  {
    "id": 1,
    "name": "truck of today",
    "location": "37.422161 -122.084267",
    "departureTime": "1602876339100",
    "cuisineId": 0,
    "photoId": 1,
    "photoUrl": "http://www.google.com"
  },
  {
    "id": 2,
    "name": "truck of tomorrow",
    "location": "47.639881 -122.124382",
    "departureTime": "1602876339100",
    "cuisineId": 4,
    "photoId": 2,
    "photoUrl": "http://www.microsoft.com"
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

let validTruckMenu = """
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

let validMenuItem = """
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
