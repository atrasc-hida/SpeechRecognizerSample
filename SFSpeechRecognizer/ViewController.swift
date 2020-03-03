//
//  ViewController.swift
//  SFSpeechRecognizer
//
//  Created by 飛田 由加 on 2020/03/03.
//  Copyright © 2020 atrasc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? SecondViewController else { return }
        switch segue.identifier {
        case "japanese": dest.lang = .japanese
        case "english": dest.lang = .english
            case "simplified": dest.lang = .simplified
            case "traditional": dest.lang = .traditional
            case "korean": dest.lang = .korean
            case "german": dest.lang = .german
            case "italian": dest.lang = .italian
            case "hindi": dest.lang = .hindi
        default:
            break
        }
    }
}

enum Language: String{
    case japanese = "日本語"
    case english = "英語"
    case simplified = "簡体字中国語"
    case traditional = "繁体字中国語"
    case korean = "韓国語"
    case german = "ドイツ語"
    case italian = "イタリア語"
    case hindi = "ヒンディー語"
    
    var identifier: String {
        switch self {
        case .japanese:
            return "ja_JP"
        case .english:
            return "en_US"
        case .simplified:
            return  "zh_Hans"
        case .traditional:
            return "zh_Hant"
        case .korean:
            return "ko"
        case .german:
            return "de_DE"
        case .italian:
            return "it_IT"
        case .hindi:
            return "hi_IN"
        }
    }
}

