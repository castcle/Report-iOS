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
//  ReportDetailViewModel.swift
//  Report
//
//  Created by Castcle Co., Ltd. on 8/8/2565 BE.
//

import Core
import Networking

public final class ReportDetailViewModel {
    private var reportRepository: ReportRepository = ReportRepositoryImpl()
    let tokenHelper: TokenHelper = TokenHelper()
    var reportType: ReportType = .content
    var castcleId: String = ""
    var contentId: String = ""
    var subject: ReportSubject = ReportSubject()
    var reason: String = ""
    private var reportRequest: ReportRequest = ReportRequest()
    private var state: State = .none

    public init(reportType: ReportType, castcleId: String, contentId: String, subject: ReportSubject = ReportSubject()) {
        self.reportType = reportType
        self.castcleId = castcleId
        self.contentId = contentId
        self.subject = subject
        self.tokenHelper.delegate = self
    }

    func report() {
        if self.reportType == .content {
            self.reportContent()
        } else {
            self.reportUser()
        }
    }

    private func reportContent() {
        self.state = .reportContent
        self.reportRequest.targetContentId = self.contentId
        self.reportRequest.subject = self.subject.slug
        self.reportRequest.message = self.reason
        self.reportRepository.reportContent(userId: UserManager.shared.castcleId, reportRequest: self.reportRequest) { (success, _, isRefreshToken) in
            if success {
                ContentHelper.shared.updateReportRef(contentId: self.contentId)
                self.didReportFinish?()
            } else {
                if isRefreshToken {
                    self.tokenHelper.refreshToken()
                } else {
                    self.didError?()
                }
            }
        }
    }

    private func reportUser() {
        self.state = .reportUser
        self.reportRequest.targetCastcleId = self.castcleId
        self.reportRequest.subject = self.subject.slug
        self.reportRequest.message = self.reason
        self.reportRepository.reportUser(userId: UserManager.shared.castcleId, reportRequest: self.reportRequest) { (success, _, isRefreshToken) in
            if success {
                self.didReportFinish?()
            } else {
                if isRefreshToken {
                    self.tokenHelper.refreshToken()
                } else {
                    self.didError?()
                }
            }
        }
    }

    var didReportFinish: (() -> Void)?
    var didError: (() -> Void)?
}

extension ReportDetailViewModel: TokenHelperDelegate {
    public func didRefreshTokenFinish() {
        if self.state == .reportContent {
            self.reportContent()
        } else if self.state == .reportUser {
            self.reportUser()
        }
    }
}
