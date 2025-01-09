//
//  AlbumsPickerViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import UIKit
import PhotosUI

protocol AlbumsPickerViewControllerDelegate: AnyObject {
    func albumsPicker(_ viewController: AlbumsPickerViewController,
                      didSelectAlbum album: Album)
}

final class AlbumsPickerViewController: UIViewController, PHPhotoLibraryChangeObserver {
    weak var delegate: AlbumsPickerViewControllerDelegate?
    fileprivate let galleryManager: GalleryManagerProtocol
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate let library = PHPhotoLibrary.shared()
    fileprivate let headerHeight: CGFloat = 50.0
    fileprivate let footerHeight: CGFloat = 50.0
    fileprivate let headerIdentifier = "AlbumsHeaderView"

    var tableViewContentHeight: CGFloat {
        albumsTableView.layoutIfNeeded()

        var height = albumsTableView.contentSize.height
        height += Constants.padding * 2 // adding the content inset
        return height
    }

    private lazy var tableViewHeightAnchor =
        albumsTableView.heightAnchor.constraint(equalToConstant: tableViewContentHeight)
    private lazy var tableViewLeadingConstraint =
        albumsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding * 2)
    private lazy var tableViewTrailingConstraint =
        albumsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding * 2)

    // MARK: - Views

    lazy var albumsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.bounces = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = GiniColor(light: .GiniCapture.light1, dark: .GiniCapture.dark1).uiColor()
        tableView.register(AlbumsPickerTableViewCell.self,
                           forCellReuseIdentifier: AlbumsPickerTableViewCell.identifier)
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.contentInset = UIEdgeInsets(top: Constants.padding, left: 0, bottom: Constants.padding, right: 0)
        tableView.separatorColor = GiniColor(light: .GiniCapture.light4, dark: .GiniCapture.dark6).uiColor()
        return tableView
    }()

    // MARK: - Initializers

    init(galleryManager: GalleryManagerProtocol,
         giniConfiguration: GiniConfiguration = GiniConfiguration.shared) {
        self.galleryManager = galleryManager
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func loadView() {
        super.loadView()
        title = NSLocalizedStringPreferredFormat("ginicapture.albums.title", comment: "Albums")
        view.backgroundColor = GiniColor(light: .GiniCapture.light2, dark: .GiniCapture.dark2).uiColor()
        setupTableView()
    }

    func setupTableView() {
        if #available(iOS 15.0, *) {
             albumsTableView.sectionHeaderTopPadding = 0
         }
        view.addSubview(albumsTableView)

        tableViewHeightAnchor.priority = .defaultHigh

        NSLayoutConstraint.activate([
            albumsTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding * 2),
            tableViewLeadingConstraint,
            tableViewTrailingConstraint,
            albumsTableView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -Constants.padding * 2),
            tableViewHeightAnchor
        ])
    }

    func reloadAlbums() {
        albumsTableView.reloadData()
    }

    func showLimitedLibraryPicker() {
        if #available(iOS 15.0, *) {
            library.presentLimitedLibraryPicker(from: self) { _ in
                DispatchQueue.main.async {
                    self.galleryManager.reloadAlbums()
                    self.reloadAlbums()
                }
            }
            return
        }

        if #available(iOS 14.0, *) {
            library.presentLimitedLibraryPicker(from: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            library.register(self)
            if galleryManager.isGalleryAccessLimited {
                let footerView = AlbumsFooterView()
                albumsTableView.tableFooterView = footerView
            }
        }

        edgesForExtendedLayout = []
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 14.0, *) {
            if galleryManager.isGalleryAccessLimited {
                self.updateLayoutForFooter()
            }
        }
        tableViewHeightAnchor.constant = tableViewContentHeight
        if UIDevice.current.isIphone {
            let isLandscape = currentInterfaceOrientation?.isLandscape == true
            let padding = isLandscape ? Constants.paddingHorizontal * 2 : Constants.padding * 2
            tableViewLeadingConstraint.constant = padding
            tableViewTrailingConstraint.constant = -padding
        }
        view.layoutIfNeeded()
    }

    fileprivate func updateLayoutForFooter() {
        guard let footerView = albumsTableView.tableFooterView else {
            return
        }

        let width = albumsTableView.bounds.size.width
        let size = footerView.systemLayoutSizeFitting(CGSize(width: width,
                                                             height: UIView.layoutFittingCompressedSize.height))

        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            albumsTableView.tableFooterView = footerView
        }
    }

    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.galleryManager.reloadAlbums()
            self.reloadAlbums()
        }
    }

    deinit {
        if #available(iOS 14.0, *) {
            library.unregisterChangeObserver(self)
        }
    }
}

// MARK: UITableViewDataSource

extension AlbumsPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleryManager.albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            AlbumsPickerTableViewCell.identifier) as? AlbumsPickerTableViewCell
        let album = galleryManager.albums[indexPath.row]
        cell?.setUp(with: album,
                    giniConfiguration: giniConfiguration,
                    galleryManager: galleryManager)
        if indexPath.row == galleryManager.albums.count - 1 {
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if #available(iOS 14.0, *) {
            if galleryManager.isGalleryAccessLimited && section == 0 {
                let headerView = AlbumsHeaderView().loadNib() as? AlbumsHeaderView
                headerView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)

                headerView?.didTapSelectButton = {
                    self.showLimitedLibraryPicker()
                }
                return headerView
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 14.0, *) {
            return galleryManager.isGalleryAccessLimited && section == 0 ? headerHeight : 0.0
        } else {
            return 0.0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: UITableViewDelegate

extension AlbumsPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.albumsPicker(self, didSelectAlbum: galleryManager.albums[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AlbumsPickerViewController {
    private enum Constants {
        static let padding: CGFloat = 8
        static let paddingHorizontal: CGFloat = 28
        static let cornerRadius: CGFloat = 16
    }
}
