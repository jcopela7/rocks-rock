//
//  ActivityFilterSheet.swift
//  jonrocks
//
import Charts
import SwiftUI

private let disciplineOptions: [(id: String?, label: String, icon: String)] = [
  (nil, "All", "square.grid.2x2"),
  ("boulder", "Boulder", "crashpadIcon"),
  ("sport", "Sport", "quickdrawIcon"),
  ("trad", "Trad", "camIcon"),
  ("board", "Board", "boardIcon"),
]

struct RangeSlider: View {
  @Binding var minValue: Double
  @Binding var maxValue: Double
  let range: ClosedRange<Double>
  let step: Double

  @State private var draggingMin: Bool = false
  @State private var draggingMax: Bool = false

  private let knobSize: CGFloat = 28
  private let trackHeight: CGFloat = 4

  var body: some View {
    GeometryReader { geometry in
      let trackWidth = geometry.size.width - knobSize
      let minPosition =
        CGFloat((minValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * trackWidth
      let maxPosition =
        CGFloat((maxValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * trackWidth

      ZStack(alignment: .leading) {
        // Background track
        RoundedRectangle(cornerRadius: 2)
          .fill(Color.theme.textSecondary.opacity(0.2))
          .frame(width: geometry.size.width * 0.95, height: trackHeight)
          .offset(x: knobSize / 2)

        // Active track (between knobs)
        RoundedRectangle(cornerRadius: 2)
          .fill(Color.theme.accent)
          .frame(width: max(0, maxPosition - minPosition), height: trackHeight)
          .offset(x: knobSize / 2 + minPosition)

        // Min knob
        Circle()
          .fill(Color.white)
          .frame(width: knobSize, height: knobSize)
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
          .overlay(
            Circle()
              .stroke(Color.theme.accent, lineWidth: 2)
          )
          .offset(x: minPosition)
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                draggingMin = true
                let newPosition = max(0, min(value.location.x, maxPosition - knobSize))
                let newValue =
                  range.lowerBound + Double(newPosition / trackWidth)
                  * (range.upperBound - range.lowerBound)
                let steppedValue = round(newValue / step) * step
                minValue = max(range.lowerBound, min(steppedValue, maxValue - step))
              }
              .onEnded { _ in
                draggingMin = false
              }
          )

        // Max knob
        Circle()
          .fill(Color.white)
          .frame(width: knobSize, height: knobSize)
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
          .overlay(
            Circle()
              .stroke(Color.theme.accent, lineWidth: 2)
          )
          .offset(x: maxPosition)
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                draggingMax = true
                let newPosition = max(minPosition + knobSize, min(value.location.x, trackWidth))
                let newValue =
                  range.lowerBound + Double(newPosition / trackWidth)
                  * (range.upperBound - range.lowerBound)
                let steppedValue = round(newValue / step) * step
                maxValue = max(minValue + step, min(steppedValue, range.upperBound))
              }
              .onEnded { _ in
                draggingMax = false
              }
          )
      }
      .frame(height: knobSize)
    }
    .frame(height: knobSize)
  }
}

struct ActivityFilterSheet: View {
  @ObservedObject var ascentsVM: AscentsVM
  @Environment(\.dismiss) private var dismiss

  private var availableGrades: [String] {
    let source = ascentsVM.ascents
    let filtered: [AscentDTO]
    if let discipline = ascentsVM.filterDiscipline {
      filtered = source.filter { $0.routeDiscipline?.lowercased() == discipline.lowercased() }
    } else {
      filtered = source
    }
    let grades = Set(filtered.compactMap(\.routeGradeValue)).filter { !$0.isEmpty }
    return grades.sorted { a, b in
      (filtered.first(where: { $0.routeGradeValue == a })?.routeGradeRank ?? 0)
        < (filtered.first(where: { $0.routeGradeValue == b })?.routeGradeRank ?? 0)
    }
  }

  private var gradeCounts: [(grade: String, count: Int)] {
    let source = ascentsVM.ascents
    let filtered: [AscentDTO]
    if let discipline = ascentsVM.filterDiscipline {
      filtered = source.filter { $0.routeDiscipline?.lowercased() == discipline.lowercased() }
    } else {
      filtered = source
    }
    return availableGrades.map { grade in
      (grade, filtered.filter { $0.routeGradeValue == grade }.count)
    }
  }

