import SwiftUI

struct CustomNavigationBarViewModifier: ViewModifier {
    let titleFontName: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                setupCurrentNavigationBar()
                // Добавляем задержку для надежности
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    setupCurrentNavigationBar()
                }
                // Несколько попыток с задержкой
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    setupCurrentNavigationBar()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    setupCurrentNavigationBar()
                }
            }
    }
    
    private func setupCurrentNavigationBar() {
        // Находим текущий navigationController
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        // Ищем navigationController в иерархии
        if let navigationController = findNavigationController(rootViewController) {
            configureNavigationBar(navigationController.navigationBar)
        }
    }
    
    private func findNavigationController(_ viewController: UIViewController) -> UINavigationController? {
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for child in viewController.children {
            if let found = findNavigationController(child) {
                return found
            }
        }
        
        return viewController.navigationController
    }
    
    private func configureNavigationBar(_ navigationBar: UINavigationBar) {
        print("configureNavigationBar")
        // Сохраняем текущие настройки и только меняем шрифт
        let standardAppearance = navigationBar.standardAppearance
        let scrollEdgeAppearance = navigationBar.scrollEdgeAppearance ?? UINavigationBarAppearance()
        
        if let titleFont = UIFont(name: titleFontName, size: 17) {
            // Обновляем только шрифт, сохраняя остальные атрибуты
            var standardTitleAttributes = standardAppearance.titleTextAttributes
            standardTitleAttributes[.font] = titleFont
            standardAppearance.titleTextAttributes = standardTitleAttributes

            var scrollTitleAttributes = scrollEdgeAppearance.titleTextAttributes
            scrollTitleAttributes[.font] = titleFont
            scrollEdgeAppearance.titleTextAttributes = scrollTitleAttributes
        }
        
        if let largeTitleFont = UIFont(name: titleFontName, size: 34) {
            var standardTitleAttributes = standardAppearance.largeTitleTextAttributes
            standardTitleAttributes[.font] = largeTitleFont
            standardAppearance.largeTitleTextAttributes = standardTitleAttributes
            
            var scrollTitleAttributes = scrollEdgeAppearance.largeTitleTextAttributes
            scrollTitleAttributes[.font] = largeTitleFont
            scrollEdgeAppearance.largeTitleTextAttributes = scrollTitleAttributes
        }
        
        if let subtitleFont = UIFont(name: titleFontName, size: 12) {
            // Обновляем только шрифт, сохраняя остальные атрибуты
            var standardTitleAttributes = standardAppearance.subtitleTextAttributes
            standardTitleAttributes[.font] = subtitleFont
            standardAppearance.subtitleTextAttributes = standardTitleAttributes

            var scrollTitleAttributes = scrollEdgeAppearance.subtitleTextAttributes
            scrollTitleAttributes[.font] = subtitleFont
            scrollEdgeAppearance.subtitleTextAttributes = scrollTitleAttributes
        }
        
        if let largeSubTitleFont = UIFont(name: titleFontName, size: 17) {
            var standardTitleAttributes = standardAppearance.largeSubtitleTextAttributes
            standardTitleAttributes[.font] = largeSubTitleFont
            standardAppearance.largeSubtitleTextAttributes = standardTitleAttributes
            
            var scrollTitleAttributes = scrollEdgeAppearance.largeSubtitleTextAttributes
            scrollTitleAttributes[.font] = largeSubTitleFont
            scrollEdgeAppearance.largeSubtitleTextAttributes = scrollTitleAttributes
        }
        
        // Восстанавливаем прозрачность
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.shadowColor = .clear
        scrollEdgeAppearance.shadowImage = UIImage()
        
        navigationBar.standardAppearance = standardAppearance
        navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
    }
}

extension View {
    func customNavBarFont(_ fontName: String) -> some View {
        self.modifier(CustomNavigationBarViewModifier(titleFontName: fontName))
    }
}

struct AppGlobalModifier: ViewModifier {
    let titleFontName: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                FontHelper.registerFontsIfNeeded()
                setupGlobalNavigationBar()
            }
    }
    
    private func setupGlobalNavigationBar() {
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.shadowColor = .clear
        
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.shadowColor = .clear
        
        if let titleFont = UIFont(name: titleFontName, size: 17) {
            // Обновляем только шрифт, сохраняя остальные атрибуты
            var standardTitleAttributes = standardAppearance.titleTextAttributes
            standardTitleAttributes[.font] = titleFont
            standardAppearance.titleTextAttributes = standardTitleAttributes

            var scrollTitleAttributes = scrollEdgeAppearance.titleTextAttributes
            scrollTitleAttributes[.font] = titleFont
            scrollEdgeAppearance.titleTextAttributes = scrollTitleAttributes
        }
        
        if let largeTitleFont = UIFont(name: titleFontName, size: 34) {
            var standardTitleAttributes = standardAppearance.largeTitleTextAttributes
            standardTitleAttributes[.font] = largeTitleFont
            standardAppearance.largeTitleTextAttributes = standardTitleAttributes
            
            var scrollTitleAttributes = scrollEdgeAppearance.largeTitleTextAttributes
            scrollTitleAttributes[.font] = largeTitleFont
            scrollEdgeAppearance.largeTitleTextAttributes = scrollTitleAttributes
        }
        
        if let subtitleFont = UIFont(name: titleFontName, size: 12) {
            // Обновляем только шрифт, сохраняя остальные атрибуты
            var standardTitleAttributes = standardAppearance.subtitleTextAttributes
            standardTitleAttributes[.font] = subtitleFont
            standardAppearance.subtitleTextAttributes = standardTitleAttributes

            var scrollTitleAttributes = scrollEdgeAppearance.subtitleTextAttributes
            scrollTitleAttributes[.font] = subtitleFont
            scrollEdgeAppearance.subtitleTextAttributes = scrollTitleAttributes
        }
        
        if let largeSubTitleFont = UIFont(name: titleFontName, size: 17) {
            var standardTitleAttributes = standardAppearance.largeSubtitleTextAttributes
            standardTitleAttributes[.font] = largeSubTitleFont
            standardAppearance.largeSubtitleTextAttributes = standardTitleAttributes
            
            var scrollTitleAttributes = scrollEdgeAppearance.largeSubtitleTextAttributes
            scrollTitleAttributes[.font] = largeSubTitleFont
            scrollEdgeAppearance.largeSubtitleTextAttributes = scrollTitleAttributes
        }
        
        UINavigationBar.appearance().standardAppearance = standardAppearance
        UINavigationBar.appearance().compactAppearance = standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = scrollEdgeAppearance
    }
}

extension View {
    func setupAppGlobalNavigationBar(_ fontName: String) -> some View {
        self.modifier(AppGlobalModifier(titleFontName: fontName))
    }
}
