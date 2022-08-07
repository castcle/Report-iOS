//  Copyright (c) 2021, Castcle and/or its affiliates. All rights reserved.
//  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
//
//  This code is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 only, as
//  published by the Free Software Foundation.
//
//  This code is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
//  version 3 for more details (a copy is included in the LICENSE file that
//  accompanied this code).
//
//  You should have received a copy of the GNU General Public License version
//  3 along with this work; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
//
//  Please contact Castcle, 22 Phet Kasem 47/2 Alley, Bang Khae, Bangkok,
//  Thailand 10160, or visit www.castcle.com if you need additional information
//  or have any questions.
//
//  ReportSubjectViewModel.swift
//  Report
//
//  Created by Castcle Co., Ltd. on 7/8/2565 BE.
//

import Core
import Networking
import SwiftyJSON

public final class ReportSubjectViewModel {
    private var reportRepository: ReportRepository = ReportRepositoryImpl()
    let tokenHelper: TokenHelper = TokenHelper()
    var reportType: ReportType = .content
    var castcleId: String = ""
    var contentId: String = ""
    var subjects: [ReportSubject] = []

    public init(reportType: ReportType, castcleId: String, contentId: String) {
        self.reportType = reportType
        self.castcleId = castcleId
        self.contentId = contentId
        self.tokenHelper.delegate = self
    }

    func getReportSubject() {
        self.reportRepository.getReportSubject { (success, response, isRefreshToken) in
            if success {
                do {
                    let rawJson = try response.mapJSON()
                    let json = JSON(rawJson)
                    self.subjects = (json[JsonKey.payload.rawValue].arrayValue).map { ReportSubject(json: $0) }.sorted { $0.order < $1.order }
                    self.didGetReportSubjectFinish?()
                } catch {}
            } else {
                if isRefreshToken {
                    self.tokenHelper.refreshToken()
                }
            }
        }
    }

    var didGetReportSubjectFinish: (() -> Void)?
}

extension ReportSubjectViewModel: TokenHelperDelegate {
    public func didRefreshTokenFinish() {
        self.getReportSubject()
    }
}
