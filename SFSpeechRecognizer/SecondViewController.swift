//
//  SecondViewController.swift
//  SFSpeechRecognizer
//
//  Created by 飛田 由加 on 2020/03/03.
//  Copyright © 2020 atrasc. All rights reserved.
//

import UIKit
import Speech

class SecondViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    var lang:Language = .english
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: lang.identifier))!
        speechRecognizer.delegate = self    // デリゲート先になる
        
        // コールバックをメインスレッドで実行している
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:   // 許可OK
                    self.recordButton.isEnabled = true
                    self.recordButton.backgroundColor = UIColor.blue
                case .denied:       // 拒否
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("録音許可なし", for: .disabled)
                case .restricted:   // 限定
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("このデバイスでは無効", for: .disabled)
                case .notDetermined:// 不明
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("録音機能が無効", for: .disabled)
                default:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("録音機能が無効", for: .disabled)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // recordButtonはアプリ起動時は無効で、ユーザから録音許可を得た後に有効化する。
        recordButton.isEnabled = false

        label.text = lang.rawValue
    }
    

    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if audioEngine.isRunning {
            // 音声エンジン動作中なら停止
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("停止", for: .disabled)
            recordButton.backgroundColor = UIColor.lightGray
            return
        }
        // 録音を開始する
        try! startRecording()
        recordButton.setTitle("認識を完了する", for: [])
        recordButton.backgroundColor = UIColor.red
    }
    
    // タスクにリクエストを登録すると、その結果に音声認識された文字列が返ってくる
    // エラーハンドリングするためthrowsキーワードをつける（実際はしない）
    
    private func startRecording() throws {
        //ここに録音する処理を記述
        if let recognitionTask = recognitionTask {
            // 既存タスクがあればキャンセルしてリセット
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        // セッションを準備する
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .default, options: [])
        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // 認識開始の前に認識リクエストを初期化
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("リクエスト生成エラー") }
        
        // 録音完了前に途中の結果を報告してくれる（デフォルトはfalse）
        // trueにすると、完了時に結果をさかのぼって修正してくれる
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        // resultのbestTranscriptionプロパティには、最も精度が高かった認識結果のStringオブジェクトが入っている
        // shouldReportPartialResultsプロパティがtrueなら、bestTranscriptionのオブジェクトが変化するのかもしれない
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("音声入力開始", for: [])
                self.recordButton.backgroundColor = UIColor.blue
                
                self.textView.text = ""
                
            }
        }
        
        // マイクからの録音フォーマット
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        // オーディオエンジンで録音を開始して、テキスト表示を変更する
        audioEngine.prepare()   // オーディオエンジン準備
        try audioEngine.start() // オーディオエンジン開始
        
        textView.text = "(認識中…)"
    }

    // 音声認識機能の状態が変化するタイミングで呼ばれる
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            // 利用可能になったら、録音ボタンを有効にする
            recordButton.isEnabled = true
            recordButton.setTitle("音声入力開始", for: [])
            recordButton.backgroundColor = UIColor.blue
        } else {
            // 利用できないなら、録音ボタンは無効にする
            recordButton.isEnabled = false
            recordButton.setTitle("現在、使用不可", for: .disabled)
        }
    }
}
