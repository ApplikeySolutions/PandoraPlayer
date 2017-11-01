//
//  PlayerSongList.swift
//  Player
//
//  Created by Boris Bondarenko on 6/2/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit

typealias CellActivityItem = (index: Int, activity: CGFloat)

protocol PlayerSongListDelegate: class {
	func currentSongDidChanged(index: Int)
    func prefetchItems(at indices: [Int])
    func next()
    func didTap()
    func previous()
    func scrollBetween(left: CellActivityItem, right: CellActivityItem)
}

class PlayerSongList: ViewWithXib {
    
    // MARK: Constants
    
    private let minimumLineSpacing: CGFloat = 10
    private let leftInsetCoefficient: CGFloat = 0.25
    private let decelerationRate: CGFloat = 200
    private let expansionValue: CGFloat = 0.3
    private let transformValueCoefficient: CGFloat = 0.8
    private let numberOfTapsRequired = 1
    
    // MARK: Properties
    
    weak var delegate: PlayerSongListDelegate?
    private(set) var songs: [Song] = []
	fileprivate (set) var currentSongIndex: Int = 0
    
    // MARK: Outlets
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    // MARK: Life Cycle
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let flowLayout = CenterCellCollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = minimumLineSpacing
        flowLayout.scrollDirection = .horizontal
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
        
        var insets = self.collectionView.contentInset
        insets.left = self.frame.size.width * leftInsetCoefficient
        insets.right = insets.left
        self.collectionView.contentInset = insets
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        DispatchQueue.main.async {
            self.updateCellSizes()
        }
    }
    
    // MARK: UI
	
    override func initUI() {
        super.initUI()
		
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.backgroundColor = UIColor.clear
		collectionView.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		collectionView.register(UINib(nibName: RoundedPictureCollectionViewCell.className, bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: RoundedPictureCollectionViewCell.className)
		collectionView.decelerationRate = decelerationRate
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
		tap.numberOfTapsRequired = numberOfTapsRequired
		addGestureRecognizer(tap)
	}
	
    func setCurrentIndex(index: Int, animated: Bool) {
        guard index < songs.count, index >= 0 else {
            return
        }
        currentSongIndex = index
        let ix = IndexPath.init(row: index, section: 0)
        collectionView.scrollToItem(at: ix, at: .centeredHorizontally, animated: animated)
        updateCellSizes()
    }
    
	@objc private func doubleTapped(g: UIGestureRecognizer) {
		delegate?.didTap()
	}

	// MARK: Configuration
    func configure(with songs: [Song]) {
        self.songs = songs
		self.collectionView.reloadData()
	}
    
    fileprivate func updateCellSizes() {
        collectionView.visibleCells.forEach { cell in
            updateCellSize(cell: cell)
        }
    }
    
    fileprivate func updateCellSize(cell: UICollectionViewCell) {
        let centerOffset = getDistanceFromCenter(for: cell)
        let transformValue = ((transformValueCoefficient + expansionValue) -
            (centerOffset*expansionValue)/(bounds.width/2))
        cell.transform = CGAffineTransform.identity.scaledBy(x: transformValue, y: transformValue)
    }
	
    fileprivate func getDistanceFromCenter(for cell: UICollectionViewCell) -> CGFloat {
        let centerXOffset = collectionView.contentOffset.x + bounds.width/2
        return abs(cell.center.x - centerXOffset)
    }
    
    fileprivate func getActivityValue(for cell: UICollectionViewCell) -> CGFloat {
        let value: CGFloat = 1 - (getDistanceFromCenter(for: cell)/(bounds.width/2))
        return max(0, min(1, value))
    }
    
    fileprivate func getScrolledBetweenCells() -> (left: CellActivityItem, right: CellActivityItem)? {
        let items: [(index: Int, cell: UICollectionViewCell)] = self.collectionView
            .visibleCells
            .sorted(by: { (left, right) -> Bool in
                return getDistanceFromCenter(for: left) < getDistanceFromCenter(for: right)
            })
            .map{ cell in
                return (index: collectionView.indexPath(for: cell)!.row, cell: cell)
        }
        
        guard items.count >= 2 else { return nil }
        let left = items[0].index < items[1].index ? items[0]: items[1]
        let right = items[0].index > items[1].index ? items[0]: items[1]
        let center = collectionView.contentOffset.x + bounds.width/2
        
        guard center < right.cell.center.x &&
            center > left.cell.center.x else { return nil }
        let leftItem = (index: left.index, activity: getActivityValue(for: left.cell))
        let rightItem = (index: right.index, activity: getActivityValue(for: right.cell))
        return (left: leftItem, right: rightItem)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PlayerSongList: UICollectionViewDelegateFlowLayout {
	
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2, height: collectionView.frame.size.height)
    }
}

// MARK: UICollectionViewDelegate
extension PlayerSongList: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.prefetchItems(at: [indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCellSizes()
        if let items = getScrolledBetweenCells() {
            delegate?.scrollBetween(left: items.left, right: items.right)
        }
    }
}

// MARK: UICollectionViewDataSource
extension PlayerSongList: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
	    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoundedPictureCollectionViewCell.className, for: indexPath) as! RoundedPictureCollectionViewCell
        cell.transform = CGAffineTransform.identity
        cell.configure(with: songs[indexPath.row].metadata?.artwork)
        return cell
    }
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let x = self.collectionView.contentOffset.x + self.collectionView.contentInset.left
		let p = CGPoint(x: x, y: 0)
		guard let ix = collectionView.indexPathForItem(at: p) else {
			return
		}

		self.currentSongIndex = ix.row
		self.delegate?.currentSongDidChanged(index: ix.row)
	}

}

// MARK: UICollectionViewDataSourcePrefetching
extension PlayerSongList: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        delegate?.prefetchItems(at: indexPaths.map{ $0.row })
    }
}
