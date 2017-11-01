//
//  PandoraPlayer.swift
//  PandoraPlayer
//
//  Created by Boris Bondarenko on 6/1/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit
import AudioKit
import AVKit
import MediaPlayer

// MARK: Constants

fileprivate let storyboardIdentifier = "PandoraPlayer"
fileprivate let nowPlaying = "Now Playing"
fileprivate let unknown = "Unknown"

fileprivate var rightChannelColor: UIColor = UIColor.green
fileprivate var leftChannelColor: UIColor = UIColor.blue

fileprivate var songNameColor: UIColor = UIColor.white
fileprivate var songAlbumColor: UIColor = UIColor.white

fileprivate var deadlineTimeOffset = 1000

fileprivate let scaleDownSizeWidth = 100
fileprivate let scaleDownSizeHeight = 100

fileprivate let animatableViewHeight = 100
fileprivate let animatableViewWidth = 100
fileprivate let animatableViewAlpha: CGFloat = 0.3
fileprivate let animatableViewScale: CGFloat = 1.7
fileprivate let animationInterval: TimeInterval = 0.2
fileprivate let defaultStartProgress: Float = 0.0

fileprivate let asyncOffset: Float = 0.2

open class PandoraPlayer: UIViewController {
	
    // MARK: Public
    
    public var playImmediately: Bool = false
    public var onClose: GenericClosure<Void>?
    
    // MARK: Instance Variables
    
    fileprivate var library: [Song] = []

    fileprivate var player: EZAudioPlayer!
    fileprivate var originalPlayList: [Song] = []
    fileprivate var count: Int = 0
    
    fileprivate var playerTimer = Timer()
    fileprivate var tasks: [Int: DispatchWorkItem] = [:]
    
    fileprivate var beeingSeek = false
    fileprivate var designated: Bool = false
    fileprivate var isReady: Bool = false

    fileprivate func rewindBackward() {
        if currentSongIndex > 0 {
            currentSongIndex -= 1
        }
        updatePlaybackStatus()
    }
    
    fileprivate var currentSongIndex: Int = -1 {
        didSet {
            guard currentSongIndex != oldValue else {
                return
            }
            isReady ? reloadPlayer(): ()
        }
    }
    
    fileprivate var isRepeatModeOn: Bool = false {
        didSet {
            controlsView.isRepeatModeOn = isRepeatModeOn
        }
    }
    
