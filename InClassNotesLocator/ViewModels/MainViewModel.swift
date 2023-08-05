//
//  MainViewModel.swift
//  InClassNotesLocator
//
//  Created by Ashley on 8/2/23.
//
import Photos
import UIKit
import SwiftUI
import CoreML
public class MainViewModel : ObservableObject{
    // array of all photos
    @Published var photos: [Photo] = []
    // grabs all photos
    public func getPhotos() {
        // initialize PHImageManager and get proper permissions from user
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
       // Gets all photos from user Camera Roll
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // Iterates through all photos
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
                let size = CGSize(width: 700, height: 700)
                manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { [self] (image, _) in
                    if let image = image  {
                        // checks if image is an in-class photo
                        if (!self.isPhotoAlreadyAdded(asset: asset) && !self.isPhotoMarkedForDeletion(asset: asset) && self.analyzeImage(image: image)){
                            self.photos.append(Photo(image: Image(uiImage: image.resize(size: CGSize(width: UIScreen.main.bounds.width / 3.0, height: UIScreen.main.bounds.width / 3.0))!), asset: asset))
                                DispatchQueue.main.async { [weak self] in
                                    self?.photos.append(Photo(image: Image(uiImage: image.resize(size: CGSize(width: 200, height: 200))!), asset: asset))
                                                        }
                        }
                       
                    }
                }
            }
        } else {
            // empty camera roll!
            print("No photos to display")
        }

    }
    
    // Machine Learning Model
    private func analyzeImage(image: UIImage?) -> Bool{
        guard let buffer = image?.getCVPixelBuffer() else
        {
            print("Image could not be buffered")
            return false;
        }
        do {
            let config = MLModelConfiguration()
            let model = try ClassPhotoIdentifier(configuration: config)
            let input = ClassPhotoIdentifierInput(image: buffer)
            let output =  try model.prediction(input: input)
            let prediction = output.classLabelProbs
            if ((prediction["CLASS PHOTOS"] ?? 0) >= 0.80){
                print(true)
                return true;
            }
            else {
                print(false)
                return false;
            }
        }
        catch {
            print("ERROR ANALYZING IMAGE")
            return false
        }
    }
    
    // delete all selected photos
    public func deleteProcessedPhotos() {
            let library = PHPhotoLibrary.shared()
            let localIdentifiersToDelete = photos.map { $0.asset.localIdentifier }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "localIdentifier IN %@", localIdentifiersToDelete)
            let assetsToDelete = PHAsset.fetchAssets(with: fetchOptions)

            library.performChanges({
                PHAssetChangeRequest.deleteAssets(assetsToDelete)
            }) { (success, error) in
                if success {
                    self.markPhotosAsDeleted(localIdentifiers: localIdentifiersToDelete)
                    self.photos.removeAll()
                } else if let error = error {
                    // Handle error
                    print("Error deleting photos: \(error.localizedDescription)")
                }
            }
        }
    public func savePhotosToAlbum(named albumName: String, completion: @escaping (Bool, Error?) -> Void) {
        
        var localIdentifiersToAddToAlbum: [String] = []
        for photo in photos {
            localIdentifiersToAddToAlbum.append(photo.asset.localIdentifier)
        }
        
        var albumPlaceholder: PHObjectPlaceholder? // Declare here

        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }) { [weak self] success, error in // Capture 'self' weakly
            guard self != nil else {
                completion(false, nil) // Return early if 'self' is deallocated
                return
            }

            if success, let placeholder = albumPlaceholder {
                PHPhotoLibrary.shared().performChanges({
                    if let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject {
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                        let assetsToAdd = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiersToAddToAlbum, options: nil)
                        albumChangeRequest?.addAssets(assetsToAdd)

                        PHPhotoLibrary.shared().performChanges({
                            // No need for another performChanges block here
                        }) { innerSuccess, innerError in
                            completion(innerSuccess, innerError)
                        }
                    }
                })
                
            }
        }
    }

    
   
    private func fetchOrCreateAlbum(named albumName: String) -> PHAssetCollection {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let album = fetchResult.firstObject {
            return album
        } else {
            var albumPlaceholder: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }) { success, error in
                if success, let placeholder = albumPlaceholder {
                    if let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject {
                        // Call your completion handler here if needed
                    }
                }
            }

            // Return a default asset collection for now
            return PHAssetCollection()
        }
    }

    private func isPhotoAlreadyAdded(asset: PHAsset) -> Bool {
            return photos.contains { $0.asset.localIdentifier == asset.localIdentifier }
        }

        private func isPhotoMarkedForDeletion(asset: PHAsset) -> Bool {
            let markedForDeletion = photos.first { $0.asset.localIdentifier == asset.localIdentifier }?.markedForDeletion ?? false
            return markedForDeletion
        }

        private func markPhotosAsDeleted(localIdentifiers: [String]) {
            for localIdentifier in localIdentifiers {
                if let index = photos.firstIndex(where: { $0.asset.localIdentifier == localIdentifier }) {
                    photos[index].markedForDeletion = true
                }
            }
        }
        
}

