import UIKit
import WebKit

class ExploreTableViewController: UITableViewController {
    private let reuseIdentifier = "👻"

    var configuration: Configuration!
    var schemeHandler: SchemeHandler!
    var articlesController: ArticlesController!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(articleCacheWasUpdated(_:)), name: ArticleCacheController.articleCacheWasUpdatedNotification, object: nil)
    }

    @objc private func articleCacheWasUpdated(_ notification: Notification) {
        tableView.reloadData()
    }

    private struct Article {
        let title: String
        let url: URL

        init(title: String, configuration: Configuration, scheme: String) {
            self.title = title
            let urlString = "https://en.wikipedia.org/wiki/\(title)"
            let url = URL(string: urlString)!
            self.url = configuration.mobileAppsServicesArticleURLForArticle(with: url, scheme: scheme)!
        }
    }
        
    private lazy var articles: [Article] = {
        return [
            Article(title: "Dog", configuration: configuration, scheme: schemeHandler.scheme),
            Article(title: "Wolf", configuration: configuration, scheme: schemeHandler.scheme),
            Article(title: "Cat", configuration: configuration, scheme: schemeHandler.scheme),
            Article(title: "Panda", configuration: configuration, scheme: schemeHandler.scheme),
            Article(title: "Unicorn", configuration: configuration, scheme: schemeHandler.scheme)
        ]
    }()

    private func article(at indexPath: IndexPath) -> Article? {
        return articles[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let article = self.article(at: indexPath)
        cell.textLabel?.text = article?.title
        let saveButton = UIButton()
        if let articleURL = article?.url {
            let isCached = articlesController.cacheController.isCached(articleURL)
            let imageName = isCached ? "save-filled" : "save"
            saveButton.setImage(UIImage(named: imageName), for: .normal)
        }
        saveButton.imageView?.contentMode = .scaleAspectFit
        saveButton.tag = indexPath.row
        saveButton.addTarget(self, action: #selector(toggleArticleSavedState), for: .touchUpInside)
        saveButton.sizeToFit()
        cell.accessoryView = saveButton
        return cell
    }

    @objc private func toggleArticleSavedState(_ sender: UIButton) {
        let articleURL = articles[sender.tag].url
        var components = URLComponents.init(url: articleURL, resolvingAgainstBaseURL: true)
        components?.scheme = Configuration.Stage.current == .local ? "http" : "https"
        guard let adjustedArticleURL = components?.url else {
            return
        }
        articlesController.toggleCache(for: adjustedArticleURL)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let articleURL = article(at: indexPath)?.url else {
            return
        }

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.setURLSchemeHandler(schemeHandler, forURLScheme: schemeHandler.scheme)
        let webViewController = WebViewController(url: articleURL, configuration: webViewConfiguration)

        let navigationController = UINavigationController(rootViewController: webViewController)
        present(navigationController, animated: true)
    }
}