    fileprivate var isShuffleModeOn: Bool = false {
        didSet {
            controlsView.isShuffleModeOn = isShuffleModeOn
            if isShuffleModeOn {
                syncColorsWithOriginalList()
                shufflePlayList()
            } else {
                resetPlaylist()
            }
            configureBackgroundImage()
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet fileprivate weak var blurredAlbumImageView: UIImageView!
    @IBOutlet fileprivate weak var playerSongListView: PlayerSongList!
	@IBOutlet fileprivate weak var sliderView: PlayerSlider!
	@IBOutlet fileprivate weak var waveVisualizer: WaveVisualizer!
	@IBOutlet fileprivate weak var controlsView: PlayerControls!
    @IBOutlet private weak var songNameLabel: UILabel!
    @IBOutlet private weak var songAlbumLabel: UILabel!
    @IBOutlet fileprivate var fadeImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    /**
     Player View Controller initializator with path.
     
     - parameter item: path.
     
     - returns: Instance of PandoraPlayer with set library.
     */
    public static func configure(withPath path: String) -> PandoraPlayer {
        return PandoraPlayer.configure(withPaths: [path])
    }
    
    /**
     Player View Controller initializator with array of path's.
     
     - parameter items: Array of AVPlayerItems.
     
     - returns: Instance of PandoraPlayer with set library.
     */
    public static func configure(withPaths paths: [String]) -> PandoraPlayer {
        let playerVC = pandoraPlayerInstance()
        let songItems = paths.flatMap({ return Song(path: $0) })
        playerVC.library = songItems
        playerVC.readyForPlay()
        return playerVC
    }
    
    /**
        Player View Controller initializator with AVPlayerItem.
     
     - parameter item: AVPlayerItem.
     
     - returns: Instance of PandoraPlayer with set library.
     */
    public static func configure(withAVItem item: AVPlayerItem) -> PandoraPlayer {
        return PandoraPlayer.configure(withAVItems: [item])
    }
    
    /**
     Player View Controller initializator with array of AVPlayerItems.
     
     - parameter items: Array of AVPlayerItems.
     
     - returns: Instance of PandoraPlayer with set library.
     */
    public static func configure(withAVItems items: [AVPlayerItem]) -> PandoraPlayer {
        let playerVC = pandoraPlayerInstance()
        let songItems = items.flatMap({ return Song(withAVPlayerItem: $0) })
        playerVC.library = songItems
        playerVC.readyForPlay()
        return playerVC
    }

    /**
     Player View Controller initializator with MPMediaItem.
     
     - parameter item: MPMediaItem.
     
     - returns: Instance of PandoraPlayer with set library.
     */
    public static func configure(withMPMediaItem item: MPMediaItem) -> PandoraPlayer {
        return PandoraPlayer.configure(withMPMediaItems: [item])
    }
    
    /**
     Player View Controller initializator with array of MPMediaItems.
     
     - parameter items: Array of MPMediaItems.
     
     - returns: Instance of PandoraPlayer with set library.
     */
    public static func configure(withMPMediaItems items: [MPMediaItem]) -> PandoraPlayer {
        let playerVC = pandoraPlayerInstance()
        
        playerVC.designated = true
        
        let group = DispatchGroup()
        var outputItems = [Song]()
        
        for item in items {
            group.enter()
            Song.construct(withMPMediaItem: item, completion: { song in
                guard let song = song else {
                    group.leave()
                    return
                }
                
                outputItems.append(song)
                group.leave()
            })
        }
        
        playerVC.library = outputItems

        group.notify(queue: DispatchQueue.main) {
            assert(outputItems.count > 0)
            playerVC.library = outputItems
            playerVC.readyForPlay()
        }
        
        return playerVC
    }
    
    // MARK: Life Cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Public
    
    // MARK: Custom Initialization
    
    private func configure() {
        configureNavigationBar()
		configurePlayer()
        configurePlayerSongListView()
    }
	
    private func configurePlayerSongListView() {
		playerSongListView.delegate = self
        playerSongListView.configure(with: library)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        title = nowPlaying
    }
    
    private func configureBackgroundImage() {
        fadeImageView.isHidden = false
        blurredAlbumImageView.image = currentSong?.metadata?.artwork
    }
    
    // MARK: Player

    fileprivate func readyForPlay() {
        isReady = true
        originalPlayList = library
        if !designated { return }
        configurePlayer()
        self.sliderView.duration = currentSong?.metadata?.duration ?? 0
        if !player.isPlaying && playImmediately {
            reloadPlayer()
        }
    }
    
	fileprivate func rewindForward() {
		if currentSongIndex < library.count {
			currentSongIndex += 1
		}
		updatePlaybackStatus()
	}
    
    fileprivate func reloadPlayer() {
        guard let songItem = currentSong,
            let url = songItem.url else {
                return
        }
        
        let titleColor = songItem.colors
        
        updateForColors(titleColor)
        self.sliderView.duration = currentSong?.metadata?.duration ?? 0

        playerSongListView.setCurrentIndex(index: currentSongIndex, animated: true)
        
        player.audioFile = EZAudioFile(url: url)
        
        if player != nil && !player.isPlaying {
            player.play()
        }
    }
    
    fileprivate func updateForColors(_ colors: UIImageColors?) {
        guard let songItem = currentSong,
            let metadata = songItem.metadata else {
                return
        }
        
        if let color = colors?.primaryColor {
            rightChannelColor = color
        }
        
        if let color = colors?.secondaryColor {
            leftChannelColor = color
        }
        
        if let color = colors?.primaryColor {
            songNameColor = color
        }
        
        if let color = colors?.primaryColor {
            songAlbumColor = color
        }
        
        songNameLabel.changeAnimated(metadata.title ?? unknown, color: songNameColor)
        songAlbumLabel.changeAnimated(metadata.albumName ?? unknown, color: songAlbumColor)
        waveVisualizer.setColors(left: leftChannelColor, right: rightChannelColor)
    }
    
    fileprivate func updateSongLabels(metadata: MetaData, colors: UIImageColors?) {
        songNameLabel.changeAnimated(metadata.title ?? unknown, color: colors?.primaryColor ?? .green)
        songAlbumLabel.changeAnimated(metadata.albumName ?? unknown, color: .lightGray)
    }
	
	fileprivate var currentSong: Song? {
		guard self.currentSongIndex >= 0,
			currentSongIndex < self.library.count else {
			return nil
		}
		let song = library[self.currentSongIndex]
		return song
	}
	
	private func configurePlayer() {
        configurePlayerControls()
        configurePlayerTimeSlider()
		player = EZAudioPlayer()
		player.delegate = self
		updatePlaybackStatus()
        currentSongIndex = 0
    }

	fileprivate func updatePlaybackStatus() {
		self.controlsView.isPlaying = self.player.isPlaying
	}
    
    fileprivate func resetPlaylist() {
        resetPendingTasks()
        library = originalPlayList
        configurePlayer(for: originalPlayList)
    }
    
    fileprivate func shufflePlayList() {
        resetPendingTasks()
        library.shuffleInPlace()
        configurePlayer(for: library)
    }
    
    fileprivate func resetPendingTasks() {
        tasks.values.forEach{ $0.cancel() }
        tasks = [:]
    }
    
    fileprivate func syncColorsWithOriginalList() {
        for i in 0..<library.count {
            originalPlayList[i].colors = library[i].colors
        }
    }
    
    fileprivate func configurePlayer(for songs: [Song]) {
        playerSongListView.configure(with: songs)
        let deadlineTime = DispatchTime.now() + .microseconds(deadlineTimeOffset)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.currentSongIndex = -1
            self.currentSongIndex = 0
        }
    }
	
    fileprivate func togglePlay() {
        guard let audioFile = player.audioFile, audioFile.url == currentSong?.url else {
            reloadPlayer()
            return
        }
        
        let isPlaying = self.player.isPlaying
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        animatePlayToggling()
        self.controlsView.isPlaying = self.player.isPlaying
    }
    
    fileprivate func animatePlayToggling(duration: TimeInterval = animationInterval) {
        let viewToAnimate = UIImageView(frame: CGRect(x: 0, y: 0, width: animatableViewWidth, height: animatableViewHeight))
        let imageStr = self.player.isPlaying ? Images.pause: Images.play
        let image = UIImage(named: imageStr, in: Bundle(for: self.classForCoder), compatibleWith: nil)
        viewToAnimate.image = image
        viewToAnimate.alpha = 0
        viewToAnimate.center = view.center
        
        view.addSubview(viewToAnimate)
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: duration/2, delay: 0, options: .autoreverse, animations: {
            viewToAnimate.alpha = animatableViewAlpha
        })
        
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.transform = viewToAnimate.transform.scaledBy(x: animatableViewScale, y: animatableViewScale)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration - (duration * asyncOffset)) {
            viewToAnimate.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }
    }
    
	private func updateProgress(time: CMTime) {
		guard !beeingSeek else {
			beeingSeek = false
			return
		}
		
		let currentSong = library[currentSongIndex]
		
		guard let duration = currentSong.metadata?.duration, duration > 0 else {
			self.sliderView.progress = 0
			return
		}
		
		let seconds = Float(CMTimeGetSeconds(time))
		self.sliderView.duration = duration
		self.sliderView.progress = seconds / Float(duration)
	}
    
    private func configurePlayerControls() {
        controlsView.status = isReady ? .Ready: .Loading
        controlsView.delegate = self
    }
    
    private func configurePlayerTimeSlider() {
		sliderView.delegate = self
		sliderView.progress = defaultStartProgress
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
    
// MARK: Actions
    
    @IBAction func closeButtonDidClick(_ sender: Any) {
        player = nil
        onClose?(())
    }
    
    
// MARK: Helpers
    
    static func pandoraPlayerInstance() -> PandoraPlayer {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: Bundle(for: PandoraPlayer.classForCoder()))
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! PandoraPlayer
    }
}

