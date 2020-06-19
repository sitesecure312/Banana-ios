//
//  BananaProducts.swift
//  Banana
//
//  Created by musharraf on 6/8/16.
//  Copyright © 2016 Stars Developer. All rights reserved.
//

public struct BananaProducts {
    
    private static let Prefix = "com.starsdeveloper.banana."
    public static let activitySponsorShip = Prefix + "sponsorships"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [BananaProducts.activitySponsorShip]
    
    public static let store = IAPHelper(productIds: BananaProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
    return productIdentifier.componentsSeparatedByString(".").last
}
