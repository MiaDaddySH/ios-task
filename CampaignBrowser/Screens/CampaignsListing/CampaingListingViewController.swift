import UIKit
import RxSwift


/**
 The view controller responsible for listing all the campaigns. The corresponding view is the `CampaignListingView` and
 is configured in the storyboard (Main.storyboard).
 */
class CampaignListingViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private let imageService = ServiceLocator.instance.imageService

    @IBOutlet
    private(set) weak var typedView: CampaignListingView!
    
    // Add Custom UICollectionViewFlowLayout for dynamic cell
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = typedView.collectionViewLayout as? UICollectionViewFlowLayout
        let width = UIScreen.main.bounds.size.width
        layout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout ?? UICollectionViewFlowLayout()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting the customized layout for collectionView
        typedView.collectionViewLayout = layout
        assert(typedView != nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Load the campaign list and display it as soon as it is available.
        ServiceLocator.instance.networkingService
            .createObservableResponse(request: CampaignListingRequest())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] campaigns in
                guard let self = self else { return }
                self.typedView.display(campaigns: campaigns.map {
                    CampaignListingView.Campaign(
                        name: $0.name,
                        description: $0.description,
                        moodImage: self.imageService.getImage(url: $0.moodImage)
                    )
                })
            })
            .disposed(by: disposeBag)
    }
}
