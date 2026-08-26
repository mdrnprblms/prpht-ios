//
//  FixturesTimeline.swift
//  prpht
//
//  Port of the web "run-in" level-map: a snaking SVG-style pathway climbed
//  bottom-to-top chronologically, glowing fixture orbs with orbiting friend
//  avatars, tap-to-expand cards with copy-bet, watch parties and calendar.
//

import SwiftUI
import EventKit

// MARK: - Model

struct FixtureCluster: Identifiable {
    let id: String            // matchId / fixture id
    let info: Fixture         // full fixture (league, venue-ish, time)
    let match: String
    let bets: [FriendBet]

    var people: [String] {
        var seen: [String] = []
        for b in bets where !seen.contains(b.who) { seen.append(b.who) }
        return seen
    }
}

struct WatchParty {
    let venue: String
    let when: String
    var going: [String]
    let match: String
    let invited: [String]
}

let partyVenues = ["The Crown & Anchor", "Mine – big telly",
                   "The Dog House", "Priya’s place", "The Railway Tavern"]

// MARK: - Clustering

extension FriendBet {
    static func runInClusters() -> [FixtureCluster] {
        var byMatch: [String: [FriendBet]] = [:]
        for b in friendsFeedData { byMatch[b.matchId, default: []].append(b) }

        let fixtures = demoFixtures.filter { $0.sport != "For You" && !marketSports.contains($0.sport) }
        var out: [FixtureCluster] = []
        var seenMatches: Set<String> = []

        // Bets first (they define the popular fixtures), then any remaining
        // fixtures that had no bets, deduped on match name + time like the web.
        func push(_ id: String, _ fx: Fixture?, _ bets: [FriendBet]) {
            let matchName = bets.first?.match ?? fx?.match ?? id
            let when = fx?.time ?? ""
            if out.contains(where: { $0.match == matchName && $0.info.time == when }) { return }
            guard let fx else { return }
            out.append(FixtureCluster(id: id, info: fx, match: matchName, bets: bets))
        }

        for b in friendsFeedData where !seenMatches.contains(b.matchId) {
            seenMatches.insert(b.matchId)
            push(b.matchId, statelessFixture(b.matchId), byMatch[b.matchId] ?? [])
        }
        for fx in fixtures where !seenMatches.contains(fx.id) {
            seenMatches.insert(fx.id)
            push(fx.id, fx, [])
        }
        // Chronological order: soonest kickoff first (bottom of the map).
        return out.sorted { KickoffParser.date(from: $0.info.time) ?? .distantPast
                              < KickoffParser.date(from: $1.info.time) ?? .distantFuture }
    }
}

private func statelessFixture(_ id: String) -> Fixture? {
    demoFixtures.first { $0.id == id }
}

// MARK: - View

struct FixturesTimelineView: View {
    @ObservedObject var state: AppState
    @State private var expanded: String? = nil
    @State private var watchParties: [String: WatchParty] = [:]
    @Environment(\.colorScheme) private var scheme

    private let spacing: CGFloat = 172
    private let padBottom: CGFloat = 96
    private let padTop: CGFloat = 84
    private let amplitude: CGFloat = 25   // % either side of centre

    private var clusters: [FixtureCluster] { FriendBet.runInClusters() }

    private func nodeX(_ i: Int, width: CGFloat) -> CGFloat {
        width * (0.5 + amplitude / 100 * sin(Double(i) * 1.05 + 0.5))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Fixtures").font(zalando(.heavy, 26))
                Spacer()
                BalancePill(state: state)
                AccountButton(state: state).padding(.leading, 10)
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 4)

            headerBar

