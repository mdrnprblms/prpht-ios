//
//  AppState.swift
//  prpht
//
//  Central observable state: feed, betslip, balance, settlement simulation,
//  friends feed and group-bet sweepstakes. Ports the JS globals + logic.
//

import Foundation
import SwiftUI

// MARK: - Odds helpers (ports of driftOdds / getFraction / winChance)

let oddsLadder: [Double] = [
    1.20, 1.25, 1.30, 1.40, 1.50, 1.60, 1.65, 1.70, 1.75, 1.80, 1.90,
    2.00, 2.10, 2.20, 2.25, 2.40, 2.50, 2.60, 2.75, 2.90, 3.00, 3.20,
    3.40, 3.50, 3.75, 4.00, 4.20, 4.50, 5.00, 5.50, 6.00, 6.50, 7.00,
    7.50, 8.00, 9.00, 10.00, 11.00, 13.00, 15.00, 17.00, 21.00, 23.00,
    26.00, 29.00, 34.00, 41.00, 51.00, 67.00
]
let oddsDrift = 2

func driftOdds(_ odds: Double) -> Double {
    var nearest = 0
    for i in 1..<oddsLadder.count {
        if abs(oddsLadder[i] - odds) < abs(oddsLadder[nearest] - odds) { nearest = i }
    }
    let step = Int.random(in: -oddsDrift...oddsDrift)
    return oddsLadder[min(oddsLadder.count - 1, max(0, nearest + step))]
}

func fractionalOdds(_ decimal: Double) -> String {
    let profit = decimal - 1
    guard profit > 0 else { return "1/1" }
    var n = Int((profit * 100).rounded()), d = 100
    func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }
    let cd = gcd(max(n, 1), d)
    return "\(n / cd)/\(d / cd)"
}

/// Settlement model: implied probability reshaped by curve, clamped.
struct SimParams { var curve = 0.88; var floor = 0.03; var ceiling = 0.92 }
var simParams = SimParams()

func winChance(odds: Double) -> Double {
    guard odds > 1 else { return simParams.ceiling }
    let fair = 1 / odds
    return min(simParams.ceiling, max(simParams.floor, pow(fair, simParams.curve)))
}

// MARK: - Bet slip

struct SlipBet: Identifiable, Equatable {
    let id: String
    let matchId: String
    let selection: String
    let match: String
    let odds: Double
    var stake: Double = 1.00
    /// Settlement result once the simulation has run for this leg.
    var outcome: LegOutcome? = nil
}

enum LegOutcome: Equatable { case won(returns: Double); case lost }

struct HistoryEntry: Identifiable {
    let id = UUID()
    let label: String
    let match: String
    let odds: Double
    let stake: Double
    let won: Bool
    let returns: Double
    let type: String
    let when: Date
}

enum FeedPage: Int, CaseIterable {
    case forYou = 0, betslip, fixtures, friends

    var label: String {
        switch self {
        case .forYou:   return "For You"
        case .betslip:  return "Betslip"
        case .fixtures: return "Fixtures"
        case .friends:  return "Friends"
        }
    }
}

// MARK: - Group bets (sweepstakes)

struct NewGroupBetDraft {
    var name = ""
    var customMode = false
    var customQuestion = ""
    var customResponses: [String] = []
    var selectedEvent = 0
    var invitedFriends: Set<String> = []
    var phoneNumbers: [String] = []
}

// MARK: - App state

@MainActor
final class AppState: ObservableObject {
    // Feed
    @Published var currentSport = "For You"
    @Published var feed: [Fixture] = []
    @Published var page: FeedPage = .forYou

    // Betslip
    @Published var bets: [SlipBet] = []
    @Published var slipExpanded = false
    @Published var simulating = false
    @Published var settled = false
    @Published var settlementNote: SettlementNote? = nil
    @Published var toast: String? = nil

    // Account
    @Published var balance = 10.00
    let startingBalance = 10.00
    @Published var betHistory: [HistoryEntry] = []

    // Social
    @Published var conversations: [Conversation] = conversationsData
    @Published var sweepstakes: [Sweepstake] = sweepstakesSeed
    @Published var joinedSweeps: Set<String> = []
    @Published var sweepPicks: [String: String] = [:]   // sweepId -> runner

    // New group bet sheet
    @Published var showNewGroupBet = false
    @Published var newBet = NewGroupBetDraft()

    private var toastTask: Task<Void, Never>? = nil

    struct SettlementNote { let net: Double; let returned: Double }

    init() {
        rebuildFeed()
    }

