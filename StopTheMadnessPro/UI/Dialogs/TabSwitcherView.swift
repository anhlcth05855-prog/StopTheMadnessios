//
//  TabSwitcherView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct TabSwitcherView: View {

    @ObservedObject var viewModel: BrowserViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(viewModel.tabs.enumerated()), id: \.element.id) { index, tab in
                            TabCardView(
                                tab: tab,
                                isSelected: index == viewModel.currentTabIndex,
                                onSelect: {
                                    viewModel.selectTab(at: index)
                                    dismiss()
                                },
                                onClose: {
                                    withAnimation {
                                        viewModel.closeTab(tab)
                                    }
                                }
                            )
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 70)
                }

                // Bottom New Tab Bar
                HStack {
                    Spacer()

                    Button {
                        viewModel.addNewTab()
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                            Text("Thẻ mới")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }

                    Spacer()
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("Đang mở (\(viewModel.tabs.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        dismiss()
                    }
                    .font(.headline)
                }
            }
        }
    }
}

struct TabCardView: View {
    @ObservedObject var tab: BrowserTab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    Text(tab.title.isEmpty ? "Thẻ mới" : tab.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(6)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Circle())
                    }
                }

                Text(tab.url)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Spacer()

                // Tracker removed badge if any
                if tab.stats.trackersRemoved > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.indigo)
                        Text("\(tab.stats.trackersRemoved) tracker đã chặn")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.indigo)
                    }
                }
            }
            .padding(12)
            .frame(height: 130)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
