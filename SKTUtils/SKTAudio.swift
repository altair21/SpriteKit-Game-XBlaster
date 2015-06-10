/*
 * Copyright (c) 2013-2014 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import AVFoundation

/**
 * Audio player that uses AVFoundation to play looping background music and
 * short sound effects. For when using SKActions just isn't good enough.
 */
public class SKTAudio {
  public var backgroundMusicPlayer: AVAudioPlayer?
  public var soundEffectPlayer: AVAudioPlayer?

  public class func sharedInstance() -> SKTAudio {
    return SKTAudioInstance
  }

  public func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
    if (url == nil) {
      print("Could not find file: \(filename)", appendNewline: false)
      return
    }

    var error: NSError? = nil
    do {
      backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: url!)
    } catch var error1 as NSError {
      error = error1
      backgroundMusicPlayer = nil
    }
    if let player = backgroundMusicPlayer {
      player.numberOfLoops = -1
      player.prepareToPlay()
      player.play()
    } else {
      print("Could not create audio player: \(error!)", appendNewline: false)
    }
  }

  public func pauseBackgroundMusic() {
    if let player = backgroundMusicPlayer {
      if player.playing {
        player.pause()
      }
    }
  }

  public func resumeBackgroundMusic() {
    if let player = backgroundMusicPlayer {
      if !player.playing {
        player.play()
      }
    }
  }

  public func playSoundEffect(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
    if (url == nil) {
      print("Could not find file: \(filename)", appendNewline: false)
      return
    }

    var error: NSError? = nil
    do {
      soundEffectPlayer = try AVAudioPlayer(contentsOfURL: url!)
    } catch var error1 as NSError {
      error = error1
      soundEffectPlayer = nil
    }
    if let player = soundEffectPlayer {
      player.numberOfLoops = 0
      player.prepareToPlay()
      player.play()
    } else {
      print("Could not create audio player: \(error!)", appendNewline: false)
    }
  }
}

private let SKTAudioInstance = SKTAudio()
