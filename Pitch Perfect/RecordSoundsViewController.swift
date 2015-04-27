//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Ross Duris on 4/2/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingStatus:UILabel!
    @IBOutlet weak var recordButton:UIButton!
    @IBOutlet weak var stopButton:UIButton!
    @IBOutlet weak var resetButton:UIButton!
    @IBOutlet weak var pauseButton:UIButton!
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Record"
        stopButton.hidden = true
        pauseButton.hidden = true
        resetButton.hidden = true
        recordingStatus.text = "Tap to Record"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startRecording(){
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        recordButton.enabled = false
        stopButton.hidden = false
        pauseButton.hidden = false
        resetButton.hidden = false
        recordingStatus.text = "Recording..."
        
        //Setup the audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: nil)
        
        //Initialize and prepare the audio recorder
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag){
            
            //Save the recorded audio
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            
            recordButton.enabled = true
            stopButton.hidden = true
            pauseButton.hidden = true
            resetButton.hidden = true
            recordingStatus.text = "Tap to Record"
            
            //Move to next scene
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
            
        } else {
            println("Recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopRecording(){
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        if stopButton.enabled == true {
            audioRecorder.pause()
            stopButton.enabled = false
            recordButton.enabled = false
            resetButton.enabled = false
            pauseButton.setImage(UIImage(named: "resume"), forState: UIControlState.Normal)
            recordingStatus.text = "Paused"
        } else {
            audioRecorder.record()
            stopButton.enabled = true
            recordButton.enabled = true
            resetButton.enabled = true
            pauseButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            recordingStatus.text = "Recording..."
        }
    }
    
    
    @IBAction func resetRecording(){
        audioRecorder.deleteRecording()
        stopButton.hidden = true
        pauseButton.hidden = true
        resetButton.hidden = true
        pauseButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        recordButton.enabled = true
        recordingStatus.text = "Tap to Record"
    }
    
    
}

