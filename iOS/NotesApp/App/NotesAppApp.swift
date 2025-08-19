import SwiftUI

@main
struct NotesAppApp: App {
    var body: some Scene {
        WindowGroup {
            let repository = NotesRepository(api: NotesAPI())
            let viewModel = NotesViewModel(repository: repository)
            NotesListView(viewModel: viewModel)
        }
    }
}