  private var minGradeIndex: Int {
    guard let g = ascentsVM.filterMinGrade, let i = availableGrades.firstIndex(of: g) else {
      return 0
    }
    return i
  }

  private var maxGradeIndex: Int {
    let n = availableGrades.count
    guard n > 0 else { return 0 }
    guard let g = ascentsVM.filterMaxGrade, let i = availableGrades.firstIndex(of: g) else {
      return n - 1
    }
    return i
  }

  private static let calendar = Calendar.current
  private static var defaultMinDate: Date {
    calendar.date(from: calendar.dateComponents([.year], from: Date())) ?? Date()
  }

  var body: some View {
    VStack(spacing: 0) {
      header
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          disciplineSection
          Divider().padding(.vertical, 4)
          gradeSection
          Divider().padding(.vertical, 4)
          dateSection
          Divider().padding(.vertical, 4)
          locationsSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
      }
      footer
    }
    .background(Color.white)
    .foregroundColor(Color.theme.textPrimary)
  }

  private var header: some View {
    HStack {
      Text("Filter")
        .font(.headline)
        .fontWeight(.bold)
        .foregroundColor(Color.theme.textPrimary)
      Spacer()
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(Color.theme.textPrimary)
          .frame(width: 32, height: 32)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(Color.white)
  }

  private var disciplineSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Discipline")
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(Color.theme.textPrimary)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(disciplineOptions, id: \.id) { option in
            let isSelected = ascentsVM.filterDiscipline == option.id
            Button {
              ascentsVM.filterDiscipline = option.id
            } label: {
              VStack(spacing: 8) {
                if option.icon == "crashpadIcon" || option.icon == "quickdrawIcon"
                  || option.icon == "camIcon" || option.icon == "boardIcon"
                {
                  Image(option.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(isSelected ? .white : Color.theme.textSecondary)
                } else {
                  Image(systemName: option.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color.theme.textSecondary)
                }
                Text(option.label)
                  .font(.caption)
                  .fontWeight(.medium)
                  .foregroundColor(isSelected ? .white : Color.theme.textPrimary)
              }
              .frame(width: 80, height: 72)
              .background(isSelected ? Color.theme.accent : Color.raw.slate100)
              .cornerRadius(12)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.vertical, 4)
      }
    }
    .padding(.top, 8)
  }

  private var gradeSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Grade Range")
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(Color.theme.textPrimary)

      if availableGrades.isEmpty {
        Text("No grades in your ascents")
          .font(.subheadline)
          .foregroundColor(Color.theme.textSecondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 24)
      } else {
        gradeChart
        gradeRangeSlider
      }
    }
    .padding(.top, 8)
  }

  private var gradeChart: some View {
    let counts = gradeCounts
    let maxCount = counts.map(\.count).max() ?? 1
    return Chart(counts, id: \.grade) { item in
      BarMark(
        x: .value("Grade", item.grade),
        y: .value("Sends", item.count)
      )
      .foregroundStyle(Color.theme.accent)
    }
    .chartYScale(domain: 0...(maxCount + 1))
    .chartXAxis {
      AxisMarks { _ in
        AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
        AxisTick()
        AxisValueLabel()
      }
    }
    .frame(height: 120)
  }

  private var gradeRangeSlider: some View {
    let grades = availableGrades
    let n = grades.count
    let minIdx = minGradeIndex
    let maxIdx = maxGradeIndex

    return VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Grade Range")
          .font(.caption)
          .foregroundColor(Color.theme.textSecondary)
        Spacer()
        HStack(spacing: 4) {
          Text(grades.isEmpty ? "" : grades[minIdx])
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(Color.theme.textPrimary)
          Text("–")
            .font(.caption)
            .foregroundColor(Color.theme.textSecondary)
          Text(grades.isEmpty ? "" : grades[maxIdx])
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(Color.theme.textPrimary)
        }
      }

      RangeSlider(
        minValue: Binding(
          get: { Double(minIdx) },
          set: { new in
            let i = min(Int(round(new)), maxIdx)
            if i == 0 && maxIdx == n - 1 {
              ascentsVM.filterMinGrade = nil
              ascentsVM.filterMaxGrade = nil
            } else {
              ascentsVM.filterMinGrade = grades[i]
              if ascentsVM.filterMaxGrade == nil && n > 0 {
                ascentsVM.filterMaxGrade = grades[n - 1]
              }
            }
          }
        ),
        maxValue: Binding(
          get: { Double(maxIdx) },
          set: { new in
            let i = max(Int(round(new)), minIdx)
            if minIdx == 0 && i == n - 1 {
              ascentsVM.filterMinGrade = nil
              ascentsVM.filterMaxGrade = nil
            } else {
              ascentsVM.filterMaxGrade = grades[i]
              if ascentsVM.filterMinGrade == nil && n > 0 {
                ascentsVM.filterMinGrade = grades[0]
              }
            }
          }
        ),
        range: 0...Double(max(0, n - 1)),
        step: 1
      )
      .frame(height: 28)
    }
  }

  private var dateSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Date Range")
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(Color.theme.textPrimary)

      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 24) {
          HStack {
            DatePicker(
              "From",
              selection: Binding(
                get: { ascentsVM.filterMinDate ?? Self.defaultMinDate },
                set: { ascentsVM.filterMinDate = $0 }
              ),
              displayedComponents: [.date]
            )
            .labelsHidden()
            if ascentsVM.filterMinDate != nil {
              Button("Clear") {
                ascentsVM.filterMinDate = nil
              }
              .font(.caption)
              .foregroundColor(Color.theme.accent)
            }
          }
          Rectangle()
            .frame(width: 18, height: 2)
            .foregroundColor(Color.theme.textSecondary)
          HStack {
            DatePicker(
              "To",
              selection: Binding(
                get: { ascentsVM.filterMaxDate ?? Date() },
                set: { ascentsVM.filterMaxDate = $0 }
              ),
              displayedComponents: [.date]
            )
            .labelsHidden()
            if ascentsVM.filterMaxDate != nil {
              Button("Clear") {
                ascentsVM.filterMaxDate = nil
              }
              .font(.caption)
              .foregroundColor(Color.theme.accent)
            }
          }
        }
      }
    }
    .padding(.top, 8)
  }

  /// Unique locations from ascents (id + name), sorted by name, excluding nil locations.
  private var uniqueLocations: [(id: UUID, name: String)] {
    var seen: Set<UUID> = []
    var list: [(id: UUID, name: String)] = []
    for a in ascentsVM.ascents {
      guard let id = a.locationId, let name = a.locationName, !name.isEmpty, !seen.contains(id)
      else { continue }
      seen.insert(id)
      list.append((id: id, name: name))
    }
    return list.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
  }

  private var locationsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Location")
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(Color.theme.textPrimary)

      if uniqueLocations.isEmpty {
        Text("No locations in your ascents")
          .font(.subheadline)
          .foregroundColor(Color.theme.textSecondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
      } else {
        VStack(spacing: 0) {
          ForEach(Array(uniqueLocations.enumerated()), id: \.element.id) { index, loc in
            let isSelected = ascentsVM.filterLocationIds.contains(loc.id)
            Button {
              if isSelected {
                ascentsVM.filterLocationIds.remove(loc.id)
              } else {
                ascentsVM.filterLocationIds.insert(loc.id)
              }
            } label: {
              HStack(spacing: 12) {
                Text(loc.name)
                  .font(.subheadline)
                  .foregroundColor(Color.theme.textPrimary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                  .font(.system(size: 22))
                  .foregroundColor(isSelected ? Color.theme.accent : Color.theme.textSecondary)
              }
              .padding(.vertical, 14)
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
          }
        }
        .cornerRadius(12)
      }
    }
    .padding(.top, 8)
  }

  private var footer: some View {
    HStack {
      Button("Clear all") {
        ascentsVM.filterDiscipline = nil
        ascentsVM.filterMinGrade = nil
        ascentsVM.filterMaxGrade = nil
        ascentsVM.filterMinDate = nil
        ascentsVM.filterMaxDate = nil
        ascentsVM.filterLocationIds = []
      }
      .font(.subheadline)
      .foregroundColor(Color.theme.textSecondary)

      Spacer()

      Button {
        dismiss()
      } label: {
        Text("Show \(ascentsVM.filteredAscents.count) results")
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(Color.theme.textPrimary)
          .cornerRadius(8)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(Color.white)
  }
}

#Preview {
  ActivityFilterSheet(ascentsVM: AscentsVM(authService: AuthenticationService()))
}
