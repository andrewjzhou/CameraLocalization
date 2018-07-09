//  This file was automatically generated and should not be edited.

import AWSAppSync

public struct CreatePostInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, location: LocationInput, active: Bool, timestamp: String, username: String, viewCount: Int, descriptor: String) {
    graphQLMap = ["id": id, "location": location, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var location: LocationInput {
    get {
      return graphQLMap["location"] as! LocationInput
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var active: Bool {
    get {
      return graphQLMap["active"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "active")
    }
  }

  public var timestamp: String {
    get {
      return graphQLMap["timestamp"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var username: String {
    get {
      return graphQLMap["username"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var viewCount: Int {
    get {
      return graphQLMap["viewCount"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "viewCount")
    }
  }

  public var descriptor: String {
    get {
      return graphQLMap["descriptor"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "descriptor")
    }
  }
}

public struct LocationInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(lat: Double, long: Double, altitude: Optional<Double?> = nil, horAcc: Optional<Double?> = nil, verAcc: Optional<Double?> = nil) {
    graphQLMap = ["lat": lat, "long": long, "altitude": altitude, "horAcc": horAcc, "verAcc": verAcc]
  }

  public var lat: Double {
    get {
      return graphQLMap["lat"] as! Double
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lat")
    }
  }

  public var long: Double {
    get {
      return graphQLMap["long"] as! Double
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "long")
    }
  }

  public var altitude: Optional<Double?> {
    get {
      return graphQLMap["altitude"] as! Optional<Double?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "altitude")
    }
  }

  public var horAcc: Optional<Double?> {
    get {
      return graphQLMap["horAcc"] as! Optional<Double?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "horAcc")
    }
  }

  public var verAcc: Optional<Double?> {
    get {
      return graphQLMap["verAcc"] as! Optional<Double?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "verAcc")
    }
  }
}

public struct UpdatePostInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, active: Optional<Bool?> = nil, timestamp: Optional<String?> = nil, username: Optional<String?> = nil, viewCount: Optional<Int?> = nil, descriptor: Optional<String?> = nil) {
    graphQLMap = ["id": id, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var active: Optional<Bool?> {
    get {
      return graphQLMap["active"] as! Optional<Bool?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "active")
    }
  }

  public var timestamp: Optional<String?> {
    get {
      return graphQLMap["timestamp"] as! Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var username: Optional<String?> {
    get {
      return graphQLMap["username"] as! Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var viewCount: Optional<Int?> {
    get {
      return graphQLMap["viewCount"] as! Optional<Int?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "viewCount")
    }
  }

  public var descriptor: Optional<String?> {
    get {
      return graphQLMap["descriptor"] as! Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "descriptor")
    }
  }
}

public struct DeletePostInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public final class GetPostQuery: GraphQLQuery {
  public static let operationString =
    "query GetPost($id: ID!) {\n  getPost(id: $id) {\n    __typename\n    id\n    location {\n      __typename\n      lat\n      long\n      altitude\n      verAcc\n      horAcc\n    }\n    active\n    timestamp\n    username\n    viewCount\n    descriptor\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getPost", arguments: ["id": GraphQLVariable("id")], type: .object(GetPost.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getPost: GetPost? = nil) {
      self.init(snapshot: ["__typename": "Query", "getPost": getPost.flatMap { $0.snapshot }])
    }

    public var getPost: GetPost? {
      get {
        return (snapshot["getPost"] as? Snapshot).flatMap { GetPost(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getPost")
      }
    }

    public struct GetPost: GraphQLSelectionSet {
      public static let possibleTypes = ["Post"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .nonNull(.object(Location.selections))),
        GraphQLField("active", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("viewCount", type: .nonNull(.scalar(Int.self))),
        GraphQLField("descriptor", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, active: Bool, timestamp: String, username: String, viewCount: Int, descriptor: String) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: Location {
        get {
          return Location(snapshot: snapshot["location"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "location")
        }
      }

      public var active: Bool {
        get {
          return snapshot["active"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "active")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var viewCount: Int {
        get {
          return snapshot["viewCount"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "viewCount")
        }
      }

      public var descriptor: String {
        get {
          return snapshot["descriptor"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "descriptor")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("long", type: .nonNull(.scalar(Double.self))),
          GraphQLField("altitude", type: .scalar(Double.self)),
          GraphQLField("verAcc", type: .scalar(Double.self)),
          GraphQLField("horAcc", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, long: Double, altitude: Double? = nil, verAcc: Double? = nil, horAcc: Double? = nil) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "long": long, "altitude": altitude, "verAcc": verAcc, "horAcc": horAcc])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var lat: Double {
          get {
            return snapshot["lat"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lat")
          }
        }

        public var long: Double {
          get {
            return snapshot["long"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "long")
          }
        }

        public var altitude: Double? {
          get {
            return snapshot["altitude"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "altitude")
          }
        }

        public var verAcc: Double? {
          get {
            return snapshot["verAcc"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "verAcc")
          }
        }

        public var horAcc: Double? {
          get {
            return snapshot["horAcc"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "horAcc")
          }
        }
      }
    }
  }
}

public final class CreatePostMutation: GraphQLMutation {
  public static let operationString =
    "mutation createPost($input: CreatePostInput!) {\n  createPost(input: $input) {\n    __typename\n    id\n    location {\n      __typename\n      lat\n      long\n      altitude\n      verAcc\n      horAcc\n    }\n    active\n    timestamp\n    username\n  }\n}"

  public var input: CreatePostInput

  public init(input: CreatePostInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createPost", arguments: ["input": GraphQLVariable("input")], type: .object(CreatePost.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createPost: CreatePost? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createPost": createPost.flatMap { $0.snapshot }])
    }

    public var createPost: CreatePost? {
      get {
        return (snapshot["createPost"] as? Snapshot).flatMap { CreatePost(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createPost")
      }
    }

    public struct CreatePost: GraphQLSelectionSet {
      public static let possibleTypes = ["Post"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .nonNull(.object(Location.selections))),
        GraphQLField("active", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, active: Bool, timestamp: String, username: String) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "active": active, "timestamp": timestamp, "username": username])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: Location {
        get {
          return Location(snapshot: snapshot["location"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "location")
        }
      }

      public var active: Bool {
        get {
          return snapshot["active"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "active")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("long", type: .nonNull(.scalar(Double.self))),
          GraphQLField("altitude", type: .scalar(Double.self)),
          GraphQLField("verAcc", type: .scalar(Double.self)),
          GraphQLField("horAcc", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, long: Double, altitude: Double? = nil, verAcc: Double? = nil, horAcc: Double? = nil) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "long": long, "altitude": altitude, "verAcc": verAcc, "horAcc": horAcc])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var lat: Double {
          get {
            return snapshot["lat"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lat")
          }
        }

        public var long: Double {
          get {
            return snapshot["long"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "long")
          }
        }

        public var altitude: Double? {
          get {
            return snapshot["altitude"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "altitude")
          }
        }

        public var verAcc: Double? {
          get {
            return snapshot["verAcc"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "verAcc")
          }
        }

        public var horAcc: Double? {
          get {
            return snapshot["horAcc"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "horAcc")
          }
        }
      }
    }
  }
}

public final class UpdatePostMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdatePost($input: UpdatePostInput!) {\n  updatePost(input: $input) {\n    __typename\n    id\n    location {\n      __typename\n      lat\n      long\n      altitude\n      verAcc\n      horAcc\n    }\n    active\n    timestamp\n    username\n  }\n}"

  public var input: UpdatePostInput

  public init(input: UpdatePostInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updatePost", arguments: ["input": GraphQLVariable("input")], type: .object(UpdatePost.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updatePost: UpdatePost? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updatePost": updatePost.flatMap { $0.snapshot }])
    }

    public var updatePost: UpdatePost? {
      get {
        return (snapshot["updatePost"] as? Snapshot).flatMap { UpdatePost(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updatePost")
      }
    }

    public struct UpdatePost: GraphQLSelectionSet {
      public static let possibleTypes = ["Post"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .nonNull(.object(Location.selections))),
        GraphQLField("active", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, active: Bool, timestamp: String, username: String) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "active": active, "timestamp": timestamp, "username": username])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: Location {
        get {
          return Location(snapshot: snapshot["location"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "location")
        }
      }

      public var active: Bool {
        get {
          return snapshot["active"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "active")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("long", type: .nonNull(.scalar(Double.self))),
          GraphQLField("altitude", type: .scalar(Double.self)),
          GraphQLField("verAcc", type: .scalar(Double.self)),
          GraphQLField("horAcc", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, long: Double, altitude: Double? = nil, verAcc: Double? = nil, horAcc: Double? = nil) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "long": long, "altitude": altitude, "verAcc": verAcc, "horAcc": horAcc])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var lat: Double {
          get {
            return snapshot["lat"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lat")
          }
        }

        public var long: Double {
          get {
            return snapshot["long"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "long")
          }
        }

        public var altitude: Double? {
          get {
            return snapshot["altitude"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "altitude")
          }
        }

        public var verAcc: Double? {
          get {
            return snapshot["verAcc"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "verAcc")
          }
        }

        public var horAcc: Double? {
          get {
            return snapshot["horAcc"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "horAcc")
          }
        }
      }
    }
  }
}

public final class DeletePostMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeletePost($input: DeletePostInput!) {\n  deletePost(input: $input) {\n    __typename\n    id\n    location {\n      __typename\n      lat\n      long\n      altitude\n      verAcc\n      horAcc\n    }\n    active\n    timestamp\n    username\n  }\n}"

  public var input: DeletePostInput

  public init(input: DeletePostInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deletePost", arguments: ["input": GraphQLVariable("input")], type: .object(DeletePost.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deletePost: DeletePost? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deletePost": deletePost.flatMap { $0.snapshot }])
    }

    public var deletePost: DeletePost? {
      get {
        return (snapshot["deletePost"] as? Snapshot).flatMap { DeletePost(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deletePost")
      }
    }

    public struct DeletePost: GraphQLSelectionSet {
      public static let possibleTypes = ["Post"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .nonNull(.object(Location.selections))),
        GraphQLField("active", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, active: Bool, timestamp: String, username: String) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "active": active, "timestamp": timestamp, "username": username])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: Location {
        get {
          return Location(snapshot: snapshot["location"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "location")
        }
      }

      public var active: Bool {
        get {
          return snapshot["active"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "active")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("long", type: .nonNull(.scalar(Double.self))),
          GraphQLField("altitude", type: .scalar(Double.self)),
          GraphQLField("verAcc", type: .scalar(Double.self)),
          GraphQLField("horAcc", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, long: Double, altitude: Double? = nil, verAcc: Double? = nil, horAcc: Double? = nil) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "long": long, "altitude": altitude, "verAcc": verAcc, "horAcc": horAcc])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var lat: Double {
          get {
            return snapshot["lat"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lat")
          }
        }

        public var long: Double {
          get {
            return snapshot["long"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "long")
          }
        }

        public var altitude: Double? {
          get {
            return snapshot["altitude"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "altitude")
          }
        }

        public var verAcc: Double? {
          get {
            return snapshot["verAcc"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "verAcc")
          }
        }

        public var horAcc: Double? {
          get {
            return snapshot["horAcc"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "horAcc")
          }
        }
      }
    }
  }
}