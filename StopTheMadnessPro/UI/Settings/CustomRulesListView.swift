//
//  CustomRulesListView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct CustomRulesListView: View {

    @ObservedObject var prefManager: PreferenceManager
    @State private var showingAddEditor: Bool = false
    @State private var selectedDomainToEdit: String? = nil

    public var body: some View {
        List {
            if prefManager.customRules.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "curlybraces")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No Custom Rules Yet")
                        .font(.headline)
                    Text("Tap '+' above to add custom CSS or JavaScript for any website.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(Array(prefManager.customRules.values.sorted(by: { $0.domain < $1.domain }))) { rule in
                    Button {
                        selectedDomainToEdit = rule.domain
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(rule.domain == "*" ? "Global (*)" : rule.domain)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    if !rule.enabled {
                                        Text("DISABLED")
                                            .font(.system(size: 9, weight: .bold))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color.secondary.opacity(0.2))
                                            .foregroundColor(.secondary)
                                            .cornerRadius(4)
                                    }
                                }

                                HStack(spacing: 12) {
                                    if !rule.customCss.isEmpty {
                                        Label("CSS", systemImage: "paintbrush")
                                            .font(.caption2)
                                            .foregroundColor(.purple)
                                    }
                                    if !rule.customJs.isEmpty {
                                        Label("JS", systemImage: "chevron.left.forwardslash.chevron.right")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteRules)
            }
        }
        .navigationTitle("Custom Rules")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddEditor) {
            CustomRuleEditorView(domain: "*", prefManager: prefManager)
        }
        .sheet(item: Binding<CustomRule?>(
            get: { selectedDomainToEdit.flatMap { prefManager.customRules[$0] } },
            set: { selectedDomainToEdit = $0?.domain }
        )) { rule in
            CustomRuleEditorView(domain: rule.domain, prefManager: prefManager)
        }
    }

    private func deleteRules(at offsets: IndexSet) {
        let sortedRules = prefManager.customRules.values.sorted(by: { $0.domain < $1.domain })
        for index in offsets {
            let domain = sortedRules[index].domain
            prefManager.removeCustomRule(domain: domain)
        }
    }
}

