//
//  AlbumDialogueBox.swift
//  InClassNotesLocator
//
//  Created by Ashley on 8/5/23.
//

import SwiftUI

struct AlbumDialogView: View {
    
    @State var albumName: String = ""
    @ObservedObject var viewModel: MainViewModel
    @Binding var isPresented: Bool
    

    var body: some View {
        VStack {
            Text("Create Album")
                .font(.title)
                .bold()
                .padding()
                .foregroundColor(.black)

            Text("Are you sure you want to create an album with " + String($viewModel.photos.count) + " photos?")
                .padding()
                .foregroundColor(.black)

            TextField("Type in album name", text: $albumName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.horizontal, .bottom])

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()

                Spacer()

                Button("Create") {
                    isPresented = false // Close the dialog
                    DispatchQueue.main.async {
                            viewModel.savePhotosToAlbum(named: albumName) { success, error in
                                if success {
                                    print("Photos saved to album successfully!")
                                    viewModel.photos.removeAll()
                                } else if let error = error {
                                    print("Error saving photos to album: \(error.localizedDescription)")
                                }
                            
                            }
                        }
                    // Perform album creation logic here using albumName
                }
                .padding()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)

    }
}


struct AlbumDialogView_Previews: PreviewProvider {
    @StateObject static var viewModel = MainViewModel() // Provide an example array of photos here

    static var previews: some View {
        AlbumDialogView(viewModel: viewModel, isPresented: .constant(true))
    }
}
