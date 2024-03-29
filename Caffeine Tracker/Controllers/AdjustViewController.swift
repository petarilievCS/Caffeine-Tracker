//
//  AdjustViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 4.1.23.
//

import UIKit
import TinyConstraints
import EFCountingLabel

class AdjustViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addDrinkButton: UIButton!
    @IBOutlet weak var caffeineLabel: EFCountingLabel!
    
    var delegate: AdjustViewControllerDelegate? = nil
    var selectedDrink: Drink? = nil
    
    private var consumedDrinksArray = [ConsumedDrink]()
    private var db = DataBaseManager()
    private var currentAmount: Int64 = 0
    
    // Constants
    let defaultHeight: CGFloat = 300
    let dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = 300
    var currentContainerHeight: CGFloat = 300
    
    // Setup default container view
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    // Setup background dimmed view
    let maxDimmedAlpha: CGFloat = 0.5
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupPanGesture()
        currentAmount = selectedDrink!.serving
        
        // Customize label
        amountLabel.text = "\(currentAmount) fl oz"
        caffeineLabel.text = "\(selectedDrink!.caffeine)"
        addDrinkButton.layer.cornerRadius = K.UI.cornerRadius
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.finishedAdding()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        setupStackView()
        containerView.addSubview(contentView)
        contentView.heightToSuperview()
        contentView.widthToSuperview()
        contentView.center(in: containerView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set static constraints
        NSLayoutConstraint.activate([
            // set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // Set container to default height
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        // Set bottom constant to 0
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    // Customize stack view
    func setupStackView() {
        plusButton.layer.cornerRadius = 15.0
        plusButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        minusButton.layer.cornerRadius = 15.0
        minusButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
    
    // Animates the presentation
    func animatePresentContainer() {
        // Update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    // Animate the dimmed view
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    // Dismiss the view
    func animateDismissView() {
        // hide main container view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
    }
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: - @IBActions
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        if currentAmount < 99 {
            currentAmount += 1
            updateAmount()
            updateCaffeine()
        }
    }
    
    @IBAction func minusButtonPressed(_ sender: UIButton) {
        if currentAmount > 0 {
            currentAmount -= 1
            updateAmount()
            updateCaffeine()
        }
    }
    
    // Log drink as consumed (update number of drinks, daily amount and amount in metabolism)
    @IBAction func addDrinkButtonPressed(_ sender: UIButton) {
        db.addConsumedDrink(with: Int(caffeineLabel.text!)!, and: selectedDrink!)
        self.animateDismissView()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func updateAmount() {
        amountLabel.text = "\(currentAmount) fl oz"
    }
    
    func updateCaffeine() {
        let newCaffeine = CGFloat(Double(currentAmount) * selectedDrink!.caffeineOz)
        caffeineLabel.countFrom(CGFloat(Int(caffeineLabel.text!)!), to: newCaffeine, withDuration: 0.25)
    }
}

protocol AdjustViewControllerDelegate {
    func finishedAdding()
}
