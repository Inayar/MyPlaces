import Foundation

struct Note: Identifiable, Codable, Equatable {
    let id: String
    var text: String
    var createdAt: Date
    var updatedAt: Date
}

extension JSONDecoder {
    static func notesDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            // Try multiple ISO8601 variants
            let iso8601WithFraction = ISO8601DateFormatter()
            iso8601WithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let iso8601NoFraction = ISO8601DateFormatter()
            iso8601NoFraction.formatOptions = [.withInternetDateTime]

            if let date = iso8601WithFraction.date(from: string) ?? iso8601NoFraction.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(string)")
        }
        return decoder
    }
}

extension JSONEncoder {
    static func notesEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

