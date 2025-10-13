import Foundation
import HealthKit

#if targetEnvironment(simulator)
@MainActor
public class HealthKitManager: ObservableObject {
    public static let shared = HealthKitManager()
    
    private init() { }
    
    public func authorizationStatusSharingDenied() async -> Bool {
        return true
    }
    
    public func requestAuthorization() async -> Bool {
        return false
    }
    
    public func saveMindfulSession(startDate: Date, endDate: Date) async throws -> Bool {
        return true
    }
}
#else
@MainActor
public class HealthKitManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    // Категория типа для осознанности
    var mindfulType: HKCategoryType? {
        return HKObjectType.categoryType(forIdentifier: .mindfulSession)
    }
    
    public static let shared = HealthKitManager()
    
    private init() { }
    
    /// В случае `.sharingDenied` нет смысла делать requestAuthorization.
    /// Уже запрещено и новый диалог не появится.
    public func authorizationStatusSharingDenied() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable(), let mindfulType = self.mindfulType else {
            return true
        }
        
        let status = healthStore.authorizationStatus(for: mindfulType)
        return status == .sharingDenied
    }
    
    // Запрос авторизации на чтение и запись данных осознанности
    public func requestAuthorization() async -> Bool {
        // Проверяем, доступен ли HealthKit на устройстве
        guard HKHealthStore.isHealthDataAvailable(), let mindfulType = self.mindfulType else {
            return false
        }
        
        // Запрашиваем разрешение на запись данных осознанности
        let typesToWrite: Set<HKSampleType> = [mindfulType]
        // Для чтения передаем пустой Set вместо nil
        let typesToRead: Set<HKObjectType> = []
        
        do {
            // Метод requestAuthorization с async/await не возвращает Bool
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            
            // Проверяем статус авторизации после запроса
            let status = healthStore.authorizationStatus(for: mindfulType)
            return status == .sharingAuthorized
        } catch {
            print("Ошибка запроса авторизации HealthKit: \(error.localizedDescription)")
            return false
        }
    }
    
    // Функция для сохранения сессии в HealthKit
    public func saveMindfulSession(startDate: Date, endDate: Date) async throws -> Bool {
        guard let mindfulType = self.mindfulType else {
            throw NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "MindfulSession type not available"])
        }
        
        // Создаем образец (sample) данных для осознанности
        let mindfulSample = HKCategorySample(type: mindfulType,
                                             value: HKCategoryValue.notApplicable.rawValue,
                                             start: startDate,
                                             end: endDate)
        
        // Сохраняем в HealthKit
        do {
            try await healthStore.save(mindfulSample)
            return true
        } catch {
            throw error
        }
    }
}
#endif