// MARK: PlayerSongListDelegate

extension PandoraPlayer: PlayerSongListDelegate {
    func scrollBetween(left: CellActivityItem, right: CellActivityItem) {
        fadeImageView.isHidden = false
        
        let origin = left.index == currentSongIndex ? left: right
        let destination = left.index != currentSongIndex ? left: right
        
        blurredAlbumImageView.image = library[origin.index].metadata?.artwork
        fadeImageView.image = library[destination.index].metadata?.artwork
        
        blurredAlbumImageView.alpha = origin.activity
        fadeImageView.alpha = destination.activity
    }

	func currentSongDidChanged(index: Int) {
		self.currentSongIndex = index
    }
	
	func next() {
		updatePlaybackStatus()
	}
	
	func didTap() {
        togglePlay()
	}
	
	func previous() {
		updatePlaybackStatus()
	}
    
    func prefetchItems(at indices: [Int]) {
        for index in indices {
            guard library[index].colors == nil else { continue }
            guard tasks[index] == nil else { continue }
            var item: DispatchWorkItem!
            item = DispatchWorkItem(block: {
                guard !item.isCancelled else { return }
                guard let image = self.library[index].metadata?.artwork else { return }
                guard !item.isCancelled else { return }
				image.getColors(scaleDownSize: CGSize(width: scaleDownSizeWidth, height: scaleDownSizeHeight), completionHandler: { (colors) in
                    guard !item.isCancelled else { return }
					self.library[index].colors = colors
					DispatchQueue.main.async(execute: {
						if self.currentSongIndex == index {
                            self.updateForColors(colors)
						}
					})
                })
            })
            tasks[index] = item
            DispatchQueue.global(qos: .default).async(execute: item)
        }
    }
}

