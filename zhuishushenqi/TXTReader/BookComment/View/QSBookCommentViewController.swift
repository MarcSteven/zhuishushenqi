//
//  QSBookCommentViewController.swift
//  zhuishushenqi
//
//  Created caonongyun on 2017/4/24.
//  Copyright © 2017年 QS. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import UIKit
import RxSwift

class ZSBookCommentViewController: ZSBaseTableViewController ,Refreshable{
    
    var viewModel:ZSBookCTViewModel = ZSBookCTViewModel()
    
    var headerRefresh:MJRefreshHeader?
    var footerRefresh:MJRefreshFooter?
    
    var detailHeaderView:ZSReviewDetailView?
    
    var helpfulHeaderView:ZSBookCommentHelpfulHeaderView?
    var normalHeaderView:ZSBookCommentHelpfulHeaderView?
    var bestHeaderView:ZSBookCommentHelpfulHeaderView?
    var writeCommentButton:UIButton!
    
    var disposeBag = DisposeBag()
    
    let helpfulHeaderViewTag = 11240
    let normalCommentHeaderViewTag = 11241
    let bestCommentHeaderViewTag = 11242
    
    override init(style: UITableView.Style) {
        super.init(style: .grouped)
        title = "书评"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        writeCommentButton.removeFromSuperview()
    }
    
    func addObserver(){
//        extern NSString *const CTDisplayViewImagePressedNotification;
//        extern NSString *const CTDisplayViewLinkPressedNotification;
//        let imagePressed = NSNotification.Name.CTDisplayViewImagePressed.rawValue
//        let linkPressed = NSNotification.Name.CTDisplayViewLinkPressed.rawValue
        print(NSNotification.Name.CTDisplayViewImagePressed)
//        NotificationCenter.qs_addObserver(observer: self, selector: #selector(handleClick(noti:)), name: imagePressed, object: nil)
//        NotificationCenter.qs_addObserver(observer: self, selector: #selector(handleClick(noti:)), name: linkPressed, object: nil)

    }
    
