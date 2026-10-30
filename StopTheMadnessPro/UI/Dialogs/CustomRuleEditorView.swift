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
                Section(header: Text("Tên miền áp dụng"), footer: Text("Dùng * để áp dụng cho tất cả các trang web hoặc nhập domain cụ thể (ví dụ: reddit.com, youtube.com).")) {
                    TextField("Domain (ví dụ: reddit.com hoặc *)", text: $domain)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Toggle("Kích hoạt quy tắc này", isOn: $isEnabled)
                }

                Section(header: Text("Custom CSS (Tùy biến giao diện)")) {
                    TextEditor(text: $customCss)
                        .font(.system(size: 13, design: .monospaced))
                        .frame(minHeight: 120)
                }

                Section(header: Text("Custom JavaScript (Tự động thực thi)")) {
                    TextEditor(text: $customJs)
                        .font(.system(size: 13, design: .monospaced))
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Tùy biến CSS / JS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
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
        let cleanDomain = initialDomain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        domain = cleanDomain.isEmpty ? "*" : cleanDomain

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
        onSaved?()
    }
}
