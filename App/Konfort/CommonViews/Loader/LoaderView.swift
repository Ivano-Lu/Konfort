//
//  LoaderView.swift
//  Konfort
//
//  Created by Ivano Lu on 27/10/24.
//

import SwiftUI


struct LoaderView: View {
    
    var text = "Loading..."
    
    var body: some View {
        
        ProgressView(text)
            .progressViewStyle(.circular)
            .padding()
            .background(Color.gray.opacity(0.9))
            .cornerRadius(8)
        
    }
    
}



#Preview {
    LoaderView()
}
