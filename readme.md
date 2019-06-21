# Weather app

This project uses location services and DarkSky's API to display the 7-day forecast for your location.

# Running the project

There are no 3rd party dependencies, so you should be able to build and run in the iOS simulator right away.
If you want to run on a device, you'll need to update the code signing info.

# Design discussion

Generally my approach is "build things the naive way first, and optimize as it becomes necessary"
I left comments around the code to help clarify my thinking, but there are some other points I'd like to list here:

* I'm using the out-of-the-box coredata setup, so the viewcontext of the persistent store coordinator is the one that gets written to disk. In a production app i'd switch things so that the "write" context is the one that persists, and not perform any operations on the viewcontext (it would only exist to attach fetchedresultscontrollers to)

* In a larger app, the responsibility for interacting with Coredata (performing writes) would probably be refactored into a separate class.

* The NGDaysCollectionViewController is responsible for making and handling its own network request. In a larger application this responsibility would be refactored into a separate networking class, and we'd probably keep references to the data tasks so that we can throttle/cancel them appropriately. 

* Right now I only attempt to fetch data once, it might make sense to also do it on applicationDidBecomeActive too

* Re: test coverage; right now I'm only testing the parsing logic for creating new Forecast objects. I did create a shared interface to allow Forecast to be mocked. The only other method in the project that accepts a Forecast as a parameter is setDailyForecast: in NGDaysCollectionViewCell. Seems more appropriate for an UI test there than a unit test. Also, the parser test only covers the happy path (good data). In a production app, if we are hitting a 3rd party API we'd also want to make sure the parser doesn't blow up when it recieves bad data, NSNull, etc. Depending on our contract with an internal API, we may want to handle bad data there as well.

* the icons I'm using are screenshots taken from SFSymbols (still in beta). really i wanted to use vector images but I think you'd have to get the latest XCode beta for that.

* in a perfect world, the custom push animation would be interactive/reversible

* I think the first item in the collection should be titled "Today" instead of the weekday. but you'd want to determine that by accessing the date property on the Forecast, rather then peeking on the indexPath of the cell.

* I'm using a 2-letter perfix NG, convention says it should be 3 letters. Also should have prefixed the AppDelegate

* The Detail ViewController doesn't respond to changes to data that occur after its been put on screen. Ideally it would respond to changes, via KVO or even a fetchedResultsController.

Thanks for reading!