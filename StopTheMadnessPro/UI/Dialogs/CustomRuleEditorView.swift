//
//  CustomRuleEditorView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct CustomRuleEditorView: View {

    let initialDomain: String
    @ObservedObject var prefManager: PreferenceManager
    var onSaved: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    @State private var domain: String = ""
    @State private var customCss: String = ""
    @State private var customJs: String = ""
    @State private var isEnabled: Bool = true
    @State private var selectedTab: CodeEditorTab = .css

    public enum CodeEditorTab: String, CaseIterable {
        case css = "Custom CSS"
        case js = "Custom JavaScript"
    }

    public init(
        domain: String,
        prefManager: PreferenceManager = .shared,
        onSaved: (() -> Void)? = nil
    ) {
        self.initialDomain = domain
        self.prefManager = prefManager
        self.onSaved = onSaved
    }

    public var body: some View {
        NavigationView {
            Form {
                // Section: Domain & Status
                Section(
                    header: Text("Target Domain"),
                    footer: Text("Use '*' to apply to all websites or specify an exact domain like 'example.com' or 'youtube.com'.")
                ) {
                    TextField("Domain (e.g. reddit.com or *)", text: $domain)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)

                    Toggle("Enable this rule", isOn: $isEnabled)
                        .tint(Color(red: 0.0, green: 0.48, blue: 1.0))
                }

                // Section: Code Editor Mode Picker
                Section(header: Text("Editor Mode")) {
                    Picker("Code Type", selection: $selectedTab) {
                        ForEach(CodeEditorTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Section: Code Editor with Line Numbers
                Section(header: Text(selectedTab == .css ? "CSS Code (Applied at document_start)" : "JavaScript Code (Injected securely)")) {
                    if selectedTab == .css {
                        LineNumberedCodeEditor(
                            text: $customCss,
                            placeholder: "/* Add custom CSS rules here */\n.ad-banner, .interstitial {\n    display: none !important;\n}"
                        )
                        .frame(minHeight: 220)
                    } else {
                        LineNumberedCodeEditor(
                            text: $customJs,
                            placeholder: "// Add custom JavaScript here\nconsole.log('Running rule for ' + location.hostname);"
                        )
                        .frame(minHeight: 220)
                    }
                }
            }
            .navigationTitle(domain.isEmpty ? "New Rule" : domain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRule()
                        dismiss()
                    }
                    .font(.headline)
                    .disabled(domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                loadExistingRule()
            }
        }
    }

    private func loadExistingRule() {
        let clean = initialDomain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        domain = clean.isEmpty ? "*" : clean

        if let existing = prefManager.getCustomRules()[domain] {
            customCss = existing.customCss
            customJs = existing.customJs
            isEnabled = existing.enabled
        }
    }

    private func saveRule() {
        let rule = CustomRule(
            domain: domain,
            customCss: customCss,
            customJs: customJs,
            enabled: isEnabled
        )
        prefManager.saveCustomRule(rule)
        SettingsManager.shared.saveCustomRule(rule)
        onSaved?()
    }
}

// MARK: - Code Editor With Line Numbers (Monospaced & Gutter)

public struct LineNumberedCodeEditor: View {
    @Binding var text: String
    var placeholder: String

    private var lineCount: Int {
        max(1, text.components(separatedBy: "\n").count)
    }

    private var lineNumbersText: String {
        (1...lineCount).map { "\($0)" }.joined(separator: "\n")
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Line Number Gutter
            Text(lineNumbersText)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .multilineTextAlignment(.trailing)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .frame(width: 34, alignment: .trailing)
                .background(Color(uiColor: .tertiarySystemGroupedBackground).opacity(0.5))
                .cornerRadius(4)

            // Monospaced Code Text Editor
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }

                TextEditor(text: $text)
                    .font(.system(size: 13, design: .monospaced))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .background(Color.clear)
            }
        }
        .padding(.vertical, 4)
    }
}
