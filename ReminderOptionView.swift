//
//  ReminderOptionView.swift
//  Recordatorios
//
//  Created by Erick David Gómez Guadiana on 01/11/24.
//

import SwiftUI

struct ReminderOptionView: View {
    @Binding var showAddReminder: Bool
    @Binding var createWithoutDate: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("¿Deseas agregar fecha y hora?")
                .font(.title2)
                .padding()

            Button(action: {
                createWithoutDate = true
                showAddReminder = false
            }) {
                Text("Sin fecha y hora")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Button(action: {
                createWithoutDate = false
                showAddReminder = true
            }) {
                Text("Con fecha y hora")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}
