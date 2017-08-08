//
//  CenterCellCollectionViewFlowLayout.swift
//  Player
//
//  Created by Pavel Yevtukhov on 6/6/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {

	var mostRecentOffset : CGPoint = CGPoint()
    
	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

		mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)

		guard let cv = self.collectionView else {
			return mostRecentOffset
		}
		
		guard let attributesForVisibleCells = self.layoutAttributesForElements(in: cv.bounds) else {
			return mostRecentOffset
		}

		
		var candidateAttributes : UICollectionViewLayoutAttributes?
		for attributes in attributesForVisibleCells {
			if attributes.representedElementCategory == UICollectionElementCategory.cell {
				candidateAttributes = attributes
			}
		}

		guard let attributes = candidateAttributes else {
			return mostRecentOffset
		}
		
		let w : CGFloat = attributes.frame.width
		let targetColumn = floor(proposedContentOffset.x/w + 1)//(velocity.x > 0 ? 1 : 0))
		let pX = targetColumn * w - cv.contentInset.left + targetColumn * self.minimumLineSpacing
		
		mostRecentOffset = CGPoint(x: CGFloat(pX), y: attributes.center.y)
		return mostRecentOffset
	}
}




