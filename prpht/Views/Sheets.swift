//
//  Sheets.swift
//  prpht
//
//  Modal sheets: account, prediction-market history graph, new group bet,
//  chat thread. All slide up from the bottom (iOS sheet default).
//

import SwiftUI

// MARK: - Account

struct AccountSheet: View {
    @ObservedObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        ZCircle(letter: "LP", colorHex: "#A6BE47", size: 54)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Luke P").font(.system(size: 17, weight: .bold))
                            Text("@mdrnprblms · Member since Jul 2026")
                                .font(.system(size: 11)).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Balance") {
                    Text(money(state.balance))
                        .font(.system(size: 34, weight: .heavy))
                    Text("Profit / loss: \(money(state.profitLoss))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(state.profitLoss >= 0 ? Brand.winGreen : Color.red)
                }

                Section("Stats") {
                    HStack {
                        stat("Placed", "\(state.placed)")
                        Divider()
                        stat("Won", "\(state.wonCount)")
                        Divider()
                        stat("Win rate", state.winRate)
                    }
                    .frame(height: 44)
                }

                Section("Group bets") {
                    ForEach(state.sweepstakes, id: \.id) { s in SweepRow(sweep: s, state: state) }
                }

                Section("Bet history") {
                    if state.betHistory.isEmpty {
                        Text("No bets yet").foregroundStyle(.tertiary).font(.system(size: 13))
                    }
                    ForEach(state.betHistory.prefix(30)) { h in
                        HistoryRow(entry: h)
                    }
                    Button("Reset demo", role: .destructive) { state.resetDemo() }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                        .foregroundStyle(Brand.brandText(scheme))
                }
            }
        }
    }

    @ViewBuilder
    private func stat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 22, weight: .black))
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold)).tracking(1)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HistoryRow: View {
    let entry: HistoryEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.label).font(.system(size: 13, weight: .bold))
                Text("\(entry.type) · \(entry.match)")
                    .font(.system(size: 11)).foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.won ? "+\(money(entry.returns))" : "-\(money(entry.stake))")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(entry.won ? Brand.winGreen : Color.red)
                Text(fractionalOdds(entry.odds)).font(.system(size: 10)).foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Prediction market history graph (seeded random walk)

func pmSeed(_ str: String) -> UInt32 {
    var h: UInt32 = 2166136261
    for ch in str.utf8 {
        h ^= UInt32(ch)
        h = h &* 16777619
    }
    return h
}

/// xorshift32 RNG matching the web implementation.
struct Xorshift {
    var s: UInt32
    mutating func next() -> Double {
        s ^= s << 13; s ^= s >> 17; s ^= s << 5
        return Double(s) / Double(UInt32.max)
    }
}

struct PmPoint { let t: Date; let p: Double }

func pmHistory(fixtureId: String) -> (fixture: Fixture, series: [[PmPoint]]) {
    guard let fx = demoFixtures.first(where: { $0.id == fixtureId })
           ?? feedFixture(id: fixtureId) else {
        return (demoFixtures[0], [])
    }
    var rng = Xorshift(s: pmSeed(fixtureId) | 1)
    let N = 90
    let days = 45
    let end = Date()
    let start = end.addingTimeInterval(-Double(days) * 86400)

    let shocks = (0..<N).map { _ in (rng.next() - 0.5) * 2 }
    let series = fx.selections.enumerated().map { si, sel -> [PmPoint] in
        let pEnd = min(0.97, max(0.03, 1 / sel.odds))
        let pStart = min(0.97, max(0.03, pEnd + (rng.next() - 0.5) * 0.36))
        var pts: [PmPoint] = []
        var drift = 0.0
        for i in 0..<N {
            let t = Double(i) / Double(N - 1)
            drift = drift * 0.86 + shocks[i] * 0.014
            let p = pStart + (pEnd - pStart) * t + sin(t * 9.7 + Double(si) * 2.1) * 0.012 + drift
            pts.append(PmPoint(t: start.addingTimeInterval((end.timeIntervalSince(start)) * t),
                               p: min(0.97, max(0.02, p))))
        }
        pts[N - 1].p = pEnd     // pin the live price exactly
        return pts
    }
    return (fx, series)
}

private func feedFixture(id: String) -> Fixture? {
    demoFixtures.first { $0.id == id }
}

let pmColors: [Color] = [
    Color(hexString: "#A6BE47"), Color(hexString: "#55828B"),
    Color(hexString: "#7D84B2"), Color(hexString: "#8FA6CB"),
    Color(hexString: "#D946EF")
]

struct PmGraphSheet: View {
    let fixtureId: String
    @State private var pos: Int = 89
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let data = pmHistory(fixtureId: fixtureId)
        let series = data.series
        let n = series.first?.count ?? 1

        return NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(data.fixture.match).font(.system(size: 20, weight: .black))
                Text("\(data.fixture.time) · \(data.fixture.league)")
                    .font(.system(size: 12)).foregroundStyle(.secondary)

                ChartCanvas(series: series, pos: Binding(get: { min(pos, n-1) }, set: { pos = $0 }))
                    .aspectRatio(16/9, allowHitTesting: true)