    func setupSubviews() {
        tableView.sectionHeaderHeight = 60
        tableView.sectionFooterHeight = CGFloat.leastNonzeroMagnitude
        tableView.estimatedRowHeight = 180
        tableView.rowHeight = UITableView.automaticDimension
        
        detailHeaderView = ZSReviewDetailView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: viewModel.layout?.totalHeight ?? 0))
        detailHeaderView?.backgroundColor = UIColor.white
        detailHeaderView?.gotoBookHandler = { id in
            self.navigationController?.pushViewController(QSBookDetailRouter.createModule(id: id), animated: true) 
        }
        
        helpfulHeaderView = ZSBookCommentHelpfulHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
        helpfulHeaderView?.titleLabel.text = "这个书评对你是否有用"
        normalHeaderView = ZSBookCommentHelpfulHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
        normalHeaderView?.titleLabel.text = "0条评论"
        bestHeaderView = ZSBookCommentHelpfulHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
        bestHeaderView?.titleLabel.text = "神评论"
        
        writeCommentButton = UIButton(type: .custom)
        writeCommentButton.frame = CGRect(x: 0, y: self.view.bounds.height - 50, width: self.view.bounds.width, height: 50)
        writeCommentButton.backgroundColor = UIColor.red
        writeCommentButton.setTitle("写评论", for: .normal)
        writeCommentButton.setTitleColor(UIColor.white, for: .normal)
        writeCommentButton.addTarget(self, action: #selector(writeComment(btn:)), for: .touchUpInside)
        writeCommentButton.isHidden = true
        KeyWindow?.addSubview(writeCommentButton)

        
        let header = initRefreshHeader(tableView) {
            self.viewModel.fetchCommentDetail(handler: { (detail) in
                self.tableView.reloadData()
            })
            self.viewModel.fetchNewNormal(handler: { (normals) in
                self.tableView.reloadData()
            })
            self.viewModel.fetchCommentBest(handler: { (best) in
                self.tableView.reloadData()
            })
        }
        let footer = initRefreshFooter(tableView) {
            if let _  = self.viewModel.best {
                
            } else {
                self.viewModel.fetchCommentBest(handler: { (best) in
                    if let _ = self.viewModel.best {
                        self.tableView.reloadSection(2, with: .none)
                    }
                })
            }
            self.viewModel.fetchNormalMore(handler: { (more) in
                self.tableView.reloadData()
            })
        }
        headerRefresh = header
        footerRefresh = footer
        
        headerRefresh?.beginRefreshing()
        viewModel.autoSetRefreshHeaderStatus(header: header, footer: footer).disposed(by: disposeBag)
    }
    
    @objc
    func writeComment(btn:UIButton) {
        if ZSLogin.share.hasLogin() {
            viewModel.fetchPost(token: ZSLogin.share.token, content: "") { (json) in
                if json?["ok"] as? Bool == true {
                    self.view.showTip(tip: "评论成功")
                } else {
                    self.view.showTip(tip: "评论失败")
                }
            }
        } else {
            self.view.showTip(tip: "请先登录")
        }
    }
    
    @objc
    func handleClick(noti:[String:Any]){
        if let linkData = noti["linkData"] as? CoreTextLinkData {
            if let comment = viewModel.linkURL(linkData: linkData) as? BookComment {
                let commentVC = ZSBookCommentViewController(style: .grouped)
                commentVC.viewModel.model = comment
                self.navigationController?.pushViewController(commentVC, animated: true)
            } else if let id = viewModel.linkURL(linkData: linkData) as? String {
                self.navigationController?.pushViewController(QSTopicDetailRouter.createModule(id: id), animated: true)

            } else if linkData.linkTo == "search" {
                let searchVC = ZSSearchViewController(style: .grouped)
                searchVC.searchViewModel.keywords = linkData.key
                self.navigationController?.pushViewController(searchVC, animated: true)
            }
        } else if let imageData = noti["imageData"] as? CoreTextImageData {
            
        }
    }
    
    override func registerCellNibs() -> Array<AnyClass> {
        return [BookCommentCell.self,UserfulCell.self,BookCommentViewCell.self]
    }
    
    //MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        if let detail = viewModel.detail {
            normalHeaderView?.titleLabel.text = "\(detail.commentCount)条评论"
            sections += 1
        }
        
        if (viewModel.detail?.helpful.total ?? 0) != 0 {
            sections += 1
        }
        if let best = viewModel.best {
            if best.count > 0 {
                sections += 1
            }
        }
        if let normal = viewModel.normal {
            if normal.count > 0 {
                sections += 1
            }
        }
        return sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sections = 0
        if let _ = viewModel.detail {
            sections += 1
            if section == (sections - 1) {
                return 0
            }
        }
        if (viewModel.detail?.helpful.total ?? 0) != 0 {
            sections += 1
            if section == (sections - 1) {
                return 1
            }
        }
        if let best = viewModel.best {
            if best.count > 0 {
                sections += 1
            }
            if section == (sections - 1) {
                return best.count
            }
        }
        if let normal = viewModel.normal {
            if normal.count > 0 {
                sections += 1
            }
            if section == (sections - 1) {
                return normal.count
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var sections = 0
        
        if let _ = viewModel.detail {
            writeCommentButton.isHidden = false
            sections += 1
        }
        if (viewModel.detail?.helpful.total ?? 0) != 0{
            sections += 1
            if indexPath.section == (sections - 1) {
                let cell:UserfulCell? = tableView.qs_dequeueReusableCell(UserfulCell.self)
                cell?.backgroundColor = UIColor.white
                cell?.selectionStyle = .none
                cell?.model = viewModel.detail
                return cell!
            }
        }
        if let best = viewModel.best {
            if best.count > 0 {
                sections += 1
            }
            if indexPath.section == (sections - 1) {
                let cell:BookCommentViewCell? = tableView.qs_dequeueReusableCell(BookCommentViewCell.self)
                cell?.backgroundColor = UIColor.white
                cell?.selectionStyle = .none
                cell?.type = .magical
                cell?.bind(book: best[indexPath.row])
                return cell!
            }
        }
        if let normal = viewModel.normal {
            if normal.count > 0 {
                sections += 1
            }
            if indexPath.section == (sections - 1) {
                let cell:BookCommentViewCell? = tableView.qs_dequeueReusableCell(BookCommentViewCell.self)
                cell?.backgroundColor = UIColor.white
                cell?.selectionStyle = .none
                cell?.type = .normal
                cell?.bind(book: normal[indexPath.row])
                return cell!
            }
        }
        return UITableViewCell(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let _ = viewModel.detail {
                return viewModel.layout?.totalHeight ?? 0
            }
            return 0
        } else {
            if (viewModel.detail?.helpful.total ?? 0) != 0 {
                return 91
            }
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var sections = 0
        if let detail = viewModel.detail {
            sections += 1
            if section == (sections - 1) {
                if let data = viewModel.data {
                    if viewModel.layout == nil {
                        viewModel.layout = ZSBookCTLayoutModel(book: detail, data: data)
                    } else {
                        viewModel.layout?.setupLayout(book: detail, data: data)
                    }
                    detailHeaderView?.setupDetail(detail: detail, data: data)
                    
                }
                return viewModel.layout?.totalHeight ?? 0
            }
        }
        return tableView.sectionHeaderHeight
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sections = 0
        if let _ = viewModel.detail {
            sections += 1
            if section == (sections - 1) {
                return detailHeaderView
            }
        }
        if (viewModel.detail?.helpful.total ?? 0) != 0 {
            sections += 1
            if section == (sections - 1) {
                return helpfulHeaderView
            }
        }
        if let best = viewModel.best {
            if best.count > 0 {
                sections += 1
            }
            if section == (sections - 1) {
                return bestHeaderView
            }
        }
        if let normal = viewModel.normal {
            if normal.count > 0 {
                sections += 1
            }
            if section == (sections - 1) {
                return normalHeaderView
            }
        }
        return nil
    }
}

class ZSBookCommentHelpfulHeaderView:UIView {
    
    var titleLabel:UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 15, y: 30, width: self.bounds.width - 30, height: 30)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(titleLabel)
    }
}

class QSBookCommentViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate, QSBookCommentViewProtocol,Refreshable {

	var presenter: QSBookCommentPresenterProtocol?

    var model:BookComment?
    var hotComments:[BookCommentDetail]? = [BookCommentDetail]()
    var normalComments:[BookCommentDetail]? = [BookCommentDetail]()
    var detail:BookComment?
    
    fileprivate lazy var tableView:UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: ScreenWidth, height: ScreenHeight - 64), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 60
        tableView.sectionFooterHeight = CGFloat.leastNonzeroMagnitude
        tableView.estimatedRowHeight = 180
        tableView.rowHeight = UITableView.automaticDimension
        tableView.qs_registerCellNib(BookCommentCell.self)
        tableView.qs_registerCellNib(UserfulCell.self)

//        tableView.qs_registerCellNib(BookCommentViewCell.self)
        tableView.qs_registerCellNib(BookCommentViewCell.self)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.qs_addObserver(observer: self, selector: #selector(refreshCell(noti:)), name: "BookCellRefreshHeight", object: nil)
        
        initRefreshFooter(tableView) {
            self.presenter?.requestMore()
        }
        title = "精华书评"
        let rightBtn = UIButton(type: .custom)
        rightBtn.addTarget(self, action: #selector(jump(btn:)), for: .touchUpInside)
        //        rightBtn.setImage(UIImage(named:"actionbar_close"), for: .normal)
        rightBtn.setTitle("去底部", for: .normal)
        rightBtn.setTitleColor(UIColor.red, for: .normal)
        rightBtn.frame = CGRect(x: self.view.bounds.width - 75, y: 7, width: 60, height: 30)
        let rightBar = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightBar
        presenter?.viewDidLoad()
        view.addSubview(tableView)
    }
    
    @objc func refreshCell(noti:Notification){
        self.tableView.reloadData()
    }
    
    @objc func jump(btn:UIButton){
        var section = 2
        var row = 0
        if (self.hotComments?.count ?? 0)  > 0  {
            section = 3
        }
        if (self.normalComments?.count ?? 0) > 0 {
            row = (self.normalComments?.count ?? 1) - 1
        }
        let indexPath = IndexPath(row: row, section: section)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 4
        if (self.hotComments?.count ?? 0) == 0 {
            sections = 3
        }
        if (self.normalComments?.count ?? 0) == 0 {
            sections = 2
        }
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return (self.hotComments?.count ?? 0)
        }else if section == 3{
            return (self.normalComments?.count ?? 0)
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellAt(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let height = BookCommentCell.totalCellHeight
            return height
        }else if indexPath.section == 1 {
            return 91
        }else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return tableView.sectionHeaderHeight
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.sectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        if section > 0 {
//            let headerTitles = ["这个书评是否对你有用","仰望神评论","\(self.detail?.commentCount ?? 0)条评论"]
//            let headerView = UIView()
//            let headerLabel = UILabel()
//            headerLabel.frame = CGRect(x: 15, y: 30, width: self.view.bounds.width - 30, height: 30)
//            headerLabel.text = headerTitles[section - 1]
//            headerLabel.textColor = UIColor.darkGray
//            headerLabel.font = UIFont.systemFont(ofSize: 13)
//            headerView.addSubview(headerLabel)
//            return headerView
//        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cellAt(indexPath:IndexPath) -> UITableViewCell {
        
        if indexPath.section ==  0{
            let cell:BookCommentCell? = tableView.qs_dequeueReusableCell(BookCommentCell.self)
            cell?.backgroundColor = UIColor.white
            cell?.selectionStyle = .none
            cell?.model = detail
            return cell!
        }else if indexPath.section == 1{
            let cell:UserfulCell? = tableView.qs_dequeueReusableCell(UserfulCell.self)
            cell?.backgroundColor = UIColor.white
            cell?.selectionStyle = .none
            cell?.model = detail
            return cell!
        }else {
//            let cell:BookCommentViewCell? = tableView.qs_dequeueReusableCell(BookCommentViewCell.self)
            let cell:BookCommentViewCell? = tableView.qs_dequeueReusableCell(BookCommentViewCell.self)
            
            cell?.backgroundColor = UIColor.white
            cell?.selectionStyle = .none
            let types = [CommentType.magical,CommentType.normal]
            cell?.type = .normal
            if (self.hotComments?.count ?? 0) > 0 {
                if indexPath.section == 2 {
                    cell?.type = types[indexPath.section - 2]
                    if let model = self.hotComments?[indexPath.row]{
                        cell?.bind(book: model)
                    }
//                    cell?.model = self.hotComments?[indexPath.row]
                }else{
                    if let model = self.normalComments?[indexPath.row]{
                        cell?.bind(book: model)
                    }
//                    cell?.model = self.normalComments?[indexPath.row]
                }
            }else{
                if let model = self.hotComments?[indexPath.row]{
                    cell?.bind(book: model)
                }
//                cell?.model = self.normalComments?[indexPath.row]
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = UIStoryboard(name: "TXTReader", bundle: nil).instantiateInitialViewController()
//        present(vc!, animated: true, completion: nil)
    }
    
    func showDetail(detail: BookComment) {
        self.detail = detail
        self.tableView.reloadData()
    }
    
    func showHot(hots: [BookCommentDetail]) {
        self.hotComments = hots
        self.tableView.reloadData()
    }
    
    func showNormal(normals: [BookCommentDetail]) {
        self.normalComments = normals
        self.tableView.reloadData()
    }
    
    func showEmpty() {
        
    }
}
