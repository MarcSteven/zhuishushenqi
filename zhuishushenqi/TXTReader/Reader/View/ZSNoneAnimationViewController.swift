//
//  ZSNoneAnimationViewController.swift
//  zhuishushenqi
//
//  Created by caony on 2018/7/3.
//  Copyright © 2018年 QS. All rights reserved.
// 无动画阅读控制器,管理手势,左滑手势显示下一页,右滑手势显示上一页,或者点击左侧右侧屏幕显示下一页,点击左侧屏幕显示上一页

import UIKit

class ZSNoneAnimationViewController: BaseViewController {
    
    var viewModel:ZSReaderViewModel = ZSReaderViewModel()
    
    var pageViewController:PageViewController = PageViewController()
    
    var record:QSRecord = QSRecord()
    
    var cachedChapter:[String:QSChapter] = [:]
    
    fileprivate var changedPage = false


    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecord()
        initial()
        setupSubviews()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func initial(){
        if let record = viewModel.book?.record {
            if let chapterModel = record.chapterModel {
                let pageIndex = record.page
                if pageIndex < chapterModel.pages.count {
                    pageViewController.page = chapterModel.pages[pageIndex]
                }
            } else if (viewModel.book?.book.localChapters.count)! > 0 {
                if let chapters =  viewModel.book?.book.localChapters {
                    let chapterIndex = record.chapter
                    let pageIndex = record.page
                    if chapterIndex < chapters.count  {
                        let chapterModel = chapters[chapterIndex]
                        if pageIndex < chapterModel.pages.count {
                            pageViewController.page = chapterModel.pages[pageIndex]
                        }
                    }
                }
            }
        }
        self.viewModel.fetchAllResource { resources in
            self.viewModel.fetchAllChapters({ (chapters) in
                self.viewModel.fetchInitialChapter({ (page) in
                    self.pageViewController.page = page
                })
            })
        }
        
    }
    
    func setupRecord(){
        // 第一次进入没有record,初始化一个record
        if let book = viewModel.book {
            record.bookId = book._id
            if book.record == nil {
                book.record = record
            }
        }
    }
    
    func setupSubviews(){
        view.addSubview(pageViewController.view)
    }
    
    func setupGesture(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        view.addGestureRecognizer(pan)
    }
    
    @objc func panAction(pan:UIPanGestureRecognizer){
        // x方向滑动超过20就翻页
        let translation:CGPoint = pan.translation(in: self.view)
        
        if pan.state == .changed && !changedPage {
            let offsetX = translation.x
            if offsetX < -20 {
                // 在本次手势结束前都不再响应
                changedPage = true
                getNextPage()
            } else if (offsetX > 20) {
                // 在本次手势结束前都不再响应
                changedPage = true
                getLastPage()
            }
        } else if pan.state == .ended {
            changedPage = false
        }
    }
    
    // 获取下一个页面
    func getNextPage(){
        
        self.viewModel.fetchNextPage { (page) in
            // 更新record
            self.pageViewController.page = page
            self.viewModel.updateNextRecord(callback: { (page) in
                if self.pageViewController.page?.curPage != self.viewModel.book?.record?.page {
                    self.pageViewController.page = page
                }
            })
        }
    }
    
    func getLastPage(){
        viewModel.fetchLastPage { (page) in
            self.pageViewController.page = page
            self.viewModel.updateLastRecord(callback: { (page) in
                if self.pageViewController.page?.curPage != self.viewModel.book?.record?.page {
                    self.pageViewController.page = page
                }
            })
        }
    }
    
    func changeSourceClicked() {
        let sourceVC = ChangeSourceViewController()
        sourceVC.viewModel = self.viewModel
        sourceVC.selectAction = { (index:Int,sources:[ResourceModel]?) in
            self.viewModel = sourceVC.viewModel
            self.viewModel.cachedChapter.removeAll()
            self.viewModel.fetchAllChapters({ (info) in
                self.viewModel.fetchCurrentPage({ (page) in
                    self.pageViewController.page = page
                })
            })
        }
        let nav = UINavigationController(rootViewController: sourceVC)
        present(nav, animated: true) {
            
        }
    }
}

extension ZSNoneAnimationViewController:ZSReaderTap{
    func showLastPage(page:QSPage) {
        pageViewController.page = page
    }
    
    func showNextPage(page:QSPage) {
        pageViewController.page = page
    }
}

extension ZSNoneAnimationViewController:ZSReaderControllerProtocol {
    typealias Item = Book
    
    
}
