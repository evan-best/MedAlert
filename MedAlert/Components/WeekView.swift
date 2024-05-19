//
//  WeekView.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI

struct WeekView: View {
    @ObservedObject var weekStore = WeekStore()
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0

    var body: some View {
        ZStack {
            ForEach(weekStore.allWeeks) { week in
                VStack {
                    HStack {
                        ForEach(0..<7) { index in
                            VStack(spacing: 10) {
                                Text(weekStore.dateToString(date: week.date[index], format: "EEE"))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                
                                ZStack {
                                    Circle()
                                        .fill(weekStore.isToday(date: week.date[index]) ? Color.blue : Color.clear)
                                        .frame(width: 40, height: 40)
                                    
                                    Text(weekStore.dateToString(date: week.date[index], format: "d"))
                                        .font(.system(size: 14))
                                        .foregroundColor(weekStore.isToday(date: week.date[index]) ? Color.white : Color.primary)
                                        .frame(maxWidth: .infinity)
                                }
                                .onTapGesture {
                                    // Updating Current Day
                                    weekStore.currentDate = week.date[index]
                                    print("DEBUG:", weekStore.formattedCurrentDate())
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .background(
                        Rectangle()
                            .fill(Color.white)
                    )
                }
                .offset(x: myXOffset(week.id), y: 0)
                .zIndex(1.0 - abs(distance(week.id)) * 0.1)
                .padding(.horizontal, 20)
            }
        }
        .frame(alignment: .top)
        .padding(.top, 50)
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 1.0)) {
                        draggingItem = snappedItem + value.translation.width / 400
                    }
                }
                .onEnded { value in
                    withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 1.0)) {
                        if value.predictedEndTranslation.width > 0 {
                            draggingItem = snappedItem + 1
                        } else {
                            draggingItem = snappedItem - 1
                        }
                        snappedItem = draggingItem
                        weekStore.update(index: Int(snappedItem))
                    }
                }
        )
    }

    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(weekStore.allWeeks.count))
    }

    func myXOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(weekStore.allWeeks.count) * distance(item)
        return sin(angle) * 200
    }
}

#Preview {
    WeekView()
}
