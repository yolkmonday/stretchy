import AppKit

let isID = Locale.preferredLanguages.first?.hasPrefix("id") == true
func L(_ en: String, _ id: String) -> String { isID ? id : en }

struct Localized<T: Decodable>: Decodable {
    let en: T, id: T
    var value: T { isID ? id : en }
}

struct Exercise: Decodable {
    /// One timed cue: show `pose` (0 = start, 1 = end) for `secs` seconds.
    struct Beat: Decodable {
        let pose: Int
        let secs: Int
        let cue: Localized<String>
    }

    struct Move: Decodable {
        let times: Int
        let beats: [Beat]
    }

    let name: Localized<String>
    let reps: Localized<String>
    let steps: Localized<[String]>
    let benefit: Localized<String>
    let image: String
    let move: Move
    /// Run the whole move again on the other side; the illustration is mirrored.
    var sides: Bool? = nil

    var sideCount: Int { sides == true ? 2 : 1 }

    /// Every beat in order, with its side (0/1) and rep number (1-based).
    var plan: [(side: Int, rep: Int, beat: Beat)] {
        (0..<sideCount).flatMap { side in
            (1...move.times).flatMap { rep in move.beats.map { (side, rep, $0) } }
        }
    }

    var duration: Int { plan.reduce(0) { $0 + $1.beat.secs } }

    /// Start pose ("-a") and end pose ("-b"), aligned on the same canvas.
    var frames: [NSImage] {
        ["a", "b"].compactMap {
            Bundle.module.url(forResource: "\(image)-\($0)", withExtension: "jpg").flatMap(NSImage.init(contentsOf:))
        }
    }

    static let all: [Exercise] = {
        let url = Bundle.module.url(forResource: "exercises", withExtension: "json")!
        return try! JSONDecoder().decode([Exercise].self, from: Data(contentsOf: url))
    }()
}
