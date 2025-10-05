import Testing
import Get
import Models
@testable import Api

@Test func exampleTrial() async throws {
    let http = HttpClient5(baseURL: Api.baseURL)
    
    let trial = try await http.send(Api.modulesTrial())
    
    print(trial.value)
    
    #expect(trial.value.data.trial == true)
}
