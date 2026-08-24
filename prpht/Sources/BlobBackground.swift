//
//  BlobBackground.swift
//  prpht
//
//  Ambient blob field: a Metal-free port of the canvas noise wash. Uses
//  TimelineView + Canvas to paint slowly drifting domain-warped value noise
//  whose bright stop eases toward the current team colour.
//

import SwiftUI

struct BlobBackgroundView: View {
    let teamColor: Color

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let W = 48, H = 96   // low-res grid, upscaled by the canvas
                let cw = size.width / CGFloat(W)
                let ch = size.height / CGFloat(H)

                // Ambient wash drift around the companion ring.
                let wash: [SIMD3<Double>] = [
                    SIMD3(63, 146, 114) / 255,
                    SIMD3(122, 134, 204) / 255,
                    SIMD3(61, 147, 166) / 255,
                    SIMD3(138, 164, 224) / 255
                ]
                func ringStop(_ ts: Double, _ phase: Double) -> SIMD3<Double> {
                    let ph = (sin(ts * 0.03 + phase * 2.1) + 1) / 2 * Double(wash.count - 1)
                    let i0 = Int(ph), i1 = min(i0 + 1, wash.count - 1), k = ph - Double(i0)
                    return wash[i0] * (1 - k) + wash[i1] * k
                }

                let team = SIMD3<Double>(teamColor.components) / 255
                let dark = traitDark
                let bg: SIMD3<Double> = dark ? SIMD3(4, 4, 3) / 255 : SIMD3(252, 244, 246) / 255

                // Background wash
                ctx.fill(Path(CGRect(origin: .zero, size: size)),
                         with: .color(Color(rgbVec: bg)))

                for iy in 0..<H {
                    for ix in 0..<W {
                        let n = fbm(Double(ix) * 0.09, Double(iy) * 0.09 + t * 0.07)
                        let edge = smoothstep(0.52, 0.72, n)
                        guard edge > 0.02 else { continue }
                        // Blend trough->mid->bright by depth of the noise.
                        let s0 = ringStop(t, 0), s1 = ringStop(t, 1)
                        let v = s0 * (1 - edge) * 0.5 + s1 * (0.5 + edge * 0.2) + team * edge * 0.45
                        let rect = CGRect(x: CGFloat(ix) * cw, y: CGFloat(iy) * ch,
                                          width: cw + 1, height: ch + 1)
                        ctx.fill(Path(rect), with: .color(Color(rgbVec: v * edge)))
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    @Environment(\.colorScheme) private var scheme
    private var traitDark: Bool { scheme == .dark }

    // MARK: value noise (ports of hash/fade/noise2/fbm)

    private func hash(_ ix: Int, _ iy: Int) -> Double {
        var n = UInt32(bitPattern: ix &* 0x27d4eb2d) ^ UInt32(bitPattern: iy &* 0x165667b1)
        n = (n ^ (n >> 15)) &* 0x2c1b3c6d
        n = (n ^ (n >> 12)) &* 0x297a2d39
        n ^= n >> 15
        return Double(n) / Double(UInt32.max)
    }
    private func fade(_ t: Double) -> Double { t * t * (3 - 2 * t) }
    private func noise2(_ x: Double, _ y: Double) -> Double {
        let ix = Int(floor(x)), iy = Int(floor(y))
        let fx = fade(x - Double(ix)), fy = fade(y - Double(iy))
        let a = hash(ix, iy), b = hash(ix + 1, iy)
        let c = hash(ix, iy + 1), d = hash(ix + 1, iy + 1)
        return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy
    }
    private func fbm(_ x: Double, _ y: Double) -> Double {
        var v = 0.0, amp = 0.5, f = 1.0
        for _ in 0..<4 { v += amp * noise2(x * f, y * f); f *= 2; amp *= 0.5 }
        return v / 0.9375
    }
    private func smoothstep(_ e0: Double, _ e1: Double, _ x: Double) -> Double {
        let t = min(1, max(0, (x - e0) / (e1 - e0)))
        return t * t * (3 - 2 * t)
    }
}

private extension Color {
    init(rgbVec v: SIMD3<Double>) {
        self.init(.sRGB,
                  red: min(1, max(0, v.x)), green: min(1, max(0, v.y)),
                  blue: min(1, max(0, v.z)), opacity: 1)
    }

    var components: [Double] {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [Double(r * 255), Double(g * 255), Double(b * 255)]
        #else
        return [166, 190, 71]
        #endif
    }
}
