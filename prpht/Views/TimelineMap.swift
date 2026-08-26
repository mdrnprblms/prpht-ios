//
//  TimelineMap.swift
//  prpht
//
//  The snaking pathway + orb nodes, sized explicitly so ScrollView gives it
//  real height (GeometryReader alone collapses inside a ScrollView).
//

import SwiftUI

struct TimelineMap: View {
    let clusters: [FixtureCluster]
    let watchParties: [String: WatchParty]
    @Binding var expanded: String?
    @Environment(\.colorScheme) private var scheme

    private let spacing: CGFloat = 172
    private let padBottom: CGFloat = 96
    private let padTop: CGFloat = 84
    private let amplitude: CGFloat = 25   // % either side of centre
    @State private var mapWidth: CGFloat = 0

    /// index in `clusters` == chronological position; i=0 is soonest (bottom).
    private func nodeX(_ i: Int) -> CGFloat {
        mapWidth * (0.5 + amplitude / 100 * sin(Double(i) * 1.05 + 0.5))
    }
    private func nodeY(_ i: Int, height: CGFloat) -> CGFloat {
        height - padBottom - CGFloat(i) * spacing
    }
    private var mapHeight: CGFloat {
        padBottom + padTop + spacing * CGFloat(max(0, clusters.count - 1))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            pathLayer
            nodeLayer
        }
        .frame(height: mapHeight)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { mapWidth = geo.size.width }
                    .onChange(of: geo.size.width) { mapWidth = $0 }
            }
        )
    }

    private func curvePoints() -> [CGPoint] {
        clusters.enumerated().map { i, _ in
            CGPoint(x: nodeX(i), y: nodeY(i, height: mapHeight))
        }
    }

    private func snakePath() -> Path {
        var p = Path()
        let pts = curvePoints()
        guard let first = pts.first else { return p }
        p.move(to: first)
        for (i, pt) in pts.enumerated() where i > 0 {
            let prev = pts[i - 1]
            let k = spacing * 0.45
            p.addCurve(to: pt,
                       control1: CGPoint(x: prev.x, y: prev.y - k),
                       control2: CGPoint(x: pt.x, y: pt.y + k))
        }
        return p
    }

    private var pathLayer: some View {
        let path = snakePath()
        return ZStack {
            path.stroke(Brand.accent(scheme).opacity(0.25),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round))
            path.stroke(Brand.accent(scheme),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round,
                                           dash: [1, 9]))
        }
    }

    private var nodeLayer: some View {
        ForEach(Array(clusters.enumerated()), id: \.element.id) { i, c in
            FixtureOrbNode(
                cluster: c,
                isNext: i == 0,
                party: watchParties[c.id],
                expanded: expanded == c.id
            )
            .position(x: nodeX(i), y: nodeY(i, height: mapHeight))
            .id(c.id)
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expanded = (expanded == c.id) ? nil : c.id
                }
            }
        }
    }
}
