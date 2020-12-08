//
//  SecrectImageView.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/7.
//

import UIKit

class SecrectImageView: UIView {

    public var image: UIImage? {
        didSet {
            guard let _image = image else {
                return
            }
            lockImgView.image = _image
        }
    }
    public var imageWidth: CGFloat = 0
    public var imageHeight: CGFloat = 0
    private var lockImgView: UIImageView = {
       let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.image = UIImage(named: "lock")
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createUI()
    }
    
    
    private func createUI() {
        addSubview(lockImgView)
        NSLayoutConstraint.activate([
            lockImgView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            lockImgView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            lockImgView.widthAnchor.constraint(equalToConstant: 23),
            lockImgView.heightAnchor.constraint(equalToConstant: 27)
        ])
    }
}
