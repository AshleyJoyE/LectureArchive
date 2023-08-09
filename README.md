# LectureArchive
LectureArchive is an IOS application capable of detecting photos taken of whiteboards or in-class presentations. Users can fetch in-class photos, delete them, or create a designated album for them.


## How It's Made:

**Tech used:** Swift, CreateML

### Machine Learning Model
The machine learning model used within this application was created using MLModel. This model was trained on 300+ photos taken in class and 300+ miscellaneous photos. 

### Application Interface
LectureArchive offers a user-friendly interface with the following key features:

#### Fetching In-Class Photos
Upon granting initial photo app permissions, users can trigger the fetching process. The app utilizes the trained machine learning model to analyze each photo in the user's library. Photos that receive a "class photo" prediction level exceeding 80% are displayed on the screen and added to the photos array.

#### Deleting Photos
LectureArchive enables users to delete photos from the app's photos array. A confirmation pop-up displays the number of selected photos for deletion. Once confirmed, the photos are removed from the user's library, and the screen is cleared, ensuring a clutter-free experience.

#### Creating Dedicated Photo Albums
To enhance organization, the app offers the option to create dedicated photo albums within the iOS Photos app. Users can select photos from the LectureArchive photos array and specify a name for the new album. After confirming the action, the selected photos are seamlessly moved to the designated album.


### Getting Started
To begin using LectureArchive, follow these steps:
1. Clone the repo in XCODE
2. Deploy the application to an actual iPhone, not a simulator
3. Use the "Fetch" option to automatically identify and display in-class photos. Grant the necessary permissions when prompted.

### License
LectureArchive is released under the MIT License.


