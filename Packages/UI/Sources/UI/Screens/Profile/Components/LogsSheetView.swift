import SwiftUI
import OSLog

@MainActor
struct LogsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logEntries: [OSLogEntryLog] = []
    @State private var isLoading = false
    @State private var refreshId = UUID()
    
    // Текущая выбранная категория для фильтрации
    @State private var selectedCategory: String? = nil
    // Все доступные категории (для picker)
    @State private var availableCategories: [String] = []

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Загрузка логов...")
                        .padding()
                } else if filteredLogs.isEmpty {
                    ContentUnavailableView.search(text: "Ничего нет")
                        .foregroundColor(.secondary)
                } else {
                    List(filteredLogs, id: \.date) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.composedMessage)
                                .font(.body)
                            
                            HStack {
                                Text(formattedDate(entry.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(entry.category)")
                                    .font(.caption)
                                    .foregroundColor(levelColor(entry.level))
                                    .italic()
                                
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            //.navigationTitle("Лог")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
//                ToolbarItem(placement: .primaryAction) {
//                    Button(action: { shareLogs() }) {
//                        Image(systemName: "square.and.arrow.up")
//                    }
//                    .disabled(filteredLogs.isEmpty)
//                }
                ToolbarItem(placement: .principal) {
                    // Плита фильтра
                    if !availableCategories.isEmpty {
                        Picker("Фильтр", selection: $selectedCategory) {
                            Text("Все логи").tag(nil as String?)
                            ForEach(availableCategories, id: \.self) { category in
                                Text(category).tag(category as String?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                isLoading = true
            }
            .task(id: refreshId) {
                isLoading = true
                await loadLogs()
                isLoading = false
            }
        }
        .navigationViewStyle(.stack)
    }

    // Отфильтрованные логи (с учётом selectedCategory)
    private var filteredLogs: [OSLogEntryLog] {
        if let category = selectedCategory {
            return logEntries.filter { $0.category == category }
        } else {
            return logEntries
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    private func levelColor(_ level: OSLogEntryLog.Level) -> Color {
        switch level {
        case .info: return .green
        case .debug: return .gray
        case .error: return .red
        case .fault: return .orange
        default: return .blue
        }
    }

    private func loadLogs() async {
        do {
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            let position = logStore.position(timeIntervalSinceLatestBoot: 0)
            
            let predicate = NSPredicate(
                format: "subsystem == %@",
                Bundle.main.bundleIdentifier!
            )
            
            let entries = try logStore.getEntries(at: position, matching: predicate)
            logEntries = entries
                .compactMap { $0 as? OSLogEntryLog }
                .sorted { $0.date > $1.date }
            
            // Собираем уникальные категории для фильтра
            availableCategories = Array(Set(logEntries.map(\.category)))
                .sorted()
        } catch {
            print("Ошибка загрузки логов: \(error)")
        }
    }

    private func shareLogs() {
        let text = filteredLogs.map { entry in
            """
            [\(formattedDate(entry.date))] [\(entry.level.rawValue)] \
            \(entry.subsystem)/\(entry.category): \(entry.composedMessage)
            """
        }.joined(separator: "\n")

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("logs.txt")

        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let activity = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activity, animated: true)
        } catch {
            print("Ошибка сохранения файла: \(error)")
        }
    }
}
