//
//  BetslipView.swift
//  prpht
//
//  Traditional betslip page: singles list, stake sliders, accumulator block,
//  settlement simulation with per-leg WON/LOST marking.
//

import SwiftUI

struct BalancePill: View {
    @ObservedObject var state: AppState
    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text("BALANCE")
                .font(.system(size: 8, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(.secondary)
            Text(money(state.balance))
                .font(.system(size: 12, weight: .bold))
        }
    }
}

struct AccountButton: View {
    @ObservedObject var state: AppState
    @State private var show = false
    var body: some View {
        Button { show = true } label: {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 22))
                .foregroundStyle(Color.secondary)
        }
        .sheet(isPresented: $show) { AccountSheet(state: state) }
    }
}

struct BetslipView: View {
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Betslip")
                    .font(.system(size: 26, weight: .heavy))
                Spacer()
                BalancePill(state: state)
                AccountButton(state: state)
                    .padding(.leading, 10)
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 6)

            if state.bets.isEmpty {
                emptyState
            } else {
                slipList
            }

            if !state.bets.isEmpty || state.settled {
                placeSection
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(.tertiary)
            Text("Your slip is empty")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Swipe to For You and tap any market.")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var slipList: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Text("SINGLES").font(.system(size: 11, weight: .bold)).tracking(1.5).foregroundStyle(.secondary)
                    Spacer()
                    Button("Clear all") { state.clearSlip() }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Brand.brandText(scheme))
                }
                .padding(.horizontal, 16)

                ForEach($state.bets) { $bet in
                    SlipRow(bet: $bet, state: state)
                }

                if state.hasAcca {
                    AccaBlock(state: state)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var placeSection: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Total stake").font(.system(size: 15, weight: .semibold))
                Spacer()
                Text(money(state.totalStake)).font(.system(size: 18, weight: .black))
            }
            Button {
                Task { await state.runSimulation() }
            } label: {
                Group {
                    if state.simulating {
                        HStack(spacing: 8) { ProgressView().tint(.white); Text("Simulating…") }
                    } else if state.settled {
                        Text("Bet again")
                    } else {
                        Text("Place bets · \(money(state.totalStake))")
                    }
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Brand.accent(scheme)))
            }
            .disabled(state.simulating)
            .opacity(state.bets.isEmpty && !state.settled ? 0.55 : 1)

            settlementFooter
        }
        .padding(.horizontal, 16).padding(.bottom, 70)
    }

    @ViewBuilder
    private var settlementFooter: some View {
        if let note = state.settlementNote {
            let up = note.net >= 0
            Text(up ? "You won \(money(note.returned)) · up \(money(note.net))"
                    : "Lost \(money(abs(note.net))) · returned \(money(note.returned))")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(up ? Brand.winGreen : Color.red)
        } else {
            Text("Stakes snap to the 5p grid · £1 max. Bet responsibly. 18+.")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Slip row

struct SlipRow: View {
    @Binding var bet: SlipBet
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(bet.selection).font(.system(size: 14, weight: .bold))
                    Text(bet.match).font(.system(size: 11)).foregroundStyle(.secondary)
                }
                Spacer()
                if let outcome = bet.outcome {
                    switch outcome {
                    case .won(let ret):
                        VStack(alignment: .trailing) {
                            Text("WON").font(.system(size: 13, weight: .black)).foregroundStyle(Brand.winGreen)
                            Text("+\(money(ret))").font(.system(size: 10, weight: .semibold)).foregroundStyle(Brand.winGreen)
                        }
                    case .lost:
                        VStack(alignment: .trailing) {
                            Text("LOST").font(.system(size: 13, weight: .black)).foregroundStyle(.red)
                            Text("-\(money(bet.stake))").font(.system(size: 10)).foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text(fractionalOdds(bet.odds))
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Brand.brandText(scheme))
                    Button {
                        withAnimation { state.removeBet(id: bet.id) }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                    .opacity(state.simulating ? 0 : 1)
                }
            }

            if bet.outcome == nil {
                HStack(spacing: 10) {
                    Slider(value: Binding(
                        get: { bet.stake },
                        set: { state.setStake(betId: bet.id, $0); bet.stake = state.bets.first(where: { $0.id == bet.id })?.stake ?? $0 }
                    ), in: 0.05...1, step: 0.05)
                    .tint(Brand.accent(scheme))
                    Text(money(bet.stake))
                        .font(.system(size: 13, weight: .bold))
                        .monospacedDigit()
                        .frame(width: 52, alignment: .trailing)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(
                bet.outcome == .lost ? Color.red.opacity(0.06) :
                (bet.outcome != nil ? Brand.winGreen.opacity(0.08) : Color.primary.opacity(0.05))
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14).strokeBorder(Color.primary.opacity(0.07))
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Accumulator block

struct AccaBlock: View {
    @ObservedObject var state: AppState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(state.bets.count)-fold Accumulator")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Brand.textBrand)
                Text("£1 stake")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.2f", state.accaOdds))
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(Brand.textBrand)
                Text("Returns £\(String(format: "%.2f", state.accaOdds))")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Brand.sageLight))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Brand.sageBorder))
        .padding(.horizontal, 16)
    }
}
