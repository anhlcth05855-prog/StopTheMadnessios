//
//  MainView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct MainView: View {

    @StateObject private var viewModel = BrowserViewModel()
    @StateObject private var prefManager = PreferenceManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Top Address Bar
                AddressBarView(viewModel: viewModel, prefManager: prefManager)

                Divider()

                // Active Web View
                if let currentTab = viewModel.currentTab {
                    StopTheMadnessWebView(
                        tab: currentTab,
                        prefManager: prefManager,
                        onOpenNewTab: { targetUrl in
                            viewModel.addNewTab(url: targetUrl.absoluteString)
                        }
                    )
                    .id(currentTab.id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Spacer()
                }

                // Bottom Navigation Toolbar
                BottomToolbarView(viewModel: viewModel)
            }
        }
        // Sheets
        .sheet(isPresented: $viewModel.isShowingProtectionSheet) {
            ProtectionSheetView(viewModel: viewModel, prefManager: prefManager)
        }
        .sheet(isPresented: $viewModel.isShowingUrlEditor) {
            UrlEditorView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isShowingTabSwitcher) {
            TabSwitcherView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isShowingCustomRuleEditor) {
            CustomRuleEditorView(domain: viewModel.editingDomainForRule, prefManager: prefManager) {
                viewModel.reload()
            }
        }
        .sheet(isPresented: $viewModel.isShowingSettings) {
            SettingsView(prefManager: prefManager)
        }
    }
}

