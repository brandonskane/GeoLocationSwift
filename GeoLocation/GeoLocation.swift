//
//  GeoLocation.swift
//
//  Created by Brandon S. Kane on 2/21/17.
//  Modified by Imri S. Goldberg on 2018-11-01
//  A Swift implementation of http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates#Java


import Foundation

class GeoLocation {
    
    enum GeoLocationError: Error {
        case invalidBound
        case invalidArgument
        case nilValue
    }
    
    let radLatitude: Double
    let radLongitude: Double
    let degLatitude: Double
    let degLongitude: Double
    
    let MinLatitude = -90.degreesToRadians // -PI/2
    let MaxLatitude = 90.degreesToRadians  // PI/2
    let MinLongitude = -180.degreesToRadians   // -PI
    let MaxLongitude = 180.degreesToRadians    // PI
    
    let earthRadius = 6371.01
    
    init(degLatitude: Double, degLongitude: Double) throws {
        self.radLatitude = degLatitude.degreesToRadians
        self.radLongitude = degLongitude.degreesToRadians
        self.degLatitude = degLatitude
        self.degLongitude = degLongitude
        
        try self.checkBounds()
    }
    
    init(radLatitude: Double, radLongitude: Double) throws {
        self.radLatitude = radLatitude
        self.radLongitude = radLongitude
        self.degLatitude = radLatitude.radiansToDegrees
        self.degLongitude = radLongitude.radiansToDegrees
        
        try self.checkBounds()
    }
    
    /**
     * @param latitude the latitude, in degrees.
     * @param longitude the longitude, in degrees.
     */
    class func fromDegrees(_ latitude: Double, _ longitude: Double) -> GeoLocation? {
        guard let result = try? GeoLocation(degLatitude: latitude, degLongitude: longitude) else {
            return nil
        }
        return result
    }
    
    /**
     * @param latitude the latitude, in radians.
     * @param longitude the longitude, in radians.
     */
    class func fromRadians(_ latitude: Double , longitude: Double) -> GeoLocation? {
        guard let result = try? GeoLocation(radLatitude: latitude, radLongitude: longitude) else {
            return nil
        }
        return result
    }
    
    fileprivate func checkBounds() throws {
        if radLatitude < MinLatitude || radLatitude > MaxLatitude || radLongitude < MinLongitude || radLongitude > MaxLongitude {
            throw GeoLocationError.invalidBound
        }
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
    
    func distanceTo(_ location: GeoLocation) -> Double {
        return acos(sin(radLatitude) * sin(location.radLatitude) +
            cos(radLatitude) * cos(location.radLatitude) *
            cos(radLongitude - location.radLongitude)) * earthRadius
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
    
    func boundingCoordinates(_ distance: Double) throws -> (GeoLocation, GeoLocation) {
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
            maxLat = min(maxLat, MaxLatitude)
            minLon = MinLongitude
            maxLon = MaxLongitude
        }
        
        if let location1 = GeoLocation.fromRadians(minLat, longitude: minLon),
            let location2 = GeoLocation.fromRadians(maxLat, longitude: maxLon) {
            return (location1, location2)
        } else {
            throw GeoLocationError.nilValue
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
