import Foundation

public actor MP3Downloader: NSObject, URLSessionDownloadDelegate {
    private var downloadTask: URLSessionDownloadTask?
    private var progressContinuation: AsyncStream<Double>.Continuation?
    private var completionContinuation: CheckedContinuation<(AsyncStream<Double>, URL), Error>?
    private var temporaryFileURL: URL?
    
    /// Папка для сохранения MP3 файлов в кэше
    private var cacheDirectory: URL {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let mp3Directory = cacheDir.appendingPathComponent("mp3", isDirectory: true)
        
        // Создаем папку если она не существует
        try? FileManager.default.createDirectory(at: mp3Directory, withIntermediateDirectories: true)
        return mp3Directory
    }
    
    /// Загружает MP3 файл по URL с отслеживанием прогресса
    /// - Parameters:
    ///   - url: URL MP3 файла
    /// - Returns: Async поток с прогрессом и финальный URL файла
    public func downloadMP3(from url: URL) async throws -> (AsyncStream<Double>, URL) {
        // Создаем поток для прогресса
        let progressStream = AsyncStream<Double> { continuation in
            self.progressContinuation = continuation
        }
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(AsyncStream<Double>, URL), Error>) in
            self.completionContinuation = continuation
            
            // Конфигурация сессии с делегатом
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(
                configuration: sessionConfiguration,
                delegate: self,
                delegateQueue: nil
            )
            
            // Создание задачи на загрузку
            downloadTask = session.downloadTask(with: url)
            downloadTask?.resume()
        }
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    /// Вызывается при прогрессе загрузки
    public nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        Task { await self.updateProgress(progress) }
    }
    
    /// Вызывается при завершении загрузки
    public nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        Task {
            // Сохраняем ссылку на временный файл сразу
            await self.setTemporaryFileURL(location)
            
            // Получаем оригинальное имя файла из URL
            let originalFileName = downloadTask.originalRequest?.url?.lastPathComponent ?? "audio_\(UUID().uuidString).mp3"
            await self.handleDownloadCompletion(fileName: originalFileName)
        }
    }
    
    /// Вызывается при ошибках загрузки
    public nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        Task {
            if let error = error {
                await self.handleDownloadError(error)
            } else {
                // Если ошибки нет, но временный файл не был обработан в didFinishDownloadingTo
                // это может случиться если файл очень маленький
                if let temporaryURL = await self.temporaryFileURL {
                    let originalFileName = task.originalRequest?.url?.lastPathComponent ?? "audio_\(UUID().uuidString).mp3"
                    await self.handleDownloadCompletion(fileName: originalFileName)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setTemporaryFileURL(_ url: URL) {
        self.temporaryFileURL = url
    }
    
    private func updateProgress(_ progress: Double) {
        progressContinuation?.yield(progress)
    }
    
    private func handleDownloadCompletion(fileName: String) {
        guard let temporaryURL = temporaryFileURL else {
            completionContinuation?.resume(throwing: NSError(domain: "MP3Downloader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Временный файл не найден"]))
            cleanup()
            return
        }
        
        do {
            // Проверяем что временный файл еще существует
            guard FileManager.default.fileExists(atPath: temporaryURL.path) else {
                completionContinuation?.resume(throwing: NSError(domain: "MP3Downloader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Временный файл был удален"]))
                cleanup()
                return
            }
            
            // Сохраняем файл в кэш директорию с оригинальным именем
            let destinationURL = cacheDirectory.appendingPathComponent(fileName)
            
            // Удаляем существующий файл, если есть
            try? FileManager.default.removeItem(at: destinationURL)
            
            // Копируем загруженный файл из временной локации в постоянную
            try FileManager.default.copyItem(at: temporaryURL, to: destinationURL)
            
            print("Файл сохранен: \(destinationURL.lastPathComponent)")
            
            // Создаем новый progress stream для возврата
            let progressStream = AsyncStream<Double> { [weak self] continuation in
                Task { [weak self] in
                    await self?.setProgressContinuation(continuation)
                }
            }
            
            completionContinuation?.resume(returning: (progressStream, destinationURL))
            cleanup()
            
        } catch {
            completionContinuation?.resume(throwing: error)
            cleanup()
        }
    }
    
    private func setProgressContinuation(_ continuation: AsyncStream<Double>.Continuation) {
        self.progressContinuation = continuation
    }
    
    private func handleDownloadError(_ error: Error) {
        completionContinuation?.resume(throwing: error)
        cleanup()
    }
    
    private func cleanup() {
        progressContinuation?.finish()
        progressContinuation = nil
        completionContinuation = nil
        temporaryFileURL = nil
    }
    
    // MARK: - Public Methods
    
    /// Проверяет существует ли файл уже в кэше
    public func fileExistsInCache(for url: URL) -> URL? {
        let fileName = url.lastPathComponent
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    public func fileExistsInCache(fileName: String) -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    /// Получает локальный URL для файла (не проверяет существование)
    public func localURL(for url: URL) -> URL {
        let fileName = url.lastPathComponent
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    /// Очищает кэш MP3 файлов
    public func clearCache() throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
        
        print("Кэш MP3 файлов очищен")
    }
    
    /// Получает размер кэша
    public func cacheSize() throws -> Int64 {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        
        return contents.reduce(0) { total, fileURL in
            do {
                let resources = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                return total + Int64(resources.fileSize ?? 0)
            } catch {
                return total
            }
        }
    }
    
    public func cacheDetails() throws -> [URL: Int64] {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        
        return contents.reduce(into: [:]) { res, fileURL in
            let resources = try? fileURL.resourceValues(forKeys: [.fileSizeKey])
            res[fileURL] = Int64(resources?.fileSize ?? 0)
        }
    }
    
    /// Приостановить загрузку
    func pauseDownload() {
        downloadTask?.suspend()
    }
    
    /// Возобновить загрузку
    func resumeDownload() {
        downloadTask?.resume()
    }
    
    /// Отменить загрузку
    public func cancelDownload() {
        downloadTask?.cancel()
        completionContinuation?.resume(throwing: CancellationError())
        cleanup()
    }
}

// MARK: - Convenience Extension
extension MP3Downloader {
    /// Упрощенный метод загрузки без отслеживания прогресса
    public func downloadMP3(from url: URL) async throws -> URL {
        let (progressStream, fileURL) = try await downloadMP3(from: url)
        
        // Потребляем progress stream чтобы он не висел
        Task {
            for await _ in progressStream { }
        }
        
        return fileURL
    }
    
    /// Умная загрузка - возвращает локальный файл если он уже есть в кэше
    public func downloadMP3IfNeeded(from url: URL) async throws -> URL {
        // Сначала проверяем есть ли файл в кэше
        if let cachedFileURL = fileExistsInCache(for: url) {
            print("Файл уже в кэше: \(cachedFileURL.lastPathComponent)")
            return cachedFileURL
        }
        
        // Если нет - загружаем
        print("Загружаем файл: \(url.lastPathComponent)")
        return try await downloadMP3(from: url)
    }
    
}

// Альтернативная упрощенная версия без прогресса
extension MP3Downloader {
    public func simpleDownloadMP3(from url: URL) async throws -> URL {
        if let cached = fileExistsInCache(for: url) {
            print("Найден в кэше")
            return cached
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let fileName = url.lastPathComponent
        let destinationURL = cacheDirectory.appendingPathComponent(fileName)
        try data.write(to: destinationURL)
        return destinationURL
    }
}

// MARK: - Пример использования с ButtonKit

/*
 Пример использования в SwiftUI View:
 
 import ButtonKit
 import SwiftUI
 
 struct DownloadView: View {
     @State private var downloader = MP3Downloader()
     @State private var downloadTask: Task<Void, Never>?
     @State private var progress: Double = 0
     @State private var isDownloading = false
     
     let audioURL = URL(string: "https://pathofthegiants.ru/Files/e2cf490b9d4f465fa6ba38d678b8ac25.mp3")!
     
     var body: some View {
         VStack {
             AsyncButton {
                 await downloadAudio()
             } label: { state in
                 switch state {
                 case .idle:
                     Text("Скачать MP3")
                 case .loading:
                     HStack {
                         ProgressView()
                             .progressViewStyle(CircularProgressViewStyle())
                         Text("\(Int(progress * 100))%")
                     }
                 case .success:
                     Image(systemName: "checkmark.circle.fill")
                         .foregroundColor(.green)
                 case .failure:
                     Image(systemName: "xmark.circle.fill")
                         .foregroundColor(.red)
                 }
             }
             
             if isDownloading {
                 ProgressView(value: progress)
                     .progressViewStyle(LinearProgressViewStyle())
                     .padding()
             }
             
             Button("Очистить кэш") {
                 Task {
                     try? await downloader.clearCache()
                 }
             }
         }
         .padding()
     }
     
     private func downloadAudio() async {
         isDownloading = true
         progress = 0
         
         do {
             let (progressStream, fileURL) = try await downloader.downloadMP3(from: audioURL)
             
             // Отслеживаем прогресс
             for await newProgress in progressStream {
                 progress = newProgress
                 print("Прогресс загрузки: \(Int(newProgress * 100))%")
             }
             
             print("Файл сохранен: \(fileURL.lastPathComponent)")
             isDownloading = false
             
             // Теперь можно передать fileURL в ваш AudioPlayer
             // audioPlayer.play(url: fileURL)
             
         } catch {
             if error is CancellationError {
                 print("Загрузка отменена")
             } else {
                 print("Ошибка загрузки: \(error.localizedDescription)")
             }
             isDownloading = false
         }
     }
 }
 
 // Или упрощенная версия с автоматическим использованием кэша:
 
 struct SmartDownloadView: View {
     @State private var downloader = MP3Downloader()
     
     var body: some View {
         AsyncButton {
             await downloadAudio()
         } label: { state in
             switch state {
             case .idle:
                 Text("Скачать MP3")
             case .loading:
                 ProgressView()
                     .progressViewStyle(CircularProgressViewStyle())
             case .success:
                 Image(systemName: "checkmark.circle.fill")
             case .failure:
                 Image(systemName: "xmark.circle.fill")
             }
         }
     }
     
     private func downloadAudio() async {
         let audioURL = URL(string: "https://pathofthegiants.ru/Files/e2cf490b9d4f465fa6ba38d678b8ac25.mp3")!
         
         do {
             let fileURL = try await downloader.downloadMP3IfNeeded(from: audioURL)
             print("Файл готов: \(fileURL.lastPathComponent)")
             // Используем fileURL для воспроизведения
         } catch {
             print("Ошибка: \(error.localizedDescription)")
         }
     }
 }
 */
