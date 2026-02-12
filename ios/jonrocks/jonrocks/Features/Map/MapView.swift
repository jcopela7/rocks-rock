import CoreLocation
import MapboxMaps
import SwiftUI

private let defaultCenter = CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0)
private let defaultZoom: CGFloat = 3

struct MapView: View {
  @EnvironmentObject var authService: AuthenticationService
  @State private var mapVM: MapViewModel?
  @State private var viewport: Viewport = .camera(
    center: defaultCenter, zoom: defaultZoom, bearing: 0, pitch: 0)
  @State private var showingLayerSheet = false

  var body: some View {
    ZStack {
      if let mapVM = mapVM {
        if let error = mapVM.error {
          VStack(spacing: 12) {
            Text("Error loading map")
              .font(.headline)
              .foregroundColor(.red)
            Text(error)
              .font(.body)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
              .padding()
            Button("Retry") {
              Task { await mapVM.loadData() }
            }
            .buttonStyle(.bordered)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          MapContentView(viewModel: mapVM, viewport: $viewport)
        }
      } else {
        LoadingListView()
      }
      if let mapVM = mapVM, mapVM.error == nil {
        VStack {
          HStack {
            Spacer()
            locateMeButton()
              .padding(.trailing, 16)
              .padding(.top, 60)
          }
          Spacer()
          HStack {
            Spacer()
            layersButton()
              .padding(.trailing, 8)
              .padding(.bottom, 8)
          }
        }
      }
    }
    .background(Color.raw.slate100)
    .onAppear {
      if mapVM == nil {
        mapVM = MapViewModel(authService: authService)
        Task {
          await mapVM?.loadData()
        }
      }
    }
    .refreshable {
      await mapVM?.loadData()
    }
    .sheet(isPresented: $showingLayerSheet) {
      if let mapVM = mapVM {
        MapLayersSheet(viewModel: mapVM)
      }
    }
  }

  private func layersButton() -> some View {
    Button {
      showingLayerSheet = true
    } label: {
      Image(systemName: "square.stack.3d.up")
        .font(.title2)
        .foregroundStyle(Color.theme.accent)
        .padding(12)
        .background(.white)
        .clipShape(Circle())
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
    .buttonStyle(ScaleButtonStyle())
  }

  private func locateMeButton() -> some View {
    Button {
      withViewportAnimation(.easeIn(duration: 0.5)) {
        viewport = .followPuck(zoom: 14, pitch: 0)
      }
    } label: {
      Image(systemName: "location.fill")
        .font(.title2)
        .foregroundStyle(Color.theme.accent)
        .padding(12)
        .background(.white)
        .clipShape(Circle())
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
  }

}

private struct MapContentView: View {
  @ObservedObject var viewModel: MapViewModel
  @Binding var viewport: Viewport

  var body: some View {
    Map(viewport: $viewport) {
      Puck2D(bearing: .heading)
        .showsAccuracyRing(true)
      if viewModel.showLocationsLayer {
        ForEvery(viewModel.mappableLocations, id: \.id) { location in
          if let lat = location.latitude, let lon = location.longitude {
            MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
              Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.theme.accent)
            }
          }
        }
      }
      if viewModel.showAscentsLayer {
        ForEvery(viewModel.mappableAscents, id: \.id) { ascent in
          if let lat = ascent.locationLatitude, let lon = ascent.locationLongitude {
            MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
              Circle()
                .fill(Color.theme.accent.opacity(0.8))
                .frame(width: 24, height: 24)
                .overlay(
                  Circle()
                    .stroke(Color.white, lineWidth: 2)
                )
            }
          }
        }
      }
    }
    .ignoresSafeArea(.all, edges: .bottom)
  }
}

private struct ScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.92 : 1)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

#Preview {
  MapView()
    .environmentObject(AuthenticationService())
}
