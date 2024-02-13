Pod::Spec.new do |spec|
  spec.name               = "GiniBankSDK"
  spec.version            = "3.7.2"
  spec.summary            = "Gini Bank SDK for iOS"
  spec.description        = "The Gini Bank SDK provides components for capturing, reviewing and analyzing photos of invoices and remittance slips."
  spec.homepage           = "https://gini.net"
  spec.documentation_url  = "https://developer.gini.net/gini-mobile-ios/GiniBankSDK/#{spec.version.to_s}/"
  spec.author             = "Gini GmbH"
  spec.license            = { :type => 'Private', :text => <<-LICENSE
                                Copyright (c) 2021-2024, Gini GmbH

                                All rights reserved.
                                
                                The projects in this repository, if not stated otherwise, are licensed through Gini GmbH ("Gini") and may not be
                                used, altered or copied in any way without explicit permission by Gini. The
                                terms of usage are defined in a separate usage agreement between Gini and the
                                licensee, where the licensee can gain access to a non-exclusive,
                                non-transferable usage right which is restricted for the time of a contractual
                                relationship between Gini and the licensee.
                                
                                For license related inquiries contact Gini via the email address
                                technical-support@gini.net.
                              LICENSE
                            }
  spec.source             = { :http => "https://github.com/gini/gini-podspecs/raw/master/GiniBankSDK/#{spec.version.to_s}/GiniBankSDK-XCFrameworks.zip" }
  spec.swift_version      = "5.3"

  # Supported deployment targets
  spec.ios.deployment_target  = "12.0"

  # Published binaries
  spec.vendored_frameworks = "GiniBankSDK.xcframework", "GiniCaptureSDK.xcframework", "GiniBankAPILibrary.xcframework"
end