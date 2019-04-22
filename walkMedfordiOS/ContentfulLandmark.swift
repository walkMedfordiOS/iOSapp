//
//  ContentfulLandmark.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 4/22/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import Foundation
import Contentful

final class ContentfulLandmark: EntryDecodable, FieldKeysQueryable {
    
    static let contentTypeId: String = "landmark"
    
    // FlatResource members.
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let landmarkId: Int?
    let landmarkName: String?
    var landmarkImage: Asset?
    
    public required init(from decoder: Decoder) throws {
        let sys         = try decoder.sys()
        
        id              = sys.id
        localeCode      = sys.locale
        updatedAt       = sys.updatedAt
        createdAt       = sys.createdAt
        
        let fields      = try decoder.contentfulFieldsContainer(keyedBy: ContentfulLandmark.FieldKeys.self)
        
        self.landmarkId       = try fields.decodeIfPresent(Int.self, forKey: .landmarkId)
        self.landmarkName      = try fields.decodeIfPresent(String.self, forKey: .landmarkName)
        
        try fields.resolveLink(forKey: .landmarkImage, decoder: decoder) { [weak self] image in
            self?.landmarkImage = image as? Asset
        }
    }
    
    // If your field names and your properties names differ, you can define the mapping in your `FieldKeys` enum.
    enum FieldKeys: String, CodingKey {
        case landmarkImage
        case landmarkId, landmarkName
    }
}
