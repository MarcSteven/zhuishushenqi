//
//  DynamicViewController.swift
//  zhuishushenqi
//
//  Created by Nory Cao on 16/10/22.
//  Copyright © 2016年 QS. All rights reserved.
//

import UIKit

class DynamicViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate ,Refreshable{

    var timeline:[QSHotModel]?
    fileprivate var segment:UISegmentedControl = {
       let seg = UISegmentedControl(frame: CGRect.zero)
        seg.insertSegment(withTitle: "动态", at: 0, animated: false)
        seg.insertSegment(withTitle: "热门", at: 1, animated: false)
        seg.insertSegment(withTitle: "我的", at: 2, animated: false)
        seg.tintColor = UIColor.red
        seg.backgroundColor = UIColor.clear
        seg.selectedSegmentIndex = 1
        return seg
    }()
    
    fileprivate lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: kNavgationBarHeight + 40, width: ScreenWidth, height: ScreenHeight - kNavgationBarHeight - 40), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = 140
        tableView.sectionHeaderHeight = 0.0001
        tableView.sectionFooterHeight = 0.0001
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "动态"
        
        initRefreshHeader(tableView) {
            self.requestData()
        }
        
        tableView.qs_registerCellNib(DynamicCell.self)
        view.addSubview(segment)
        view.addSubview(tableView)
        requestData()  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        layoutSubview()
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        layoutSubview()
    }
    
    func layoutSubview() {
        segment.snp.remakeConstraints { (make) in
            let statusHeight = UIApplication.shared.statusBarFrame.height
            let navHeight = self.navigationController?.navigationBar.height ?? 0
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(navHeight + statusHeight + 5)
            make.height.equalTo(30)
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(segment.snp.bottom).offset(5)
        }
    }
    
    func requestData(){
        self.showProgress()
        let urlString = "\(BASEURL)/user/twitter/hottweets"
        zs_get(urlString, parameters: nil) { (response) in
            self.hideProgress()
            if let hottweets = response?["tweets"] as? [Any] {
                if let time = [QSHotModel].deserialize(from: hottweets) as? [QSHotModel] {
                    self.timeline = time
                    self.tableView.reloadData()
                    self.tableView.mj_header.endRefreshing()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeline?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DynamicCell = tableView.qs_dequeueReusableCell(DynamicCell.self)
        if let model = self.timeline?[indexPath.row] {
            cell.setContent(model: model)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //post为null
//        http://api.zhuishushenqi.com/user/twitter/58d14859d0693ae736034619/comments
        //post不为null，id从post中取
//        http://api.zhuishushenqi.com/post/58d1d313bd7cc9961f93192d/comment?start=0&limit=50
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.timeline?[indexPath.row]
        let comment = BookComment()
        comment._id = (model?.tweet.post._id) ?? ""
        let commentVC = ZSBookCommentViewController(style: .grouped)
        commentVC.viewModel.model = comment
        self.navigationController?.pushViewController(commentVC, animated: true)
//        let reviewVC = ZSBookReviewDetailViewController()
//        reviewVC.viewModel.model = comment
//        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
