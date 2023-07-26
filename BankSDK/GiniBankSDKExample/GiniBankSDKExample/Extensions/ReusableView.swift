//
//  ReusableView.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 12.06.23.
//

import UIKit

protocol ReusableView: AnyObject {}

extension ReusableView where Self: UIView {
	
	static var reuseIdentifier: String {
		return String(describing: self)
	}
}

