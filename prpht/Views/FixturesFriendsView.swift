//
//  FixturesFriendsView.swift
//  prpht
//
//  Fixtures timeline (bets grouped by match) + Friends split page
//  (friends' bets carousel on top, messages list below).
//

import SwiftUI

// MARK: - Fixtures timeline

struct FixturesView: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Fixtures").font(.system(size: 26, weight: .heavy))
                Spacer()
                BalancePill(state: state)
                AccountButton(state: state).padding(.leading, 10)
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 4)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    ForEach(fixtureOrder, id: \.self) { mid in
                        if let meta = fixtureTimes[mid] {
                            let bets = state.friendsFeedBets(matchId: mid)
                            FixtureCluster(matchId: mid, meta: meta, bets: bets, state: state)
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }
        }
    }
}

struct FixtureCluster: View {
    let matchId: String
    let meta: (when: String, venue: String, comp: String)
    let bets: [FriendBet]
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(meta.when).font(.system(size: 13, weight: .black))
                    Text("\(meta.comp) · \(meta.venue)")
                        .font(.system(size: 11)).foregroundStyle(.secondary)
                }
                Spacer()
                Text(matchTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Brand.brandText(scheme))
            }

            ForEach(bets, id: \.who) { b in
                HStack(spacing: 10) {
                    FriendAvatar(who: b.who, size: 30)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(b.selection).font(.system(size: 13, weight: .bold))
                        Text(b.note).font(.system(size: 11)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(fractionalOdds(b.odds)).font(.system(size: 13, weight: .black))
                        Text(b.ago).font(.system(size: 10)).foregroundStyle(.tertiary)
                    }
                }
                .padding(9)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.045)))
            }
        }
    }

    private var matchTitle: String { bets.first?.match ?? "" }
}

// MARK: - Friends split page

struct FriendsView: View {
    @ObservedObject var state: AppState

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top pane: friends' bets, vertical snap carousel (~55%).
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(friendsFeedData, id: \.who) { b in
                            FriendBetCard(bet: b, state: state)
                                .frame(width: geo.size.width, height: geo.size.height * 0.55)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .frame(height: geo.size.height * 0.55)

                Divider()

                // Messages header with + Group bet.
                HStack {
                    Text("MESSAGES")
                        .font(.system(size: 10, weight: .bold)).tracking(1.5)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        state.newBet = NewGroupBetDraft()
                        state.showNewGroupBet = true
                    } label: {
                        Text("+ Group bet")
                            .font(.system(size: 11, weight: .bold))
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
                    Text(bet.who).font(.system(size: 14, weight: .bold))
                    Text(bet.ago).font(.system(size: 11)).foregroundStyle(.secondary)
                }
                Spacer()
            }

            Spacer()

            Text("🎯 \(bet.line)")
                .font(.system(size: 22, weight: .heavy))
                .lineSpacing(3)

            Text("“\(bet.note)”")
                .font(.system(size: 13, weight: .semibold))
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
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().fill(Brand.accent(scheme)))
                        .foregroundStyle(.white)
                }
                .buttonStyle(SquishButtonStyle())
                Spacer()
                VStack(alignment: .trailing) {
                    Text(fractionalOdds(bet.odds)).font(.system(size: 15, weight: .black))
                    Text(bet.match).font(.system(size: 10)).foregroundStyle(.secondary)
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
                    Text(convo.who).font(.system(size: 14, weight: .bold))
                    Text(lastLine)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
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
                    .font(.system(size: size * 0.42, weight: .black))
                    .foregroundStyle(.white)
            )
    }
}
