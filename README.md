# VirtualTourist

An application that can "virtually" show you any part of the world through photos, powered by the Flickr API. Drop a pin anywhere on the map and create a custom photo album for any place in the world! For an experience that always feels new, use the "New Collection" button to refresh your photo album! Your pins and customized albums will be saved after exiting the application.

## Installation

* Fork the [official repository](https://github.com/tbajis/VirtualTourist) and run the project file in Xcode.

* You will need to supply a valid Flickr API Key. You can apply for your own Flickr API Key [here.](https://www.flickr.com/services/apps/create/apply) 

## Usage

Upon running the application, the [Travel Locations View](screenshots/mapView.png) will be loaded. From here, use scrolling and "pinch to zoom" gestures to locate a geographic region that you'd like to visit. A short touch gesture will add a pin to the map. To remove a pin, click the "EDIT" button on the top tool bar. A short touch will then [remove the pin.](screenshots/removePinsView.png) When a pin is touched, the [photo album](screenshots/collectionView.png) will appear and download photos from Flickr for that region. A new collection of photos can be downloaded at anytime by pressing the "New Collection" button. You can individually select photos to remove from the album by [touching the photos.](screenshots/removeItemsFromCollectionView.png) 

## Contributing

I'd love to get pull requests from everyone. Here are some ways _you_ can contribute:

* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code(ie. fix typos, add comments, clean up inconsistent white space)
* by creating more detailed, eye-pleasing design elements

### Submitting a Pull Request

1. [Fork](https://help.github.com/articles/fork-a-repo/) the [official repository.](https://github.com/tbajis/VirtualTourist)
2. [Create a topic branch.](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/)
3. Implement your feature or bug fix.
4. Add, commit, and push your changes. Please try to use the [Udacity Git Commit Message Style Guide.](http://udacity.github.io/git-styleguide/)
5. [Submit a pull request.](https://help.github.com/articles/about-pull-requests/)

## Notes

* Please add tests if you change the code
* If you don't know how to add a test, please put in a PR and leave a comment asking for help. I'd love to help!

## Code Status

Currently the _build_ is **PASSING.**

## Issues

No issues reported so far!