//
//  ScreenRecorder.swift
//  BugReporterTest
//
//  Created by Giridhar on 09/06/17.
//  Copyright © 2017 Giridhar. All rights reserved.
//
import Foundation
import ReplayKit
import AVKit


class ScreenRecorder
{
    var assetWriter:AVAssetWriter!
    var videoInput:AVAssetWriterInput!
    var audioInput:AVAssetWriterInput!

//    let viewOverlay = WindowUtil()
    
    //MARK: Screen Recording
    func startRecording(withFileName fileName: String, recordingHandler:@escaping (Error?)-> Void)
    {
        if #available(iOS 11.0, *)
        {
           
            //Get File path
            let fileURL = URL(fileURLWithPath: ReplayFileUtil.filePath(fileName))
            
//        guard let firstDocumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
//
//            let directoryContents = try! FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: firstDocumentDirectoryPath), includingPropertiesForKeys: nil, options: [])
//            print(directoryContents)
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//
//            let outputPathURL = documentsDirectory.appendingPathComponent("/\(arc4random()).mp4")

            
//            let fileURL  = URL(fileURLWithPath: firstDocumentDirectoryPath.appending("/\(arc4random()).mp4"))
            
            print(fileURL.absoluteString)
       
            assetWriter = try! AVAssetWriter(outputURL: fileURL, fileType:
                AVFileTypeMPEG4)
            
            
            //Video Settings
            let videoSettings: [String : Any] = [
                AVVideoCodecKey  : AVVideoCodecType.h264,
                AVVideoWidthKey  : 720,
                AVVideoHeightKey : 1280,
                ]
            videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
            videoInput?.expectsMediaDataInRealTime = true;
            print("Setup AVAssetWriterInput: Video")
            if (assetWriter?.canAdd(videoInput!))!
            {
                assetWriter?.add(videoInput!)
                print("Added AVAssetWriterInput: Video")
            } else{
                print("Could not add VideoWriterInput to VideoWriter")
            }

//            let videoOutputSettings: Dictionary<String, Any> = [
//                AVVideoCodecKey : AVVideoCodecType.h264,
//                AVVideoWidthKey : UIScreen.main.bounds.size.width,
//                AVVideoHeightKey : UIScreen.main.bounds.size.height
//            ];
//            var channelLayout = AudioChannelLayout.init()
//            channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_MPEG_5_1_D
//            let audioOutputSettings: [String : Any] = [
//                AVNumberOfChannelsKey: 6,
//                AVFormatIDKey: kAudioFormatMPEG4AAC_HE,
//                AVSampleRateKey: 44100,
//                AVChannelLayoutKey: NSData(bytes: &channelLayout, length: MemoryLayout.size(ofValue: channelLayout)),
//                ]
//
            //Audio Settings
//            let audioSettings : [String : Any] = [
//                AVFormatIDKey : kAudioFormatMPEG4AAC,
//                AVSampleRateKey : 44100,
//                AVEncoderBitRateKey : 64000,
//                AVNumberOfChannelsKey: 1
//            ]
//            audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioSettings)
//            audioInput?.expectsMediaDataInRealTime = true;
//            print("Setup AVAssetWriterInput: Audio")
//            if (assetWriter?.canAdd(audioInput!))!
//            {
//                assetWriter?.add(audioInput!)
//                print("Added AVAssetWriterInput: Audio")
//            } else{
//                print("Could not add AudioWriterInput to VideoWriter")
//            }
//            audioInput  = AVAssetWriterInput(mediaType: AVMediaTypeAudio,outputSettings: audioSettings)

//            videoInput  = AVAssetWriterInput (mediaType: AVMediaTypeVideo, outputSettings: videoOutputSettings)
//            videoInput.expectsMediaDataInRealTime = true

//            assetWriter.add(videoInput)
//            assetWriter.add(audioInput)
//            RPScreenRecorder.shared().isMicrophoneEnabled = true

            RPScreenRecorder.shared().startCapture(handler: { (sample, bufferType, error) in
//                print(sample,bufferType,error)

                recordingHandler(error)
                
                if CMSampleBufferDataIsReady(sample)
                {
                    if self.assetWriter.status == AVAssetWriterStatus.unknown
                    {
                        self.assetWriter.startWriting()
                        self.assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample))
                    }
                    
                    if self.assetWriter.status == AVAssetWriterStatus.failed {
                        print("Error occured, status = \(self.assetWriter.status.rawValue), \(self.assetWriter.error!.localizedDescription) \(String(describing: self.assetWriter.error))")
                        return
                    }
                    
                    if (bufferType == .video)
                    {
                        if self.videoInput.isReadyForMoreMediaData
                        {
                            self.videoInput.append(sample)
                        }
                    }
//                    if (bufferType == .audioApp)
//                    {
//                        if self.audioInput.isReadyForMoreMediaData
//                        {
//                            //print("Audio Buffer Came")
//                            self.audioInput.append(sample)
//                        }
//                    }
//                    if (bufferType == .audioMic)
//                    {
//                        if self.audioInput.isReadyForMoreMediaData
//                        {
//                            //print("Audio Buffer Came")
//                            self.audioInput.append(sample)
//                        }
//                    }
                }
                
            }) { (error) in
                recordingHandler(error)
//                debugPrint(error)
            }
        } else
        {
            // Fallback on earlier versions
        }
    }
    
    func stopRecording(handler: @escaping (Error?) -> Void)
    {
        if #available(iOS 11.0, *)
        {
            RPScreenRecorder.shared().stopCapture
            {    (error) in
                    handler(error)
                    self.assetWriter.finishWriting
                {
                   // print(ReplayFileUtil.fetchAllReplays())
                    
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
}
