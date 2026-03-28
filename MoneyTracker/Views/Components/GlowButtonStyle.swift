import SwiftUI

/// 글로우 버튼 스타일 — 녹색 발광 효과
struct GlowButtonStyle: ButtonStyle {
    /// 글로우 색상
    var glowColor: Color = AppColor.primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(glowColor)
            .foregroundStyle(AppColor.background)
            .font(.headline)
            .cornerRadius(12)
            .shadow(color: glowColor.opacity(configuration.isPressed ? 0.3 : 0.6), radius: configuration.isPressed ? 4 : 10, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// ButtonStyle 확장 — 글로우 스타일 편의 접근
extension ButtonStyle where Self == GlowButtonStyle {
    /// 기본 글로우 버튼 스타일
    static var glow: GlowButtonStyle {
        GlowButtonStyle()
    }

    /// 커스텀 색상 글로우 버튼 스타일
    static func glow(color: Color) -> GlowButtonStyle {
        GlowButtonStyle(glowColor: color)
    }
}
