import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @State private var photos: [Photo] = []
    @State private var showAlert: Bool = false
    @State private var dialogeShown: Bool = false
    
    var columns: [GridItem] = [
        GridItem(.fixed(((UIScreen.main.bounds.width * 0.3) - 10))),
        GridItem(.fixed(((UIScreen.main.bounds.width * 0.3) - 10))),
        GridItem(.fixed(((UIScreen.main.bounds.width * 0.3) - 10))),
    ]
    
    let height: CGFloat = (UIScreen.main.bounds.width * 0.3) - 10
    
    
    var body: some View {
        // HEADER
        VStack{
            GeometryReader { geometry in
                ZStack{
                    Rectangle().frame(height: geometry.size.height*1.5)
                        .foregroundColor(.blue)
                        .edgesIgnoringSafeArea(.top)
                    VStack {
                        Spacer()
                        
                        Text("LectureArchive")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        
                        Text("Organize Your In-Class Notes!")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        
                        Spacer()
                    }.offset(y: (geometry.size.height * 0.90) - geometry.size.height )
                }
                
            }
            
            // IMAGES
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(photos) { photo in
                        PhotosView(image: photo.image.resizable()).frame(height: height)
                            .aspectRatio(contentMode: .fit) // Set a consistent aspect ratio
                            .padding(10)
                            .id(UUID()) // Add a unique identifier to handle view reuse
                    }
                }
                    .padding()
                    .onChange(of: viewModel.photos) { newPhotos in
                        photos = newPhotos
                    }
            }.frame(height: 500)
            
            // BOTTOM ACTION ITEMS
            GeometryReader { geometry in
                ZStack{
                    Rectangle().frame(height: geometry.size.height*1.5)
                        .foregroundColor(.blue)
                        .edgesIgnoringSafeArea(.bottom)
                    Grid {
                        let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
                        LazyVGrid(columns: rows, spacing: 0) {
                            
                            
                            // SAVE TO ALBUM
                            Button {
                                dialogeShown = true;
                            } label: {
                                VStack{
                                    Image(systemName: "folder.circle.fill").foregroundColor(.white).font(.system(size: 50))
                                    
                                    Text("Save To Albulm").bold().foregroundColor(.white).font(.system(size: 20))
                                }
                                
                            }.sheet(isPresented: $dialogeShown) {
                                AlbumDialogView(viewModel: viewModel, isPresented: $dialogeShown)
                            }
                            
                            // FETCH PHOTOS
                            Button {
                                viewModel.getPhotos()
                            } label: {
                                VStack{
                                    Image(systemName: "plus.square.fill.on.square.fill").foregroundColor(.white).font(.system(size: 50))
                                    
                                    Text("Fetch Photos").bold().foregroundColor(.white).font(.system(size: 20))
                                }
                            }
                            
                            // DELETE PHOTOS
                            Button {
                                viewModel.deleteProcessedPhotos()
                            } label: {
                                VStack{
                                    Image(systemName: "trash.fill").foregroundColor(.white).font(.system(size: 50))
                                    
                                    Text("Delete").bold().foregroundColor(.white).font(.system(size: 20))
                                }
                            }.padding()
                            
                        }
                    }.offset(y: UIScreen.main.bounds.height * -0.03)
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
