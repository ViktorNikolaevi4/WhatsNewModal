//  WhatsNewModalView.swift
//  Окно «Что нового» для macOS (SwiftUI)
//
//  ✅ Что делает:
//  • Показывает модальное окно как на скриншоте: иконка, заголовок, прокручиваемый текст.
//  • Читает содержимое из .md (Markdown) файла и умеет выводить картинки, указанные в Markdown.
//  • Кнопка «Continue» закрывает окно.
//  • (Новая фича) Автоматически берёт заголовок окна из первого заголовка уровня H1 (`# ...`) в Markdown
//    и удаляет эту строку из основного текста, чтобы не дублировать заголовок.
//
//  🔧 Что нужно подключить:
//  1) Добавьте Swift Package "MarkdownUI": File → Add Packages… → https://github.com/gonzalezreal/MarkdownUI
//  2) Положите в таргет файл WhatsNew.md (и изображения, если они используются) — чтобы оказались в Copy Bundle Resources.
//  3) В Markdown можно ссылаться на файлы в бандле так: ![](whatsnew-hero.png)
//     Мы задаём .markdownImageProvider(.networkImage()) // загружаем изображения по HTTPS) // загружаем изображения по HTTPS из Markdown, чтобы относительные пути работали.

import SwiftUI
import MarkdownUI

// MARK: - Модальное окно «Что нового»
struct WhatsNewModalView: View {
    @Environment(\.dismiss) private var dismiss
    var markdownFileName: String = "WhatsNew"
    var title: String = "Что нового"
    var preferH1Title: Bool = true
    var icon: NSImage? = NSApp.applicationIconImage

    // новый колбэк — для режима overlay
    var onContinue: (() -> Void)? = nil

    @State private var markdownText: String = ""
    @State private var runtimeTitle: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            if let icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(radius: 8)
                    .padding(.top, 8)
            }

            Text(runtimeTitle ?? title)
                .font(.title).bold()
                .padding(.top, 4)

            ScrollView {
                Markdown(markdownText)
                //    .markdownTheme(.gitHub)
                    .frame(maxWidth: 560, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(.clear)
            }
            .frame(maxHeight: 360)

            Button("Continue") {
                if let onContinue { onContinue() } else { dismiss() }
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(PrimaryCapsuleButtonStyle())
            .padding(.bottom, 4)
        }
        .padding(24)
        .frame(minWidth: 640, minHeight: 520)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(nsColor: .windowBackgroundColor)) // фон всего оверлея
        .accessibilityAddTraits(.isModal)
        .onAppear {
            let raw = MarkdownLoader.load(named: markdownFileName)
            if preferH1Title {
                let parts = MarkdownLoader.extractH1AndBody(from: raw)
                runtimeTitle = parts.title ?? runtimeTitle
                markdownText = parts.body
            } else {
                markdownText = raw
            }
        }
    }
}


// MARK: - Стиль основной капсульной кнопки
struct PrimaryCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(
                Capsule().fill(Color.accentColor.opacity(configuration.isPressed ? 0.75 : 1))
            )
            .foregroundColor(.white)
    }
}

// MARK: - Загрузчик текста из Markdown-файла + извлечение H1
enum MarkdownLoader {
    /// Возвращает содержимое .md-файла из бандла как String.
    /// Если файла нет или не удалось прочитать — возвращает человеко-понятное сообщение об ошибке.
    static func load(named: String) -> String {
        guard let url = Bundle.main.url(forResource: named, withExtension: "md") else {
            return "*(Файл `\(named).md` не найден в бандле приложения.)*"
        }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return "*(Не удалось прочитать `\(named).md`: \(error.localizedDescription))*"
        }
    }

    /// Достаём первый заголовок уровня H1 (строка, начинающаяся с `# `) и возвращаем
    ///  (title: String?, body: String) — где body это Markdown без найденного H1.
    ///  Примеры H1, которые поймаем: `# Новое в 3.13`, `#   Title` или `# Title ####`.
    static func extractH1AndBody(from markdown: String) -> (title: String?, body: String) {
        var title: String? = nil
        var bodyLines: [String] = []
        let lines = markdown.components(separatedBy: .newlines)

        var skippedHeading = false
        for line in lines {
            if !skippedHeading {
                // Убираем лидирующие пробелы и проверяем H1 (именно # + пробел)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("# ") {
                    // Снимаем ведущий `# ` и возможные завершающие #
                    var rawTitle = String(trimmed.dropFirst(2))
                    // Если в конце стоят # (стиль Markdown), удаляем их
                    while rawTitle.hasSuffix("#") {
                        rawTitle.removeLast()
                    }
                    title = rawTitle.trimmingCharacters(in: .whitespaces)
                    skippedHeading = true
                    continue // не добавляем строку H1 в body
                }
            }
            bodyLines.append(line)
        }
        return (title, bodyLines.joined(separator: "\n"))
    }
}

// MARK: - Пример интеграции в приложение
struct RootView: View {
    @State private var showWhatsNew = true   // показываем сразу для теста

    var body: some View {
        ZStack {
            // твой основной интерфейс
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .disabled(showWhatsNew)              // блокируем клики под модалкой
                .blur(radius: showWhatsNew ? 0 : 0)  // можно добавить блюр, если захочешь

            if showWhatsNew {
                WhatsNewModalView(
                    markdownFileName: "release-notes",
                    preferH1Title: true,
                    onContinue: { showWhatsNew = false }
                )
                .transition(.opacity) // аккуратное появление/скрытие
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showWhatsNew)
    }
}


// Заглушка основного контента
struct ContentView: View {
    var body: some View {
        Text("Main app UI goes here")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


/*
=============================
Пример файла WhatsNew.md (положите в таргет)
=============================
# Добро пожаловать в v1.2

Пишите о своём дне и добавляйте фото, видео, места и многое другое.

- ✨ Новый виджет серия привычек
- 🗓️ Планируйте время для записей
- 🔒 Синхронизация iCloud и блокировка журнала

![Обложка](whatsnew-hero.png)

Также можно добавить ссылку: [Подробнее](https://example.com/whats-new).
*/
