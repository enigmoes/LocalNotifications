//
//  SheetView.swift
//  localNotifications
//
//  Created by Joel on 31/7/24.
//

import SwiftUI

struct ScheduleView: View {
    @Binding var isPresented: Bool
    @State var selection = 0
    
    var body: some View {
        NavigationStack {
            Form {
                
            }
            .navigationBarTitle(Text("Schedule"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        self.isPresented = false
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                Picker(selection: $selection, label: Text("")) {
                    Text("Date").tag(0)
                    Text("Seconds").tag(1)
                }
                .pickerStyle(.segmented)
            }.padding()
        }
    }
}

#Preview {
    ScheduleView(isPresented: .constant(true))
}
