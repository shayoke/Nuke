//
//  Nuker.swift
//  Nuke 2
//
//  Created by Shayoke Mukherjee on 08/04/2020.
//  Copyright © 2020 Shayoke Mukherjee. All rights reserved.
//

import Foundation

enum NukerError: Error {
    case badURLs
}

protocol NukerDelegate: class {
    func didStartQuittingXcode()
    func didStartCleaningDerivedData()
    func didStartCleaningDependencies()
    func didStartCleaningCarthage()
    func didFinish()
}

class Nuker {
    var shouldQuitXcodeFirst = false
    var repoURL: URL?
    var derivedDataURL: URL?
    weak var delegate: NukerDelegate?
    let fileManager = FileManager.default
    
    func nuke() throws {
        guard let ddURL = derivedDataURL, let rURL = repoURL else {
            throw NukerError.badURLs
        }
        
        // send update: updated xcode
        if shouldQuitXcodeFirst {
            quitXcode()
        }
        
        cleanDerivedData(derivedDataLocation: ddURL)
        cleanRepo(location: rURL)
        
        delegate?.didFinish()
    }
    
    func quitXcode() {
        let script = NSAppleScript(source: "tell app \"Xcode\" to quit")
        
        var errors: NSDictionary?
        script?.executeAndReturnError(&errors)
    }
    
    func cleanDerivedData(derivedDataLocation: URL) {
        delegate?.didStartCleaningDerivedData()
        deleteFiles(at: derivedDataLocation)
    }
    
    func cleanRepo(location: URL) {
        delegate?.didStartCleaningDependencies()
        delegate?.didStartCleaningCarthage()
    }
    
    func deleteFiles(at location: URL) {
        let enumerator = fileManager.enumerator(at: location, includingPropertiesForKeys: nil, options: [], errorHandler: nil)
        
        while let fileUrl = enumerator?.nextObject() {
            do {
                try fileManager.removeItem(at: fileUrl as! URL)
            } catch {
                print(error)
            }
        }
    }
    
    func executeCommand(command: String, args: [String]) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        
//        task.launchPath = command
        task.arguments = args

        let pipe = Pipe()
        task.standardOutput = pipe
//        task.launch()
        
        do {
            try task.run()
        } catch  {
            print(error)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }

}
