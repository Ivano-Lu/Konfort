//
//  CalibrationContentView.swift
//  Konfort
//
//  Created by Ivano Lu on 18/11/24.
//

import SwiftUI

struct CalibrationContentView: View {
    var title = ""
    var subtitleText = ""
    var titleButton = ""

    @Binding var coordinates: [Coordinates]
    @State private var showCalibrationCard = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                Text(subtitleText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(spacing: 30) {
                    ForEach($coordinates, id: \.id) { coordinate in
                        CalibrationSectionView(coordinate: coordinate)
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    withAnimation {
                        showCalibrationCard = true
                    }
                }) {
                    Text(titleButton)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.top, 30)
            }
            .blur(radius: showCalibrationCard ? 3 : 0)

            if showCalibrationCard {
                CalibrationCard(show: $showCalibrationCard)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showCalibrationCard)
    }
}

struct CalibrationCard: View {
    @Binding var show: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("🧭 Calibrazione")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("Posizionati correttamente per iniziare la calibrazione. Mantieni la postura dritta e stabile.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                // Logica per iniziare la calibrazione vera e propria
                withAnimation {
                    show = false
                }
            }) {
                Text("Inizia calibrazione")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: {
                withAnimation {
                    show = false
                }
            }) {
                Text("Annulla")
                    .foregroundColor(.red)
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding()
    }
}



struct CalibrationSectionView: View {
    @Binding var coordinate: Coordinates

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(coordinate.name)
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 50) {
                CalibrationAxisView(axisTitle: "X", state: $coordinate.x)
                CalibrationAxisView(axisTitle: "Y", state: $coordinate.y)
                CalibrationAxisView(axisTitle: "Z", state: $coordinate.z)
            }
        }
    }
}

struct CalibrationAxisView: View {
    
    var axisTitle: String
    @Binding var state: Int
    
    var body: some View {
        VStack {
            Text(axisTitle)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(state > 0 ? "+" : "")\(state)°")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(state > 0 ? .green : state < 0 ? .red : .yellow)
        }
    }
}

#Preview {
    CalibrationView()
}
