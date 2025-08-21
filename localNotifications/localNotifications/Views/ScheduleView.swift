//
//  SheetView.swift
//  localNotifications
//
//  Created by Joel on 31/7/24.
//

import SwiftUI

struct ScheduleView: View
{
    @Binding var isPresented: Bool
    @State var selection = 0
    
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
        NavigationStack {
            VStack(spacing: 0) {
                // Picker fijo en la parte superior
                Picker(selection: $selection, label: Text("")) {
                    Text("Date").tag(0)
                    Text("Seconds").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color(UIColor.systemBackground))
                
                // Contenido principal con scroll
                Form {
                    if selection == 0 {
                        // Section para Date
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
                    } else {
                        // Section para Seconds
                        Section(header: Text("Notification In \(Int(selectedInterval)) Seconds")) {
                            TextField("Title:", text: $intTitle)
                                .focused($isInputActive)
                            TextField("Message:", text: $intMessage)
                                .focused($isInputActive)
                            
                            HStack {
                                Slider(value: $selectedInterval, in: 5...60, step: 1) {
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
                    }
                }
            }
            .navigationBarTitle(Text("Schedule"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        self.isPresented = false
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Close") {
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

#Preview {
    ScheduleView(isPresented: .constant(true))
}
