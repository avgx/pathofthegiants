import Foundation

extension URLCache {
    public static let imageCache: URLCache = CustomURLCache(memoryCapacity: 100*1024*1024, diskCapacity: 100*1024*1024, diskPath: nil)
}

class CustomURLCache: URLCache, Loggable, @unchecked Sendable {
    
    // Преобразование запроса
    private func normalizeRequest(_ request: URLRequest) -> URLRequest {
        var mutableRequest = URLRequest(url: request.url!)
        mutableRequest.httpMethod = request.httpMethod
        mutableRequest.allHTTPHeaderFields = [:]
        return mutableRequest
    }

    // Инициализация с заданными параметрами памяти и диска
    override init(memoryCapacity: Int, diskCapacity: Int, diskPath path: String?) {
        super.init(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: nil)
    }
    
    // Метод для получения закэшированного ответа
    override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        let normalizedRequest = normalizeRequest(request)
        // Здесь можно добавить собственную логику обработки
        // Например, логирование или проверку условий
        let cachedResponse = super.cachedResponse(for: normalizedRequest)
        
        // Пример логирования
        if let response = cachedResponse {
            logger.info("Получен закэшированный ответ для \(request.url?.absoluteString ?? "")")
        } else {
            logger.info("Кэшированный ответ не найден для \(request.url?.absoluteString ?? "")")
        }
        
        return cachedResponse
    }
    
    // Метод для сохранения закэшированного ответа
    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        let normalizedRequest = normalizeRequest(request)
        // Можно добавить проверку перед сохранением
        guard shouldStore(cachedResponse, for: normalizedRequest) else {
            return
        }
        
        logger.info("Сохраняем ответ для \(normalizedRequest.url?.absoluteString ?? "") currentMemoryUsage:\(super.currentMemoryUsage)")
        
        // Сохраняем ответ
        super.storeCachedResponse(cachedResponse, for: normalizedRequest)
        
        logger.info("Сохранен ответ для \(normalizedRequest.url?.absoluteString ?? "") currentMemoryUsage:\(super.currentMemoryUsage)")
    }
    
    // Метод для удаления закэшированного ответа
    override func removeCachedResponse(for request: URLRequest) {
        let normalizedRequest = normalizeRequest(request)
        // Добавляем дополнительную логику при удалении
        // К сожалению оно работает как-то странно и не удаляет 
        logger.info("Удаление кэша для \(normalizedRequest.url?.absoluteString ?? "")")
        super.removeCachedResponse(for: normalizedRequest)
    }
    
    // Пример метода для проверки условий хранения
    private func shouldStore(_ cachedResponse: CachedURLResponse, for request: URLRequest) -> Bool {
        
        // Здесь можно добавить логику фильтрации
        // Например, проверять размер ответа или другие параметры
        //return true
        let res = request.httpMethod == "GET" && request.url?.absoluteString.contains("?_=") == false
        logger.info("А нужно ли сохранить ответ на: \(request.httpMethod ?? "") \(request) |\(res)")
        return res
    }
    
    // Функция для очистки кэша
    func clearCache(for url: URL) {
        var request = URLRequest(url: url)
        // Устанавливаем политику, игнорирующую кэш
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.removeCachedResponse(for: request)
        logger.info("Удаление кэша для: \(request.httpMethod ?? "") \(request)")
    }
}