            ScrollViewReader { proxy in
                ScrollView {
                    TimelineMap(clusters: clusters, watchParties: watchParties,
                                expanded: $expanded)
                        .padding(.bottom, 70)
                }
                .onAppear {
                    // Start at the bottom — the next fixture up. Delay a tick so
                    // the ScrollView has laid out the map before scrolling.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if let first = clusters.first {
                            withAnimation { proxy.scrollTo(first.id, anchor: .center) }
                        }
                    }
                }
            }
        }
        .overlay {
            if let id = expanded, let row = cluster(id) {
                ExpandedFixtureCard(
                    cluster: row,
                    party: watchParties[id],
                    state: state,
                    organise: { organiseParty(id) },
                    toggleGoing: { toggleGoing(id) },
                    close: { withAnimation { expanded = nil } }
                )
                .transition(.opacity)
            }
        }
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text("The run-in").font(zalando(.bold, 14))
                Text("Next up at the bottom · climb as the week goes on")
                    .font(zalando(.regular, 10)).foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                state.showNewGroupBet = true
            } label: {
                Text("Group bets")
                    .font(zalando(.bold, 11))
                    .foregroundStyle(Brand.textBrand)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Brand.whiteGrape))
            }
            .buttonStyle(SquishButtonStyle())
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background((scheme == .dark ? Color.black.opacity(0.55) : Color.white.opacity(0.85)))
    }

    // The snaking pathway behind the orbs.
    private var pathLayer: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { p in
                let pts = clusters.enumerated().map { (i, c) -> CGPoint in
                    CGPoint(x: nodeX(i, width: w),
                            y: h - padBottom - CGFloat(i) * spacing)
                }
                guard let first = pts.first else { return }
                p.move(to: first)
                for (i, pt) in pts.enumerated() where i > 0 {
                    let prev = pts[i - 1]
                    let k = spacing * 0.45
                    p.addCurve(to: pt,
                               control1: CGPoint(x: prev.x, y: prev.y - k),
                               control2: CGPoint(x: pt.x, y: pt.y + k))
                }
            }
            .stroke(Brand.accent(scheme).opacity(0.25),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .overlay(
                // Dashed lime overlay on top of the soft stroke.
                GeometryReader { _ in EmptyView() }
            )
            Path { p in
                let pts = clusters.enumerated().map { (i, _) -> CGPoint in
                    CGPoint(x: nodeX(i, width: w),
                            y: h - padBottom - CGFloat(i) * spacing)
                }
                guard let first = pts.first else { return }
                p.move(to: first)
                for (i, pt) in pts.enumerated() where i > 0 {
                    let prev = pts[i - 1]
                    let k = spacing * 0.45
                    p.addCurve(to: pt,
                               control1: CGPoint(x: prev.x, y: prev.y - k),
                               control2: CGPoint(x: pt.x, y: pt.y + k))
                }
            }
            .stroke(Brand.accent(scheme),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round,
                                       dash: [1, 9]))
            .frame(width: w, height: h)
        }
        .ignoresSafeArea()
    }

    private var nodeLayer: some View {
        GeometryReader { geo in
            ForEach(Array(clusters.enumerated()), id: \.element.id) { i, c in
                FixtureOrbNode(
                    cluster: c,
                    isNext: i == clusters.count - 1,
                    party: watchParties[c.id],
                    expanded: expanded == c.id
                )
                .position(x: nodeX(i, width: geo.size.width),
                          y: geo.size.height - padBottom - CGFloat(i) * spacing)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        expanded = (expanded == c.id) ? nil : c.id
                    }
                }
            }
        }
    }

    private func cluster(_ id: String) -> FixtureCluster? {
        clusters.first { $0.id == id }
    }

    // Watch-party actions -------------------------------------------------

    private func organiseParty(_ id: String) {
        guard let row = cluster(id) else { return }
        let venue = partyVenues.randomElement() ?? "The Crown & Anchor"
        watchParties[id] = WatchParty(venue: venue, when: row.info.time,
                                      going: ["You"], match: row.match,
                                      invited: row.people)
        createPartyChat(id, row: row)
        state.showToast("Watch party created · \(row.people.count) invited")
    }

    private func toggleGoing(_ id: String) {
        guard var p = watchParties[id] else { return }
        if let i = p.going.firstIndex(of: "You") {
            p.going.remove(at: i)
            state.showToast("Left the watch party")
        } else {
            p.going.append("You")
            state.showToast("You're going")
        }
        watchParties[id] = p
    }

    private func createPartyChat(_ id: String, row: FixtureCluster) {
        let chatId = "wp-\(id)"
        guard !state.conversations.contains(where: { $0.id == chatId }) else { return }
        let sys = ChatMsg(fromMe: false, kindBet: false, matchId: "", selection: "",
                          match: "", odds: 0, line: "",
                          text: "Watch party at \(watchParties[id]?.venue ?? "") · \(row.info.time)",
                          t: "now")
        let reply = ChatMsg(fromMe: false, kindBet: false, matchId: "", selection: "",
                            match: "", odds: 0, line: "",
                            text: row.people.first.map { "\($0): in" } ?? "in", t: "now")
        let convo = Conversation(id: chatId, who: row.match,
                                 colorHex: row.info.colorHex,
                                 msgs: [sys, reply])
        state.conversations.insert(convo, at: 0)
    }
}
