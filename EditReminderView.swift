//
//  EditReminderView.swift
//  Recordatorios
//
//  Created by Erick David Gómez Guadiana on 31/10/24.
//

import SwiftUI
import Foundation

struct EditReminderView: View {
    @Binding var reminder: Reminder
    @Binding var reminders: [Reminder]
    @State private var newReminderText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var addDate = false
    @State private var addTime = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) private var presentationMode
    
    private var minimumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var isValidDateTime: Bool {
        if !addDate && !addTime { return true }
        
        let calendar = Calendar.current
        let now = Date()
        
        if addDate && addTime {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
            var combinedComponents = dateComponents
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            
            guard let combinedDate = calendar.date(from: combinedComponents) else { return false }
            return combinedDate > now
        } else if addDate {
            return calendar.startOfDay(for: selectedDate) >= calendar.startOfDay(for: now)
        } else if addTime {
            let selectedComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
            let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
            
            let selectedMinutes = (selectedComponents.hour ?? 0) * 60 + (selectedComponents.minute ?? 0)
            let currentMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)
            
            return selectedMinutes > currentMinutes
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Editar Recordatorio")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.pink)
                    .padding()
                
                TextField("Escribe tu recordatorio aquí...", text: $newReminderText)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Toggle("Agregar fecha", isOn: $addDate)
                    .padding(.horizontal)
                
                if addDate {
                    DatePicker(
                        "Selecciona la fecha",
                        selection: $selectedDate,
                        in: minimumDate...,
                        displayedComponents: .date
                    )
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Toggle("Agregar hora", isOn: $addTime)
                    .padding(.horizontal)
                    .onChange(of: addTime) { newValue in
                        if newValue {
                            // Establecer la hora actual + 1 minuto como mínimo
                            selectedTime = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
                        }
                    }
                
                if addTime {
                    DatePicker(
                        "Selecciona la hora",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: saveChanges) {
                    Text("Guardar cambios")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .alert(alertMessage, isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
            .onAppear(perform: setupInitialValues)
        }
    }
    
    private func setupInitialValues() {
        newReminderText = reminder.text
        if let reminderDate = reminder.date {
            selectedDate = reminderDate
            addDate = true
        }
        if let reminderTime = reminder.time {
            selectedTime = reminderTime
            addTime = true
        }
    }
    
    private func saveChanges() {
        if newReminderText.isEmpty {
            alertMessage = "El recordatorio debe tener nombre."
            showAlert = true
            return
        }
        
        if !isValidDateTime {
            alertMessage = "La fecha y hora seleccionadas deben ser posteriores a la actual."
            showAlert = true
            return
        }
        
        // Cancelar la notificación existente antes de actualizarla
        NotificationManager.shared.cancelNotification(for: reminder)
        
        // Actualizar el recordatorio
        reminder.text = newReminderText
        reminder.date = addDate ? selectedDate : nil
        reminder.time = addTime ? selectedTime : nil
        
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            
            // Programar nueva notificación si tiene fecha y hora
            if addDate && addTime {
                NotificationManager.shared.scheduleNotification(for: reminder)
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}
