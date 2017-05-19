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
    
    fileprivate var radLatitude: Double?
    fileprivate var radLongitude: Double?
    fileprivate var degLatitude: Double?
    fileprivate var degLongitude: Double?
    
    fileprivate let MinLatitude = -90.degreesToRadians // -PI/2
    fileprivate let MaxLatitude = 90.degreesToRadians  // PI/2
    fileprivate let MinLongitude = -180.degreesToRadians   // -PI
    fileprivate let MaxLongitude = 180.degreesToRadians    // PI
    
    fileprivate let earthRadius = 6371.01
    
    /**
     * @param latitude the latitude, in degrees.
     * @param longitude the longitude, in degrees.
     */
    class func fromDegrees(_ latitude: Double, longitude: Double) -> GeoLocation? {
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
    
    class func fromRadians(_ latitude: Double , longitude: Double) -> GeoLocation? {
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
    
    fileprivate func checkBounds() throws {
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
        return "\(String(describing: degLatitude))°, \(String(describing: degLongitude))° = \(String(describing: radLatitude)) rad, \(String(describing: radLongitude)) rad"
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
    
    func distanceTo(_ location: GeoLocation) -> Double? {
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
    
    func boundingCoordinates(_ distance: Double) throws -> [GeoLocation] {
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
            
            if minLon < MinLongitude { minLon += 2 * .pi }
            maxLon = radLongitude + deltaLon
            if maxLon > MaxLongitude { maxLon -= 2 * .pi }
        }
        else {
            minLat = max(minLat, MinLatitude)
            maxLat = max(maxLat, MaxLatitude)
            minLon = MinLongitude
            maxLon = MaxLongitude
        }
        
        if let location1 = GeoLocation.fromRadians(minLat, longitude: minLon),
            let location2 = GeoLocation.fromRadians(maxLat, longitude: maxLon) {
            return [location1, location2]
        }
        else {
            return []
        }
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / .pi }
}

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
}
