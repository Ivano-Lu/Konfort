//
//  HistoryView.swift
//  Konfort
//
//  Created by Ivano Lu on 03/11/24.
//

import SwiftUI

struct HistoryView: View {
    
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        HistoryContentView(
            titleSection: $viewModel.titleSection,
            ygraph: $viewModel.days,
            leftTitle: $viewModel.weeklyScroreText,
            leftValue: $viewModel.weeklyScore,
            leftValueColor: $viewModel.weeklyScoreColor,
            rightTitle: $viewModel.todayScoreText,
            rightValue: $viewModel.todayScore,
            rightValueColor: $viewModel.todayScoreColor,
            subtitleSection: $viewModel.subTitleSection,
            leftSubtitle: $viewModel.xInfoTitle,
            centarlSubtitle: $viewModel.yInfoTitle,
            rightSubtitle: $viewModel.zInfoTitle,
            leftSubtitleValue: $viewModel.xInfoValue,
            centerSubtitleValue: $viewModel.yInfoValue,
            rightSubtitleValue: $viewModel.zInfoValue,
            leftSubtitleValueColor: $viewModel.xInfoTitleColor,
            centerSubtitleValueColor: $viewModel.yInfoTitleColor,
            rightSubtitleValueColor: $viewModel.zInfoTitleColor,
            firstInfoBottom: $viewModel.hystoryPostureInfo,
            info: $viewModel.hystoryPostureInfo,
            infoColor: $viewModel.hystoryPostureInfoColor,
            subInfo: viewModel.subInfo
        )
    }
}

#Preview {
    HistoryView()
}
