//
//  BlobBackground.swift
//  prpht
//
//  Ambient blob field: a Metal-free port of the canvas noise wash. Mirrors the
//  web app's #blob-canvas — domain-warped value noise painted into a tiny
//  internal grid, upscaled, blurred and grained, with the bright stop of the
//  ramp easing toward the current team colour.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct BlobBackgroundView: View {
    let teamColor: Color

    /// Internal grid, upscaled by the draw. Same dimensions as the web canvas:
    /// the smoothing on that upscale is what makes the blob edges soft, so the
    /// grid has to stay small rather than matching screen resolution.
    private let W = 64, H = 132

    @Environment(\.colorScheme) private var scheme
    private var traitDark: Bool { scheme == .dark }

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
                Canvas { ctx, size in
                    guard let cg = field(at: timeline.date.timeIntervalSinceReferenceDate,
                                         dark: traitDark) else { return }
                    ctx.draw(Image(decorative: cg, scale: 1).interpolation(.high),
                             in: CGRect(origin: .zero, size: size))
                }
            }
            // Post-upscale softening. The web blurs 6px over a 64-wide canvas
            // filling the viewport — i.e. about one cell — so derive it from
            // the cell width instead of hard-coding a point value.
            .blur(radius: max(4, geo.size.width / CGFloat(W)))
            // Overscaled so the blur's soft edge is clipped by the parent's
            // bounds rather than fading out against the page.
            .scaleEffect(1.15)
            .clipped()
            .overlay(GrainOverlay(opacity: traitDark ? 0.085 : 0.18))
        }
        .allowsHitTesting(false)
    }

    // MARK: field

    private func field(at ts: TimeInterval, dark: Bool) -> CGImage? {
        let t = ts * 0.07

        /// Ambient wash: the muted companions shared by the coolors palettes
        /// (granite green, lavender blue, pacific cyan, wisteria blue), with
        /// chroma pushed up from the raw swatches — the muted originals painted
        /// the blob EDGES and read as a grey halo around every cloud.
        let wash: [SIMD3<Double>] = [
            SIMD3(63, 146, 114),
            SIMD3(122, 134, 204),
            SIMD3(61, 147, 166),
            SIMD3(138, 164, 224)
        ]
        // Ambient drift: slide both wash stops around the companion ring over a
        // few minutes, out of phase, so the field never sits still.
        func ringStop(_ phase: Double) -> SIMD3<Double> {
            let ph = (sin(ts * 0.03 + phase * 2.1) + 1) / 2 * Double(wash.count - 1)
            let i0 = Int(ph), i1 = min(i0 + 1, wash.count - 1), k = ph - Double(i0)
            return wash[i0] * (1 - k) + wash[i1] * k
        }
        // Colour ramp: trough -> mid cloud -> bright end (the team colour).
        let stop0 = ringStop(0)
        let stop1 = ringStop(1)
        let stop2 = SIMD3<Double>(teamColor.components)

        // The theme background is painted BY the field, not left to the page,
        // so the blur has real colour to feather into at the edges.
        let bg: SIMD3<Double> = dark ? SIMD3(4, 4, 3) : SIMD3(252, 244, 246)
        // Light mode is the WEAKER of the two: on a pale page a strong field
        // tints the card backgrounds and drags muted text under the AA
        // threshold. --bg-grain-light does the rest of the dimming.
        let strength = dark ? 0.62 : 0.56
        let coreLift = dark ? 0.35 : 0.22
        let white = SIMD3<Double>(repeating: 255)

        var px = [UInt8](repeating: 255, count: W * H * 4)
        var p = 0
        for y in 0..<H {
            let ny = (Double(y) / Double(H)) * 3.1
            for x in 0..<W {
                let nx = (Double(x) / Double(W)) * 1.7
                // Domain warp: sample noise at coordinates displaced by more
                // noise. This is what makes the shapes tendrilled and amorphous
                // rather than elliptical.
                let wx = Noise.fbm(nx * 1.25 + t, ny * 1.25)
                let wy = Noise.fbm(nx * 1.25 + 4.7, ny * 1.25 - t * 0.85)
                let v = Noise.fbm(nx + wx * 1.9 + t * 0.6, ny + wy * 1.9)

                let a = Noise.smoothstep(0.50, 0.74, v) * strength
                var out = bg
                if a > 0 {
                    let tt = Noise.smoothstep(0.50, 0.86, v)
                    var c: SIMD3<Double>
                    if tt < 0.5 {
                        c = stop0 + (stop1 - stop0) * (tt * 2)
                    } else {
                        c = stop1 + (stop2 - stop1) * ((tt - 0.5) * 2)
                    }
                    // A whisper of white lift at the crest for glow.
                    let core = Noise.smoothstep(0.78, 0.90, v) * coreLift
                    c += (white - c) * core
                    // Composite over the theme background; output is opaque.
                    out = bg + (c - bg) * a
                }
                px[p]     = UInt8(clamping: Int(out.x.rounded()))
                px[p + 1] = UInt8(clamping: Int(out.y.rounded()))
                px[p + 2] = UInt8(clamping: Int(out.z.rounded()))
                px[p + 3] = 255
                p += 4
            }
        }

        guard let provider = CGDataProvider(data: Data(px) as CFData) else { return nil }
        return CGImage(width: W, height: H,
                       bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: W * 4,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider, decode: nil,
                       shouldInterpolate: true, intent: .defaultIntent)
    }

}

