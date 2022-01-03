# Dub Dub Grub - WORK IN PROGRESS - 2022
Dub Dub Grub (a course by Sean Allen) is my current work in progress project for taking the next (more advanced) steps in learning Swift and SwiftUI.
It is also an exploration of the frameworks *CloudKit* and *MapKit*.

## Purpose
Dub Dub Grub let Apple Developer's who visit [WWDC](https://apple.fandom.com/wiki/Worldwide_Developers_Conference) at the San Jose Convention Center,
check-in/out at nearby restaurants/bars to meet like-minded developers.

## Naming
The annual developer convention hosted by Apple where they talk about all the new stuff coming for developers, is called the
Apple World Wide Developer Convention or “WWDC” for short. People commonly call this event “Dub Dub” as a shortened form of “WWDC”.

- WWDC = “Dub Dub”
- Food you eat = “Grub”

Therefore: “Dub Dub Grub”

(Siri pronounces WWDC as "dub-dub-dee-see")

## Screens
First screens are coming soon 😉

## App Store
Not yet

## Used Technologies
- Swift 5.5
- SwiftUI
- [CloudKit](https://developer.apple.com/icloud/cloudkit/)
- [MapKit](https://developer.apple.com/documentation/mapkit)
- XCTest

## A word on 3rd Party Libraries
By not using 3rd party libraries in your project, you are going to learn more. Especially if it is a small projects. Unless you
specifically want to experiment with certain libs. Be aware that someone might ask: Did you write any of this code on your own
or did you just use libraries?

## Learnings
### CloudKit
CloudKit is essentially Apple's 1st party version Backend Service (similar to Google's [Firebase](https://firebase.google.com/)).
It is available on all Apple Platforms.
#### Pros
- It does not have any scaling issues because Apple uses it for its own apps (Notes, News, Photos, WWDC)  with millions of users.
- It is free (up to certain limit) if you have signed up to the Apple Developer Program
- Automatic Authentication (it is linked to the users iCloud account)
- Sync of data across devices
- Sharing with others functionality out of the box
- Apple Privacy if that is important for your App
- Apple's 1st party supported framework
- Import CloudKit and you are good to go
#### Cons
- Apple Only (if you are considering also to provide an Android App)
- You need to have an [Apple Developer Account](https://developer.apple.com/support/compare-memberships/) which costs $99/year in order to use CloudKit.
- If you are using CloudKit with your App, you cannot Transfer (give away to someone else) that App without the specific Apple Developer Account bound to it.
(To get around this issue, you can create a new specific Apple Developer Account for the App and pay another yearly fee of $99/year.)
#### Terminologies and Definitions
- Within an Apps Container there are three main databases: Public, Private, Shared
    - Public: every user of the app can see that data (eg. the locations in the DubDubGrup App)
    - Private (Apple level privacy): user specific data (not visible to the Developer)
    - Shared: data (eg. photo albums) is shared between users
- Record Type (eg. DDGLocation)
    - CKRecord is an instance of that type (eg. Chipole) and lives in the Public or Private database
    - CKRecord.Reference creates a pointer to a CKRecord
    - DubDubGrub: DGGProfile will have a reference to a DDGLocation
    - CKOperation is the work horse of CloudKit and is used for CRUD operations on CloudKit
#### Record Types
- The 'Users' record type is what you get with the automatic authentication. As soon as somebody comes with an iCloud account, it creates
a record of this type. The restriction though is, that you can't query it. That is why we have to create a DDGProfile object.
- As a custom field, we have to add a userProfile as a reference to the DDGProfile object.
- We have to define which fields of a Record Type are searchable, queryable or sortable 
### Note on learning from videos
Rewatching videos after I have build and experimented with a certain framework, they make so much more sense to me.
### Initializers
- Pro tip: put your custom initializer in an extension if you want to keep the memberwise initializer.
### Logging in Swift (>iOS14)
- [OSLog is the future of logging](https://www.avanderlee.com/workflow/oslog-unified-logging/#improved-apis-in-ios-14-and-up)
### Extensions
- [Extensions can add new computed properties, but they can’t add stored instance properties (static are allowed), or add property observers to existing properties.](https://docs.swift.org/swift-book/LanguageGuide/Extensions.html#ID152)
- [Stored properties in extensions - old post from 2017](https://medium.com/@marcosantadev/stored-properties-in-swift-extensions-615d4c5a9a58)
- [We can add Subscripts to a Type](https://docs.swift.org/swift-book/LanguageGuide/Extensions.html#ID156)

## Code comments
For learning purposes, I have added lots of comments alongside the code. I am aware that this would propably be ommitted in 'production' code ;)

## Credits
A big thanks to Sean Allen for an amazingly rich filled and well structured course 👏🏼
