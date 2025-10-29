//
//  PhotoLibraryManager.swift
//  flrt
//
//  Manager for accessing and fetching photos from the user's photo library
//

import Foundation
import Photos
import UIKit

class PhotoLibraryManager: ObservableObject {
    static let shared = PhotoLibraryManager()
    
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            self.authorizationStatus = status
        }
        return status
    }
    
    // MARK: - Fetch Latest Screenshot
    
    /// Fetches the most recent screenshot from the photo library
    func fetchLatestScreenshot() -> UIImage? {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            print("❌ Photo library access not authorized")
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
    
    /// Fetches the most recent photo (not just screenshots)
    func fetchLatestPhoto() -> UIImage? {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
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
    
    /// Fetches asset metadata for the latest screenshot
    func fetchLatestScreenshotMetadata() -> (image: UIImage, asset: PHAsset)? {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            print("❌ Photo library access not authorized")
            return nil
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        fetchOptions.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard let asset = fetchResult.firstObject else {
            print("❌ No screenshots found in photo library")
            return nil
        }
        
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
        
        guard let image = resultImage else {
            print("❌ Failed to load image from asset")
            return nil
        }
        
        return (image, asset)
    }
}

