//
//  PillView.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI

//
//  PillView.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI

struct PillView: View {
    
    enum Day: String, CaseIterable {
        case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    }
    
    @StateObject var drugViewModel = DrugViewModel()
    @State private var searchTerm = ""
    @State private var isDropdownExpanded = false
    @State var name: String = ""
    @State var amount: String = ""
    @State var dose = ""  // Corrected type declaration and initialization
    @State var frequency: [Day] = []
    @State var reminders: [String] = [""]  // Initialize with one empty string to start with one picker
    
    private var reminderTimes: [String] {
        var times: [String] = []
        var date = Calendar.current.date(from: DateComponents(hour: 7))!
        let endDate = Calendar.current.date(from: DateComponents(hour: 22))!
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        while date <= endDate {
            times.append(formatter.string(from: date))
            date = Calendar.current.date(byAdding: .minute, value: 30, to: date)!
        }
        return times
    }
    
    var body: some View {
        VStack(spacing: -10) {
            Image("image2")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .padding(.top)
            
            NavigationStack {
                Form {
                    Section(header: Text("Drug Information").font(.subheadline)) {
                        TextField("Drug Name", text: $searchTerm)
                            .onChange(of: searchTerm) { newTerm in
                                Task {
                                    await drugViewModel.fetchSuggestions(term: newTerm)
                                    isDropdownExpanded = true
                                }
                            }
                        if isDropdownExpanded && !drugViewModel.suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(drugViewModel.suggestions, id: \.self) { suggestion in
                                    Text(suggestion)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .onTapGesture {
                                            searchTerm = suggestion
                                            isDropdownExpanded = false
                                            name = searchTerm
                                            Task {
                                                await drugViewModel.performAPICall(term: suggestion)
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                            .background(Color.white)
                        }
                        if let errorMessage = drugViewModel.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else {
                            Picker("Select a strength", selection: $dose) {
                                ForEach(drugViewModel.strengths, id: \.self) { strengthList in
                                    ForEach(strengthList, id: \.self) { strength in
                                        Text(strength)
                                            .tag(strength)
                                    }
                                }
                            }
                        }
                        TextField("Amount", text: $amount)
                    }
                    
                    Section(header: Text("Scheduling").font(.subheadline)) {
                        HStack (alignment: .center){
                            ForEach(Day.allCases, id: \.self) { day in
                                Text(String(day.rawValue.first!))
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(frequency.contains(day) ? Color.cyan.cornerRadius(10) : Color.gray.cornerRadius(10))
                                    .onTapGesture {
                                        if frequency.contains(day) {
                                            frequency.removeAll(where: {$0 == day})
                                        } else {
                                            frequency.append(day)
                                        }
                                        print(frequency)
                                    }
                            }
                        }
                        
                        ForEach($reminders, id: \.self) { $reminder in
                            Picker("Reminder", selection: $reminder) {
                                ForEach(reminderTimes, id: \.self) { time in
                                    Text(time).tag(time as String?)
                                }
                            }
                        }
                        
                        Button(action: {
                            reminders.append("")
                            print(reminders)
                        }) {
                            Text("Add another reminder")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                VStack {
                    Button {
                        Task {
                            //Drug(name: name, amount: Int(amount), dose: dose, frequency: frequency, reminder: reminders)
                            print(name, amount, dose, frequency, reminders)
                        }
                    } label: {
                        HStack {
                            Text("ADD")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(Color.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 56)
                    }
                    .background(Color(.systemBlue))
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .cornerRadius(10)
                    Spacer()
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationTitle("Add Drug")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

extension PillView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !name.isEmpty
        && !amount.isEmpty
        && !dose.isEmpty
        && !frequency.isEmpty
    }
}

#Preview {
    PillView()
}

