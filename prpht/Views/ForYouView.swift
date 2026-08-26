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
                            if let iconName = sportIconAssetName(sport) {
                                Image(iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 13, height: 13)
                            } else if marketSports.contains(sport) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(zalando(.bold, 11))
                            }
                            Text(sport)
                                .font(zalando(.bold, 12))
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
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                Spacer()
                HStack(spacing: 12) {
                    BalancePill(state: state)
                    AccountButton(state: state)
                }
            }
            .padding(.horizontal, 14).padding(.top, 6)

            SportStrip(state: state)

            if cards.isEmpty {
                Spacer()
                Text("Nothing here yet").foregroundStyle(.secondary)
                Spacer()
            } else {
                VerticalPagingFeed(cards: cards, state: state)
                    .id(state.currentSport)
                    .padding(.bottom, 70)
            }
        }
    }
}

// MARK: - Vertical one-card-per-swipe paging (iOS 16 compatible; TabView's
// .page style only snaps horizontally, so paging is done manually with a
// drag gesture that settles on the nearest card).

struct VerticalPagingFeed: View {
    let cards: [Fixture]
    @ObservedObject var state: AppState
    @State private var index = 0
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            VStack(spacing: 0) {
                ForEach(cards, id: \.id) { fx in
                    SwipeCard(fixture: fx, state: state)
                        .frame(width: geo.size.width, height: h)
                }
            }
            .offset(y: -CGFloat(index) * h + dragOffset)
            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: index)
            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, out, _ in
                        out = value.translation.height
                    }
                    .onEnded { value in
                        let threshold = h * 0.22
                        if value.translation.height < -threshold, index < cards.count - 1 {
                            index += 1
                        } else if value.translation.height > threshold, index > 0 {
                            index -= 1
                        }
                    }
            )
        }
        .clipped()
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
                    .font(zalando(.bold, 11))
                    .kerning(1)
                    .textCase(.uppercase)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill(Color.primary.opacity(0.07)))
            }
            .padding(.bottom, 18)

            Spacer()

            // Headline
            Text(headline.selection?.line ?? headline.text)
                .font(zalando(.heavy, 30))
                .lineSpacing(4)
                .lineLimit(4)
                .minimumScaleFactor(0.6)
                .padding(.bottom, 10)

            Text("\(fixture.match) · \(fixture.league) · \(fixture.time)")
                .font(zalando(.semibold, 13))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
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
                ShareLink(item: shareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .font(zalando(.semibold, 13))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .padding(.top, 14)
        }
        .padding(24)
    }

    private var shareText: String {
        "\(fixture.match) · \(fixture.market) on prpht"
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
            if let iconName = sportIconAssetName(sport) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            } else if marketSports.contains(sport) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 10, weight: .bold))
            } else {
                Circle()
                    .fill(Color(hexString: colorHex))
                    .frame(width: 8, height: 8)
            }
            Text(sport)
                .font(zalando(.black, 12))
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
                            .font(zalando(.bold, 11))
                            .lineLimit(1).minimumScaleFactor(0.7)
                        Text("→ \(money(sel.odds))")
                            .font(zalando(.black, 16))
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
                            .font(zalando(.bold, 22))
                        Text(placed ? "Placed" : "£1 bet")
                            .font(zalando(.bold, 10))
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
