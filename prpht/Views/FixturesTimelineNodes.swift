//
//  FixturesTimelineNodes.swift
//  prpht
//
//  Orb nodes, avatar rings, and the expanded fixture card (copy bet, watch
//  party, add to calendar).
//

import SwiftUI
import EventKit

// MARK: - Orb node

struct FixtureOrbNode: View {
    let cluster: FixtureCluster
    let isNext: Bool
    let party: WatchParty?
    let expanded: Bool
    @Environment(\.colorScheme) private var scheme
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 6) {
            orb
            VStack(spacing: 1) {
                Text(isNext ? "Next up" : cluster.info.time)
                    .font(zalando(.bold, 10))
                    .kerning(1)
                    .textCase(.uppercase)
                    .foregroundStyle(isNext ? Brand.textBrand : Color.secondary)
                Text(cluster.match)
                    .font(zalando(.bold, 12))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 150)
                if party != nil {
                    HStack(spacing: 3) {
                        Circle().fill(Brand.textBrand).frame(width: 5, height: 5)
                        Text("Watch party").font(zalando(.bold, 9))
                            .foregroundStyle(Brand.textBrand)
                    }
                }
            }
        }
        .onAppear {
            guard isNext else { return }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var orb: some View {
        let glow = Circle()
            .fill(RadialGradient(colors: [Color(hexString: "#D6E0A8"),
                                          Color(hexString: "#A6BE47"),
                                          Color(hexString: "#3E5210")],
                                 center: UnitPoint(x: 0.32, y: 0.28),
                                 startRadius: 2, endRadius: 46))
            .frame(width: 64, height: 64)
            .blur(radius: 16)
            .opacity(0.8)

        let pulseRing = Circle()
            .fill(Brand.accent(scheme).opacity(pulse ? 0.55 : 0.15))
            .frame(width: pulse ? 78 : 66, height: pulse ? 78 : 66)

        let ring = Circle()
            .stroke(Brand.accent(scheme), lineWidth: expanded ? 4 : 2)
            .opacity(expanded ? 1 : 0.4)
            .frame(width: 64, height: 64)

        return ZStack {
            glow
            if isNext { pulseRing }
            ring
            orbCount
            avatars
        }
        .frame(width: 96, height: 96)
    }

    private var orbCount: some View {
        VStack(spacing: 1) {
            Text("\(cluster.bets.count)")
                .font(zalando(.black, 18))
                .foregroundStyle(Color(hexString: "#3E5210"))
            Text(cluster.bets.count == 1 ? "BET" : "BETS")
                .font(zalando(.bold, 8))
                .kerning(1)
                .foregroundStyle(Color(hexString: "#3E5210").opacity(0.8))
        }
    }

    private var avatars: some View {
        ForEach(Array(orbitingPeople.enumerated()), id: \.offset) { k, who in
            orbitAvatar(who: who, index: k, total: orbitingPeople.count)
        }
    }

    private func orbitAvatar(who: String, index k: Int, total: Int) -> some View {
        let angle = (-140 + (Double(k) * (260.0 / Double(max(1, total - 1))))) * .pi / 180
        return FriendAvatar(who: who, size: 24)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .offset(x: cos(angle) * 46, y: sin(angle) * 46)
    }

    private var orbitingPeople: [String] {
        Array(cluster.people.prefix(5))
    }
}

// MARK: - Expanded card

struct ExpandedFixtureCard: View {
    let cluster: FixtureCluster
    let party: WatchParty?
    @ObservedObject var state: AppState
    let organise: () -> Void
    let toggleGoing: () -> Void
    let close: () -> Void
    @Environment(\.colorScheme) private var scheme
    @State private var calendarToast: String? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture(perform: close)

