//
//  ActivityLoggingView.swift
//  jonrocks
//
//  Created by Jonathan Cope on 2025-11-14.
//
import PhotosUI
import SwiftUI

struct ActivityLoggingView: View {
  @ObservedObject var ascentsVM: AscentsVM

  @State private var ascentToDelete: AscentDTO?
  @State private var showingDeleteAlert = false

  @State private var pickingForAscent: AscentDTO?
  @State private var selectedItem: PhotosPickerItem?

  var body: some View {
    VStack(spacing: 8) {
      SearchBar(text: $ascentsVM.searchText)
        .padding(.horizontal, 16)
        .padding(.top, 8)
      List(ascentsVM.filteredAscents) { ascent in
        ActivityRowView(
          ascent: ascent,
          viewModel: ascentsVM,
          selectedItem: $selectedItem,
          pickingForAscent: $pickingForAscent,
          ascentToDelete: $ascentToDelete,
          showingDeleteAlert: $showingDeleteAlert
        )
        // iOS 17+: trim default side gutters
        .listRowSeparator(.visible)
      }
      .listStyle(.plain)
      .contentMargins(.horizontal, 12)  // iOS 17
    }
    .background(Color.raw.slate100)
    .overlay(alignment: .center) {
      loadingOverlay
    }
    .task { await ascentsVM.loadAscents() }
    .alert("Delete Ascent", isPresented: $showingDeleteAlert) {
      deleteAlertContent
    } message: {
      deleteAlertMessage
    }
  }

  private var searchBar: some View {
    SearchBar(text: $ascentsVM.searchText)
      .padding(.horizontal)
      .padding(.top, 8)
  }

  private var ascentsList: some View {
    List(ascentsVM.filteredAscents) { ascent in
      ActivityRowView(
        ascent: ascent,
        viewModel: ascentsVM,
        selectedItem: $selectedItem,
        pickingForAscent: $pickingForAscent,
        ascentToDelete: $ascentToDelete,
        showingDeleteAlert: $showingDeleteAlert
      )
    }
  }

  private var loadingOverlay: some View {
    Group {
      if ascentsVM.loading { LoadingListView() }
      if let e = ascentsVM.error {
        Text(e).foregroundStyle(.red).padding()
      }
    }
  }

  @ViewBuilder
  private var deleteAlertContent: some View {
    Button("Cancel", role: .cancel) { ascentToDelete = nil }
    Button("Delete", role: .destructive) {
      if let ascent = ascentToDelete {
        Task { await ascentsVM.deleteAscent(ascent) }
      }
      ascentToDelete = nil
    }
  }

  @ViewBuilder
  private var deleteAlertMessage: some View {
    if let ascent = ascentToDelete {
      Text(
        "Are you sure you want to delete this \(ascent.style) ascent? This action cannot be undone."
      )
    }
  }
}
