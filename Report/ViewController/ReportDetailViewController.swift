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
//  ReportDetailViewController.swift
//  Report
//
//  Created by Castcle Co., Ltd. on 8/8/2565 BE.
//

import UIKit
import Core
import Component
import Defaults

class ReportDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var viewModel = ReportDetailViewModel(reportType: .content, castcleId: "", contentId: "")

    enum ReportDetailViewControllerSection: Int, CaseIterable {
        case subject = 0
        case reason
        case submit
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.configureTableView()
        self.viewModel.didReportFinish = {
            CCLoading.shared.dismiss()
            Utility.currentViewController().navigationController?.pushViewController(ReportOpener.open(.reportSuccess(self.viewModel.reportType, self.viewModel.castcleId)), animated: true)
        }
        self.viewModel.didError = {
            CCLoading.shared.dismiss()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavBar()
        Defaults[.screenId] = ""
    }

    func setupNavBar() {
        self.customNavigationBar(.secondary, title: "Report \(self.viewModel.reportType == .content ? "Cast" : "User")")
    }

    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: ReportNibVars.TableViewCell.reportDetail, bundle: ConfigBundle.report), forCellReuseIdentifier: ReportNibVars.TableViewCell.reportDetail)
        self.tableView.register(UINib(nibName: ReportNibVars.TableViewCell.reportReason, bundle: ConfigBundle.report), forCellReuseIdentifier: ReportNibVars.TableViewCell.reportReason)
        self.tableView.register(UINib(nibName: ReportNibVars.TableViewCell.reportSubmit, bundle: ConfigBundle.report), forCellReuseIdentifier: ReportNibVars.TableViewCell.reportSubmit)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
}

extension ReportDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ReportDetailViewControllerSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == ReportDetailViewControllerSection.reason.rawValue {
            return (self.viewModel.subject.slug == "something-else" ? 1 : 0)
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case ReportDetailViewControllerSection.subject.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportNibVars.TableViewCell.reportDetail, for: indexPath as IndexPath) as? ReportDetailTableViewCell
            cell?.configCell(reportType: self.viewModel.reportType, subject: self.viewModel.subject)
            cell?.backgroundColor = UIColor.clear
            return cell ?? ReportDetailTableViewCell()
        case ReportDetailViewControllerSection.reason.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportNibVars.TableViewCell.reportReason, for: indexPath as IndexPath) as? ReportReasonTableViewCell
            cell?.backgroundColor = UIColor.clear
            cell?.delegate = self
            return cell ?? ReportReasonTableViewCell()
        case ReportDetailViewControllerSection.submit.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportNibVars.TableViewCell.reportSubmit, for: indexPath as IndexPath) as? ReportSubmitTableViewCell
            cell?.backgroundColor = UIColor.clear
            cell?.configCell(subject: self.viewModel.subject, reason: self.viewModel.reason)
            cell?.delegate = self
            return cell ?? ReportSubmitTableViewCell()
        default:
            return UITableViewCell()
        }
    }
}

extension ReportDetailViewController: ReportReasonTableViewCellDelegate {
    func didValueChange(_ reportReasonTableViewCell: ReportReasonTableViewCell, reason: String) {
        self.viewModel.reason = reason
        let indexPath = IndexPath(item: 0, section: 2)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension ReportDetailViewController: ReportSubmitTableViewCellDelegate {
    func didSubmit(_ reportSubmitTableViewCell: ReportSubmitTableViewCell) {
        if self.viewModel.subject.slug == "something-else" && !self.viewModel.reason.isEmpty {
            CCLoading.shared.show(text: "Reporting")
            self.viewModel.report()
        } else if self.viewModel.subject.slug != "something-else" {
            CCLoading.shared.show(text: "Reporting")
            self.viewModel.report()
        }
    }
}
