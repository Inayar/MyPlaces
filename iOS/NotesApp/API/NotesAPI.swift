import Foundation
import Combine

struct CreateNoteRequest: Encodable {
    let text: String
}

struct UpdateNoteRequest: Encodable {
    let text: String
}

protocol NotesAPIProtocol {
    func fetchNotes() -> AnyPublisher<[Note], Error>
    func createNote(text: String) -> AnyPublisher<Note, Error>
    func updateNote(id: String, text: String) -> AnyPublisher<Note, Error>
    func deleteNote(id: String) -> AnyPublisher<Void, Error>
}

final class NotesAPI: NotesAPIProtocol {
    private let baseURL: URL
    private let urlSession: URLSession

    init(baseURL: URL = AppConfig.baseURL, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    func fetchNotes() -> AnyPublisher<[Note], Error> {
        let url = baseURL.appendingPathComponent("notes")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { try NotesAPI.handleURLResponse(data: $0.data, response: $0.response) }
            .decode(type: [Note].self, decoder: .notesDecoder())
            .eraseToAnyPublisher()
    }

    func createNote(text: String) -> AnyPublisher<Note, Error> {
        let url = baseURL.appendingPathComponent("notes")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder.notesEncoder().encode(CreateNoteRequest(text: text))
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { try NotesAPI.handleURLResponse(data: $0.data, response: $0.response) }
            .decode(type: Note.self, decoder: .notesDecoder())
            .eraseToAnyPublisher()
    }

    func updateNote(id: String, text: String) -> AnyPublisher<Note, Error> {
        let url = baseURL.appendingPathComponent("notes/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder.notesEncoder().encode(UpdateNoteRequest(text: text))
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { try NotesAPI.handleURLResponse(data: $0.data, response: $0.response) }
            .decode(type: Note.self, decoder: .notesDecoder())
            .eraseToAnyPublisher()
    }

    func deleteNote(id: String) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("notes/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response in
                _ = try NotesAPI.validate(response: response, data: data)
                return ()
            }
            .eraseToAnyPublisher()
    }

    private static func handleURLResponse(data: Data, response: URLResponse) throws -> Data {
        _ = try validate(response: response, data: data)
        return data
    }

    private static func validate(response: URLResponse, data: Data) throws -> HTTPURLResponse {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            // Attempt to surface error body for debugging
            let body = String(data: data, encoding: .utf8) ?? "<binary>"
            throw NSError(domain: "NotesAPI", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: body])
        }
        return http
    }
}

