import AppKit
import SwiftUI

// Renders the GitHub profile banner and the LinkedIn background (light and dark):
// the profile text written as Swift code in an Xcode-style editor window.
// Usage: DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift assets/RenderBanner.swift assets

enum Token {
    case plain(String)
    case keyword(String)
    case declaration(String)
    case type(String)
    case string(String)
    case number(String)
}

/// One line of code per array: the profile as a Swift type.
let code: [[Token]] = [
    [.keyword("struct"), .plain(" "), .declaration("HelioMartin"), .plain(": "), .type("Developer"), .plain(" {")],
    [.plain("    "), .keyword("let"), .plain(" "), .declaration("name"), .plain(" = "), .string("\"Helio Martín\"")],
    [.plain("    "), .keyword("let"), .plain(" "), .declaration("role"), .plain(" = "), .string("\"iOS Engineer · Team Lead\"")],
    [.plain("    "), .keyword("let"), .plain(" "), .declaration("building"), .plain(" = "), .string("\"Native iOS apps\"")],
    [.plain("    "), .keyword("let"), .plain(" "), .declaration("since"), .plain(" = "), .number("2013")],
    [.plain("}")],
]

/// Xcode's Default (Light) and Default (Dark) editor themes.
struct Theme {
    let page: Color
    let editor: Color
    let chrome: Color
    let border: Color
    let lineNumber: Color
    let title: Color
    let plain: Color
    let keyword: Color
    let declaration: Color
    let type: Color
    let string: Color
    let number: Color
    let caret: Color

    static let light = Theme(
        page: .white, editor: .white, chrome: Color(hex: 0xF5F5F7), border: Color(hex: 0xD8DEE4),
        lineNumber: Color(hex: 0xA6A6A6), title: Color(hex: 0x6E6E73),
        plain: Color(hex: 0x262626), keyword: Color(hex: 0x9B2393), declaration: Color(hex: 0x0F68A0),
        type: Color(hex: 0x3900A0), string: Color(hex: 0xC41A16), number: Color(hex: 0x1C00CF), caret: Color(hex: 0x0F68A0)
    )
    static let dark = Theme(
        page: Color(hex: 0x0D1117), editor: Color(hex: 0x1F1F24), chrome: Color(hex: 0x2A2A30), border: Color(hex: 0x3D444D),
        lineNumber: Color(hex: 0x747478), title: Color(hex: 0x98989D),
        plain: Color(hex: 0xDFDFE0), keyword: Color(hex: 0xFC5FA3), declaration: Color(hex: 0x5DD8FF),
        type: Color(hex: 0xD0A8FF), string: Color(hex: 0xFC6A5D), number: Color(hex: 0xD0BF69), caret: Color(hex: 0x5DD8FF)
    )
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

let fontSize: CGFloat = 27

func attributed(_ line: [Token], theme: Theme) -> AttributedString {
    var result = AttributedString()
    for token in line {
        var run: AttributedString
        switch token {
        case .plain(let text):
            run = AttributedString(text)
            run.foregroundColor = theme.plain
        case .keyword(let text):
            run = AttributedString(text)
            run.foregroundColor = theme.keyword
            run.font = .system(size: fontSize, weight: .bold, design: .monospaced)
        case .declaration(let text):
            run = AttributedString(text)
            run.foregroundColor = theme.declaration
        case .type(let text):
            run = AttributedString(text)
            run.foregroundColor = theme.type
        case .string(let text):
            run = AttributedString(text)
            run.foregroundColor = theme.string
        case .number(let text):
            run = AttributedString(text)
            run.foregroundColor = theme.number
        }
        result += run
    }
    return result
}

struct EditorWindow: View {
    let theme: Theme
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach([0xFF5F57, 0xFEBC2E, 0x28C840], id: \.self) { hex in
                    Circle().fill(Color(hex: UInt32(hex))).frame(width: 13, height: 13)
                }
                Spacer()
            }
            .overlay {
                Text("HelioMartin.swift")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(theme.title)
            }
            .padding(.horizontal, 16)
            .frame(height: 42)
            .background(theme.chrome)
            .overlay(alignment: .bottom) { Rectangle().fill(theme.border).frame(height: 1) }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(code.enumerated()), id: \.offset) { index, line in
                    HStack(alignment: .firstTextBaseline, spacing: 24) {
                        Text("\(index + 1)")
                            .foregroundStyle(theme.lineNumber)
                            .frame(width: 22, alignment: .trailing)
                        HStack(spacing: 2) {
                            Text(attributed(line, theme: theme))
                            if index == code.count - 2 {
                                Rectangle().fill(theme.caret).frame(width: 3, height: fontSize + 4)
                            }
                        }
                    }
                }
            }
            .font(.system(size: fontSize, weight: .regular, design: .monospaced))
            .padding(.vertical, 26)
            .padding(.leading, 20)
            .padding(.trailing, 48)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.editor)
        }
        .fixedSize()
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(theme.border, lineWidth: 1) }
    }
}

struct Banner: View {
    let theme: Theme
    var body: some View {
        EditorWindow(theme: theme)
            .frame(width: 1200, height: 420)
            .background(theme.page)
    }
}

/// LinkedIn's 1584 × 396 background. The photo covers the lower left, so the
/// editor is scaled down and sits a little right of center.
struct LinkedInBanner: View {
    let theme: Theme
    var body: some View {
        EditorWindow(theme: theme)
            .scaleEffect(0.8)
            .offset(x: 80)
            .frame(width: 1584, height: 396)
            .background(theme.page)
    }
}

@MainActor
func render(_ view: some View, to url: URL) throws {
    let renderer = ImageRenderer(content: view)
    renderer.scale = 2
    guard let image = renderer.cgImage else { throw CocoaError(.fileWriteUnknown) }
    try NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])?.write(to: url)
    print("wrote", url.path, image.width, "x", image.height)
}

let output = URL(fileURLWithPath: CommandLine.arguments[1])
try MainActor.assumeIsolated {
    try render(Banner(theme: .light), to: output.appendingPathComponent("banner-light.png"))
    try render(Banner(theme: .dark), to: output.appendingPathComponent("banner-dark.png"))
    try render(LinkedInBanner(theme: .light), to: output.appendingPathComponent("linkedin-banner-light.png"))
    try render(LinkedInBanner(theme: .dark), to: output.appendingPathComponent("linkedin-banner-dark.png"))
}
