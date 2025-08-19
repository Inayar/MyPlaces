import Foundation
import Combine

final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil

    private let repository: NotesRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(repository: NotesRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        isLoading = true
        repository.fetchNotes()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.alertMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] notes in
                self?.notes = notes
            }
            .store(in: &cancellables)
    }

    func addNote(text: String) {
        repository.create(text: text)
            .flatMap { [repository] _ in repository.fetchNotes() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion { self?.alertMessage = error.localizedDescription }
            } receiveValue: { [weak self] notes in
                self?.notes = notes
            }
            .store(in: &cancellables)
    }

    func updateNote(id: String, text: String) {
        repository.update(id: id, text: text)
            .flatMap { [repository] _ in repository.fetchNotes() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion { self?.alertMessage = error.localizedDescription }
            } receiveValue: { [weak self] notes in
                self?.notes = notes
            }
            .store(in: &cancellables)
    }

    func deleteNotes(at offsets: IndexSet) {
        let ids = offsets.compactMap { index in notes[safe: index]?.id }
        guard let id = ids.first else { return }
        repository.delete(id: id)
            .flatMap { [repository] _ in repository.fetchNotes() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion { self?.alertMessage = error.localizedDescription }
            } receiveValue: { [weak self] notes in
                self?.notes = notes
            }
            .store(in: &cancellables)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

