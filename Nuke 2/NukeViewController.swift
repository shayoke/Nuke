import Cocoa
import ServiceManagement

class NukeViewController: NSViewController {
    @IBOutlet weak var repoTextField: NSTextField!
    @IBOutlet weak var derivedDataTextField: NSTextField!
    
    @IBOutlet weak var nukeButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var infoLabel: NSTextField!
    
    let nuker = Nuker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressIndicator.isDisplayedWhenStopped = false
        progressIndicator.stopAnimation(nil)
    }
    
    @IBAction func quit(sender: NSButton) {
        NSApplication.shared.terminate(sender)
    }
    
    @IBAction func selectRepoFolder(_ sender: NSButton) {
        if let fileURL = openFolderPicker() {
            nuker.repoURL = fileURL
            repoTextField.stringValue = fileURL.absoluteString.replacingOccurrences(of: "file://", with: "")
        }
    }
    
    @IBAction func selectDerivedDataFolder(_ sender: NSButton) {
        if let fileURL = openFolderPicker() {
            nuker.derivedDataURL = fileURL
            derivedDataTextField.stringValue = fileURL.absoluteString.replacingOccurrences(of: "file://", with: "")
        }
    }
    
    @IBAction func selectQuitXcode(_ sender: NSButton) {
        nuker.shouldQuitXcodeFirst = sender.state == .on
    }
    
    @IBAction func selectLaunchOnStartup(_ sender: NSButton) {
        // TODO: This looks a little more involved for now
    }
    
    @IBAction func nuke(_ sender: NSButton) {
        progressIndicator.startAnimation(self)
        do {
            try nuker.nuke()
        } catch {
            print(error)
        }
    }
    
    private func openFolderPicker() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        (NSApplication.shared.delegate as? AppDelegate)?.togglePopover(self)
        
        let response = panel.runModal()
        
        (NSApplication.shared.delegate as? AppDelegate)?.togglePopover(self)
        
        if response == .OK {
            return panel.urls.first
        }
        
        return nil
    }
    
    func updateInfo(_ string: String) {
        infoLabel.stringValue = string
    }
}

extension NukeViewController: NukerDelegate {
    func didFinish() {
        updateInfo("Nuke complete.")
        progressIndicator.stopAnimation(self)
    }
    
    func didStartQuittingXcode() {
        updateInfo("Quitting Xcode")
    }
    
    func didStartCleaningDerivedData() {
        updateInfo("Cleaning DerivedData")
    }
    
    func didStartCleaningDependencies() {
        updateInfo("Cleaning .dependencies")
    }
    
    func didStartCleaningCarthage() {
        updateInfo("Cleaning Carthage build files")
    }
}

// MARK: Storyboard instantiation
extension NukeViewController {
    static func freshController() -> NukeViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("NukeViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? NukeViewController else {
            fatalError("Can't find viewcontroller")
        }
        return viewcontroller
    }
}
