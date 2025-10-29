//
//  PhotoLibraryManager.swift
//  flirtKeyboard
//
//  Manager for accessing and fetching photos from the user's photo library
//

import Foundation
import Photos
import UIKit

class PhotoLibraryManager {
    static let shared = PhotoLibraryManager()
    
    private init() {}
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            completion(status)
        }
    }
    
    // MARK: - Fetch Latest Screenshot
    
    /// Fetches the most recent screenshot from the photo library
    func fetchLatestScreenshot() -> UIImage? {
        let status = checkAuthorizationStatus()
        guard status == .authorized || status == .limited else {
            print("❌ Photo library access not authorized. Status: \(status.rawValue)")
            return nil
        }
        
        // Fetch options to get the most recent screenshot
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        // Filter for screenshots only (mediaSubtypes contains .photoScreenshot)
        fetchOptions.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard let asset = fetchResult.firstObject else {
            print("❌ No screenshots found in photo library")
            return nil
        }
        
        print("📸 Found screenshot from: \(asset.creationDate?.description ?? "unknown date")")
        
        // Request the image
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        var resultImage: UIImage?
        
        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: requestOptions
        ) { image, info in
            resultImage = image
        }
        
        return resultImage
    }
    
    /// Fetches the most recent photo (not just screenshots) - fallback option
    func fetchLatestPhoto() -> UIImage? {
        let status = checkAuthorizationStatus()
        guard status == .authorized || status == .limited else {
            print("❌ Photo library access not authorized")
            return nil
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard let asset = fetchResult.firstObject else {
            print("❌ No photos found in photo library")
            return nil
        }
        
        print("📷 Found photo from: \(asset.creationDate?.description ?? "unknown date")")
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        var resultImage: UIImage?
        
        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: requestOptions
        ) { image, info in
            resultImage = image
        }
        
        return resultImage
    }
}

