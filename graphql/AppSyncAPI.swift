//  This file was automatically generated and should not be edited.

import AWSAppSync

public struct CreatePostInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, location: LocationInput, active: Bool, timestamp: String, username: String, viewCount: Int, descriptor: String, image: S3ObjectInput, altitude: Optional<Double?> = nil, horAcc: Optional<Double?> = nil, verAcc: Optional<Double?> = nil) {
    graphQLMap = ["id": id, "location": location, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor, "image": image, "altitude": altitude, "horAcc": horAcc, "verAcc": verAcc]
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

  public var image: S3ObjectInput {
    get {
      return graphQLMap["image"] as! S3ObjectInput
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "image")
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

public struct LocationInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(lat: Double, lon: Double) {
    graphQLMap = ["lat": lat, "lon": lon]
  }

  public var lat: Double {
    get {
      return graphQLMap["lat"] as! Double
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lat")
    }
  }

  public var lon: Double {
    get {
      return graphQLMap["lon"] as! Double
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lon")
    }
  }
}

public struct S3ObjectInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(bucket: String, key: String, region: String, localUri: Optional<String?> = nil, mimeType: Optional<String?> = nil) {
    graphQLMap = ["bucket": bucket, "key": key, "region": region, "localUri": localUri, "mimeType": mimeType]
  }

  public var bucket: String {
    get {
      return graphQLMap["bucket"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bucket")
    }
  }

  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  public var region: String {
    get {
      return graphQLMap["region"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "region")
    }
  }

  public var localUri: Optional<String?> {
    get {
      return graphQLMap["localUri"] as! Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "localUri")
    }
  }

  public var mimeType: Optional<String?> {
    get {
      return graphQLMap["mimeType"] as! Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mimeType")
    }
  }
}

