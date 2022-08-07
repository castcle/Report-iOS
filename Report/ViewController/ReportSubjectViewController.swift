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
//  ReportSubjectViewController.swift
//  Report
//
//  Created by Castcle Co., Ltd. on 7/8/2565 BE.
//

import UIKit
import Core
import Defaults

class ReportSubjectViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var viewModel = ReportSubjectViewModel(reportType: .content, castcleId: "", contentId: "")

    enum ReportSubjectViewControllerSection: Int, CaseIterable {
        case header = 0
        case subject
        case footer
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Asset.darkGraphiteBlue
        self.configureTableView()
        self.viewModel.getReportSubject()
        self.viewModel.didGetReportSubjectFinish = {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavBar()
        Defaults[.screenId] = ""
    }

    func setupNavBar() {
        self.customNavigationBar(.secondary, title: "Report \(self.viewModel.reportType == .content ? "Cast" : "User"))")
    }

    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: ReportNibVars.TableViewCell.reportSubjectHeader, bundle: ConfigBundle.report), forCellReuseIdentifier: ReportNibVars.TableViewCell.reportSubjectHeader)
        self.tableView.register(UINib(nibName: ReportNibVars.TableViewCell.reportSubject, bundle: ConfigBundle.report), forCellReuseIdentifier: ReportNibVars.TableViewCell.reportSubject)
        self.tableView.register(UINib(nibName: ReportNibVars.TableViewCell.reportSubjectFooter, bundle: ConfigBundle.report), forCellReuseIdentifier: ReportNibVars.TableViewCell.reportSubjectFooter)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
}

extension ReportSubjectViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ReportSubjectViewControllerSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == ReportSubjectViewControllerSection.subject.rawValue {
            return self.viewModel.subjects.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case ReportSubjectViewControllerSection.header.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportNibVars.TableViewCell.reportSubjectHeader, for: indexPath as IndexPath) as? ReportSubjectHeaderTableViewCell
            cell?.configCell(reportType: self.viewModel.reportType)
            cell?.backgroundColor = UIColor.clear
            return cell ?? ReportSubjectHeaderTableViewCell()
        case ReportSubjectViewControllerSection.subject.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportNibVars.TableViewCell.reportSubject, for: indexPath as IndexPath) as? ReportSubjectTableViewCell
            cell?.backgroundColor = UIColor.clear
            cell?.configCell(reportSublect: self.viewModel.subjects[indexPath.row])
            return cell ?? ReportSubjectTableViewCell()
        case ReportSubjectViewControllerSection.footer.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportNibVars.TableViewCell.reportSubjectFooter, for: indexPath as IndexPath) as? ReportSubjectFooterTableViewCell
            cell?.backgroundColor = UIColor.clear
            return cell ?? ReportSubjectFooterTableViewCell()
        default:
            return UITableViewCell()
        }
    }
}
