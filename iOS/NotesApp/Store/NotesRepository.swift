import Foundation
import Combine

protocol NotesRepositoryProtocol {
    func fetchNotes() -> AnyPublisher<[Note], Error>
    func create(text: String) -> AnyPublisher<Note, Error>
    func update(id: String, text: String) -> AnyPublisher<Note, Error>
    func delete(id: String) -> AnyPublisher<Void, Error>
}

final class NotesRepository: NotesRepositoryProtocol {
    private let api: NotesAPIProtocol

    init(api: NotesAPIProtocol = NotesAPI()) {
        self.api = api
    }

    func fetchNotes() -> AnyPublisher<[Note], Error> { api.fetchNotes() }
    func create(text: String) -> AnyPublisher<Note, Error> { api.createNote(text: text) }
    func update(id: String, text: String) -> AnyPublisher<Note, Error> { api.updateNote(id: id, text: text) }
    func delete(id: String) -> AnyPublisher<Void, Error> { api.deleteNote(id: id) }
}

