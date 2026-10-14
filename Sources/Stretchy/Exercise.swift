import Foundation

let isID = Locale.preferredLanguages.first?.hasPrefix("id") == true
func L(_ en: String, _ id: String) -> String { isID ? id : en }

struct Localized<T: Decodable>: Decodable {
    let en: T, id: T
    var value: T { isID ? id : en }
}

struct Exercise: Decodable {
    let name: Localized<String>
    let duration: Int
    let reps: Localized<String>
    let steps: Localized<[String]>
    let benefit: Localized<String>

    static let all: [Exercise] = {
        let url = Bundle.module.url(forResource: "exercises", withExtension: "json")!
        return try! JSONDecoder().decode([Exercise].self, from: Data(contentsOf: url))
    }()
}
