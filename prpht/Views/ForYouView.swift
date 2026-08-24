//
//  ForYouView.swift
//  prpht
//
//  TikTok-style vertical swipe feed of bet cards + sport category strip.
//  Also hosts the Betslip page (traditional list) via the shared card row.
//

import SwiftUI

// MARK: - Sport strip

struct SportStrip: View {
    @ObservedObject var state: AppState
    var showMarketsIcon = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sportsList, id: \.self) { sport in
                    let active = state.currentSport == sport
                    Button {
                        state.currentSport = sport
                    } label: {
                        HStack(spacing: 5) {
                            if marketSports.contains(sport) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            Text(sport)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(
                            Capsule().fill(active ? Brand.whiteGrape : Color.primary.opacity(0.06))
                        )
                        .foregroundStyle(active ? Color.white : Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - For You (vertical snap feed)

struct ForYouView: View {
    @ObservedObject var state: AppState

    private var cards: [Fixture] { state.fixtures(for: state.currentSport) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BalancePill(state: state)
                Spacer()
                AccountButton(state: state)
            }
            .padding(.horizontal, 14).padding(.top, 6)

            SportStrip(state: state)

            if cards.isEmpty {
                Spacer()
                Text("Nothing here yet").foregroundStyle(.secondary)
                Spacer()
            } else {
                GeometryReader { geo in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(cards, id: \.id) { fx in
                                SwipeCard(fixture: fx, state: state)
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Swipe card

struct SwipeCard: View {
    let fixture: Fixture
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category icon chip
            HStack(spacing: 8) {
                CategoryBadge(sport: fixture.sport == "For You"
                              ? (fyIcon[fixture.id] ?? "Football")
                              : fixture.sport,
                              colorHex: fixture.colorHex)
                Spacer()
                Text(fixture.market)
                    .font(.system(size: 11, weight: .bold))
                    .kerning(1)
                    .textCase(.uppercase)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill(Color.primary.opacity(0.07)))
            }
            .padding(.bottom, 18)

            Spacer()

            // Headline
            Text(headline.selection?.line ?? headline.text)
                .font(.system(size: 30, weight: .heavy))
                .lineSpacing(4)
                .padding(.bottom, 10)

            Text("\(fixture.match) · \(fixture.league) · \(fixture.time)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)

            Spacer()

            // Bet buttons
            HStack(spacing: 10) {
                ForEach(fixture.selections, id: \.name) { sel in
                    BetButton(fixture: fixture, sel: sel, state: state, style: .pill)
                }
            }

            HStack(spacing: 14) {
                Label("\(fixture.likes)", systemImage: "heart")
                Spacer()
                GraphButton(fixtureId: fixture.id)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 14)
        }
        .padding(24)
    }

    private var headline: (selection: Sel?, text: String) {
        let i = min(fixture.target, fixture.selections.count - 1)
        return (fixture.selections[i], fixture.match)
    }
}

struct CategoryBadge: View {
    let sport: String
    let colorHex: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hexString: colorHex))
                .frame(width: 8, height: 8)
            Text(sport)
                .font(.system(size: 12, weight: .black))
                .textCase(.uppercase)
                .kerning(1)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Capsule().fill(Color(hexString: colorHex).opacity(0.15)))
        .foregroundStyle(Color(hexString: colorHex))
    }
}

// MARK: - Bet button (pill + tiktok styles)

struct BetButton: View {
    let fixture: Fixture
    let sel: Sel
    @ObservedObject var state: AppState
    var style: Style = .pill
    @Environment(\.colorScheme) private var scheme

    enum Style { case pill, tiktok }

    private var placed: Bool { state.isPlaced(fixtureId: fixture.id, selName: sel.name) }

    var body: some View {
        Group {
            switch style {
            case .pill:
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        state.placeBet(fixtureId: fixture.id, sel: sel)
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(placed ? sel.name : "£1 bet \(sel.name)")
                            .font(.system(size: 11, weight: .bold))
                            .lineLimit(1).minimumScaleFactor(0.7)
                        Text("→ \(money(sel.odds))")
                            .font(.system(size: 16, weight: .black))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(placed ? Brand.accent(scheme) : Color.primary.opacity(0.06))
                    )
                    .foregroundStyle(placed ? Color.white : Color.primary)
                }
                .buttonStyle(SquishButtonStyle())
                .accessibilityLabel("Bet £1 on \(sel.name) at \(fractionalOdds(sel.odds))")
            case .tiktok:
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        state.placeBet(fixtureId: fixture.id, sel: sel)
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: placed ? "checkmark.circle.fill" : "sterlingsign.circle")
                            .font(.system(size: 22, weight: .bold))
                        Text(placed ? "Placed" : "£1 bet")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(placed ? Brand.brandText(scheme) : Color.secondary)
                }
                .buttonStyle(SquishButtonStyle())
            }
        }
    }
}

// MARK: - PM graph entry point

struct GraphButton: View {
    let fixtureId: String
    @State private var showGraph = false

    var body: some View {
        Button { showGraph = true } label: {
            Label("History", systemImage: "chart.xyaxis.line")
        }
        .sheet(isPresented: $showGraph) {
            PmGraphSheet(fixtureId: fixtureId)
        }
    }
}
