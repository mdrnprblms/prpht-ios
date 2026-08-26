//
//  FixturesFriendsView.swift
//  prpht
//
//  Fixtures timeline (bets grouped by match) + Friends split page
//  (friends' bets carousel on top, messages list below).
//

import SwiftUI

// MARK: - Fixtures list (league-grouped, with time headers and fractional odds)

struct FixturesView: View {
    @ObservedObject var state: AppState

    /// Real fixtures only: skip the "For You" duplicates (same matches re-tagged
    /// with a bet-builder market) and the Polymarket-style rows, which have no
    /// kickoff time to group under.
    private var fixtures: [Fixture] {
        demoFixtures.filter { $0.sport != "For You" && !marketSports.contains($0.sport) }
    }

    private var leagueGroups: [(league: String, items: [Fixture])] {
        var order: [String] = []
        var byLeague: [String: [Fixture]] = [:]
        for fx in fixtures {
            if byLeague[fx.league] == nil { order.append(fx.league) }
            byLeague[fx.league, default: []].append(fx)
        }
        return order.map { ($0, byLeague[$0] ?? []) }
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

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(leagueGroups, id: \.league) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.league.uppercased())
                                .font(zalando(.bold, 11))
                                .kerning(1.2)
                                .foregroundStyle(.secondary)

                            ForEach(group.items, id: \.id) { fx in
                                FixtureRow(fixture: fx, state: state)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 70)
            }
        }
    }
}

struct FixtureRow: View {
    let fixture: Fixture
    @ObservedObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(fixture.time)
                    .font(zalando(.bold, 11))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(fixture.market)
                    .font(zalando(.bold, 10))
                    .kerning(0.5)
                    .textCase(.uppercase)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Color.primary.opacity(0.07)))
            }

            Text(fixture.match)
                .font(zalando(.bold, 15))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 8) {
                ForEach(fixture.selections, id: \.name) { sel in
                    FixtureOddsButton(fixture: fixture, sel: sel, state: state)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.045)))
    }
}

struct FixtureOddsButton: View {
    let fixture: Fixture
    let sel: Sel
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    private var placed: Bool { state.isPlaced(fixtureId: fixture.id, selName: sel.name) }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state.placeBet(fixtureId: fixture.id, sel: sel)
            }
        } label: {
            VStack(spacing: 2) {
                Text(sel.name)
                    .font(zalando(.semibold, 11))
                    .lineLimit(1).minimumScaleFactor(0.7)
                Text(fractionalOdds(sel.odds))
                    .font(zalando(.black, 14))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(placed ? Brand.accent(scheme) : Color.primary.opacity(0.06))
            )
            .foregroundStyle(placed ? Color.white : Color.primary)
        }
        .buttonStyle(SquishButtonStyle())
        .accessibilityLabel("Bet £1 on \(sel.name) at \(fractionalOdds(sel.odds))")
    }
}

// MARK: - Friends split page

struct FriendsView: View {
    @ObservedObject var state: AppState

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top pane: friends' bets, vertical snap carousel (~55%).
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(friendsFeedData, id: \.who) { b in
                            FriendBetCard(bet: b, state: state)
                                .frame(width: geo.size.width, height: geo.size.height * 0.55)
                        }
                    }
                }
                .frame(height: geo.size.height * 0.55)

                Divider()

                // Messages header with + Group bet.
                HStack {
                    Text("MESSAGES")
                        .font(zalando(.bold, 10)).tracking(1.5)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        state.newBet = NewGroupBetDraft()
                        state.showNewGroupBet = true
                    } label: {
                        Text("+ Group bet")
                            .font(zalando(.bold, 11))
                            .foregroundStyle(Brand.textBrand)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Brand.whiteGrape))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14).padding(.vertical, 8)

                // Message list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(state.conversations, id: \.id) { c in
                            ConversationRow(convo: c, lastLine: state.lastLine(c))
                        }
                    }
                }
            }
        }
    }
}

struct FriendBetCard: View {
    let bet: FriendBet
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                FriendAvatar(who: bet.who, size: 36)
                VStack(alignment: .leading, spacing: 1) {
                    Text(bet.who).font(zalando(.bold, 14))
                    Text(bet.ago).font(zalando(.regular, 11)).foregroundStyle(.secondary)
                }
                Spacer()
            }

            Spacer()

            Text("🎯 \(bet.line)")
                .font(zalando(.heavy, 22))
                .lineSpacing(3)

            Text("“\(bet.note)”")
                .font(zalando(.semibold, 13))
                .italic()
                .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Button {
                    let fx = state.fixture(id: bet.matchId)
                    let sel = fx?.selections.first(where: { $0.name == bet.selection })
                        ?? Sel(name: bet.selection, odds: bet.odds,
                               line: bet.line)
                    withAnimation { state.placeBet(fixtureId: bet.matchId, sel: sel) }
                } label: {
                    Label(state.isPlaced(fixtureId: bet.matchId, selName: bet.selection) ? "Placed" : "Copy £1",
                          systemImage: state.isPlaced(fixtureId: bet.matchId, selName: bet.selection) ? "checkmark" : "doc.on.doc")
                        .font(zalando(.bold, 13))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().fill(Brand.accent(scheme)))
                        .foregroundStyle(.white)
                }
                .buttonStyle(SquishButtonStyle())
                Spacer()
                VStack(alignment: .trailing) {
                    Text(fractionalOdds(bet.odds)).font(zalando(.black, 15))
                    Text(bet.match).font(zalando(.regular, 10)).foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
    }
}

struct ConversationRow: View {
    let convo: Conversation
    let lastLine: String

    var body: some View {
        NavigationLink {
            ThreadView(convo: convo)
        } label: {
            HStack(spacing: 12) {
                ConvoAvatar(convo: convo)
                VStack(alignment: .leading, spacing: 2) {
                    Text(convo.who).font(zalando(.bold, 14))
                    Text(lastLine)
                        .font(zalando(.regular, 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(zalando(.bold, 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

struct ConvoAvatar: View {
    let convo: Conversation
    var body: some View {
        ZCircle(letter: String(convo.who.prefix(1)), colorHex: convo.colorHex, size: 44)
    }
}

/// Coloured initials disc; uses the real avatar photo where one exists.
struct FriendAvatar: View {
    let who: String
    var size: CGFloat = 36

    var body: some View {
        if let asset = AvatarAssets.photo(for: who) {
            Image(uiImage: asset)
                .resizable().scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            ZCircle(letter: String(who.prefix(1)),
                    colorHex: "#A6BE47", size: size)
        }
    }
}

struct ZCircle: View {
    let letter: String
    let colorHex: String
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color(hexString: colorHex))
            .frame(width: size, height: size)
            .overlay(
                Text(letter)
                    .font(zalando(.black, size * 0.42))
                    .foregroundStyle(.white)
            )
    }
}
