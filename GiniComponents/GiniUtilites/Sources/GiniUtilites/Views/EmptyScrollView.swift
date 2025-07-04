//
//  EmptyScrollView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit
import Combine

public final class EmptyScrollView: UIScrollView {

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var size: CGSize = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addContentSubview(_ view: UIView) {
        contentView.addSubview(view)
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.makeConstraints { make in
            make.edges.equalTo(contentLayoutGuide)
            make.centerX.equalToSuperview()
        }
        
        bindToSizeUpdates()
    }
    
    private func bindToSizeUpdates() {
        publisher(for: \.contentSize)
            .filter({ $0.height > 0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.size = value
            }.store(in: &cancellables)
    }
}
