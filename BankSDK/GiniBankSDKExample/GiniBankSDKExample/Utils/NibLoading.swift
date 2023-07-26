//
//  NibLoading.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 27/10/2022.
//

import UIKit

protocol NibLoadableView: AnyObject {
	static var nibName: String { get }
	func loadNib()
}

extension NibLoadableView where Self: UIView {
	
	static var nibName: String {
		return String(describing: self)
	}
	
	func loadNib() {
		Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)
	}
}

protocol NibObjectLoading: AnyObject {
	func loadNibObject<T: NibLoadableView>() -> T
}

extension NibObjectLoading {
	func loadNibObject<T: NibLoadableView>() -> T {
		let nib = UINib(nibName: T.nibName, bundle: Bundle.main)
		var hint = "\(T.nibName) xib missing"
		guard let loadedObject = nib.instantiate(withOwner: self, options: nil).first else {
			preconditionFailure("Required value was nil. \(hint)")
		}
		hint = "\(T.nibName) xib does not contain expected object"
		guard let object = (loadedObject as? T) else {
			preconditionFailure("Required value was nil. \(hint)")
		}
		return object
	}
}
