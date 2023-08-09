//
//  ContentView.swift
//  SubtitleAppend
//
//  Created by Shashankh on 09/08/23.
//

import SwiftUI
import AppKit


struct SubtitleTrack: Identifiable, Equatable, Hashable {
    let id = UUID()
    let index: Int
    let language: String
    let url: URL
    
    var displayName: String {
        // Convert language codes to human-readable names if needed
        // Example: "eng" -> "English"
        // You can implement your own logic here
        return language
    }
}

func executeFFmpegCommand(_ command: String) -> (output: String, error: String) {
    
    let message = "EXECUTING THE FOLLOWING Command \n " + command
    print(message)
    let task = Process()
    task.environment = ["PATH" : "/opt/homebrew/bin"]
    let outputPipe = Pipe()
    let errorPipe = Pipe()

    task.standardOutput = outputPipe
    task.standardError = outputPipe
    task.arguments = ["-c", command]
    task.launchPath = "/opt/homebrew/bin"
    

    if #available(macOS 10.13, *) {
       try? task.run()

     } else {
       task.launch()
     }
    task.waitUntilExit()
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
   
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

    let output = String(data: outputData, encoding: .utf8) ?? "No output"
    let error = String(data: errorData, encoding: .utf8) ?? "No error"
    
    print("This was the output " , outputData, output)
    print("This was the ERROR " , errorData, error)

    return (output, "error")
}





struct ContentView: View {
    @State private var selectedVideoURL: URL?
    @State private var selectedSubtitleURL : URL?
    @State private var selectedTargetLanguage : String = "English"
    @State private var availableSubtitleTracks: [SubtitleTrack] = []
    @State private var isPresentingVideoPicker = false
    @State private var ffmpegLogs: String = ""

    
    var body: some View {
        VStack {
           Text("Subtitle Append")
                .font(.title)
                .padding()
            
            if selectedVideoURL != nil {
            if let videoTitle = selectedVideoURL?.lastPathComponent {
                Text("Uploaded Video: \(videoTitle)")
                    .padding()
            }
        } else {
            Button(action: {
                openVideoPicker()
            }) {
                Text("Upload Video")
            }
            .padding()
        }
            
            

            
//            Picker("Select Subtitle", selection : $selectedSubtitleURL){
//                ForEach(availableSubtitleTracks, id: \.self) { subtitle in
//                                    Text(subtitle.displayName).tag(subtitle.url)
//                                }
//            }
//            .padding()
            
//            Picker("Select Target Language", selection: $selectedTargetLanguage){
//                Text("English").tag("en")
//                Text("French").tag("fr")
//            }
//            .pickerStyle(MenuPickerStyle())
//            .padding()
            
      
            
            Button(action: {
                if let videoURL = selectedVideoURL {
                    let outputSubtitlePath = "/Users/shashankh/Desktop/lmao"
                    let subtitleExtractionCommand = """
                        ffprobe -v error -select_streams s:0 -show_entries stream_tags=title -of default=nw=1:nk=1 "\(videoURL.path)"
                        """
                    
                    let (output, error) = executeFFmpegCommand(subtitleExtractionCommand)
                    ffmpegLogs = output + error
                }
            }) {
                Text("Translate and Add Subtitles")
            }
            .padding()

            ScrollView {
                Text(ffmpegLogs)
                    .padding()
            }
            .frame(maxHeight: 200)
            
        }
        .padding()
    }
    
   
    
    
    
    private func openVideoPicker() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a Video With Subtitles"
        openPanel.allowedFileTypes = ["mp4", "avi", "mov", "mkv"]
        openPanel . begin {
            response in
            if response == .OK, let videoURl = openPanel.url {
                selectedVideoURL = videoURl
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
