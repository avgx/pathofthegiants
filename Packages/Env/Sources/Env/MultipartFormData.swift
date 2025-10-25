import Foundation

struct MultipartFormData {
    private let boundary = "__MULTIPART_BOUNDARY__"
    private var data = Data()
    
    var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
    
    mutating func addString(_ value: String, forField field: String) {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(field)\"\r\n\r\n"
        fieldString += "\(value)\r\n"
        data.append(fieldString.data(using: .utf8)!)
    }
    
    mutating func addFile(named name: String, data fileData: Data, mimeType: String, forField field: String) {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(name)\"\r\n"
        fieldString += "Content-Type: \(mimeType)\r\n\r\n"
        data.append(fieldString.data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
    }
    
    mutating func makeBody() -> Data {
        let terminator = "--\(boundary)--"
        data.append(terminator.data(using: .utf8)!)
        return data
    }
}
