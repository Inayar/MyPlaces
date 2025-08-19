import SwiftUI

struct NotesListView: View {
    @StateObject private var viewModel: NotesViewModel

    @State private var isPresentingNew: Bool = false
    @State private var editingNote: Note? = nil

    init(viewModel: NotesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.notes.isEmpty {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.notes) { note in
                            Button {
                                editingNote = note
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(note.text.isEmpty ? "(empty)" : note.text)
                                        .lineLimit(2)
                                    Text(note.updatedAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: viewModel.deleteNotes)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresentingNew = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear { viewModel.load() }
            .alert(item: Binding(get: {
                viewModel.alertMessage.map { AlertMessage(message: $0) }
            }, set: { _ in viewModel.alertMessage = nil })) { item in
                Alert(title: Text("Error"), message: Text(item.message), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $isPresentingNew) {
                NoteEditorView(initialText: "") { text in
                    viewModel.addNote(text: text)
                    isPresentingNew = false
                } onCancel: {
                    isPresentingNew = false
                }
            }
            .sheet(item: $editingNote) { note in
                NoteEditorView(initialText: note.text) { text in
                    viewModel.updateNote(id: note.id, text: text)
                    editingNote = nil
                } onCancel: {
                    editingNote = nil
                }
            }
        }
    }
}

private struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct NotesListView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = NotesViewModel(repository: NotesRepository())
        NotesListView(viewModel: vm)
    }
}

