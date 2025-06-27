//
//  NoteListView.swift
//  NoteApp
//
//  Created by Jenith KJ on 23/06/25.
//

import SwiftUI

struct NoteListView: View {
    @StateObject var viewModel: NoteViewModel
    @State private var showingAddNote = false
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    @State private var selectedNote: Note?
    @State private var showingEditNote = false


    var body: some View {
        NavigationView {
            VStack {
                TextField("Search notes...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                List {
                    ForEach(viewModel.notes, id: \.id) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title ?? "")
                                .font(.headline)
                            Text(note.content ?? "")
                                .lineLimit(2)
                                .foregroundColor(.secondary)
                            if let updatedAt = note.updatedAt {
                                Text("Edited: \(formatter.string(from: updatedAt))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onTapGesture {
                            selectedNote = note
                        }
                        .contextMenu {
                            Button("Edit") { selectedNote = note }
                            Button("Delete", role: .destructive) {
                                viewModel.deleteNote(note)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteNote(viewModel.notes[index])
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                Button(action: {
                    showingAddNote = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel)
            }
            .sheet(item: $selectedNote) { note in
                EditNoteView(viewModel: viewModel, note: note)
            }
        }
    }
}


struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: NoteViewModel

    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextEditor(text: $content)
                    .frame(height: 150)
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addNote(title: title, content: content)
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct EditNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: NoteViewModel

    @State var title: String
    @State var content: String
    var note: Note

    init(viewModel: NoteViewModel, note: Note) {
        self.viewModel = viewModel
        self.note = note
        _title = State(initialValue: note.title ?? "")
        _content = State(initialValue: note.content ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextEditor(text: $content)
                    .frame(height: 150)
            }
            .navigationTitle("Edit Note")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateNote(note, title: title, content: content)
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