/// Value noise shared by the field and the grain tile (ports of the web's
/// hash/fade/noise2/fbm).
private enum Noise {

    static func hash(_ ix: Int, _ iy: Int) -> Double {
        var n = UInt32(bitPattern: Int32(truncatingIfNeeded: ix) &* 0x27d4eb2d) ^ UInt32(bitPattern: Int32(truncatingIfNeeded: iy) &* 0x165667b1)
        n = (n ^ (n >> 15)) &* 0x2c1b3c6d
        n = (n ^ (n >> 12)) &* 0x297a2d39
        n ^= n >> 15
        return Double(n) / Double(UInt32.max)
    }
    static func fade(_ t: Double) -> Double { t * t * (3 - 2 * t) }
    static func noise2(_ x: Double, _ y: Double) -> Double {
        let ix = Int(floor(x)), iy = Int(floor(y))
        let fx = fade(x - Double(ix)), fy = fade(y - Double(iy))
        let a = hash(ix, iy), b = hash(ix + 1, iy)
        let c = hash(ix, iy + 1), d = hash(ix + 1, iy + 1)
        return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy
    }
    static func fbm(_ x: Double, _ y: Double) -> Double {
        var v = 0.0, amp = 0.5, f = 1.0
        for _ in 0..<4 { v += amp * noise2(x * f, y * f); f *= 2; amp *= 0.5 }
        return v / 0.9375   // amplitudes sum to 0.9375; renormalise to ~[0,1]
    }
    static func smoothstep(_ e0: Double, _ e1: Double, _ x: Double) -> Double {
        let t = min(1, max(0, (x - e0) / (e1 - e0)))
        return t * t * (3 - 2 * t)
    }
}

/// Screen-resolution grain. It has to be its own layer rather than drawn into
/// the field: the field is 64px wide and upscaled, so grain painted there would
/// be magnified into blotches instead of masking the low-res.
private struct GrainOverlay: View {
    let opacity: Double

    var body: some View {
        #if canImport(UIKit)
        Image(uiImage: GrainOverlay.tile)
            .resizable(resizingMode: .tile)
            .opacity(opacity)
            .allowsHitTesting(false)
        #else
        Color.clear
        #endif
    }

    #if canImport(UIKit)
    /// Port of the web's `feTurbulence fractalNoise` tile. Built once:
    /// regenerating per frame makes the grain crawl, which reads as video noise
    /// rather than film grain.
    private static let tile: UIImage = {
        let n = 128
        var px = [UInt8](repeating: 0, count: n * n * 4)
        // Three octaves, like numOctaves='3'. Summing octaves is what keeps the
        // values bunched around mid — a flat random byte per pixel spans the
        // whole range and reads as television static instead of grain.
        func fractal(_ x: Double, _ y: Double, _ seed: Double) -> Double {
            var v = 0.0, amp = 0.5, f = 1.2   // baseFrequency 1.2
            for _ in 0..<3 {
                v += amp * Noise.noise2(x * f + seed, y * f + seed)
                f *= 2; amp *= 0.5
            }
            return v / 0.875
        }
        for iy in 0..<n {
            for ix in 0..<n {
                let x = Double(ix), y = Double(iy)
                let g = fractal(x, y, 0)
                // feTurbulence writes noise into the alpha channel too, so the
                // veil varies in strength as well as in tone.
                let a = fractal(x, y, 31.7)
                let grey = 255 * g
                let alpha = 255 * a
                let i = (iy * n + ix) * 4
                // Premultiplied: the grey has to be scaled by its own alpha.
                let v = UInt8(clamping: Int(grey * a))
                px[i] = v; px[i + 1] = v; px[i + 2] = v
                px[i + 3] = UInt8(clamping: Int(alpha))
            }
        }
        guard let provider = CGDataProvider(data: Data(px) as CFData),
              let cg = CGImage(width: n, height: n,
                               bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: n * 4,
                               space: CGColorSpaceCreateDeviceRGB(),
                               bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                               provider: provider, decode: nil,
                               shouldInterpolate: false, intent: .defaultIntent)
        else { return UIImage() }
        // scale < 1 renders each noise pixel slightly larger than a point,
        // matching the web's grainSize of 1.2.
        return UIImage(cgImage: cg, scale: 1 / 1.2, orientation: .up)
    }()
    #endif
}

private extension Color {
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
