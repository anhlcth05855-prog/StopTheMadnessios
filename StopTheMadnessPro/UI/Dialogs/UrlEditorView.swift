//
//  UrlEditorView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct UrlEditorView: View {

    @ObservedObject var viewModel: BrowserViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var urlText: String = ""
    @State private var toastMessage: String?
    @State private var showToast: Bool = false

    public init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Large Text Editor
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ĐƯỜNG DẪN URL HIỆN TẠI")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)

                        TextEditor(text: $urlText)
                            .font(.system(size: 14, design: .monospaced))
                            .frame(minHeight: 110)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // Quick Action Buttons
                    HStack(spacing: 12) {
                        Button {
                            cleanCurrentUrl()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "wand.and.stars")
                                Text("Dọn sạch URL")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.indigo.opacity(0.15))
                            .foregroundColor(.indigo)
                            .cornerRadius(10)
                        }

                        Button {
                            copyCleanUrl()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc")
                                Text("Sao chép sạch")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }

                    // Query Parameters Analysis
                    let params = UrlSanitizer.extractAllQueryParams(urlText)
                    if !params.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("THAM SỐ TRUY VẤN (\(params.count))")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Spacer()
                                let trackerCount = params.filter { $0.isTracker }.count
                                if trackerCount > 0 {
                                    Text("\(trackerCount) tracker phát hiện")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.red)
                                }
                            }

                            VStack(spacing: 8) {
                                ForEach(Array(params.enumerated()), id: \.offset) { _, item in
                                    HStack(alignment: .center, spacing: 8) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(item.name)
                                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                    .foregroundColor(item.isTracker ? .red : .primary)

                                                if item.isTracker {
                                                    Text("TRACKER")
                                                        .font(.system(size: 9, weight: .bold))
                                                        .padding(.horizontal, 5)
                                                        .padding(.vertical, 2)
                                                        .background(Color.red.opacity(0.15))
                                                        .foregroundColor(.red)
                                                        .cornerRadius(4)
                                                }
                                            }

                                            Text(item.value)
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }

                                        Spacer()

                                        if item.isTracker {
                                            Button {
                                                removeParam(named: item.name)
                                            } label: {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.red)
                                                    .padding(6)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 20)

                    // Navigation Action Buttons
                    VStack(spacing: 10) {
                        Button {
                            dismiss()
                            viewModel.navigate(to: urlText, inNewTab: false)
                        } label: {
                            Text("Truy cập liên kết")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button {
                            dismiss()
                            viewModel.navigate(to: urlText, inNewTab: true)
                        } label: {
                            Text("Mở trong thẻ mới")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemBackground))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Trình chỉnh sửa URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        dismiss()
                    }
                }
            }
            .overlay(
                // Toast overlay
                Group {
                    if let msg = toastMessage, showToast {
                        VStack {
                            Spacer()
                            Text(msg)
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .padding(.bottom, 30)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            )
            .onAppear {
                urlText = viewModel.currentTab?.url ?? ""
            }
        }
    }

    private func cleanCurrentUrl() {
        let result = UrlSanitizer.sanitize(urlText)
        urlText = result.cleanedUrl
        if !result.removedParams.isEmpty {
            showToastMessage("Đã gỡ bỏ \(result.removedParams.count) tham số tracker!")
        } else {
            showToastMessage("URL đã sạch sẽ, không có tracker.")
        }
    }

    private func copyCleanUrl() {
        let result = UrlSanitizer.sanitize(urlText)
        UIPasteboard.general.string = result.cleanedUrl
        showToastMessage("Đã sao chép URL sạch vào bộ nhớ tạm!")
    }

    private func removeParam(named name: String) {
        guard var components = URLComponents(string: urlText) else { return }
        components.queryItems = components.queryItems?.filter { $0.name != name }
        if components.queryItems?.isEmpty == true {
            components.queryItems = nil
        }
        urlText = components.string ?? urlText
        showToastMessage("Đã xóa tham số \(name)")
    }

    private func showToastMessage(_ msg: String) {
        toastMessage = msg
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showToast = false }
        }
    }
}

