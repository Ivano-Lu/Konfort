//
//  HistoryContentView.swift
//  Konfort
//
//  Created by Ivano Lu on 07/11/24.
//

import SwiftUI



struct HistoryContentView: View {
    
    @Binding var titleSection: String
    @Binding var ygraph: [String]
    
    @Binding var leftTitle: String
    @Binding var leftValue: String
    @Binding var leftValueColor: Color
    
    @Binding var rightTitle: String
    @Binding var rightValue: String
    @Binding var rightValueColor: Color
    
    @Binding var subtitleSection: String
    
    @Binding var leftSubtitle: String
    @Binding var centarlSubtitle: String
    @Binding var rightSubtitle: String
    
    @Binding var leftSubtitleValue: String
    @Binding var centerSubtitleValue: String
    @Binding var rightSubtitleValue: String
    
    @Binding var leftSubtitleValueColor: Color
    @Binding var centerSubtitleValueColor: Color
    @Binding var rightSubtitleValueColor: Color
    
    @Binding var firstInfoBottom: String
    
    @Binding var info: String
    @Binding var infoColor: Color
    
    var subInfo = ""
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text(titleSection)
                .foregroundColor(.white)
                .bold()
            
           
            HStack(spacing: 10) {
                ForEach(ygraph, id: \.self) { element in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.7))
                            .frame(width: 20, height: CGFloat.random(in: 50...120))
                        Text(element)
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }
            }
            .frame(height: 170)
            
            HStack(spacing: 16) {
                VStack {
                    Text(leftTitle)
                        .foregroundColor(.gray)
                    Text(leftValue)
                        .font(.title)
                        .foregroundColor(leftValueColor)
                }
                
                VStack {
                    Text(rightTitle)
                        .foregroundColor(.gray)
                    Text(rightValue)
                        .font(.title)
                        .foregroundColor(rightValueColor)
                }
            }
            
            
            Text(subtitleSection)
                .foregroundColor(.white)
                .bold()
            
            HStack {
                VStack {
                    Text(leftSubtitle)
                        .foregroundColor(.gray)
                    Text(leftSubtitleValue)
                        .foregroundColor(leftSubtitleValueColor)
                        .font(.title2)
                }
                Spacer()
                VStack {
                    Text(centarlSubtitle)
                        .foregroundColor(.gray)
                    Text(centerSubtitleValue)
                        .foregroundColor(centerSubtitleValueColor)
                        .font(.title2)
                }
                Spacer()
                VStack {
                    Text(rightSubtitle)
                        .foregroundColor(.gray)
                    Text(rightSubtitleValue)
                        .foregroundColor(rightSubtitleValueColor)
                        .font(.title2)
                }
            }
            
            Text(info)
                .foregroundColor(infoColor)
                .font(.caption)
            
            Text(subInfo)
                .foregroundColor(.gray)
                .font(.footnote)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
        .cornerRadius(15)
    }
    //    .padding()
}


#Preview {
    HistoryView()
}
