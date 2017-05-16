//
//  ViewController.swift
//  phpRunner
//
//  Created by Tony Johnston VC on 5/11/17.
//  Copyright © 2017 Clipper Vacations. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate {
    
    //Controller Outlets
    @IBOutlet var runButton: NSButton!
    @IBOutlet var inputText: NSTextView!
    @IBOutlet var outputText: NSTextView!
    @IBOutlet var spinner: NSProgressIndicator!
    
    dynamic var isRunning = false
    var macaw: Macaw?
    var inputPipe:Pipe!
    var outputPipe:Pipe!
    var buildTask:Process!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func startTask(_ sender: Any) {
        outputText.string = ""
        
        //guard let scriptLocation = Bundle.main.path(forResource: "phpinfo",ofType: "php") else {
        //    return
        //}
        var arguments:[String] = []
        arguments.append("-r")
        arguments.append(inputText.string!)
        
        runButton.isEnabled = false
        
        runScript(arguments)
    }
    
    func runScript(_ arguments:[String]) {
        
        //1. Enables the Stop button, since it’s bound to the TasksViewController‘s isRunning property via Cocoa Bindings. You want this to happen on the main thread.
        isRunning = true
        
        //2. Creates a DispatchQueue to run the heavy lifting on a background thread.
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        //3. Uses async on the DispatchQueue The application will continue to process things like button clicks on the main thread, but the NSTask will run on the background thread until it is complete.
        taskQueue.async {
            
            //1. Gets the path to a script named BuildScript.command, included in application’s bundle.
            // guard let path = Bundle.main.path(forResource: "php",ofType:nil) else {
            //print("Unable to locate BuildScript.command")
            //return
            //}
            
            let path:String = "/usr/bin/php"
            
            //2. Creates a new Process object and assigns it to the TasksViewController‘s buildTask property. The launchPath property is the path to the executable you want to run. Assigns the BuildScript.command‘s path to the Process‘s launchPath, then assigns the arguments that were passed to runScript:to Process‘s arguments property. Process will pass the arguments to the executable, as though you had typed them into terminal.
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            
            print(arguments)
            
            //3. Process has a terminationHandler property that contains a block which is executed when the task is finished. This updates the UI to reflect that finished status as you did before.
            self.buildTask.terminationHandler = {
                
                task in
                DispatchQueue.main.async(execute: {
                    self.runButton.isEnabled = true
                    self.spinner.stopAnimation(self)
                    self.isRunning = false
                })
                
            }
            
            // Output Handling
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            
            //4. In order to run the task and execute the script, calls launch on the Process object. There are also methods to terminate, interrupt, suspend or resume an Process. First,  pass the arguments through an NSPipe and use stdin to get the argument to properly go into terminal
            self.buildTask.standardInput = self.inputPipe
            self.buildTask.launch()
            
            //5. Calls waitUntilExit, which tells the Process object to block any further activity on the current thread until the task is complete. Remember, this code is running on a background thread. Your UI, which is running on the main thread, will still respond to user input.
            self.buildTask.waitUntilExit()
            
        }
        
    }
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        
        //1. Creates an Pipe and attaches it to buildTask‘s standard output. Pipe is a class representing the same kind of pipe that you created in Terminal. Anything that is written to buildTask‘s stdout will be provided to this Pipe object.
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        //2. Pipe has two properties: fileHandleForReading and fileHandleForWriting. These are NSFileHandle objects. Covering NSFileHandle is beyond the scope of this tutorial, but the fileHandleForReading is used to read the data in the pipe. You call waitForDataInBackgroundAndNotify on it to use a separate background thread to check for available data.
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //3. Whenever data is available, waitForDataInBackgroundAndNotify notifies you by calling the block of code you register with NSNotificationCenter to handle NSFileHandleDataAvailableNotification.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            //4. Inside your notification handler, gets the data as an NSData object and converts it to a string.
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            //5. On the main thread, appends the string from the previous step to the end of the text in outputText and scrolls the text area so that the user can see the latest output as it arrives. This must be on the main thread, like all UI and user interaction.
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string ?? ""
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                
                let range = NSRange(location:nextOutput.characters.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                
            })
            
            //6. Finally, repeats the call to wait for data in the background. This creates a loop that will continually wait for available data, process that data, wait for available data, and so on.
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        
    }

    func initialize() {
        macaw = Macaw(inputText)
        var text = "function test() {\n$name = \"Taylor Swift\" // Tested\n}"
        if let url = Bundle.main.url(forResource: "phpinfo", withExtension: "php") {
            text = try! String(contentsOf: url)
        }
        inputText.string = text
        inputText.font = NSFont(name: "Menlo", size: 14)
        inputText.isAutomaticQuoteSubstitutionEnabled  = false
        inputText.isAutomaticDashSubstitutionEnabled   = false
        inputText.isAutomaticSpellingCorrectionEnabled = false
        inputText.isAutomaticLinkDetectionEnabled      = false
        inputText.textStorage?.font = NSFont(name: "Menlo", size: 14)
        inputText.textStorage?.delegate = self
        macaw?.colorize() // All
    }
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        macaw?.colorize(editedRange)
    }


}

