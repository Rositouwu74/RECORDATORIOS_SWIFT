//
//  AddReminderView.swift
//  Recordatorios
//
//  Created by Erick David Gómez Guadiana on 31/10/24.
//

import SwiftUI
import UserNotifications

struct AddReminderView: View {
    @Binding var reminders: [Reminder]
    @Binding var isAddingReminder: Bool
    @State private var newReminder = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var addDate = false
    @State private var addTime = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private var minimumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var isValidDateTime: Bool {
        if !addDate && !addTime { return true }
        
        let calendar = Calendar.current
        let now = Date()
        
        if addDate && addTime {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            
            guard let combinedDate = calendar.date(from: dateComponents) else { return false }
            return combinedDate > now
        } else if addDate {
            return calendar.startOfDay(for: selectedDate) >= calendar.startOfDay(for: now)
        } else if addTime {
            let selectedComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
            let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
            
            let selectedMinutes = selectedComponents.hour! * 60 + selectedComponents.minute!
            let currentMinutes = currentComponents.hour! * 60 + currentComponents.minute!
            
            return selectedMinutes > currentMinutes
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente suave
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header con ícono
                        VStack(spacing: 15) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.pink, .pink.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                )
                                .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Text("Nuevo Recordatorio")
                                .font(.title2.bold())
                                .foregroundColor(.pink)
                        }
                        .padding(.top, 20)
                        
                        // Campo de texto principal
                        VStack(alignment: .leading, spacing: 8) {
                            Text(" ")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            TextField("Escribe tu recordatorio aquí...", text: $newReminder)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.05) : Color.white)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                                .focused($isFocused)
                        }
                        .padding(.horizontal)
                        
                        // Sección de opciones
                        VStack(spacing: 20) {
                            // Toggle de fecha
                            OptionToggle(
                                isOn: $addDate,
                                icon: "calendar",
                                title: "Agregar fecha",
                                subtitle: "Selecciona la fecha de tu recordatorio"
                            )
                            
                            if addDate {
                                DatePicker("", selection: $selectedDate,
                                         in: minimumDate...,
                                         displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(colorScheme == .dark ? Color.black.opacity(0.05) : Color.white)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                                    .padding(.horizontal)
                                    .accentColor(.pink)
                            }
                            
                            // Toggle de hora
                            OptionToggle(
                                isOn: $addTime,
                                icon: "clock.fill",
                                title: "Agregar hora",
                                subtitle: "Selecciona la hora de tu recordatorio"
                            )
                            .onChange(of: addTime) { newValue in
                                if newValue {
                                    selectedTime = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
                                }
                            }
                            
                            if addTime {
                                DatePicker("", selection: $selectedTime,
                                         displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(colorScheme == .dark ? Color.black.opacity(0.05) : Color.white)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Botón de guardar
                        Button(action: {
                            if newReminder.isEmpty {
                                alertMessage = "El recordatorio debe tener nombre."
                                showAlert = true
                            } else if !isValidDateTime {
                                alertMessage = "La fecha y hora seleccionadas deben ser posteriores a la actual."
                                showAlert = true
                            } else {
                                let reminder = Reminder(
                                    text: newReminder,
                                    tag: "",
                                    date: addDate ? selectedDate : nil,
                                    time: addTime ? selectedTime : nil
                                )
                                withAnimation {
                                    reminders.append(reminder)
                                }
                                saveReminders()
                                if addTime {
                                    scheduleNotification(for: reminder)
                                }
                                isAddingReminder = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                Text("Crear Recordatorio")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.pink, .pink.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(color: .pink.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isAddingReminder = false }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Regresar")
                        }
                        .foregroundColor(.pink)
                    }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: "savedReminders")
        }
    }
    
    private func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio"
        content.body = reminder.text
        content.sound = .default
        
        if let date = reminder.date, let time = reminder.time {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error al programar la notificación: \(error)")
                }
            }
        }
    }
}

// Vista personalizada para los toggles de opciones
struct OptionToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let title: String
    let subtitle: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Toggle(isOn: $isOn) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(.pink)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .tint(.pink)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color.black.opacity(0.05) : Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}