    // MARK: Feed building (port of buildFeed)

    func rebuildFeed() {
        var out: [Fixture] = []
        for sport in sportsList {
            let pool = demoFixtures.filter { $0.sport == sport }.shuffled()
            let drifted = pool.map { fx -> Fixture in
                var f = fx
                f.likes = Int.random(in: 12..<162)
                return Fixture(id: f.id, sport: f.sport, colorHex: f.colorHex,
                               league: f.league, time: f.time, match: f.match,
                               market: f.market,
                               selections: f.selections.map {
                                   Sel(name: $0.name, odds: driftOdds($0.odds), line: $0.line)
                               },
                               target: Int.random(in: 0..<f.selections.count),
                               likes: f.likes)
            }
            out.append(contentsOf: drifted)
        }
        // For You folds in three prediction markets on every visit.
        if let fyIdx = sportsList.firstIndex(of: "For You") {
            let picks = demoFixtures.filter { $0.id.hasPrefix("pm") }.shuffled().prefix(3)
            let folded = picks.map { fx -> Fixture in
                var copies = demoFixtures.first { $0.id == fx.id }!
                _ = copies
                return Fixture(id: fx.id, sport: "For You", colorHex: fx.colorHex,
                               league: fx.league, time: fx.time, match: fx.match,
                               market: fx.market,
                               selections: fx.selections.map {
                                   Sel(name: $0.name, odds: driftOdds($0.odds), line: $0.line)
                               },
                               target: Int.random(in: 0..<fx.selections.count),
                               likes: Int.random(in: 12..<162))
            }
            out.insert(contentsOf: folded, at: indexForInsert(sportCount: fyIdx))
        }
        feed = out
    }

    private func indexForInsert(sportCount: Int) -> Int {
        // Insert after the For You strand: For You is first in sportsList.
        return demoFixtures.filter { $0.sport == "For You" }.count
    }

    func fixtures(for sport: String) -> [Fixture] {
        feed.filter { $0.sport == sport }
    }

    func fixture(id: String) -> Fixture? {
        feed.first { $0.id == id } ?? demoFixtures.first { $0.id == id }
    }

    // MARK: Toast

