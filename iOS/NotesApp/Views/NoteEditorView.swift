import SwiftUI

struct NoteEditorView: View {
    @State private var text: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    init(initialText: String, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        _text = State(initialValue: initialText)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextEditor(text: $text)
                    .padding()
            }
            .navigationTitle("Edit Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(text.trimmingCharacters(in: .whitespacesAndNewlines)) }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct NoteEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NoteEditorView(initialText: "Hello") { _ in } onCancel: {}
    }
}

