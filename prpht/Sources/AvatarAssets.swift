//
//  AvatarAssets.swift
//  prpht
//
//  Loads the bundled friend photos (dp-*.jpg) with graceful fallback.
//

import UIKit

enum AvatarAssets {
    private static let cache: [String: UIImage] = {
        var m: [String: UIImage] = [:]
        for name in ["dee", "marcus", "priya", "simon"] {
            if let img = UIImage(named: "dp-\(name)") ?? UIImage(named: "dp-\(name).jpg") {
                m[name] = img
            }
        }
        return m
    }()

    static func photo(for who: String) -> UIImage? {
        guard !who.isEmpty, who != "You" else { return nil }
        return cache[who.lowercased()]
    }
}
