import Testing
import UIKit
import AVFoundation
import Get
import Models
@testable import Api

@Test func exampleTrial() async throws {
    let http = HttpClient5(baseURL: Api.baseURL)
    
    let trial = try await http.send(Api.modulesTrial())
    
    print(trial.value)
    
    #expect(trial.value.data.trial == true)
    
    #expect(trial.value.data.image == "a5561d053c96469d85fff3e8772a56ae.png")
    #expect(trial.value.data.practicesIDS.contains(20))
    let p20 = trial.value.data.practices.first(where: { $0.id == 20 })!
    #expect(p20.image == "0845ca2ddcc0483fafd1e3d77ca0a028.png")
    #expect(p20.audio == "b394c9c23855444483e10a4a73c3cb47.mp3")
    
    let p20imageData = try await http.send(Api.file(name: p20.image))
    let p20image = UIImage(data: p20imageData.data)
    #expect(p20image != nil)
    #expect(p20image!.size.height > 0)
    
    let p20audioData = try await http.send(Api.file(name: p20.audio))
    let p20audioPlayer = try AVAudioPlayer(data: p20audioData.data)
    #expect(p20audioPlayer.duration == 296)
}
