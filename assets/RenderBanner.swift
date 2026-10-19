import AppKit
import SwiftUI

// Renders the GitHub profile banner (light and dark) in KeylineKit's visual language.
// Usage: DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift assets/RenderBanner.swift assets

struct Palette {
    let background: Color
    let ink: Color
    let slate: Color
    let paddingFill: Color
    let spacingFill: Color

    static let light = Palette(background: .white, ink: Color(hex: 0x0F172B), slate: Color(hex: 0x62748E),
                               paddingFill: Color(hex: 0xFFD6A7), spacingFill: Color(hex: 0xE9D4FF).opacity(0.7))
    static let dark = Palette(background: Color(hex: 0x0D1117), ink: Color(hex: 0xF0F6FC), slate: Color(hex: 0x9198A1),
                              paddingFill: Color(hex: 0xCA3500).opacity(0.45), spacingFill: Color(hex: 0x8200DB).opacity(0.45))
}

let blue = Color(hex: 0x1447E6)
let orange = Color(hex: 0xCA3500)
let green = Color(hex: 0x008236)
let purple = Color(hex: 0x8200DB)

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

struct Badge: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .frame(height: 19)
            .background(color, in: RoundedRectangle(cornerRadius: 3.5))
            .fixedSize()
    }
}

/// The avatar with an orange padding band and a measured edge, the way
/// `.padding(16)` around an `Image` looks under `#Keyline`.
struct Avatar: View {
    let image: NSImage
    let palette: Palette
    var body: some View {
        let padding: CGFloat = 16
        Image(nsImage: image)
            .resizable()
            .frame(width: 176, height: 176)
            .clipShape(Circle())
            .overlay { Circle().stroke(green, lineWidth: 2) }
            .padding(padding)
            .background { Rectangle().fill(palette.paddingFill) }
            .overlay { Rectangle().stroke(blue, lineWidth: 1.5) }
            .overlay(alignment: .topLeading) { Badge(text: "Image", color: blue).offset(y: -21) }
            .overlay(alignment: .top) {
                // Dimension line across the top band, with end ticks and its value.
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: 9, y: 1)); path.addLine(to: CGPoint(x: 9, y: padding - 1))
                        path.move(to: CGPoint(x: 4, y: 1)); path.addLine(to: CGPoint(x: 14, y: 1))
                        path.move(to: CGPoint(x: 4, y: padding - 1)); path.addLine(to: CGPoint(x: 14, y: padding - 1))
                    }
                    .stroke(orange, lineWidth: 1.5)
                    .frame(width: 18, height: padding)
                    Badge(text: "16", color: orange).offset(x: 26)
                }
            }
    }
}

struct Banner: View {
    let palette: Palette
    let avatar: NSImage
    var body: some View {
        HStack(alignment: .center, spacing: 56) {
            Avatar(image: avatar, palette: palette)
            VStack(alignment: .leading, spacing: 16) {
                Text("Helio Martín")
                    .font(.system(size: 72, weight: .bold))
                    .tracking(-1.2)
                    .foregroundStyle(palette.ink)
                    .padding(.horizontal, 2)
                    .overlay { Rectangle().stroke(blue, lineWidth: 1.5) }
                    .overlay(alignment: .topLeading) { Badge(text: "Text", color: blue).offset(y: -21) }
                    .overlay(alignment: .bottom) {
                        ZStack {
                            Rectangle().fill(palette.spacingFill)
                            Badge(text: "16", color: purple)
                        }
                        .frame(height: 16)
                        .offset(y: 16)
                    }
                VStack(alignment: .leading, spacing: 6) {
                    Text("iOS Engineer · Team Lead")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(palette.ink)
                    Text("Building native iOS apps since 2013")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(palette.slate)
                }
            }
        }
        .frame(width: 1200, height: 400)
        .background(palette.background)
    }
}

@MainActor
func render(_ palette: Palette, avatar: NSImage, to url: URL) throws {
    let renderer = ImageRenderer(content: Banner(palette: palette, avatar: avatar))
    renderer.scale = 2
    guard let image = renderer.cgImage else { throw CocoaError(.fileWriteUnknown) }
    try NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])?.write(to: url)
    print("wrote", url.path, image.width, "x", image.height)
}

let output = URL(fileURLWithPath: CommandLine.arguments[1])
guard let avatar = NSImage(contentsOf: output.appendingPathComponent("avatar.png")) else {
    fatalError("Missing assets/avatar.png")
}
try MainActor.assumeIsolated {
    try render(.light, avatar: avatar, to: output.appendingPathComponent("banner-light.png"))
    try render(.dark, avatar: avatar, to: output.appendingPathComponent("banner-dark.png"))
}
