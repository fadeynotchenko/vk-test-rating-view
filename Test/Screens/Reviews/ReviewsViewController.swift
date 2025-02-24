import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel
    private let loadingLayer = CAShapeLayer()

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupLoadingLayer()
        viewModel.getReviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingLayer.position = view.center
    }

    deinit {
        print("\(#file) deinit")
    }
}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            
            self.loadingLayer.isHidden = state.items.count > 0
            self.reviewsView.tableView.reloadData()
        }
    }
    
    func setupLoadingLayer() {
        let size: CGFloat = 40
        let lineWidth: CGFloat = 3
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        let circularPath = UIBezierPath(
            ovalIn: rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        )
        let loadingAnimationGroup = CAAnimationGroup()
        
        /// Настройка слоя
        loadingLayer.path = circularPath.cgPath
        loadingLayer.fillColor = UIColor.clear.cgColor
        loadingLayer.strokeColor = UIColor.systemBlue.cgColor
        loadingLayer.lineWidth = lineWidth
        loadingLayer.lineCap = .round
        loadingLayer.strokeEnd = 0
        loadingLayer.bounds = rect
        loadingLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        /// Анимации
        let strokeStartAnimation = CABasicAnimation(
            keyPath: #keyPath(CAShapeLayer.strokeStart)
        )
        strokeStartAnimation.fromValue = -0.5
        strokeStartAnimation.toValue = 1.0
        
        let strokeEndAnimation = CABasicAnimation(
            keyPath: #keyPath(CAShapeLayer.strokeEnd)
        )
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0
        
        let rotationAnimation = CABasicAnimation(
            keyPath: "transform.rotation.z"
        )
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        
        loadingAnimationGroup.animations = [
            strokeStartAnimation,
            strokeEndAnimation,
            rotationAnimation
        ]
        loadingAnimationGroup.duration = 1.5
        loadingAnimationGroup.repeatCount = .infinity
        loadingAnimationGroup.timingFunction = CAMediaTimingFunction(
            name: .easeInEaseOut
        )
        
        view.layer.addSublayer(loadingLayer)
        loadingLayer.add(loadingAnimationGroup, forKey: "loading")
    }
    
}
