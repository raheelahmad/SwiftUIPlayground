//
//  ContentView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 10/26/21.
//

import SwiftUI

struct MonthAnchorData: Equatable {
    let idx: Int
    let bounds: CGRect
}

struct MonthAnchorKey: PreferenceKey {
    static var defaultValue: [MonthAnchorData] = []

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

struct MonthView: View {
    let label: String
    let idx: Int

    var body: some View {
        Text(label)
            .font(.caption)
            .padding(10)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: MonthAnchorKey.self, value: [.init(idx: idx, bounds: proxy.frame(in: .named("Calendar")))])
                }
            )
//            .anchorPreference(key: MonthAnchorKey.self, value: .bounds, transform: { bounds in
//                [.init(idx: idx, bounds: bounds)]
//            })
    }
}

struct Month: Identifiable {
    var id: Int { idx }
    let idx: Int
    let text: String
}

struct ContentView: View {
    let months = ["January", "Februrary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"].enumerated()
        .map {
            Month(idx: $0, text: $1)
        }

    @State var selection = 0
    @State var frames: [Int: CGRect] = [:]

    var monthArray: [[Month]] {
        months.reduce([[Month]].init(repeating: [], count: 3)) { partialResult, month in
            var result = partialResult
            let index = month.idx / 4
            var array = result[index]
            array.append(month)
            result[index] = array
            return result
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(monthArray.enumerated()), id: \.0) { array in
                HStack(spacing: 10) {
                    ForEach(array.element) { month in
                        MonthView(label: month.text, idx: month.idx)
                            .onTapGesture {
                                selection = month.idx
                            }
                    }
                }
            }

//            RoundedRectangle(cornerRadius: 6, style: .continuous)
//                .stroke(lineWidth: 3)
//                .foregroundColor(.green)
//                .frame(width: frames[selection]?.width, height: frames[selection]?.height)
//                .offset(x: frames[selection]?.minX ?? 0, y: frames[selection]?.minY ?? 0)
//                .animation(.easeInOut(duration: 0.2), value: frames[selection])
        }.backgroundPreferenceValue(MonthAnchorKey.self, { values in
            GeometryReader { proxy in

                border(proxy: proxy, data: values)
            }
                .animation(.easeInOut(duration: 0.2), value: selection)
        })
//        .backgroundPreferenceValue(MonthAnchorKey.self, { values in
//            GeometryReader { proxy in
//                RoundedRectangle(cornerRadius: 6, style: .continuous)
//                    .stroke(lineWidth: 3).foregroundColor(.green)
//                    .frame(width: <#T##CGFloat?#>, height: <#T##CGFloat?#>, alignment: <#T##Alignment#>)
//            }
//        })
//        .onPreferenceChange(MonthAnchorKey.self) { values in
//            for value in values {
//                frames[value.idx] = value.bounds
//            }
//        }
                .coordinateSpace(name: "Calendar")
    }

    func border(proxy: GeometryProxy, data: [MonthAnchorData]) -> some View {
        let value = data.first { $0.idx == selection }!.bounds
            return RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(lineWidth: 3)
                .foregroundColor(.green)
                .frame(width: value.width, height: value.height)
                .offset(x: value.minX, y: value.minY)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 500, height: 340))
    }
}
