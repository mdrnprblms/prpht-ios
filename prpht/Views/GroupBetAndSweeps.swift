//
//  GroupBetAndSweeps.swift
//  prpht
//
//  New group bet sheet (slides up from the bottom) + group bet list rows.
//

import SwiftUI

struct NewGroupBetSheet: View {
    @ObservedObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Office sweep", text: $state.newBet.name)
                }

                Section {
                    Toggle(isOn: $state.newBet.customMode) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Custom question")
                            Text("Ask your own instead of picking a fixture")
                                .font(zalando(.regular, 11)).foregroundStyle(.secondary)
                        }
                    }
                    .tint(Brand.accent(scheme))

                    if state.newBet.customMode {
                        TextField("Your question", text: $state.newBet.customQuestion)
                        responsesEditor
                    } else {
                        Picker("Event", selection: $state.newBet.selectedEvent) {
                            ForEach(Array(sweepEvents.enumerated()), id: \.offset) { i, e in
                                Text(e.event).tag(i)
                            }
                        }
                        let runners = sweepEvents[state.newBet.selectedEvent].runners
                        Text("Runners: " + runners.joined(separator: " · "))
                            .font(zalando(.regular, 11)).foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Question")
                }

                Section("Invite friends") {
                    ForEach(allFriends, id: \.self) { f in
                        Button {
                            if state.newBet.invitedFriends.contains(f) {
                                state.newBet.invitedFriends.remove(f)
                            } else {
                                state.newBet.invitedFriends.insert(f)
                            }
                        } label: {
                            HStack {
                                FriendAvatar(who: f, size: 30)
                                Text(f).foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: state.newBet.invitedFriends.contains(f)
                                      ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(state.newBet.invitedFriends.contains(f)
                                                     ? Brand.accent(scheme) : Color.secondary.opacity(0.4))
                            }
                        }
                    }
                    PhoneInvites(state: state)
                }

                Section {
                    Button {
                        state.createGroupBet()
                        dismiss()
                    } label: {
                        Text("Create group bet")
                            .font(zalando(.bold, 16))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Brand.accent(scheme))
                    .disabled(!canCreate)
                } footer: {
                    Text("£1 flat entry · the whole pot goes to the winner · 0% fees.")
                }
            }
            .navigationTitle("New group bet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Brand.brandText(scheme))
                }
            }
        }
        .presentationDetents([.large])
    }

    private var canCreate: Bool {
        state.newBet.customMode
            ? !state.newBet.customResponses.isEmpty && !state.newBet.customQuestion.isEmpty
            : true
    }

    @ViewBuilder
    private var responsesEditor: some View {
        HStack {
            TextField("Answer option", text: Binding(
                get: { draftResponse },
                set: { draftResponse = $0 }
            ))
            Button("Add") {
                let v = draftResponse.trimmingCharacters(in: .whitespaces)
                    .reduce("") { acc, ch in
                        // collapse whitespace runs like the web's \s+ replace
                        ("  \n\t\r".contains(ch) && acc.last.map("  \n\t\r".contains) == true)
                            ? acc : acc + String(ch)
                    }
                    .trimmingCharacters(in: .whitespaces)
                guard !v.isEmpty else { return }
                let dup = state.newBet.customResponses.contains { $0.lowercased() == v.lowercased() }
                guard !dup else { state.showToast("Already added"); draftResponse = ""; return }
                guard state.newBet.customResponses.count < 8 else {
                    state.showToast("Eight answers max"); return
                }
                state.newBet.customResponses.append(v)
                draftResponse = ""
            }
            .font(zalando(.bold, 13))
        }
        if !state.newBet.customResponses.isEmpty {
            FlowChips(items: state.newBet.customResponses) { i in
                state.newBet.customResponses.remove(at: i)
            }
        }
    }

    @State private var draftResponse = ""
}

struct PhoneInvites: View {
    @ObservedObject var state: AppState
    @State private var phone = ""