            VStack(alignment: .leading, spacing: 12) {
                headerRow
                Text(cluster.match).font(zalando(.heavy, 17))
                watchPartySection
                betsSection
                calendarButton
                Button(action: close) {
                    Text("Close").font(zalando(.bold, 11))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(scheme == .dark ? Color(white: 0.13) : .white)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Brand.accent(scheme).opacity(0.5)))
                    .shadow(color: .black.opacity(0.25), radius: 18, y: 8)
            )
            .padding(.horizontal, 20)
        }
    }

    private var headerRow: some View {
        HStack {
            Text("\(cluster.info.league) · Aintree")
                .font(zalando(.semibold, 10))
                .foregroundStyle(.secondary)
            Spacer()
            Text(cluster.info.time)
                .font(zalando(.semibold, 10))
                .foregroundStyle(Brand.textBrand)
        }
    }

    @ViewBuilder
    private var watchPartySection: some View {
        if let p = party {
            VStack(alignment: .leading, spacing: 6) {
                Text("WATCH PARTY")
                    .font(zalando(.bold, 9)).kerning(1.2)
                    .foregroundStyle(Brand.textBrand)
                Text(p.venue).font(zalando(.bold, 14))
                Text("\(p.when) · \(p.going.count) going")
                    .font(zalando(.regular, 11)).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Button(action: toggleGoing) {
                        Text(p.going.contains("You") ? "You're going" : "I'm in")
                            .font(zalando(.bold, 11))
                            .foregroundStyle(p.going.contains("You") ? Color.primary : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .fill(p.going.contains("You") ? Color.primary.opacity(0.12) : Brand.accent(scheme)))
                    }
                    .buttonStyle(SquishButtonStyle())
                    NavigationLink {
                        if let convo = state.conversations.first(where: { $0.id == "wp-\(cluster.id)" }) {
                            ThreadView(convo: convo)
                        }
                    } label: {
                        Text("Group chat")
                            .font(zalando(.bold, 11))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.primary.opacity(0.15)))
                    }
                    .buttonStyle(SquishButtonStyle())
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12)
                .fill(Brand.accent(scheme).opacity(0.08)))
        } else {
            Button(action: organise) {
                Text("Organise watch party")
                    .font(zalando(.bold, 12))
                    .foregroundStyle(Brand.textBrand)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Brand.whiteGrape))
            }
            .buttonStyle(SquishButtonStyle())
        }
    }

    @ViewBuilder
    private var betsSection: some View {
        if cluster.bets.isEmpty {
            Text("No bets from your friends yet")
                .font(zalando(.regular, 12)).foregroundStyle(.secondary)
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 6) {
                    ForEach(Array(cluster.bets.enumerated()), id: \.offset) { _, b in
                        betRow(b)
                    }
                }
            }
            .frame(maxHeight: 210)
        }
    }

    private func betRow(_ b: FriendBet) -> some View {
        HStack(spacing: 10) {
            FriendAvatar(who: b.who, size: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(b.who) · \(b.selection)")
                    .font(zalando(.bold, 11)).lineLimit(1)
                Text(b.line)
                    .font(zalando(.regular, 10)).foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            Text(fractionalOdds(b.odds))
                .font(zalando(.semibold, 11))
                .foregroundStyle(Color(hexString: "#61AD34"))
            Button {
                copyBet(b)
            } label: {
                Text(state.isPlaced(fixtureId: b.matchId, selName: b.selection) ? "Copied" : "Copy")
                    .font(zalando(.bold, 10))
                    .foregroundStyle(state.isPlaced(fixtureId: b.matchId, selName: b.selection) ? Color.secondary : Brand.textBrand)
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(state.isPlaced(fixtureId: b.matchId, selName: b.selection) ? Color.secondary.opacity(0.4) : Brand.whiteGrape))
            }
            .buttonStyle(SquishButtonStyle())
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8)
            .fill(Color.primary.opacity(0.05)))
    }

    private func copyBet(_ b: FriendBet) {
        let fx = state.fixture(id: b.matchId)
        let sel = fx?.selections.first { $0.name == b.selection }
            ?? Sel(name: b.selection, odds: b.odds, line: b.line)
        withAnimation { state.placeBet(fixtureId: b.matchId, sel: sel) }
        state.showToast("Copied \(b.who)'s bet")
    }

    // MARK: Calendar (iOS enhancement)

    private var calendarButton: some View {
        Button {
            addToCalendar()
        } label: {
            Label("Add to calendar", systemImage: "calendar.badge.plus")
                .font(zalando(.bold, 11))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.06)))
        }
        .buttonStyle(SquishButtonStyle())
    }

    private func addToCalendar() {
        let store = EKEventStore()
        if #available(iOS 17.0, *) {
            store.requestFullAccessToEvents { granted, _ in
                self.finishCalendarRequest(granted: granted, store: store)
            }
        } else {
            store.requestAccess(to: .event) { granted, _ in
                self.finishCalendarRequest(granted: granted, store: store)
            }
        }
    }

    private func finishCalendarRequest(granted: Bool, store: EKEventStore) {
        DispatchQueue.main.async {
            guard granted else {
                state.showToast("Calendar access denied")
                return
            }
            let event = EKEvent(eventStore: store)
            event.title = "\(cluster.match)\(party != nil ? " — watch party" : "")"
            event.startDate = KickoffParser.date(from: cluster.info.time) ?? Date().addingTimeInterval(3600)
            event.endDate = event.startDate.addingTimeInterval(2 * 3600)
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(event, span: .thisEvent)
                state.showToast("Added to calendar")
            } catch {
                state.showToast("Couldn't save event")
            }
        }
    }
}

// Parses kickoff strings like "17:30 - Sat 26 Jul" or "16:00 - Tomorrow".
enum KickoffParser {
    static func date(from s: String) -> Date? {
        // "HH:mm - <rest>"
        let parts = s.components(separatedBy: " - ")
        guard parts.count == 2 else { return nil }
        let timeParts = parts[0].components(separatedBy: ":")
        guard timeParts.count == 2,
              let h = Int(timeParts[0]), let m = Int(timeParts[1]) else { return nil }

        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = h; comps.minute = m

        let day = parts[1].lowercased()
        if day.contains("tomorrow") {
            return cal.date(byAdding: .day, value: 1, to: cal.date(from: comps) ?? Date())
        }
        if day.contains("today") {
            return cal.date(from: comps)
        }
        // Weekday names like "Sat 26 Jul" — year defaults to 2000, so rebuild
        // with the current year.
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_GB")
        df.dateFormat = "EEE d MMM"
        if let parsed = df.date(from: parts[1]) {
            let year = cal.component(.year, from: Date())
            var parsedComps = cal.dateComponents([.month, .day], from: parsed)
            parsedComps.year = year
            // If that date is more than a month in the past, roll forward a year.
            if let built = cal.date(from: parsedComps),
               built.timeIntervalSinceNow < -30 * 86400 {
                parsedComps.year = year + 1
            }
            comps.month = parsedComps.month
            comps.day = parsedComps.day
            return cal.date(from: comps)
        }
        // Relative days like "Tomorrow"/"Today" combined with a weekday name
        // the parser missed, or bare text — treat unknown as today+1 week so it
        // sorts after concrete dates but still appears on the map.
        if day.contains("week") { return cal.date(byAdding: .day, value: 7, to: Date()) }
        return nil
    }
}
