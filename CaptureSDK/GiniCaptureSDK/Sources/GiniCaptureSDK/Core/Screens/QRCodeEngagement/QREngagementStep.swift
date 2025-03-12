//
//  QREngagementStep.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public enum QREngagementStep {
    case first
    case second
    case third

    var title: String {
        // TODO: PP-1043 add localization strings
        switch self {
        case .first:
            return "Nicht nur QR-Codes!"
        case .second:
            return "Fotos, PDFs & mehr!"
        case .third:
            return "Sogar Bildschirme & GIFs!"
        }
    }

    var description: String {
        // TODO: PP-1043 add localization strings
        switch self {
        case .first:
            return "Fotoüberweisung kann mehr als nur QR-Codes scannen! Rechnungen, Zahlungsformulare, Bildschirme, PDFs und sogar GIFs – tippen Sie auf Mehr lesen, um mehr zu erfahren."
        case .second:
            return "Machen Sie ein Foto, laden Sie ein PDF hoch (bis zu 10 Seiten) oder scannen Sie digital erstellte Rechnungen und Überweisungsträger – Fotoüberweisung übernimmt die Zahlungsdaten für Sie!"
        case .third:
            return "Scannen Sie Zahlungsdaten direkt von einem Monitor, Screenshot, GIF oder QR-Code – schnell und einfach!"
        }
    }

    var image: UIImage? {
        switch self {
        case .first:
            return GiniCaptureImages.qrCodeEngagementStep0.image
        case .second:
            return GiniCaptureImages.qrCodeEngagementStep1.image
        case .third:
            return GiniCaptureImages.qrCodeEngagementStep2.image
        }
    }
}