    var body: some View {
        HStack {
            TextField("+44 phone number", text: $phone)
                .keyboardType(.phonePad)
            Button("Add") {
                let v = phone.trimmingCharacters(in: .whitespaces)
                guard !v.isEmpty else { return }
                state.newBet.phoneNumbers.append(v)
                phone = ""
            }
            .font(zalando(.bold, 13))
        }
        ForEach(Array(state.newBet.phoneNumbers.enumerated()), id: \.offset) { i, p in
            HStack {
                Image(systemName: "phone")
                Text(p).font(zalando(.regular, 13))
                Spacer()
                Button {
                    state.newBet.phoneNumbers.remove(at: i)
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
                }
            }
        }
    }
}

/// Simple wrap of chips with remove buttons (custom answers).
struct FlowChips: View {
    let items: [String]
    let onRemove: (Int) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 6)], spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                HStack(spacing: 5) {
                    Text(item).font(zalando(.bold, 11)).lineLimit(1)
                    Button { onRemove(i) } label: {
                        Image(systemName: "xmark").font(zalando(.black, 9))
                    }
                }
                .padding(.horizontal, 9).padding(.vertical, 5)
                .background(Capsule().fill(Brand.sageLight))
                .overlay(Capsule().strokeBorder(Brand.sageBorder))
                .foregroundStyle(Brand.textBrand)
            }
        }
    }
}

// MARK: - Sweep rows (group bets list)

struct SweepRow: View {
    let sweep: Sweepstake
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    private var joined: Bool { state.joined(sweep) }
    private var pot: Double { Double(sweep.entrants.count) * 1.00 }

    var body: some View {
        NavigationLink {
            SweepDetail(sweep: sweep, state: state)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(sweep.name).font(zalando(.bold, 14)).lineLimit(1)
                    Spacer()
                    Text(money(pot)).font(zalando(.black, 13))
                        .foregroundStyle(Brand.brandText(scheme))
                }
                Text("\(sweep.event) · hosted by \(sweep.host) · \(sweep.entrants.count) entrants")
                    .font(zalando(.regular, 11)).foregroundStyle(.secondary)
                if joined {
                    Label("You're in — \(state.sweepPicks[sweep.id] ?? "")",
                          systemImage: "checkmark.seal.fill")
                        .font(zalando(.bold, 11))
                        .foregroundStyle(Brand.winGreen)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

struct SweepDetail: View {
    let sweep: Sweepstake
    @ObservedObject var state: AppState
    @Environment(\.colorScheme) private var scheme

    private var joined: Bool { state.joined(sweep) }

    var body: some View {
        List {
            Section {
                LabeledRow("Event", sweep.event)
                LabeledRow("Host", sweep.host)
                LabeledRow("Pot", money(Double(sweep.entrants.count)))
                LabeledRow("Status", sweep.status.capitalized)
            } header: {
                Text("Details")
            } footer: {
                Text("Every £1 goes into the pot and the whole pot goes to the winner. prpht doesn't take a penny – we just run the group chat.")
            }

            Section("Runners") {
                if joined {
                    Text("Your pick: \(state.sweepPicks[sweep.id] ?? "")")
                        .font(zalando(.bold, 13)).foregroundStyle(Brand.winGreen)
                } else {
                    ForEach(sweep.runners, id: \.self) { r in
                        Button {
                            state.join(sweep, pick: r)
                        } label: {
                            HStack {
                                Text(r).foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "hand.tap").foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }

            Section("Entrants (\(sweep.entrants.count))") {
                ForEach(Array(sweep.entrants.enumerated()), id: \.offset) { _, e in
                    HStack(spacing: 10) {
                        FriendAvatar(who: e.who, size: 28)
                        Text(e.who)
                    }
                }
            }
        }
        .navigationTitle(sweep.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LabeledRow: View {
    let label: String
    let value: String
    init(_ label: String, _ value: String) { self.label = label; self.value = value }
    var body: some View {
        HStack { Text(label); Spacer(); Text(value).foregroundStyle(.secondary) }
    }
}
