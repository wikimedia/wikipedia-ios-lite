import UIKit
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let configuration = Configuration.current
    
    lazy var session: Session = {
        assert(Thread.isMainThread)
        return Session()
    }()
    
    lazy var schemeHandler: SchemeHandler = {
        assert(Thread.isMainThread)
        return SchemeHandler(scheme: "app", session: session)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.register(defaults: [
            #keyPath(UserDefaults.expandTables): false
        ])

        let persistentURLCache = PermanentlyPersistableURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        URLCache.shared = persistentURLCache

        window = UIWindow(frame: UIScreen.main.bounds)

        let explore = ExploreTableViewController()
        explore.configuration = configuration
        explore.schemeHandler = schemeHandler
        let articleFetcher = ArticleFetcher(session: session, configuration: configuration)
        let articleCacheController = ArticleCacheController(fetcher: articleFetcher)
        persistentURLCache.delegate = articleCacheController
        explore.cacheController = articleCacheController
        let defaultTheme = UserDefaults.standard.theme
        explore.theme = Theme(kind: defaultTheme.kind, dimImages: defaultTheme.dimImages)
        explore.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(named: "explore"), tag: 0)

        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintAdjustmentMode = .normal
        tabBarController.viewControllers = [explore]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

