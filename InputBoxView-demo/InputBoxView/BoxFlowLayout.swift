//
//  BoxFlowLayout.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/7.
//

import UIKit

class BoxFlowLayout: UICollectionViewFlowLayout {
    public var ifNeedEqualGap = true
    public var itemNum = 0
    public var minLineSpacing: CGFloat = 10
    override init() {
        super.init()
        initPara()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initPara()
    }
}

extension BoxFlowLayout {
    func autoCalucateLineSpacing() {
        guard itemNum > 1 else {
            minimumLineSpacing = 0
            return
        }
        let width = collectionView!.frame.width
        let contentW = width - CGFloat(itemNum) * itemSize.width - collectionView!.contentInset.left - collectionView!.contentInset.right
        let val = 1.0 * contentW / CGFloat(itemNum - 1)
        minimumLineSpacing = floor(val)
        if minimumLineSpacing < minLineSpacing {
            minimumLineSpacing = minLineSpacing
        }
    }
}


extension BoxFlowLayout {
    private func initPara() {
        self.ifNeedEqualGap = true;
        self.scrollDirection = .horizontal;
        self.minLineSpacing = 10;
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        self.sectionInset = .zero;
        self.itemNum = 1;
    }
}


extension BoxFlowLayout {
    override func prepare() {
        if ifNeedEqualGap {
            autoCalucateLineSpacing()
        }
        super.prepare()
    }
}
