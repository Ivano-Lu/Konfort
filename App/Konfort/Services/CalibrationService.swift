//
//  CalibrationService.swift
//  Konfort
//
//  Created by Ivano Lu on 21/06/25.
//

import Foundation
import SwiftUI

class CalibrationService {
    static let shared = CalibrationService()
    private init() {}

    private var storedCalibrationData: CalibrationDataPayload?
    
    func setCalibrationData(_ data: CalibrationDataPayload) {
            self.storedCalibrationData = data
        }

    func getCalibrationData() -> CalibrationDataPayload? {
        return self.storedCalibrationData
    }
    
    func fetchCalibrationData(userId: Int, completion: @escaping (Bool) -> Void) {
        let query = """
        query FetchCalibrationData($userId: ID!) {
            fetchCalibrationData(userId: $userId) {
                id
                matrix
                invertedMatrix
                determinant
            }
        }
        """

        let variables = ["userId": String(userId)]

        let requestBody: [String: Any] = [
            "query": query,
            "variables": variables,
            "operationName": "FetchCalibrationData"
        ]

        guard let url = URL(string: "http://192.168.88.40:8080/graphql"),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ URL o body invalido")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Errore richiesta: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = data else {
                print("❌ Nessun dato ricevuto")
                completion(false)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataDict = json["data"] as? [String: Any],
                   let calibData = dataDict["fetchCalibrationData"] as? [String: Any] {

                    let id = calibData["id"] as? String ?? ""
                    let determinant = calibData["determinant"] as? Double ?? 0.0
                    let matrix = calibData["matrix"] as? [[Double]] ?? []
                    let invertedMatrix = calibData["invertedMatrix"] as? [[Double]] ?? []

                    let calibrationData = CalibrationDataPayload(
                        id: id,
                        matrix: matrix,
                        invertedMatrix: invertedMatrix,
                        determinant: determinant
                    )

                    // ✅ Salva internamente nel service
                    self.setCalibrationData(calibrationData)

                    completion(true)
                } else {
                    print("❌ JSON parsing error o dati mancanti")
                    completion(false)
                }
            } catch {
                print("❌ Errore parsing JSON: \(error)")
                completion(false)
            }
        }.resume()
    }

}
