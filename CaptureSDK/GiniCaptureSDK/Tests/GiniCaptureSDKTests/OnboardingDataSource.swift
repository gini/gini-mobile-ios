//
//  OnboardingDataSource.swift
//  
//
//  Created by Valentina Iancu on 28.07.23.
//

import XCTest
@testable import GiniCaptureSDK

final class OnboardingDataSourceTests: XCTestCase {

    private let giniConfiguration = GiniConfiguration.shared
    
    private var pages = [OnboardingDataSource.OnboardingPageModel]()
    
    override func setUp() {
        super.setUp()
        giniConfiguration.multipageEnabled = false
        giniConfiguration.qrCodeScanningEnabled = false
        giniConfiguration.customOnboardingPages = nil
    }
    
    private func setDefaultOnboardingPages() {
        pages = [(page: OnboardingPage(imageName: DefaultOnboardingPage.flatPaper.imageName,
                                       title: DefaultOnboardingPage.flatPaper.title,
                                       description: DefaultOnboardingPage.flatPaper.description),
                  illustrationAdapter: giniConfiguration.onboardingAlignCornersIllustrationAdapter),
                 (page: OnboardingPage(imageName: DefaultOnboardingPage.lighting.imageName,
                                       title: DefaultOnboardingPage.lighting.title,
                                       description: DefaultOnboardingPage.lighting.description),
                  illustrationAdapter: giniConfiguration.onboardingLightingIllustrationAdapter)]
        
        if giniConfiguration.multipageEnabled {
            pages.append((page: OnboardingPage(imageName: DefaultOnboardingPage.multipage.imageName,
                                               title: DefaultOnboardingPage.multipage.title,
                                               description: DefaultOnboardingPage.multipage.description),
                          illustrationAdapter: giniConfiguration.onboardingMultiPageIllustrationAdapter))
        }
        
        if giniConfiguration.qrCodeScanningEnabled {
            pages.append((page: OnboardingPage(imageName: DefaultOnboardingPage.qrcode.imageName,
                                               title: DefaultOnboardingPage.qrcode.title,
                                               description: DefaultOnboardingPage.qrcode.description),
                          illustrationAdapter: giniConfiguration.onboardingQRCodeIllustrationAdapter))
        }
    }
    
    private func setCustomOnboardingPages() {
        guard let customPages = giniConfiguration.customOnboardingPages else { return }
        pages =  customPages.map { page in
            return (page: page, illustrationAdapter: nil)
        }
    }
    
    private func setPages() {
        giniConfiguration.customOnboardingPages == nil ? setDefaultOnboardingPages() : setCustomOnboardingPages()
    }
    
    func testNumberOfDefaultOnboardingPages() {
        setPages()
        XCTAssertEqual(pages.count, 2, "Expacted 2 default onboarding pages but found \(pages)")
        
        giniConfiguration.multipageEnabled = true
        setPages()
        XCTAssertEqual(pages.count, 3, "Expacted 3 default onboarding pages but found \(pages)")
        
        
        giniConfiguration.qrCodeScanningEnabled = true
        setPages()
        XCTAssertEqual(pages.count, 4, "Expacted 4 default onboarding pages but found \(pages)")
    }
    
    func testNumberOfCustomOnboardingPages() {
        giniConfiguration.customOnboardingPages = [OnboardingPage(imageName: "captureSuggestion1", title: "Page 1", description: "Description for page 1"),
                                                   OnboardingPage(imageName: "captureSuggestion2", title: "Page 2", description: "Description for page 2"),
                                                   OnboardingPage(imageName: "captureSuggestion3", title: "Page 3", description: "Description for page 3"),
                                                   OnboardingPage(imageName: "captureSuggestion4", title: "Page 4", description: "Description for page 4"),
                                                   OnboardingPage(imageName: "captureSuggestion5", title: "Page 5", description: "Description for page 5"),
                                                   OnboardingPage(imageName: "captureSuggestion6", title: "Page 6", description: "Description for page 6")]
        setPages()
        XCTAssert(pages.count == giniConfiguration.customOnboardingPages?.count, "Expacted 6 custom onboarding pages but found \(pages.count)")
    }
}