// MARK: PlayerControlsDelegate

extension PandoraPlayer: PlayerControlsDelegate {
	
	func onRepeat() {
        self.isRepeatModeOn = !self.isRepeatModeOn
	}
	
	func onRewindBack() {
		rewindBackward()
    }
	
	func onPlay() {
		togglePlay()
	}
	
	func onRewindForward() {
        rewindForward()
	}
	
	func onShuffle() {
        self.isShuffleModeOn = !self.isShuffleModeOn
	}
}

// MARK: PlayerSliderProtocol

extension PandoraPlayer: PlayerSliderProtocol {
	func onValueChanged(progress: Float, timePast: TimeInterval) {
		beeingSeek = true
		let frame = Int64(Float(player.audioFile.totalFrames) * progress)
		self.player.seek(toFrame: frame)
	}
}

// MARK: EZAudioPlayerDelegate

extension PandoraPlayer: EZAudioPlayerDelegate {
	public func audioPlayer(_ audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, in audioFile: EZAudioFile!) {
	
        DispatchQueue.main.async {[weak self] in
			self?.updatePlaybackStatus()
		}
		self.waveVisualizer?.updateWaveWithBuffer(buffer, withBufferSize: bufferSize, withNumberOfChannels: numberOfChannels)
	}
	
	public func audioPlayer(_ audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, in audioFile: EZAudioFile!) {
		guard !beeingSeek else {
			beeingSeek = false
			return
		}
		
		let duration = audioFile.duration
		let progress = audioFile.totalFrames > 0 ? Float(framePosition) / Float(audioFile.totalFrames): 0
		let isPlaying = audioPlayer.isPlaying
		DispatchQueue.main.async {[weak sliderView, weak controlsView] in
			controlsView?.isPlaying = isPlaying
			sliderView?.duration = duration
			sliderView?.progress = progress
		}
	}
	
	public func audioPlayer(_ audioPlayer: EZAudioPlayer!, reachedEndOf audioFile: EZAudioFile!) {
        guard !isRepeatModeOn else {
            DispatchQueue.main.async { [weak self] in
                self?.reloadPlayer()
            }
            return
        }
		guard self.currentSongIndex < library.count else {
			return
		}
		
		let newIndex = currentSongIndex < library.count - 1 ? currentSongIndex + 1: 0
		DispatchQueue.main.async { [weak self] in
			self?.currentSongIndex = newIndex
		}
	}
}