                legend(selections: pmHistory(fixtureId: fixtureId).fixture.selections, series: series)
                Spacer()
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(Brand.textBrand)
                }
            }
        }
        .presentationDetents([.large])
    }

    @ViewBuilder
    private func legend(selections: [Sel], series: [[PmPoint]]) -> some View {
        let p = min(pos, (series.first?.count ?? 1) - 1)
        VStack(spacing: 6) {
            ForEach(Array(selections.enumerated()), id: \.offset) { si, sel in
                HStack {
                    Circle().fill(pmColors[si % pmColors.count]).frame(width: 10, height: 10)
                    Text(sel.name).font(.system(size: 12, weight: .semibold)).lineLimit(1)
                    Spacer()
                    Text("\(Int((series[si][min(p, series[si].count-1)].p) * 100))%")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(pmColors[si % pmColors.count])
                }
            }
        }
    }
}

// Small canvas chart with drag-to-scrub.
struct ChartCanvas: View {
    let series: [[PmPoint]]
    @Binding var pos: Int

    var body: some View {
        Canvas { ctx, size in
            guard !series.isEmpty else { return }
            let n = series[0].count
            var lo = 1.0, hi = 0.0
            for s in series { for pt in s { lo = min(lo, pt.p); hi = max(hi, pt.p) } }
            let span = max(0.08, hi - lo)
            lo = max(0, lo - span * 0.15); hi = min(1, hi + span * 0.15)

            func y(_ p: Double) -> CGFloat {
                size.height - CGFloat((p - lo) / (hi - lo)) * size.height
            }
            func x(_ i: Int) -> CGFloat {
                size.width * CGFloat(i) / CGFloat(n - 1)
            }

            // gridlines at 25/50/75%
            for gp in stride(from: 0.25, to: 1, by: 0.25) where gp > lo && gp < hi {
                var line = Path()
                line.move(to: CGPoint(x: 0, y: y(gp)))
                line.addLine(to: CGPoint(x: size.width, y: y(gp)))
                ctx.stroke(line, with: .color(.secondary.opacity(0.18)), lineWidth: 0.5)
            }

            for (si, s) in series.enumerated() {
                let col = pmColors[si % pmColors.count]
                var path = Path()
                for i in 0...pos {
                    let pt = CGPoint(x: x(i), y: y(s[min(i, s.count - 1)].p))
                    i == 0 ? path.move(to: pt) : path.addLine(to: pt)
                }
                ctx.stroke(path, with: .color(col), style: StrokeStyle(lineWidth: 2, lineJoin: .round))

                let dot = CGRect(x: x(pos)-3, y: y(s[pos].p)-3, width: 6, height: 6)
                ctx.fill(Path(ellipseIn: dot), with: .color(col))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { g in
                let frac = max(0, min(1, g.location.x / max(1, UIScreen.main.bounds.width)))
                pos = Int((frac * CGFloat(series.first?.count ?? 1 - 1)).rounded())
            }
        )
        .background(Color.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


// MARK: - Chat thread

struct ThreadView: View {
    let convo: Conversation
    @ObservedObject var state = AppStateHolder.shared.state
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(convo.msgs.enumerated()), id: \.offset) { _, m in
                    if m.kindBet {
                        BetBubble(msg: m, state: state)
                    } else {
                        TextBubble(msg: m, colorHex: convo.colorHex)
                    }
                }
            }
            .padding(12)
        }
        .navigationTitle(convo.who)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TextBubble: View {
    let msg: ChatMsg
    let colorHex: String

    var body: some View {
        HStack {
            if msg.fromMe { Spacer(minLength: 60) }
            Text(msg.text)
                .font(.system(size: 14))
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(msg.fromMe ? Color(hexString: colorHex).opacity(0.85) : Color.primary.opacity(0.07))
                )
                .foregroundStyle(msg.fromMe ? .white : .primary)
            if !msg.fromMe { Spacer(minLength: 60) }
        }
    }
}

struct BetBubble: View {
    let msg: ChatMsg
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack {
            if msg.fromMe { Spacer(minLength: 40) }
            VStack(alignment: .leading, spacing: 6) {
                Label("\(msg.match)", systemImage: "trophy")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Brand.brandText(scheme))
                Text(msg.line).font(.system(size: 13, weight: .semibold))
                HStack {
                    Button {
                        let sel = Sel(name: msg.selection, odds: msg.odds, line: msg.line)
                        withAnimation { state.placeBet(fixtureId: msg.matchId, sel: sel) }
                    } label: {
                        Text(state.isPlaced(fixtureId: msg.matchId, selName: msg.selection)
                             ? "On slip ✓" : "£1 bet \(msg.selection)")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Capsule().fill(Brand.accent(scheme)))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(SquishButtonStyle())
                    Spacer()
                    Text(fractionalOdds(msg.odds)).font(.system(size: 12, weight: .black))
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 14).fill(Brand.sageLight))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Brand.sageBorder))
            .frame(maxWidth: 300)
            if !msg.fromMe { Spacer(minLength: 40) }
        }
    }
}

/// Tiny holder so thread views can observe the same AppState instance.
enum AppStateHolder {
    static var shared = Shared()
    struct Shared { let state = AppState() }
}
