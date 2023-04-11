//
//  ContentView.swift
//  localNotifications
//
//  Created by Joel on 10/4/23.
//

import SwiftUI

struct AlertView: Identifiable
{
    enum AlertView {
        case aTime
        case aDate
        case aEmpty
    }
    
    let id: AlertView
    let title: String
    let message: String
}

struct ContentView: View
{
    // For schedule by date
    @State private var dateTitle = ""
    @State private var dateMessage = ""
    @State private var selectedDate = Date()
    // For schedule by interval
    @State private var intTitle = ""
    @State private var intMessage = ""
    @State private var selectedInterval: Float = 5
    
    @State private var alertInfo: AlertView?
    
    @FocusState var isInputActive: Bool
    
    @ObservedObject var notify = NotificationHandler()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Schedule Notification")) {
                    TextField("Title:", text: $dateTitle)
                        .focused($isInputActive)
                    TextField("Message:", text: $dateMessage)
                        .focused($isInputActive)
                    
                    DatePicker("Date:", selection: $selectedDate, in: Date()...)
                    
                    Button("Schedule") {
                        if (!self.dateTitle.isEmpty && !self.dateMessage.isEmpty) {
                            notify.sendNotification(
                                date: selectedDate,
                                type: "date",
                                title: dateTitle,
                                body: dateMessage)
                            
                            alertInfo = AlertView(
                                id: .aTime,
                                title: "Notification schedule",
                                message: "For \(notify.formattedDate(date: selectedDate))"
                            )
                        } else {
                            if (self.dateTitle.isEmpty) {
                                alertInfo = AlertView(
                                    id: .aEmpty,
                                    title: "Warning",
                                    message: "Title cannot be empty"
                                )
                            } else if (self.dateMessage.isEmpty) {
                                alertInfo = AlertView(
                                    id: .aEmpty,
                                    title: "Warning",
                                    message: "Message cannot be empty"
                                )
                            }
                        }
                    }
                    .padding(5)
                    .tint(.orange)
                    .buttonStyle(.borderedProminent)
                }
                Section(header: Text("Notification In \(Int(selectedInterval)) Seconds")) {
                    TextField("Title:", text: $intTitle)
                        .focused($isInputActive)
                    TextField("Message:", text: $intMessage)
                        .focused($isInputActive)
                    
                    HStack {
                        Slider(value: $selectedInterval, in: 5...30, step: 1) {
                            Text("Interval")
                        }
                        .accessibilityValue("\(Int(selectedInterval)) seconds")
                        Spacer()
                        Text("\(Int(selectedInterval)) seconds")
                            .accessibilityHidden(true)
                    }
                    
                    Button("Schedule In \(Int(selectedInterval)) seconds") {
                        if (!self.intTitle.isEmpty && !self.intMessage.isEmpty) {
                            notify.sendNotification(
                                date: Date(),
                                type: "time",
                                timeInverval: Double(selectedInterval),
                                title: intTitle,
                                body: intMessage)
                            
                            alertInfo = AlertView(
                                id: .aTime,
                                title: "Notification schedule",
                                message: "On \(Int(selectedInterval)) seconds"
                            )
                        } else {
                            if (self.intTitle.isEmpty) {
                                alertInfo = AlertView(
                                    id: .aEmpty,
                                    title: "Warning",
                                    message: "Title cannot be empty"
                                )
                            } else if (self.intMessage.isEmpty) {
                                alertInfo = AlertView(
                                    id: .aEmpty,
                                    title: "Warning",
                                    message: "Message cannot be empty"
                                )
                            }
                        }
                    }
                    .padding(5)
                    .buttonStyle(.borderedProminent)
                }
                Section(header: Text("Not working?")) {
                    Button("Request permissions") {
                        notify.askPermission()
                    }
                }
            }
            .navigationTitle(Text("Notifications"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        // Reset controls
                        self.dateTitle = ""
                        self.dateMessage = ""
                        self.selectedDate = Date()
                        
                        self.intTitle = ""
                        self.intMessage = ""
                        self.selectedInterval = 5
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isInputActive = false
                    }
                }
            }
            .alert(item: $alertInfo, content: { info in
                Alert(
                    title: Text(info.title),
                    message: Text(info.message)
                )
            })
        }
        .onAppear() {
            notify.askPermission()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