public struct UpdatePostInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, location: Optional<LocationInput?> = nil, active: Optional<Bool?> = nil, timestamp: Optional<String?> = nil, username: Optional<String?> = nil, viewCount: Optional<Int?> = nil, descriptor: Optional<String?> = nil, image: Optional<S3ObjectInput?> = nil, altitude: Optional<Double?> = nil, horAcc: Optional<Double?> = nil, verAcc: Optional<Double?> = nil) {
    graphQLMap = ["id": id, "location": location, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor, "image": image, "altitude": altitude, "horAcc": horAcc, "verAcc": verAcc]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var location: Optional<LocationInput?> {
    get {
      return graphQLMap["location"] as! Optional<LocationInput?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
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

  public var image: Optional<S3ObjectInput?> {
    get {
      return graphQLMap["image"] as! Optional<S3ObjectInput?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "image")
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
    "query GetPost($id: ID!) {\n  getPost(id: $id) {\n    __typename\n    id\n    location {\n      __typename\n      ...Location\n    }\n    active\n    timestamp\n    username\n    viewCount\n    descriptor\n    altitude\n    verAcc\n    horAcc\n    image {\n      __typename\n      ...S3Object\n    }\n  }\n}"

  public static var requestString: String { return operationString.appending(Location.fragmentString).appending(S3Object.fragmentString) }

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
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("verAcc", type: .scalar(Double.self)),
        GraphQLField("horAcc", type: .scalar(Double.self)),
        GraphQLField("image", type: .nonNull(.object(Image.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, active: Bool, timestamp: String, username: String, viewCount: Int, descriptor: String, altitude: Double? = nil, verAcc: Double? = nil, horAcc: Double? = nil, image: Image) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor, "altitude": altitude, "verAcc": verAcc, "horAcc": horAcc, "image": image.snapshot])
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

      public var image: Image {
        get {
          return Image(snapshot: snapshot["image"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "image")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, lon: Double) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "lon": lon])
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

        public var lon: Double {
          get {
            return snapshot["lon"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lon")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var location: Location {
            get {
              return Location(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["S3Object"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "S3Object", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var s3Object: S3Object {
            get {
              return S3Object(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class OnDeactivatedPostSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeactivatedPost($id: ID!) {\n  onUpdatePost(id: $id) {\n    __typename\n    id\n    active\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdatePost", arguments: ["id": GraphQLVariable("id")], type: .object(OnUpdatePost.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdatePost: OnUpdatePost? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdatePost": onUpdatePost.flatMap { $0.snapshot }])
    }

    public var onUpdatePost: OnUpdatePost? {
      get {
        return (snapshot["onUpdatePost"] as? Snapshot).flatMap { OnUpdatePost(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdatePost")
      }
    }

    public struct OnUpdatePost: GraphQLSelectionSet {
      public static let possibleTypes = ["Post"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("active", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, active: Bool) {
        self.init(snapshot: ["__typename": "Post", "id": id, "active": active])
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

      public var active: Bool {
        get {
          return snapshot["active"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "active")
        }
      }
    }
  }
}

public final class ListPostsByLocationQuery: GraphQLQuery {
  public static let operationString =
    "query ListPostsByLocation($lat: Float!, $lon: Float!, $distance: String!) {\n  listPostsByLocation(lat: $lat, lon: $lon, distance: $distance) {\n    __typename\n    id\n    location {\n      __typename\n      ...Location\n    }\n    active\n    timestamp\n    username\n    viewCount\n    descriptor\n    altitude\n    verAcc\n    horAcc\n    image {\n      __typename\n      ...S3Object\n    }\n  }\n}"

  public static var requestString: String { return operationString.appending(Location.fragmentString).appending(S3Object.fragmentString) }

  public var lat: Double
  public var lon: Double
  public var distance: String

  public init(lat: Double, lon: Double, distance: String) {
    self.lat = lat
    self.lon = lon
    self.distance = distance
  }

  public var variables: GraphQLMap? {
    return ["lat": lat, "lon": lon, "distance": distance]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listPostsByLocation", arguments: ["lat": GraphQLVariable("lat"), "lon": GraphQLVariable("lon"), "distance": GraphQLVariable("distance")], type: .list(.object(ListPostsByLocation.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listPostsByLocation: [ListPostsByLocation?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listPostsByLocation": listPostsByLocation.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listPostsByLocation: [ListPostsByLocation?]? {
      get {
        return (snapshot["listPostsByLocation"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListPostsByLocation(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listPostsByLocation")
      }
    }

    public struct ListPostsByLocation: GraphQLSelectionSet {
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
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("verAcc", type: .scalar(Double.self)),
        GraphQLField("horAcc", type: .scalar(Double.self)),
        GraphQLField("image", type: .nonNull(.object(Image.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, active: Bool, timestamp: String, username: String, viewCount: Int, descriptor: String, altitude: Double? = nil, verAcc: Double? = nil, horAcc: Double? = nil, image: Image) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor, "altitude": altitude, "verAcc": verAcc, "horAcc": horAcc, "image": image.snapshot])
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

      public var image: Image {
        get {
          return Image(snapshot: snapshot["image"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "image")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, lon: Double) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "lon": lon])
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

        public var lon: Double {
          get {
            return snapshot["lon"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lon")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var location: Location {
            get {
              return Location(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["S3Object"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "S3Object", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var s3Object: S3Object {
            get {
              return S3Object(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class QueryMostRecentByUsernameQuery: GraphQLQuery {
  public static let operationString =
    "query QueryMostRecentByUsername($username: String!, $size: Int!) {\n  queryMostRecentByUsername(username: $username, size: $size) {\n    __typename\n    id\n    location {\n      __typename\n      ...Location\n    }\n    timestamp\n    image {\n      __typename\n      ...S3Object\n    }\n    viewCount\n    active\n  }\n}"

  public static var requestString: String { return operationString.appending(Location.fragmentString).appending(S3Object.fragmentString) }

  public var username: String
  public var size: Int

  public init(username: String, size: Int) {
    self.username = username
    self.size = size
  }

  public var variables: GraphQLMap? {
    return ["username": username, "size": size]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("queryMostRecentByUsername", arguments: ["username": GraphQLVariable("username"), "size": GraphQLVariable("size")], type: .list(.object(QueryMostRecentByUsername.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(queryMostRecentByUsername: [QueryMostRecentByUsername?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "queryMostRecentByUsername": queryMostRecentByUsername.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var queryMostRecentByUsername: [QueryMostRecentByUsername?]? {
      get {
        return (snapshot["queryMostRecentByUsername"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { QueryMostRecentByUsername(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "queryMostRecentByUsername")
      }
    }

    public struct QueryMostRecentByUsername: GraphQLSelectionSet {
      public static let possibleTypes = ["Post"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .nonNull(.object(Location.selections))),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("image", type: .nonNull(.object(Image.selections))),
        GraphQLField("viewCount", type: .nonNull(.scalar(Int.self))),
        GraphQLField("active", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, timestamp: String, image: Image, viewCount: Int, active: Bool) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "timestamp": timestamp, "image": image.snapshot, "viewCount": viewCount, "active": active])
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

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var image: Image {
        get {
          return Image(snapshot: snapshot["image"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "image")
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

      public var active: Bool {
        get {
          return snapshot["active"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "active")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, lon: Double) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "lon": lon])
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

        public var lon: Double {
          get {
            return snapshot["lon"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lon")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var location: Location {
            get {
              return Location(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["S3Object"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "S3Object", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var s3Object: S3Object {
            get {
              return S3Object(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class QueryMostViewedByUsernameQuery: GraphQLQuery {
  public static let operationString =
    "query QueryMostViewedByUsername($username: String!, $size: Int!) {\n  queryMostViewedByUsername(username: $username, size: $size) {\n    __typename\n    id\n    location {\n      __typename\n      ...Location\n    }\n    timestamp\n    image {\n      __typename\n      ...S3Object\n    }\n    viewCount\n    active\n  }\n}"

  public static var requestString: String { return operationString.appending(Location.fragmentString).appending(S3Object.fragmentString) }

  public var username: String
  public var size: Int

  public init(username: String, size: Int) {
    self.username = username
    self.size = size
  }

  public var variables: GraphQLMap? {
    return ["username": username, "size": size]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("queryMostViewedByUsername", arguments: ["username": GraphQLVariable("username"), "size": GraphQLVariable("size")], type: .list(.object(QueryMostViewedByUsername.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(queryMostViewedByUsername: [QueryMostViewedByUsername?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "queryMostViewedByUsername": queryMostViewedByUsername.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var queryMostViewedByUsername: [QueryMostViewedByUsername?]? {
      get {
        return (snapshot["queryMostViewedByUsername"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { QueryMostViewedByUsername(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "queryMostViewedByUsername")
      }
    }

    public struct QueryMostViewedByUsername: GraphQLSelectionSet {
      public static let possibleTypes = ["Post"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .nonNull(.object(Location.selections))),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("image", type: .nonNull(.object(Image.selections))),
        GraphQLField("viewCount", type: .nonNull(.scalar(Int.self))),
        GraphQLField("active", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, timestamp: String, image: Image, viewCount: Int, active: Bool) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "timestamp": timestamp, "image": image.snapshot, "viewCount": viewCount, "active": active])
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

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var image: Image {
        get {
          return Image(snapshot: snapshot["image"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "image")
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

      public var active: Bool {
        get {
          return snapshot["active"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "active")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, lon: Double) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "lon": lon])
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

        public var lon: Double {
          get {
            return snapshot["lon"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lon")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var location: Location {
            get {
              return Location(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["S3Object"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "S3Object", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var s3Object: S3Object {
            get {
              return S3Object(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class QueryTotalViewsByUsernameQuery: GraphQLQuery {
  public static let operationString =
    "query QueryTotalViewsByUsername($username: String!) {\n  queryTotalViewsByUsername(username: $username)\n}"

  public var username: String

  public init(username: String) {
    self.username = username
  }

  public var variables: GraphQLMap? {
    return ["username": username]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("queryTotalViewsByUsername", arguments: ["username": GraphQLVariable("username")], type: .scalar(Int.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(queryTotalViewsByUsername: Int? = nil) {
      self.init(snapshot: ["__typename": "Query", "queryTotalViewsByUsername": queryTotalViewsByUsername])
    }

    public var queryTotalViewsByUsername: Int? {
      get {
        return snapshot["queryTotalViewsByUsername"] as? Int
      }
      set {
        snapshot.updateValue(newValue, forKey: "queryTotalViewsByUsername")
      }
    }
  }
}

public final class CreatePostMutation: GraphQLMutation {
  public static let operationString =
    "mutation createPost($input: CreatePostInput!) {\n  createPost(input: $input) {\n    __typename\n    id\n    location {\n      __typename\n      ...Location\n    }\n    active\n    timestamp\n    username\n    viewCount\n    descriptor\n    image {\n      __typename\n      ...S3Object\n    }\n    altitude\n    verAcc\n    horAcc\n  }\n}"

  public static var requestString: String { return operationString.appending(Location.fragmentString).appending(S3Object.fragmentString) }

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
        GraphQLField("viewCount", type: .nonNull(.scalar(Int.self))),
        GraphQLField("descriptor", type: .nonNull(.scalar(String.self))),
        GraphQLField("image", type: .nonNull(.object(Image.selections))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("verAcc", type: .scalar(Double.self)),
        GraphQLField("horAcc", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, active: Bool, timestamp: String, username: String, viewCount: Int, descriptor: String, image: Image, altitude: Double? = nil, verAcc: Double? = nil, horAcc: Double? = nil) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor, "image": image.snapshot, "altitude": altitude, "verAcc": verAcc, "horAcc": horAcc])
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

      public var image: Image {
        get {
          return Image(snapshot: snapshot["image"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "image")
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

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, lon: Double) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "lon": lon])
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

        public var lon: Double {
          get {
            return snapshot["lon"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lon")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var location: Location {
            get {
              return Location(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["S3Object"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "S3Object", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var s3Object: S3Object {
            get {
              return S3Object(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class UpdatePostMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdatePost($input: UpdatePostInput!) {\n  updatePost(input: $input) {\n    __typename\n    id\n    location {\n      __typename\n      ...Location\n    }\n    active\n    timestamp\n    username\n    viewCount\n    descriptor\n    image {\n      __typename\n      ...S3Object\n    }\n    altitude\n    verAcc\n    horAcc\n  }\n}"

  public static var requestString: String { return operationString.appending(Location.fragmentString).appending(S3Object.fragmentString) }

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
        GraphQLField("viewCount", type: .nonNull(.scalar(Int.self))),
        GraphQLField("descriptor", type: .nonNull(.scalar(String.self))),
        GraphQLField("image", type: .nonNull(.object(Image.selections))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("verAcc", type: .scalar(Double.self)),
        GraphQLField("horAcc", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: Location, active: Bool, timestamp: String, username: String, viewCount: Int, descriptor: String, image: Image, altitude: Double? = nil, verAcc: Double? = nil, horAcc: Double? = nil) {
        self.init(snapshot: ["__typename": "Post", "id": id, "location": location.snapshot, "active": active, "timestamp": timestamp, "username": username, "viewCount": viewCount, "descriptor": descriptor, "image": image.snapshot, "altitude": altitude, "verAcc": verAcc, "horAcc": horAcc])
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

      public var image: Image {
        get {
          return Image(snapshot: snapshot["image"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "image")
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

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["Location"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, lon: Double) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "lon": lon])
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

        public var lon: Double {
          get {
            return snapshot["lon"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lon")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var location: Location {
            get {
              return Location(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["S3Object"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "S3Object", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var s3Object: S3Object {
            get {
              return S3Object(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class IncrementViewCountMutation: GraphQLMutation {
  public static let operationString =
    "mutation IncrementViewCount($id: ID!) {\n  incrementViewCount(id: $id) {\n    __typename\n    id\n    viewCount\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("incrementViewCount", arguments: ["id": GraphQLVariable("id")], type: .object(IncrementViewCount.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(incrementViewCount: IncrementViewCount? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "incrementViewCount": incrementViewCount.flatMap { $0.snapshot }])
    }

    public var incrementViewCount: IncrementViewCount? {
      get {
        return (snapshot["incrementViewCount"] as? Snapshot).flatMap { IncrementViewCount(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "incrementViewCount")
      }
    }

    public struct IncrementViewCount: GraphQLSelectionSet {
      public static let possibleTypes = ["Post"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("viewCount", type: .nonNull(.scalar(Int.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, viewCount: Int) {
        self.init(snapshot: ["__typename": "Post", "id": id, "viewCount": viewCount])
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

      public var viewCount: Int {
        get {
          return snapshot["viewCount"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "viewCount")
        }
      }
    }
  }
}

public final class DeletePostMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeletePost($input: DeletePostInput!) {\n  deletePost(input: $input) {\n    __typename\n    id\n    location {\n      __typename\n      ...Location\n    }\n    active\n    timestamp\n    username\n  }\n}"

  public static var requestString: String { return operationString.appending(Location.fragmentString) }

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
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
          GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lat: Double, lon: Double) {
          self.init(snapshot: ["__typename": "Location", "lat": lat, "lon": lon])
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

        public var lon: Double {
          get {
            return snapshot["lon"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lon")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var location: Location {
            get {
              return Location(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public struct Location: GraphQLFragment {
  public static let fragmentString =
    "fragment Location on Location {\n  __typename\n  lat\n  lon\n}"

  public static let possibleTypes = ["Location"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
    GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(lat: Double, lon: Double) {
    self.init(snapshot: ["__typename": "Location", "lat": lat, "lon": lon])
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

  public var lon: Double {
    get {
      return snapshot["lon"]! as! Double
    }
    set {
      snapshot.updateValue(newValue, forKey: "lon")
    }
  }
}

public struct S3Object: GraphQLFragment {
  public static let fragmentString =
    "fragment S3Object on S3Object {\n  __typename\n  bucket\n  key\n  region\n}"

  public static let possibleTypes = ["S3Object"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
    GraphQLField("key", type: .nonNull(.scalar(String.self))),
    GraphQLField("region", type: .nonNull(.scalar(String.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(bucket: String, key: String, region: String) {
    self.init(snapshot: ["__typename": "S3Object", "bucket": bucket, "key": key, "region": region])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var bucket: String {
    get {
      return snapshot["bucket"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "bucket")
    }
  }

  public var key: String {
    get {
      return snapshot["key"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "key")
    }
  }

  public var region: String {
    get {
      return snapshot["region"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "region")
    }
  }
}