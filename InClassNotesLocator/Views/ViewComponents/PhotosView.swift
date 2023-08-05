//
//  PhotosView.swift
//  InClassNotesLocator
//
//  Created by Ashley on 8/3/23.
//

import SwiftUI
import Photos

struct PhotosView: View {
    let image: Image
    var body: some View {
        VStack {
            image.resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
        }
        
    }
}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView(image: Image(systemName: "pencil.circle.fill"))
    }
}

struct Photo: Identifiable, Equatable {
    let id = UUID()
    let image: Image
    let asset: PHAsset
    var markedForDeletion = false
}

extension Photo {
    static func ==(lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
    struct RowView: View {
        let photos: [Photo]
        let width: CGFloat
        let height: CGFloat
        let horizontalSpacing: CGFloat
        var body: some View {
            HStack(spacing: horizontalSpacing) {
                ForEach(photos) { photo in
                    PhotosView(image: photo.image)
                        .frame(width: width, height: height)
                }
            }
            .padding()
        }
    }
}
