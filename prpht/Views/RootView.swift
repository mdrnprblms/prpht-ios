//
//  RootView.swift
//  prpht
//
//  Four horizontally-paged tabs (For You / Betslip / Fixtures / Friends) with
//  the persistent bottom bar: four page tabs + centre create button, matching
//  the web layout. Sheets slide up from the bottom.
//

import SwiftUI

struct RootView: View {
    @StateObject private var state = AppState()
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            BlobBackgroundView(teamColor: currentTeamColor)
                .ignoresSafeArea()

            TabView(selection: Binding(
                get: { state.page },
                set: { state.page = $0 }
            )) {
                ForYouView(state: state)
                    .tag(FeedPage.forYou)
                BetslipView(state: state)
                    .tag(FeedPage.betslip)
                FixturesTimelineView(state: state)
                    .tag(FeedPage.fixtures)
                FriendsView(state: state)
                    .tag(FeedPage.friends)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: 0) {
                Spacer()
                PageNavBar(state: state)
            }
        }
        .preferredColorScheme(nil)   // follows system, like the web default
        .overlay(alignment: .top) {
            if let toast = state.toast {
                ToastView(text: toast)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.toast)
        // Group bet sheet slides UP from the bottom.
        .sheet(isPresented: $state.showNewGroupBet) {
            NewGroupBetSheet(state: state)
        }
    }

    private var currentTeamColor: Color {
        // Tint toward the sport strand currently in view (web uses the card
        // colour of the centred TikTok card; page-level tint is the port).
        switch state.page {
        case .forYou:   return Brand.whiteGrape
        case .betslip:  return Wash.pacificCyan
        case .fixtures: return Wash.graniteGreen
        case .friends:  return Wash.lavenderBlue
        }
    }
}

// MARK: - Bottom nav bar

struct PageNavBar: View {
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 0) {
            tab(.forYou)
            tab(.betslip)
            plusButton
            tab(.fixtures)
            tab(.friends)
        }
        .frame(height: 56)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Divider().opacity(0.3)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    @ViewBuilder
    private func tab(_ p: FeedPage) -> some View {
        let active = state.page == p
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                state.page = p
            }
        } label: {
            Text(p.label.uppercased())
                .font(zalando(.bold, 10))
                .kerning(1.2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(active ? AnyShapeStyle(Color.white) : AnyShapeStyle(Color.secondary))
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(active ? Brand.accent(scheme) : .clear)
                )
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    /// Centre create (+) button — opens the group bet sheet.
    private var plusButton: some View {
        Button {
            state.newBet = NewGroupBetDraft()
            state.showNewGroupBet = true
        } label: {
            Image(systemName: "plus")
                .font(zalando(.bold, 18))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Brand.accent(scheme)))
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        }
        .buttonStyle(SquishButtonStyle())
        .accessibilityLabel("Create group bet")
    }
}

/// Small press-in effect like the web's active:scale-90.
struct SquishButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Toast

struct ToastView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(zalando(.semibold, 13))
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(Capsule().fill(Color.black.opacity(0.75)))
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
    }
}
