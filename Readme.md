![ios](https://cocoapod-badges.herokuapp.com/v/PandoraPlayer/badge.png) ![ios](https://cocoapod-badges.herokuapp.com/p/PandoraPlayer/badge.png) ![Swift 4.0.x](https://img.shields.io/badge/Swift-4.0.x-orange.svg) ![GitHub license](https://cocoapod-badges.herokuapp.com/l/PandoraPlayer/badge.(png|svg))

Made by [Applikey Solutions](https://applikeysolutions.com)

Find this [project on Dribbble](https://dribbble.com/shots/3456425-Music-waves)

![PandoraPlayer](https://f.flockusercontent2.com/2a4adb31502114757e42a129)

# Table of Contents
1. [Purpose](#purpose)
2. [Features](#features)
3. [Supported OS & SDK Versions](#supported-os--sdk-versions)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Demo](#demo)
7. [Release Notes](#release-notes)
8. [Contact Us](#contact-us)
9. [License](#license)

# Purpose

`PandoraPlayer` is a lightweight music player for iOS, based on [AudioKit](https://github.com/AudioKit/AudioKit) and completely written in [Swift](https://developer.apple.com/swift/), constructed to be fast, light and have a nice design.

# Features
- [x] Plays iPod music / bundle music
- [x] Real-time two-channel visual equalizer
- [x] Standard controls
- [x] Simple API
- [x] Simple & intuitive design

# Supported OS & SDK Versions

* Supported build target - iOS 9.0

# Installation

### [CocoaPods](https://github.com/CocoaPods/CocoaPods)
Add the following line in your `Podfile`.
```
pod 'PandoraPlayer'
```

# Usage

```swift
import PandoraPlayer

let playerVC = PandoraPlayer.configure(withMPMediaItems: mediaItems)
navigationController?.present(playerVC, animated: true, completion: nil)
```

# Demo
![example-plain](https://f.flockusercontent2.com/2a4adb31501665971ce5e1c4)

# Release Notes

Version 1.0

- Release version.

Version 1.1

- Added Xcode 9 and Swift 4 support 

# Contact Us

You can always contact us via github@applikey.biz We are open for any inquiries regarding our libraries and controls, new open-source projects and other ways of contributing to the community. If you have used our component in your project we would be extremely happy if you write us your feedback and let us know about it!

# License

The MIT License (MIT)

Copyright © 2017 Applikey Solutions

Permission is hereby granted free of charge to any person obtaining a copy of this software and associated documentation files (the "Software") to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
