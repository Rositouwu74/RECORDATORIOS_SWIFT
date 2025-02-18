//
//  ContentView.swift
//  Recordatorios
//
//  Created by Erick David Gómez Guadiana on 30/10/24.
//

import SwiftUI
import Foundation
import UIKit

struct ContentView: View {
    @State var reminders: [Reminder] = []
    @State var showAddReminder = false
    @State var selectedReminder: Reminder? = nil
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    
    // Colores personalizados
    private let accentColor = Color.pink
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.gray.opacity(0.1)
    }
    
    private var filteredReminders: [Reminder] {
        reminders.filter { !$0.isDeleted }.filter { reminder in
            searchText.isEmpty ||
            reminder.text.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {  // Esta es la implementación requerida del protocolo View
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header personalizado
                    HStack {
                        NavigationLink {
                            DeletedRemindersView(reminders: $reminders)
                        } label: {
                            Image(systemName: "trash")
                                .font(.title3)
                                .foregroundColor(accentColor)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        
                        Spacer()
                        
                        Text("Recordatorios")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(accentColor)
                        
                        Spacer()
                        
                        Button {
                            showAddReminder = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(accentColor)
                                .clipShape(Circle())
                                .shadow(color: accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Barra de búsqueda
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Buscar recordatorio...", text: $searchText)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .padding()
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    if filteredReminders.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 60))
                                .foregroundColor(accentColor.opacity(0.3))
                            
                            Text("No hay recordatorios")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Text("Toca + para crear uno nuevo")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredReminders) { reminder in
                                    ReminderCard(reminder: reminder, reminders: $reminders, selectedReminder: $selectedReminder)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddReminder) {
            AddReminderView(reminders: $reminders, isAddingReminder: $showAddReminder)
        }
        .sheet(item: $selectedReminder) { reminder in
            if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                EditReminderView(reminder: $reminders[index], reminders: $reminders)
            }
        }
        .onAppear {
            requestNotificationPermission()
            loadReminders()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permiso concedido para notificaciones")
            } else if let error = error {
                print("Error al solicitar permiso: \(error)")
            }
        }
    }
    
    private func loadReminders() {
        if let savedData = UserDefaults.standard.data(forKey: "savedReminders"),
           let decodedReminders = try? JSONDecoder().decode([Reminder].self, from: savedData) {
            reminders = decodedReminders
        }
    }
}
