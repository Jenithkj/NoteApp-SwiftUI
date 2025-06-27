//
//  NoteViewModel.swift
//  NoteApp
//
//  Created by Jenith KJ on 23/06/25.
//

import Foundation
import Combine
import CoreData

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = ""

    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context
        setupSearchPipeline()
        fetchNotes()
    }

    private func setupSearchPipeline() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] search in
                self?.fetchNotes(filter: search)
            }
            .store(in: &cancellables)
    }

    func fetchNotes(filter: String = "") {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]

        if !filter.trimmingCharacters(in: .whitespaces).isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", filter, filter)
        }

        do {
            notes = try context.fetch(request)
        } catch {
            print("Fetch failed: \(error)")
        }
    }

    func addNote(title: String, content: String) {
        let newNote = Note(context: context)
        newNote.id = UUID()
        newNote.title = title
        newNote.content = content
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        saveContext()
    }

    func updateNote(_ note: Note, title: String, content: String) {
        note.title = title
        note.content = content
        note.updatedAt = Date()
        saveContext()
    }

    func deleteNote(_ note: Note) {
        context.delete(note)
        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
            fetchNotes(filter: searchText)
        } catch {
            print("Save failed: \(error)")
        }
    }
}

