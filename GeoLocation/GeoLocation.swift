import Foundation

//
//  GeoLocation.swift
//
//  Created by Brandon S. Kane on 2/21/17.
//  A Swift implementation of http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates#Java


import Foundation

class GeoLocation {
    
    enum GeoLocationError: Error {
        case invalidBound
        case invalidArgument
        case nilValue
    }
    
    private var radLatitude: Double?
    private var radLongitude: Double?
    private var degLatitude: Double?
    private var degLongitude: Double?
    
    private let MinLatitude = -90.degreesToRadians // -PI/2
    private let MaxLatitude = 90.degreesToRadians  // PI/2
    private let MinLongitude = -180.degreesToRadians   // -PI
    private let MaxLongitude = 180.degreesToRadians    // PI
    
    private let earthRadius = 6371.01
    
    /**
     * @param latitude the latitude, in degrees.
     * @param longitude the longitude, in degrees.
     */
    class func fromDegrees(latitude: Double, longitude: Double) -> GeoLocation? {
        let result = GeoLocation()
        result.radLatitude = latitude.degreesToRadians
        result.radLongitude = longitude.degreesToRadians
        result.degLatitude = latitude
        result.degLongitude = longitude
        
        do {
            try result.checkBounds()
            return result
        } catch {
            print("GeoLocationError.InvalidBound")
        }
        
        return nil
    }
    
    /**
     * @param latitude the latitude, in radians.
     * @param longitude the longitude, in radians.
     */
    
    class func fromRadians(latitude: Double , longitude: Double) -> GeoLocation? {
        let result = GeoLocation()
        result.radLatitude = latitude
        result.radLongitude = longitude
        
        result.degLatitude = latitude.radiansToDegrees
        result.degLongitude = longitude.radiansToDegrees
        
        do {
            try result.checkBounds()
            return result
        } catch {
            print("GeoLocationError.InvalidBound")
        }
        
        return nil
    }
    
    private func checkBounds() throws {
        if radLatitude! < MinLatitude || radLatitude! > MaxLatitude || radLongitude! < MinLongitude || radLongitude! > MaxLongitude {
            throw GeoLocationError.invalidBound
        }
    }
    
    /**
     * @return the latitude, in degrees.
     */
    func getLatitudeInDegree() -> Double? {
        return degLatitude ?? nil
    }
    
    /**
     * @return the longitude, in degrees.
     */
    func getLongitudeInDegrees() -> Double? {
        return degLongitude ?? nil
    }
    
    /**
     * @return the latitude, in radians.
     */
    func getLatitudeInRadians() -> Double? {
        return radLatitude ?? nil
    }
    
    /**
     * @return the longitude, in radians.
     */
    func getLongitudeInRadians() -> Double? {
        return radLongitude ?? nil
    }
    
    var description: String {
        return "\(degLatitude)°, \(degLongitude)° = \(radLatitude) rad, \(radLongitude) rad"
    }
    
    /**
     * Computes the great circle distance between this GeoLocation instance
     * and the location argument.
     * @param radius the radius of the sphere, e.g. the average radius for a
     * spherical approximation of the figure of the Earth is approximately
     * 6371.01 kilometers.
     * @return the distance, measured in the same unit as the radius
     * argument.
     */
    
    func distanceTo(location: GeoLocation) -> Double? {
        guard let radLatitude = radLatitude,
            let locationRatLatitude = location.radLatitude,
            let radLongitude = radLongitude,
            let locationRatLongitude = location.radLongitude
            else {
                print("distanceTo Error: Some value is nil")
                return nil
        }
        
        
        return acos(sin(radLatitude) * sin(locationRatLatitude) +
            cos(radLatitude) * cos(location.radLatitude!) *
            cos(radLongitude - locationRatLongitude)) * earthRadius
    }
    
    /**
     Computes the bounding coordinates of all points on the surface
     of a sphere that has a great circle distance to the point represented
     by this GeoLocation instance that is less or equal to the distance argument.
     
     Param:
     distance - the distance from the point represented by this GeoLocation
     instance. Must be measured in the same unit as the radius
     argument (which is kilometers by default)
     
     Returns a list of two GeoLoations - the SW corner and the NE corner - that
     represents the bounding box.
     */
    
    func boundingCoordinates(distance: Double) throws -> [GeoLocation] {
        guard let radLatitude = radLatitude,
            let radLongitude = radLongitude
            else { throw GeoLocationError.nilValue }
        
        if distance < 0.0 {
            throw GeoLocationError.invalidArgument
        }
        
        // angular distance is radians on a great circle
        
        let radDist = distance / earthRadius
        
        var minLat:Double = radLatitude - radDist
        var maxLat:Double = radLatitude + radDist
        
        var minLon:Double, maxLon:Double
        
        if minLat > MinLatitude && maxLat < MaxLatitude {
            let deltaLon = asin(sin(radDist) / cos(radLatitude))
            minLon = radLongitude - deltaLon
            
            if minLon < MinLongitude { minLon += 2 * M_PI }
            maxLon = radLongitude + deltaLon
            if maxLon > MaxLongitude { maxLon -= 2 * M_PI }
        }
        else {
            minLat = max(minLat, MinLatitude)
            maxLat = max(maxLat, MaxLatitude)
            minLon = MinLongitude
            maxLon = MaxLongitude
        }
        
        if let location1 = GeoLocation.fromRadians(latitude: minLat, longitude: minLon),
            let location2 = GeoLocation.fromRadians(latitude: maxLat, longitude: maxLon) {
            return [location1, location2]
        }
        else {
            return []
        }
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * M_PI / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / M_PI }
}

extension Double {
    var degreesToRadians: Double { return self * M_PI / 180 }
    var radiansToDegrees: Double { return self * 180 / M_PI }
}
