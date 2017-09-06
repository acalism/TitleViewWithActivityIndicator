//
//  TitleView.swift
//  TitleViewWithActivityIndicator
//
//  Created by donaldsong on 17-9-6.
//  Copyright © 2017 Tencent. All rights reserved.
//

import UIKit

/// 功能：左侧带菊花的 titleView，菊花和文字自适应。
/// 使用方法：设置 titleLabel.text 和 activityIndicator.startAnimating()/stopAnimating()，无需设置titleView.frame
class TitleView: UIView {

    let activityIndicator = ActivityIndicatorView(activityIndicatorStyle: .white)
    let titleLabel = UILabel()

    /// 可按自己项目的需要修改
    private let titleAttributes: [String: Any] = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName : UIFont.boldSystemFont(ofSize: 20)]

    private var myContext = 0

    deinit {
        if #available(iOS 9, *) {
            //
        } else {
            titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &myContext)
        }
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.alpha), context: &myContext)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicator.color = .blue
        addSubview(activityIndicator)
        addSubview(titleLabel)

        titleLabel.font = titleAttributes[NSFontAttributeName] as! UIFont
        titleLabel.textColor = titleAttributes[NSForegroundColorAttributeName] as! UIColor
        titleLabel.backgroundColor = .clear
        titleLabel.lineBreakMode = .byTruncatingTail

        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.alpha), options: [.new], context: &myContext)
        if #available(iOS 9, *) {
            //
        } else { // iOS 8.x 省略符号是灰色的，会消失不见，改为用attributedText来解决
            titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), options: [.new], context: &myContext)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 作为导航栏的 titleView，其frame会被导航栏自动调整，两个子view则依titleView变化
    // titleLabel 和菊花可能会适当超出 TitleView.frame，但不会与左右 BarButtonItem 重叠或过于靠近
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.sizeToFit()
        guard let sFrame = superview?.frame else {
            return
        }
        // 以下出现的 magic number 是从 Xcode 的 view debugger 得来。
        var leftAmendment: CGFloat = 12 // 左侧修正，titleView与返回按钮的间距为12
        if #available(iOS 9, *) {
            leftAmendment += 16 // iOS 9+，返回按钮（即UINavigationItemButtonView）宽为48，在iOS 8上则为32————故需补齐差值48-32=16，使表现一致
        } else {
            //
        }
        let outerInsets = UIEdgeInsets(top: frame.minY, left: frame.minX - leftAmendment, bottom: sFrame.height - frame.maxY, right: sFrame.width - frame.maxX)
        let m = max(outerInsets.left, outerInsets.right)

        // 菊花尺寸
        let aSize = activityIndicator.isAnimating ? activityIndicator.frame.size : CGSize.zero

        let xMargin: CGFloat = 8
        let tMaxWidth = (frame.width + leftAmendment) - aSize.width - xMargin // 标题容许的最大宽度

        // 标题尺寸
        var tSize = titleLabel.sizeThatFits(CGSize(width: tMaxWidth, height: frame.height))
        if tSize.width > tMaxWidth {
            tSize.width = tMaxWidth
        }

        var originX: CGFloat
        if tSize.width <= sFrame.width - (aSize.width + xMargin + m) * 2 { // 宽度足够时，标题在导航栏居中
            originX = (sFrame.width - tSize.width) / 2 - outerInsets.left - leftAmendment
        } else { // 宽度不充裕时，菊花和标题整体在titleView里居中
            originX = (frame.width - tSize.width + aSize.width + xMargin) / 2 - leftAmendment
        }
        titleLabel.frame = CGRect(x: originX, y: (frame.height - tSize.height) / 2, width: tSize.width, height: tSize.height)
        activityIndicator.frame.origin = CGPoint(x: titleLabel.frame.origin.x - xMargin - activityIndicator.frame.width, y: (frame.height - activityIndicator.frame.height) / 2)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == #keyPath(UILabel.text) {
            if let t = change?[.newKey] as? String {
                titleLabel.attributedText = NSAttributedString(string: t, attributes: [NSForegroundColorAttributeName: titleLabel.textColor!, NSFontAttributeName: titleLabel.font!])
            } else {
                titleLabel.attributedText = nil
            }
        } else if keyPath == #keyPath(UILabel.alpha) {
            if let nValue = change?[.newKey], let a = ((nValue as? Double) ?? (nValue as? NSNumber)?.doubleValue) {
                activityIndicator.alpha = CGFloat(a)
            }
        } else if keyPath == #keyPath(UIActivityIndicatorView.isAnimating) {
            let nValue = change?[.newKey]
            if let _ = (nValue as? Bool) ?? (nValue as? NSNumber)?.boolValue {
                setNeedsLayout()
            } else {
                print("Error: You can not be here")
            }
        }
    }


    class ActivityIndicatorView: UIActivityIndicatorView {
        override func startAnimating() {
            super.startAnimating()
            superview?.setNeedsLayout()
            superview?.layoutIfNeeded()
        }
        override func stopAnimating() {
            super.stopAnimating()
            superview?.setNeedsLayout()
            superview?.layoutIfNeeded()
        }
    }
}

