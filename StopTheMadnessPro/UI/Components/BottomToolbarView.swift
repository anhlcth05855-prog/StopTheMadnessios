//
//  BottomToolbarView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct BottomToolbarView: View {

    @ObservedObject var viewModel: BrowserViewModel
    @State private var showingActionMenu = false

    public var body: some View {
        HStack {
            // Back Button
            Button {
                viewModel.goBack()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(viewModel.currentTab?.canGoBack == true ? .primary : .secondary.opacity(0.4))
            }
            .disabled(viewModel.currentTab?.canGoBack != true)

            Spacer()

            // Forward Button
            Button {
                viewModel.goForward()
            } label: {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(viewModel.currentTab?.canGoForward == true ? .primary : .secondary.opacity(0.4))
            }
            .disabled(viewModel.currentTab?.canGoForward != true)

            Spacer()

            // New Tab (+) Button
            Button {
                viewModel.addNewTab()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }

            Spacer()

            // Tab Switcher Button (with count badge)
            Button {
                viewModel.isShowingTabSwitcher = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    Text("\(viewModel.tabs.count)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }

            Spacer()

            // Overflow Menu
            Menu {
                Button {
                    viewModel.isShowingSettings = true
                } label: {
                    Label("Cài đặt StopTheMadness", systemImage: "gearshape")
                }

                Button {
                    if let host = URL(string: viewModel.currentTab?.url ?? "")?.host {
                        viewModel.editingDomainForRule = host
                    } else {
                        viewModel.editingDomainForRule = "*"
                    }
                    viewModel.isShowingCustomRuleEditor = true
                } label: {
                    Label("Tùy biến CSS / JS trang này", systemImage: "curlybraces")
                }

                Button {
                    viewModel.copyCleanUrl()
                } label: {
                    Label("Sao chép liên kết sạch", systemImage: "doc.on.doc")
                }

                if let currentUrl = viewModel.currentTab?.url, let url = URL(string: currentUrl) {
                    ShareLink(item: url) {
                        Label("Chia sẻ liên kết", systemImage: "square.and.arrow.up")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(Color(.systemBackground))
        .overlay(
            Divider(),
            alignment: .top
        )
    }
}
