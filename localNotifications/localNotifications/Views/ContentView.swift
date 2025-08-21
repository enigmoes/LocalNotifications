//
//  ContentView.swift
//  localNotifications
//
//  Created by Joel on 10/4/23.
//

import SwiftUI

struct ContentView: View
{
    @ObservedObject var notify = NotificationHandler()
    @State private var isPresented: Bool = false
    @State private var showClearAllConfirmation: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                if notify.pendingNotifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Scheduled Notifications")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Tap the + button to schedule your first notification")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(notify.pendingNotifications) { notification in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(notification.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: notification.type == "date" ? "calendar" : "clock")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            
                            Text(notification.body)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            HStack {
                                Text("Scheduled for:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(notify.formattedDate(date: notification.scheduledDate))
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete(perform: deleteNotifications)
                }
            }
            .refreshable {
                notify.showNotifications()
            }
            .navigationBarTitle(Text("Notifications"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
        }
        .onAppear() {
            notify.askPermission()
            notify.showNotifications()
        }
    }
    
    // Función para eliminar notificaciones seleccionadas
    private func deleteNotifications(offsets: IndexSet) {
        for index in offsets {
            let notification = notify.pendingNotifications[index]
            notify.removeNotification(withId: notification.id)
        }
    }
    
    // Función para construir el toolbar
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Clear All") {
                showClearAllConfirmation = true
            }
            .foregroundColor(.red)
            .opacity(notify.pendingNotifications.isEmpty ? 0 : 1)
            .disabled(notify.pendingNotifications.isEmpty)
            .alert("Clear All Notifications", isPresented: $showClearAllConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    notify.removeAllNotifications()
                }
            } message: {
                Text("Are you sure you want to remove all scheduled notifications? This action cannot be undone.")
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Add", systemImage: "plus.circle") {
                isPresented.toggle()
            }.sheet(isPresented: $isPresented) {
                ScheduleView(isPresented: $isPresented)
                    .onDisappear {
                        // Actualizar la lista cuando se cierre el sheet
                        notify.showNotifications()
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