    func showToast(_ msg: String) {
        toast = msg
        toastTask?.cancel()
        toastTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_900_000_000)
            if !Task.isCancelled { self?.toast = nil }
        }
    }

    // MARK: Bet placement (port of placeBet)

    func placeBet(fixtureId: String, sel: Sel) {
        if simulating { showToast("Simulation in progress"); return }
        if settled { startNewSlip() }

        let betId = "\(fixtureId):\(sel.name)"
        if bets.contains(where: { $0.id == betId }) {
            removeBet(id: betId)
            return
        }
        // One bet per match: replacing swaps the selection.
        if let existing = bets.first(where: { $0.matchId == fixtureId }) {
            bets.removeAll { $0.id == existing.id }
        }
        bets.append(SlipBet(id: betId, matchId: fixtureId, selection: sel.name,
                            match: fixture(id: fixtureId)?.match ?? "", odds: sel.odds))
        objectWillChange.send()
    }

    func isPlaced(fixtureId: String, selName: String) -> Bool {
        bets.contains { $0.id == "\(fixtureId):\(selName)" }
    }

    func setStake(betId: String, _ stake: Double) {
        guard !simulating else { return }
        guard let idx = bets.firstIndex(where: { $0.id == betId }) else { return }
        var s = (stake * 20).rounded() / 20          // snap to 5p grid
        s = min(1, max(0.05, s))
        bets[idx].stake = s
    }

    func removeBet(id: String) {
        if simulating { return }
        if settled { startNewSlip(); return }
        bets.removeAll { $0.id == id }
    }

    func startNewSlip() {
        guard !simulating else { return }
        bets = []
        settled = false
        settlementNote = nil
    }

    func clearSlip() {
        guard !simulating else { return }
        settled = false
        bets = []
        settlementNote = nil
        slipExpanded = false
    }

    // Totals (port of setSlipStake math)
    var hasAcca: Bool { bets.count > 1 }
    var totalStake: Double {
        bets.reduce(0) { $0 + $1.stake } + (hasAcca ? 1 : 0)
    }
    var totalReturns: Double {
        bets.reduce(0) { $0 + $1.odds * $1.stake } +
        (hasAcca ? bets.reduce(1.0) { $0 * $1.odds } : 0)
    }
    var accaOdds: Double { bets.reduce(1.0) { $0 * $1.odds } }

    // MARK: Settlement simulation (port of runSimulation)

    func runSimulation() async {
        if simulating { return }
        if settled { clearSlip(); return }
        guard !bets.isEmpty else { showToast("Add a bet first"); return }

        let legs = bets
        let acca = hasAcca
        let stake = totalStake

        guard stake <= balance + 1e-9 else {
            showToast("Not enough balance for \(money(stake))")
            return
        }

        simulating = true
        settlementNote = nil
        for i in bets.indices { bets[i].outcome = nil }
        balance -= stake

        var returned = 0.0
        var outcomes: [Bool] = []

        for leg in legs {
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            let won = Double.random(in: 0...1) < winChance(odds: leg.odds)
            outcomes.append(won)
            let ret = won ? leg.odds * leg.stake : 0
            returned += ret
            if won { balance += ret }
            if let i = bets.firstIndex(where: { $0.id == leg.id }) {
                bets[i].outcome = won ? .won(returns: ret) : .lost
            }
            betHistory.insert(HistoryEntry(label: leg.selection, match: leg.match,
                                           odds: leg.odds, stake: leg.stake,
                                           won: won, returns: ret, type: "Single",
                                           when: Date()), at: 0)
        }

        if acca {
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            let accaWon = outcomes.allSatisfy { $0 }
            let ret = accaWon ? accaOdds : 0
            returned += ret
            if accaWon { balance += ret }
            betHistory.insert(HistoryEntry(
                label: "\(legs.count)-fold Accumulator",
                match: legs.map(\.selection).joined(separator: " / "),
                odds: accaOdds, stake: 1, won: accaWon, returns: ret,
                type: "Acca", when: Date()), at: 0)
        }

        let net = returned - stake
        simulating = false
        settled = true
        settlementNote = SettlementNote(net: net, returned: returned)
        showToast(net >= 0 ? "Up \(money(net))!" : "Down \(money(abs(net)))")
    }

    // MARK: Account stats

    var placed: Int { betHistory.count }
    var wonCount: Int { betHistory.filter(\.won).count }
    var winRate: String {
        placed == 0 ? "–" : "\(Int((Double(wonCount) / Double(placed) * 100).rounded()))%"
    }
    var profitLoss: Double {
        betHistory.reduce(0) { $0 + ($1.returns - $1.stake) }
    }

    func resetDemo() {
        balance = startingBalance
        betHistory = []
        bets = []
        settled = false
        settlementNote = nil
        joinedSweeps = []
        sweepPicks = [:]
        rebuildFeed()
    }

    // MARK: Conversations

    func lastLine(_ c: Conversation) -> String {
        guard let m = c.msgs.last else { return "" }
        return m.kindBet ? "🎯 \(m.line)" : m.text
    }

    // MARK: Group bets

    func join(_ s: Sweepstake, pick runner: String) {
        guard !joined(s) else { return }
        joinedSweeps.insert(s.id)
        sweepPicks[s.id] = runner
        sweepstakes.appendTo(id: s.id) { $0.entrants.append(SweepEntrant(who: "You")) }
        showToast("You're in · \(runner)")
    }

    func joined(_ s: Sweepstake) -> Bool { joinedSweeps.contains(s.id) }

    func createGroupBet() {
        let runners = newBet.customMode
            ? newBet.customResponses
            : sweepEvents[newBet.selectedEvent].runners
        let event = newBet.customMode ? newBet.customQuestion : sweepEvents[newBet.selectedEvent].event
        let name = newBet.name.isEmpty ? event : newBet.name
        let id = "s\(UUID().uuidString.prefix(6))"
        var entrants = newBet.invitedFriends.map { SweepEntrant(who: $0) }
        entrants.append(SweepEntrant(who: "You"))
        sweepstakes.insert(Sweepstake(id: id, name: name, host: "You", event: event,
                                      runners: runners.isEmpty ? ["TBD"] : runners,
                                      entrants: entrants, status: "open"), at: 0)
        let count = newBet.invitedFriends.count + newBet.phoneNumbers.count
        newBet = NewGroupBetDraft()
        showNewGroupBet = false
        showToast("Group bet created · \(count) invited")
    }
}

extension Array where Element == Sweepstake {
    subscript(id key: String) -> Sweepstake? {
        get { firstIndex(where: { $0.id == key }).map { self[$0] } }
    }
    mutating func appendTo(id key: String, _ mutate: (inout Sweepstake) -> Void) {
        if let i = firstIndex(where: { $0.id == key }) { mutate(&self[i]) }
    }
}
