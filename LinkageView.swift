//
//  LinkageView.swift
//  AptitudesQuery
//
//  Created by TongNa on 2017/5/15.
//  Copyright © 2017年 TongNa. All rights reserved.
//

import Foundation
import TagListView
import SVProgressHUD

public struct DropIndexPath {
    var column: Int
    var row: Int
    var item: Int
    var otherItem: Int
}

struct TableScale {
    var left: Double
    var mid: Double
    var right: Double
    func leftScale() -> Double {
        return left/(left+mid+right)
    }
    func midScale() -> Double {
        return mid/(left+mid+right)
    }
    func rightScale() -> Double {
        return right/(left+mid+right)
    }
}

class DropBackgroundCellView: UIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setStrokeColor(red: 219.0/255, green: 224.0/255, blue: 228.0/255, alpha: 1)
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: rect.w , y: 0))
        context?.move(to: CGPoint(x: 0 , y: rect.h))
        context?.addLine(to: CGPoint(x: rect.w , y: rect.h))
        context?.strokePath()
    }
}

public protocol DropDownMenuDataSource: NSObjectProtocol {
    
    //返回 menu 有多少列 ，默认1列
    func numberOfColumnsInMenu(_ menu: DropDownMenu) -> Int
    //返回 menu 第column列有多少行
    func menu(_ menu: DropDownMenu, numberOfRowsInColumn column: Int) -> Int
    //返回 menu 第column列 每行title
    func menu(_ menu: DropDownMenu, titleForRowAtIndexPath indexPath: DropIndexPath) -> String
    //返回 menu 第column列 每行image
    func menu(_ menu: DropDownMenu, imageNameForRowAtIndexPath indexPath: DropIndexPath) -> String
    //detailText ,right text
    func menu(_ menu: DropDownMenu, detailTextForRowAtIndexPath indexPath: DropIndexPath) -> String
    //当有column列 row 行 返回有多少个item ，如果>0，说明有二级列表 ，=0 没有二级列表
    //如果都没有可以不实现该协议
    func menu(_ menu: DropDownMenu, numberOfItemsInRow row: Int, column: Int) -> Int
    //当有column列 row 行 item项 title
    //如果都没有可以不实现该协议
    func menu(_ menu: DropDownMenu, titleForItemsInRowAtIndexPath indexPath: DropIndexPath) -> String
    //当有column列 row 行 item项 image
    func menu(_ menu: DropDownMenu, imageNameForItemsInRowAtIndexPath indexPath: DropIndexPath) -> String
    //当有column列 row 行 item项 detailText
    func menu(_ menu: DropDownMenu, detailTextForItemsInRowAtIndexPath indexPath: DropIndexPath) -> String
    //当有column列 row 行 item项 返回有多少个otherItem ，如果>0，说明有三级列表 ，=0 没有三级列表
    //如果都没有可以不实现该协议
    func menu(_ menu: DropDownMenu, numberOfOtherItemsInItem item: Int, row: Int, column: Int) -> Int
    //当有column列 row 行 item项 otherItem title
    //如果都没有可以不实现该协议
    func menu(_ menu: DropDownMenu, titleForOtherItemsInItemAtIndexPath indexPath: DropIndexPath) -> String
    //当有column列 row 行 item项 otherItem image
    func menu(_ menu: DropDownMenu, imageNameForOtherItemsInItemAtIndexPath indexPath: DropIndexPath) -> String
    //当有column列 row 行 item项 otherItem detailText
    func menu(_ menu: DropDownMenu, detailTextForOtherItemsInItemAtIndexPath indexPath: DropIndexPath) -> String
}

public protocol DropDownMenuDelegate: NSObjectProtocol {
    func menu(_ menu: DropDownMenu, didSelectRowAtIndexPath indexPath: DropIndexPath,tableIndex: Int)
    func menu(_ menu: DropDownMenu, deSelectRowAtIndexPath indexPath: DropIndexPath)
    func menu(_ menu: DropDownMenu, willSelectRowAtIndexPath indexPath: DropIndexPath)
}

let kTableViewCellHeight = 43
let kTableViewHeight = h(300)
let kButtomImageViewHeight = 21
let kTextColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
let kDetailTextColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1)
let kSeparatorColor = UIColor(red: 219/255.0, green: 219/255.0, blue: 219/255.0, alpha: 1)
let kCellBgColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
let kTextSelectColor = UIColor(red: 246/255.0, green: 79/255.0, blue: 0/255.0, alpha: 1)
let kButtonHeight: CGFloat = 44
let tagTopMagin: CGFloat = h(10)

open class DropDownMenu: UIView {
    
    struct DataSourceFlags {
        var numberOfRowsInColumn = true
        var numberOfItemsInRow = true
        var numberOfOtherItemsInItem = true
        var titleForRowAtIndexPath = true
        var titleForItemsInRowAtIndexPath = true
        var titleForOtherItemsInItemAtIndexPath = true
        var imageNameForRowAtIndexPath = true
        var imageNameForItemsInRowAtIndexPath = true
        var imageNameForOtherItemsInItemAtIndexPath = true
        var detailTextForRowAtIndexPath = true
        var detailTextForItemsInRowAtIndexPath = true
        var detailTextForOtherItemsInItemAtIndexPath = true
    }
    var dataSourceFlags = DataSourceFlags()
    
    var cellStyle: UITableViewCellStyle = .default
    var indicatorColor: UIColor?                    // 三角指示器颜色
    var textColor: UIColor?                         // 文字title颜色
    var textSelectedColor: UIColor?                 // 文字title选中颜色
    var detailTextColor: UIColor?                   // detailText文字颜色
    var detailTextFont: UIFont?                    // font
    var separatorColor: UIColor?                    // 分割线颜色
    var fontSize: Int?                              // 字体大小
    var menuFontSize: Int?
    
    var isClickHaveItemValid: Bool?                 // 当有二级列表item时，点击row 是否调用点击代理方法
    var isClickHaveOtherItemValid: Bool?            // 当有三级列表otherItem时，点击item 是否调用点击代理方法
    var remainMenuTitle: Bool?                      // 切换条件时是否更改menu title
    var currentSelectRowArray = [Any]()          // 恢复默认选项用
    var currentSelectItemArray = [Any]()
    var finishedBlock: ((DropIndexPath) -> ()?)?       //回收回调
    var menuTappedBlock: (()->())?
    var currentSelectedMenudIndex: Int?
    var show: Bool? {
        didSet {
            if !show! {
                if let finish = finishedBlock, let index = currentIndexPath {
                    finish(index)
                }
            }
        }
    }
    var numOfMenu: Int?
    var _origin: CGPoint?
    var backGroundView: UIView?
    var leftTableView: UITableView?
    var middleTableView: UITableView?
    var rightTableView: UITableView?
    var buttomImageView: UIImageView?
    var bottomShadow: UIView?
    var array = [Any]()
    var titles = [CATextLayer]()
    var indicators = [CAShapeLayer]()
    var bgLayers = [CALayer]()
    var currentIndexPath: DropIndexPath?
    var tableViewHeight: CGFloat?
    
    var tableScale = TableScale(left: 1, mid: 1, right: 1)//只针对三级
    
    var tagView: TagListView?
    var tagBottomView: UIView?
    var isShowTag: Bool? {
        didSet{
            if isShowTag! {
                isClickHaveItemValid = false
                isClickHaveOtherItemValid = false
            }
        }
    }//是否显示tagView
    var tagsIndexPath = [DropIndexPath]()
    var resetBlock: (([DropIndexPath]) -> ()?)?       //重置回调
    var determineBlock: (([DropIndexPath]) -> ()?)?       //确定回调
    var tagsChangeBlock: ((DropIndexPath,Int) -> ()?)?
    var resetButton: UIButton?
    var determineButton: UIButton?
    
    var dataSource: DropDownMenuDataSource? {
        didSet {
            guard let dataSource = self.dataSource else {
                return
            }
            if dataSource.responds(to: Selector(("numberOfColumnsInMenu:"))) {
                numOfMenu = dataSource.numberOfColumnsInMenu(self)
            }else {
                numOfMenu = 1
            }
            for _ in 0..<numOfMenu! {
                currentSelectRowArray.append(0)
                currentSelectItemArray.append(0)
            }
            dataSourceFlags.numberOfRowsInColumn = dataSource.responds(to: Selector(("menu:numberOfRowsInColumn:")))
            dataSourceFlags.numberOfItemsInRow = dataSource.responds(to: Selector(("menu:numberOfItemsInRow:column:")))
            dataSourceFlags.numberOfOtherItemsInItem = dataSource.responds(to: Selector(("menu:numberOfOtherItemsInItem:row:column:")))
//            dataSourceFlags.titleForRowAtIndexPath = dataSource.responds(to: Selector(("menu:titleForRowAtIndexPath:")))
//            dataSourceFlags.titleForItemsInRowAtIndexPath = dataSource.responds(to: Selector(("menu:titleForItemsInRowAtIndexPath:")))
//            dataSourceFlags.imageNameForRowAtIndexPath = dataSource.responds(to: Selector(("menu:imageNameForRowAtIndexPath:")))
//            dataSourceFlags.imageNameForItemsInRowAtIndexPath = dataSource.responds(to: Selector(("menu:imageNameForItemsInRowAtIndexPath:")))
//            dataSourceFlags.detailTextForRowAtIndexPath = dataSource.responds(to: Selector(("menu:detailTextForRowAtIndexPath:")))
//            dataSourceFlags.detailTextForItemsInRowAtIndexPath = dataSource.responds(to: Selector(("menu:detailTextForItemsInRowAtIndexPath:")))
            
            bottomShadow?.isHidden = false
            
            let textLayerInterval = self.w / (CGFloat(numOfMenu!) * 2)
            let separatorLineInterval = self.w / (CGFloat(numOfMenu!))
            let bgLayerInterval = self.w / (CGFloat(numOfMenu!))
            
            var tempTitles = [CATextLayer]()
            var tempIndicators = [CAShapeLayer]()
            var tempBgLayers = [CALayer]()
            
            for index in 0..<numOfMenu! {
                //bglayer,
                let bgLayerPosition = CGPoint(x: CGFloat((index+Int(0.5)))*bgLayerInterval+textLayerInterval, y: self.h/2)//此处由于不知名原因加了textLayerInterval
                let bgLayer = createBgLayerWithColor(.white, position: bgLayerPosition)
                self.layer.addSublayer(bgLayer)
                tempBgLayers.append(bgLayer)
                //title
                let titlePosition = CGPoint(x: (CGFloat(index) * 2 + 1) * textLayerInterval, y: self.h/2)
                var titleString = String()
                if !isClickHaveItemValid! && dataSourceFlags.numberOfItemsInRow && dataSource.menu(self, numberOfItemsInRow: 0, column: index) > 0 {
                    if !isClickHaveOtherItemValid! && dataSourceFlags.numberOfOtherItemsInItem && dataSource.menu(self, numberOfOtherItemsInItem: 0, row: 0, column: index) > 0 {
                        titleString = dataSource.menu(self, titleForOtherItemsInItemAtIndexPath: DropIndexPath(column: index, row: 0, item: 0, otherItem: 0))
                    }else{
                        titleString = dataSource.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: index, row: 0, item: 0, otherItem: 0))
                    }
                }else {
                    titleString = dataSource.menu(self, titleForRowAtIndexPath: DropIndexPath(column: index, row: 0, item: -1, otherItem: -1))
                }
                let title = createTextLayerWithNSString(titleString, color: textColor!, point: titlePosition)
                self.layer.addSublayer(title)
                tempTitles.append(title)
                //indicator
//                let indicator = createIndicatorWithColor(indicatorColor!, point: CGPoint(x: (CGFloat(index) + 1) * separatorLineInterval - 10, y: self.h/2))
                let indicator = createIndicatorWithColor(indicatorColor!, point: CGPoint(x: title.position.x + title.bounds.size.width, y: self.h/2))
                self.layer.addSublayer(indicator)
                tempIndicators.append(indicator)
                //separator
                if index != numOfMenu! - 1 {
                    let separatorPosition = CGPoint(x: CGFloat(ceilf(Float((CGFloat(index) + 1) * separatorLineInterval-1))), y: self.h/2)
                    let separator = createSeparatorLineWithColor(separatorColor!, point: separatorPosition)
                    self.layer.addSublayer(separator)
                }
            }
            titles = tempTitles
            indicators = tempIndicators
            bgLayers = tempBgLayers
        }
    }
    var delegate: DropDownMenuDelegate?
    
    public init(origin: CGPoint,andHeight height:CGFloat) {
        
        super.init(frame: CGRect(x: origin.x, y: origin.y, w: SCREEN_WIDTH, h: height))

        _origin = origin
        currentSelectedMenudIndex = -1
        show = false
        fontSize = Int(14.fw())
        menuFontSize = 14
        cellStyle = .value1
        separatorColor = kSeparatorColor
        textColor = kTextColor
        textSelectedColor = kTextSelectColor
        indicatorColor = .gray
        detailTextFont = UIFont.systemFont(ofSize: 11)
        detailTextColor = kDetailTextColor
        tableViewHeight = kTableViewHeight
        isClickHaveItemValid = true
        isClickHaveOtherItemValid = true
        remainMenuTitle = true
        isShowTag = false
        
        tagBottomView = UIView(frame: CGRect(x: origin.x, y: self.y + self.h, w: self.w, h: 0))
        tagBottomView?.backgroundColor = kCellBgColor
        tagView = TagListView(frame: CGRect(x: origin.x, y: 0, w: self.w, h: 0))
        tagView?.delegate = self
        tagView?.textFont = UIFont.systemFont(ofSize: CGFloat(fontSize!))
        tagView?.alignment = .center
        tagView?.marginX = 10.fh()
        tagView?.marginY = 10.fh()
        tagView?.paddingX = 15.fh()
        tagView?.paddingY = 10.fh()
        tagView?.cornerRadius = (15.fh()+CGFloat(fontSize!))/2
        tagView?.layer.backgroundColor = kCellBgColor.cgColor
        tagView?.tagBackgroundColor = LineColor2
        tagView?.borderWidth = 1
        tagView?.borderColor = LineColor
        tagView?.textColor = TextColor1
        tagBottomView?.addSubview(tagView!)
        
        leftTableView = UITableView(frame: CGRect(x: origin.x, y: self.y + self.h, w: self.w/3, h: 0), style: .plain)
        leftTableView?.rowHeight = CGFloat(kTableViewCellHeight)
        leftTableView?.delegate = self
        leftTableView?.dataSource = self
        leftTableView?.separatorColor = kSeparatorColor
        leftTableView?.separatorInset = UIEdgeInsets.zero
        leftTableView?.tableFooterView = UIView()
        
        middleTableView = UITableView(frame: CGRect(x: origin.x + self.w/3, y: self.y + self.h, w: self.w/3, h: 0), style: .plain)
        middleTableView?.rowHeight = CGFloat(kTableViewCellHeight)
        middleTableView?.delegate = self
        middleTableView?.dataSource = self
        middleTableView?.separatorColor = kSeparatorColor
        middleTableView?.separatorInset = UIEdgeInsets.zero
        
        rightTableView = UITableView(frame: CGRect(x: origin.x + self.w/3, y: self.y + self.h, w: self.w/3, h: 0), style: .plain)
        rightTableView?.rowHeight = CGFloat(kTableViewCellHeight)
        rightTableView?.delegate = self
        rightTableView?.dataSource = self
        rightTableView?.separatorColor = kSeparatorColor
        rightTableView?.separatorInset = UIEdgeInsets.zero
//        rightTableView?.tableFooterView = UIView()
        
        resetButton = UIButton(type: .custom)
        resetButton?.frame = CGRect(x: origin.x, y: self.y + self.h, w: w/2, h: kButtonHeight)
        resetButton?.setTitle("重置", for: .normal)
        resetButton?.setTitleColor(.black, for: .normal)
        resetButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        resetButton?.addTarget(self, action: #selector(resetBtnClick), for: .touchUpInside)
        resetButton?.backgroundColor = .white
        
        determineButton = UIButton(type: .custom)
        determineButton?.frame = CGRect(x: origin.x + w/2, y: self.y + self.h, w: w/2, h: kButtonHeight)
        determineButton?.setTitle("确定", for: .normal)
        determineButton?.setTitleColor(kTextSelectColor, for: .normal)
        determineButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        determineButton?.addTarget(self, action: #selector(determineBtnClick), for: .touchUpInside)
        determineButton?.backgroundColor = .white
        
        buttomImageView = UIImageView(frame: CGRect(x: origin.x, y: self.y + self.h, w: w, h: CGFloat(kButtomImageViewHeight)))
        buttomImageView?.image = #imageLiteral(resourceName: "icon_chose_bottom")
        
        backgroundColor = .white
        self.addTapGesture { (tap) in
            self.menuTapped(paramSender: tap)
        }
        
        backGroundView = UIView(frame: CGRect(x: origin.x, y: origin.y, w: SCREEN_WIDTH, h: SCREEN_HEIGHT))
        backGroundView?.backgroundColor = .white
        backGroundView?.isOpaque = false
        backGroundView?.addTapGesture(action: { (tap) in
            self.backgroundTapped()
        })
        
        bottomShadow = UIView(frame: CGRect(x: 0, y: self.h-0.5, w: SCREEN_WIDTH, h: 0.5))
        bottomShadow?.backgroundColor = kSeparatorColor
        bottomShadow?.isHidden = true
        self.addSubview(bottomShadow!)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension DropDownMenu: TagListViewDelegate {
    public func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print(title)
        var deleteIndex = -3
        sender.tagViews.forEachEnumerated { (index, tag) in
            if tag.titleLabel?.text == title {
                deleteIndex = index
                self.tagsIndexPath.remove(at: index)
                return
            }
        }
        sender.removeTag(title)
        changeTagViewFrame(currentTagIndex: currentIndexPath!,deleteIndex: deleteIndex)
        if sender.tagViews.count == 0 {
            setDefaultMenuTitle(currentIndexPath!, t: "行业")
        }
    }
    func resetBtnClick() {
        tagView?.removeAllTags()
        tagsIndexPath.removeAll()
        changeTagViewFrame(currentTagIndex: currentIndexPath!,deleteIndex: -2)
        setDefaultMenuTitle(currentIndexPath!, t: "行业")
    }
    func determineBtnClick() {
        backgroundTapped()
        if let finish = determineBlock {
            finish(tagsIndexPath)
        }
    }
}
//MARK: method
extension DropDownMenu {
    func titleForRowAtIndexPath(_ indexPath: DropIndexPath) -> String {
        return (dataSource?.menu(self, titleForRowAtIndexPath: indexPath))!
    }
    func reloadData() {
        animateBackGroundView(backGroundView!, show: false) {
            animateTableView(UITableView(), show: false, complete: {
                show = false
                let VC = dataSource
                dataSource = nil
                dataSource = VC
            })
        }
    }
    func setDefaultMenuTitle(_ indexPath: DropIndexPath, t: String) {
        let title = titles[indexPath.column]
        title.string = t
        let size = calculateTitleSizeWithString(title.string as! String)
        let sizeWidth = size.width < (self.w / CGFloat(numOfMenu!)) - 25 ? size.width : (self.w / CGFloat(numOfMenu!)) - 25
        title.bounds = CGRect(x: 0, y: 0, w: sizeWidth, h: size.height)
    }
    func selectDefalutIndexPath() {
        selectIndexPath(DropIndexPath(column: 0, row: 0, item: -1, otherItem: -1))
    }
    func selectIndexPath(_ indexPath: DropIndexPath, trigger: Bool) {
        if dataSource == nil || delegate == nil {
            return
        }
        if (dataSource?.numberOfColumnsInMenu(self))! <= indexPath.column || (dataSource?.menu(self, numberOfRowsInColumn: indexPath.column))! <= indexPath.row {
            return
        }
        let title = titles[indexPath.column]
        if indexPath.item < 0 {
            if !isClickHaveItemValid! && (dataSource?.menu(self, numberOfItemsInRow: indexPath.row, column: indexPath.column))! > 0 {
                title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: indexPath.column, row: remainMenuTitle! ? indexPath.row : 0, item: 0, otherItem: -1))
                if trigger {
                    delegate?.menu(self, didSelectRowAtIndexPath: DropIndexPath(column: indexPath.column, row: indexPath.row, item: 0, otherItem: -1),tableIndex: 0)
                }
            }else {
                title.string = dataSource?.menu(self, titleForRowAtIndexPath: DropIndexPath(column: indexPath.column, row: remainMenuTitle! ? indexPath.row : 0, item: -1, otherItem: -1))
                if trigger {
                    delegate?.menu(self, didSelectRowAtIndexPath: indexPath,tableIndex: 0)
                }
            }
            if currentSelectRowArray.count > indexPath.column {
                currentSelectRowArray[indexPath.column] = indexPath.row
            }
            let size = calculateTitleSizeWithString(title.string as! String)
            let sizeWidth = size.width < (self.w / CGFloat(numOfMenu!)) - 25 ? size.width : (self.w / CGFloat(numOfMenu!)) - 25
            title.bounds = CGRect(x: 0, y: 0, w: sizeWidth, h: size.height)
            currentIndexPath = indexPath
        }else if (dataSource?.menu(self, numberOfItemsInRow: indexPath.row, column: indexPath.column))! > 0 {
            if indexPath.otherItem < 0 {
                title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: indexPath)
            }else if (dataSource?.menu(self, numberOfOtherItemsInItem: indexPath.item, row: indexPath.row, column: indexPath.column))! > 0 {
                title.string = dataSource?.menu(self, titleForOtherItemsInItemAtIndexPath: indexPath)
            }
            if trigger {
                delegate?.menu(self, didSelectRowAtIndexPath: indexPath,tableIndex: 0)
            }
            if currentSelectRowArray.count > indexPath.column {
                currentSelectRowArray[indexPath.column] = indexPath.row
            }
            let size = calculateTitleSizeWithString(title.string as! String)
            let sizeWidth = size.width < (self.w / CGFloat(numOfMenu!)) - 25 ? size.width : (self.w / CGFloat(numOfMenu!)) - 25
            title.bounds = CGRect(x: 0, y: 0, w: sizeWidth, h: size.height)
            currentIndexPath = indexPath
        }
    }
    func selectIndexPath(_ indexPath: DropIndexPath) {
        selectIndexPath(indexPath, trigger: true)
    }
}
// MARK: gesture handle
extension DropDownMenu {
    func menuTapped(paramSender: UITapGestureRecognizer) {
        guard self.dataSource != nil else {
            return
        }
        if let finish = menuTappedBlock {
            finish()
        }
        let touchPoint = paramSender.location(in: self)
        let tapIndex = touchPoint.x / (self.w / CGFloat(numOfMenu!))
        for index in 0..<numOfMenu! {
            if index != Int(tapIndex) {
                animateIdicator(indicators[index], forward: false, complecte: {
                    animateTitle(titles[index], show: false, complete: {
                        let pointX = titles[index].position.x + titles[index].bounds.size.width < (CGFloat(index) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10 ? titles[index].position.x + titles[index].bounds.size.width : (CGFloat(index) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10
                        indicators[index].position = CGPoint(x: pointX, y: self.h/2)
                    })
                })
            }
        }
        if Int(tapIndex) == currentSelectedMenudIndex && show! {
            animateIdicator(indicators[currentSelectedMenudIndex!], background: backGroundView!, tableView: leftTableView!, title: titles[currentSelectedMenudIndex!], forward: false, complete: {
                show = false
            })
        }else {
            currentSelectedMenudIndex = Int(tapIndex)
            leftTableView?.reloadData()
            if dataSourceFlags.numberOfItemsInRow {
                middleTableView?.reloadData()
                if dataSourceFlags.numberOfOtherItemsInItem {
                    rightTableView?.reloadData()
                }
            }
            animateIdicator(indicators[Int(tapIndex)], background: backGroundView!, tableView: leftTableView!, title: titles[Int(tapIndex)], forward: true, complete: {
                show = true
            })
        }
    }
    func backgroundTapped() {
        animateIdicator(indicators[currentSelectedMenudIndex!], background: backGroundView!, tableView: leftTableView!, title: titles[currentSelectedMenudIndex!], forward: false) { 
            show = false
        }
    }
    public func hideMenu()  {
        if show! {
            backgroundTapped()
        }
    }
}
// MARK: tableview
extension DropDownMenu: UITableViewDataSource,UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.dataSource != nil else {
            return 0
        }
        if tableView == leftTableView {
            if dataSourceFlags.numberOfRowsInColumn {
                return (dataSource?.menu(self, numberOfRowsInColumn: currentSelectedMenudIndex!))!
            }
        }else if tableView == middleTableView {
            if dataSourceFlags.numberOfItemsInRow {
                let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!]
                return (dataSource?.menu(self, numberOfItemsInRow: currentSelectedMenudRow as! Int, column: currentSelectedMenudIndex!))!
            }
        }else {
            if dataSourceFlags.numberOfOtherItemsInItem {
                let row = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
                let currentSelectedMenudItem = currentSelectItemArray[currentSelectedMenudIndex!] as! Int
                return (dataSource?.menu(self, numberOfOtherItemsInItem: currentSelectedMenudItem, row: row, column: currentSelectedMenudIndex!))!
            }
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DropDownMenuCell")
        if cell == nil {
            cell = UITableViewCell(style: cellStyle, reuseIdentifier: "DropDownMenuCell")
            let bg = DropBackgroundCellView()
            bg.backgroundColor = .white
            cell?.selectedBackgroundView = bg
            cell?.textLabel?.highlightedTextColor = textSelectedColor
            cell?.textLabel?.textColor = textColor
            cell?.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize!))
            cell?.textLabel?.numberOfLines = 2
            if dataSourceFlags.detailTextForRowAtIndexPath || dataSourceFlags.detailTextForItemsInRowAtIndexPath {
                cell?.detailTextLabel?.textColor = detailTextColor
                cell?.detailTextLabel?.font = detailTextFont
            }
        }
        if tableView == leftTableView {
            if dataSourceFlags.titleForRowAtIndexPath {
                cell?.textLabel?.text = dataSource?.menu(self, titleForRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: indexPath.row, item: -1, otherItem: -1))
                if dataSourceFlags.imageNameForRowAtIndexPath {
                    let imageName = dataSource?.menu(self, imageNameForRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: indexPath.row, item: -1, otherItem: -1))
                    if imageName != nil && (imageName?.characters.count)! > 0 {
                        cell?.imageView?.image = UIImage(named: imageName!)
                    }else {
                        cell?.imageView?.image = nil
                    }
                }else {
                    cell?.imageView?.image = nil
                }
                if dataSourceFlags.detailTextForRowAtIndexPath {
                    let detailText = dataSource?.menu(self, detailTextForRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: indexPath.row, item: -1, otherItem: -1))
                    cell?.detailTextLabel?.text = detailText
                }else {
                    cell?.detailTextLabel?.text = nil
                }
            }else {
                
            }
            let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
            if currentSelectedMenudRow == indexPath.row {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            if dataSourceFlags.numberOfItemsInRow && (dataSource?.menu(self, numberOfItemsInRow: indexPath.row, column: currentSelectedMenudIndex!))! > 0 {
                cell?.accessoryView = UIImageView(image: UIImage(named: "icon_chose_arrow_nor"), highlightedImage: UIImage(named: "icon_chose_arrow_sel"))
            }else {
                cell?.accessoryView = nil
            }
            cell?.backgroundColor = kCellBgColor
        }else if tableView == middleTableView {
            if dataSourceFlags.titleForItemsInRowAtIndexPath {
                let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
                cell?.textLabel?.text = dataSource?.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: indexPath.row, otherItem: -1))
                if dataSourceFlags.imageNameForItemsInRowAtIndexPath {
                    let imageName = dataSource?.menu(self, imageNameForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: indexPath.row, otherItem: -1))
                    if imageName != nil && (imageName?.characters.count)! > 0 {
                        cell?.imageView?.image = UIImage(named: imageName!)
                    }else {
                        cell?.imageView?.image = nil
                    }
                }else {
                    cell?.imageView?.image = nil
                }
                if dataSourceFlags.detailTextForItemsInRowAtIndexPath {
                    let detailText = dataSource?.menu(self, detailTextForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: indexPath.row, otherItem: -1))
                    cell?.detailTextLabel?.text = detailText
                }else {
                    cell?.detailTextLabel?.text = nil
                }
            }else {
                
            }
            let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
            let currentSelectedMenudItem = currentSelectItemArray[currentSelectedMenudIndex!] as! Int
            if currentSelectedMenudItem == indexPath.row {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            if dataSourceFlags.numberOfOtherItemsInItem && (dataSource?.menu(self, numberOfOtherItemsInItem: indexPath.row, row:currentSelectedMenudRow, column: currentSelectedMenudIndex!))! > 0 {
                cell?.accessoryView = UIImageView(image: UIImage(named: "icon_chose_arrow_nor"), highlightedImage: UIImage(named: "icon_chose_arrow_sel"))
            }else {
                cell?.accessoryView = nil
            }
            cell?.backgroundColor = kCellBgColor
            
        }else {
            if dataSourceFlags.titleForOtherItemsInItemAtIndexPath {
                let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
                let currentSelectedMenudItem = currentSelectItemArray[currentSelectedMenudIndex!] as! Int
                cell?.textLabel?.text = dataSource?.menu(self, titleForOtherItemsInItemAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: currentSelectedMenudItem, otherItem: indexPath.row))
                if dataSourceFlags.imageNameForOtherItemsInItemAtIndexPath {
                    let imageName = dataSource?.menu(self, imageNameForOtherItemsInItemAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: currentSelectedMenudItem, otherItem: indexPath.row))
                    if imageName != nil && (imageName?.characters.count)! > 0 {
                        cell?.imageView?.image = UIImage(named: imageName!)
                    }else {
                        cell?.imageView?.image = nil
                    }
                }else {
                    cell?.imageView?.image = nil
                }
                if dataSourceFlags.detailTextForOtherItemsInItemAtIndexPath {
                    let detailText = dataSource?.menu(self, detailTextForOtherItemsInItemAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: currentSelectedMenudItem, otherItem: indexPath.row))
                    cell?.detailTextLabel?.text = detailText
                }else {
                    cell?.detailTextLabel?.text = nil
                }
            }else {
                
            }
            if cell?.textLabel?.text == titles[currentSelectedMenudIndex!].string as? String {
                let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
                let currentSelectedMenudItem = currentSelectItemArray[currentSelectedMenudIndex!] as! Int
                leftTableView?.selectRow(at: NSIndexPath(row: currentSelectedMenudRow, section: 0) as IndexPath, animated: true, scrollPosition: .none)
                middleTableView?.selectRow(at: NSIndexPath(row: currentSelectedMenudItem, section: 0) as IndexPath, animated: true, scrollPosition: .none)
                rightTableView?.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            cell?.backgroundColor = .white
            cell?.accessoryView = nil
        }
        
        return cell!
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == leftTableView {
            currentIndexPath = DropIndexPath(column: currentSelectedMenudIndex!, row: indexPath.row, item: -1, otherItem: -1)
            if delegate != nil {
                delegate?.menu(self, didSelectRowAtIndexPath: currentIndexPath!,tableIndex: 1)
            }else {
                
            }
            confiMenuWithSelectRow(indexPath.row)
        }else if tableView == middleTableView {
            let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!]
            currentIndexPath = DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow as! Int, item: indexPath.row, otherItem: -1)
            if delegate != nil {
                delegate?.menu(self, didSelectRowAtIndexPath: currentIndexPath!,tableIndex: 2)
            }else {
                
            }
            confiMenuWithSelectItems(indexPath.row)
        }else {
            let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
            let currentSelectedMenudItem = currentSelectItemArray[currentSelectedMenudIndex!] as! Int
            currentIndexPath = DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: currentSelectedMenudItem, otherItem: indexPath.row)
            if delegate != nil {
                delegate?.menu(self, didSelectRowAtIndexPath: currentIndexPath!,tableIndex: 3)
            }else {
                
            }
            confiMenuWithSelectOtherItem(indexPath.row)
        }
    }
    func confiMenuWithSelectRow(_ row: Int) {
        currentSelectRowArray[currentSelectedMenudIndex!] = row
        let title = titles[currentSelectedMenudIndex!]
        if dataSourceFlags.numberOfItemsInRow && (dataSource?.menu(self, numberOfItemsInRow: row, column: currentSelectedMenudIndex!))! > 0 {
            let currentSelectedMenudItem = currentSelectItemArray[currentSelectedMenudIndex!] as! Int
            if (dataSource?.menu(self, numberOfItemsInRow: row, column: currentSelectedMenudIndex!))! <= currentSelectedMenudItem {
                currentSelectItemArray[currentSelectedMenudIndex!] = 0
            }
            //有双列表，有item数据
            if isClickHaveItemValid! {
                title.string = dataSource?.menu(self, titleForRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: row, item: -1, otherItem: -1))
                animateTitle(title, show: true, complete: {
                    let pointX = title.position.x + title.bounds.size.width < (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10 ? title.position.x + title.bounds.size.width : (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10
                    self.indicators[currentSelectedMenudIndex!].position = CGPoint(x: pointX, y: self.h/2)
                    middleTableView?.reloadData()
                })
            }else {
                let currentSelectedMenudItem = currentSelectItemArray[currentSelectedMenudIndex!] as! Int
                title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: row, item: currentSelectedMenudItem, otherItem: -1))
                animateTitle(title, show: true, complete: {
                    let pointX = title.position.x + title.bounds.size.width < (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10 ? title.position.x + title.bounds.size.width : (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10
                    self.indicators[currentSelectedMenudIndex!].position = CGPoint(x: pointX, y: self.h/2)
                    middleTableView?.reloadData()
                })
                rightTableView?.reloadData()
            }
        }else {
            title.string = dataSource?.menu(self, titleForRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: remainMenuTitle! ? row : 0, item: -1, otherItem: -1))
            animateIdicator(indicators[currentSelectedMenudIndex!], background: backGroundView!, tableView: leftTableView!, title: titles[currentSelectedMenudIndex!], forward: false, complete: { 
                show = false
            })
        }
    }
    func confiMenuWithSelectItems(_ item: Int) {
        currentSelectItemArray[currentSelectedMenudIndex!] = item
        let title = titles[currentSelectedMenudIndex!]
        let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
        if dataSourceFlags.numberOfOtherItemsInItem && (dataSource?.menu(self, numberOfOtherItemsInItem: item, row: currentSelectedMenudRow, column: currentSelectedMenudIndex!))! > 0 {
            //有三列表，有otherItem数据
            if isClickHaveOtherItemValid! {
                title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: item, otherItem: -1))
                animateTitle(title, show: true, complete: {
                    let pointX = title.position.x + title.bounds.size.width < (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10 ? title.position.x + title.bounds.size.width : (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10
                    self.indicators[currentSelectedMenudIndex!].position = CGPoint(x: pointX, y: self.h/2)
                    rightTableView?.reloadData()
                })
            }else {
                title.string = dataSource?.menu(self, titleForOtherItemsInItemAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: item, otherItem: 0))
                animateTitle(title, show: true, complete: {
                    let pointX = title.position.x + title.bounds.size.width < (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10 ? title.position.x + title.bounds.size.width : (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10
                    self.indicators[currentSelectedMenudIndex!].position = CGPoint(x: pointX, y: self.h/2)
                    rightTableView?.reloadData()
                })
            }
        }else {
            title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: remainMenuTitle! ? currentSelectedMenudRow : 0, item: item, otherItem: -1))
            rightTableView?.reloadData()
            if isClickHaveOtherItemValid! {
                animateIdicator(indicators[currentSelectedMenudIndex!], background: backGroundView!, tableView: leftTableView!, title: titles[currentSelectedMenudIndex!], forward: false, complete: {
                    show = false
                })
            }else {
                animateTitle(title, show: true, complete: {
                    let pointX = title.position.x + title.bounds.size.width < (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10 ? title.position.x + title.bounds.size.width : (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10
                    self.indicators[currentSelectedMenudIndex!].position = CGPoint(x: pointX, y: self.h/2)
                    rightTableView?.reloadData()
                })
                guard (tagView?.tagViews.count)! < 5 else {
                    SVProgressHUD.showInfo(withStatus: "标签最多存在5个")
                    return
                }
                let tagStr = dataSource?.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: remainMenuTitle! ? currentSelectedMenudRow : 0, item: item, otherItem: -1))
                var isRepeat = false
                tagView?.tagViews.forEachEnumerated({ (index, tag) in
                    if tagStr == tag.titleLabel?.text {
                        isRepeat = true
                        return
                    }
                })
                guard isRepeat == false else {
                    SVProgressHUD.showError(withStatus: "已存在该标签")
                    return
                }
                tagView?.addTag(tagStr!)
                tagsIndexPath.append(currentIndexPath!)
                changeTagViewFrame(currentTagIndex: currentIndexPath!,deleteIndex: -1)
            }
        }
    }
    
    func confiMenuWithSelectItem(_ item: Int) {
        let title = titles[currentSelectedMenudIndex!]
        let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!]
        title.string = dataSource?.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow as! Int, item: item, otherItem: -1))
        animateIdicator(indicators[currentSelectedMenudIndex!], background: backGroundView!, tableView: leftTableView!, title: titles[currentSelectedMenudIndex!], forward: false) {
            show = false
        }
    }
    func confiMenuWithSelectOtherItem(_ item: Int) {
        let title = titles[currentSelectedMenudIndex!]
        let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
        let currentSelectedMenudItem = currentSelectItemArray[currentSelectedMenudIndex!] as! Int
        title.string = dataSource?.menu(self, titleForOtherItemsInItemAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: currentSelectedMenudItem, otherItem: item))
        animateTitle(title, show: true, complete: {
            let pointX = title.position.x + title.bounds.size.width < (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10 ? title.position.x + title.bounds.size.width : (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10
            self.indicators[currentSelectedMenudIndex!].position = CGPoint(x: pointX, y: self.h/2)
        })
        if isShowTag! {
            guard (tagView?.tagViews.count)! < 5 else {
                SVProgressHUD.showInfo(withStatus: "标签最多存在5个")
                return
            }
            let tagStr = (dataSource?.menu(self, titleForItemsInRowAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: remainMenuTitle! ? currentSelectedMenudRow : 0, item: currentSelectedMenudItem, otherItem: -1)))! + "|" + (dataSource?.menu(self, titleForOtherItemsInItemAtIndexPath: DropIndexPath(column: currentSelectedMenudIndex!, row: currentSelectedMenudRow, item: currentSelectedMenudItem, otherItem: item)))!
            var isRepeat = false
            tagView?.tagViews.forEachEnumerated({ (index, tag) in
                if tagStr == tag.titleLabel?.text {
                    isRepeat = true
                    return
                }
            })
            guard isRepeat == false else {
                SVProgressHUD.showError(withStatus: "已存在该标签")
                return
            }
            tagView?.addTag(tagStr)
            tagsIndexPath.append(currentIndexPath!)
            changeTagViewFrame(currentTagIndex: currentIndexPath!,deleteIndex: -1)
        }else {
            animateIdicator(indicators[currentSelectedMenudIndex!], background: backGroundView!, tableView: leftTableView!, title: titles[currentSelectedMenudIndex!], forward: false) {
                show = false
            }
        }
    }
    func changeTagViewFrame(currentTagIndex: DropIndexPath,deleteIndex: Int) {
        if let finish = tagsChangeBlock {
            finish(currentTagIndex,deleteIndex)
        }
        let leftWidth = CGFloat(tableScale.leftScale()) * self.w
        let midWidth = CGFloat(tableScale.midScale()) * self.w
        let rightWidth = CGFloat(tableScale.rightScale()) * self.w
        var tableViewH: CGFloat = 0
        if let num = leftTableView?.numberOfRows(inSection: 0) {
            tableViewH = num*kTableViewCellHeight > Int(tableViewHeight!)+1 ? CGFloat(tableViewHeight!)-kButtonHeight : CGFloat(num*kTableViewCellHeight+1)-kButtonHeight
        }
        let tagViewHeigt = (self.tagView?.intrinsicContentSize.height)!
        self.tagBottomView?.frame = CGRect(x: self.x, y: self.y + self.h, w: self.w, h: tagViewHeigt > 0 ? tagViewHeigt + tagTopMagin*2 : tagViewHeigt)
        self.tagView?.frame = CGRect(x: self.x, y: tagTopMagin, w: self.w, h: tagViewHeigt)
        let tableY = (self.tagBottomView?.frame.maxY)!
        self.leftTableView?.frame = CGRect(x: self.x, y: tableY, w: leftWidth, h: tableViewH)
        self.middleTableView?.frame = CGRect(x: self.x + leftWidth, y: tableY, w: midWidth, h: tableViewH)
        self.rightTableView?.frame = CGRect(x: self.x + self.w - rightWidth, y: tableY, w: rightWidth, h: tableViewH)
        self.resetButton?.frame = CGRect(x: self.x, y: (self.leftTableView?.frame.maxY)!, w: self.w/2, h: kButtonHeight)
        self.determineButton?.frame = CGRect(x: self.x+self.w/2, y: (self.leftTableView?.frame.maxY)!, w: self.w/2, h: kButtonHeight)
        self.buttomImageView?.frame = CGRect(x: self.x, y: (self.resetButton?.frame.maxY)! - 2, w: self.w, h: CGFloat(kButtomImageViewHeight))
    }
}
// MARK: animation method
extension DropDownMenu {
    
    func animateIdicator(_ indicator: CAShapeLayer, forward: Bool , complecte: ()->())  {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0))
        
        let anim = CAKeyframeAnimation(keyPath: "transform.rotation")
        anim.values = forward ? [0,Double.pi] : [Double.pi,0] as [Any]
        
        if !anim.isRemovedOnCompletion {
            indicator.add(anim, forKey: anim.keyPath)
        }else {
            indicator.add(anim, forKey: anim.keyPath)
            indicator.setValue(anim.values?.last, forKeyPath: anim.keyPath!)
        }
        
        CATransaction.commit()
        
        if forward {
            indicator.fillColor = textSelectedColor?.cgColor
        }else {
            indicator.fillColor = textColor?.cgColor
        }
        
        complecte()
    }
    
    func animateBackGroundView(_ view: UIView, show: Bool, complete: ()->()) {
        if show {
            self.superview?.addSubview(view)
            view.superview?.addSubview(self)
            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            })
        }else {
            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            }, completion: { (finished) in
                view.removeFromSuperview()
            })
        }
        complete()
    }
    
    func animateTableView(_ tableView: UITableView, show: Bool, complete: ()->()) {
        var haveItems = false
        var haveOtherItems = false
        
        if (dataSource != nil) {
            let num = leftTableView?.numberOfRows(inSection: 0)
            for index in 0..<num! {
                if  dataSourceFlags.numberOfItemsInRow && (dataSource?.menu(self, numberOfItemsInRow: index, column: currentSelectedMenudIndex!))! > 0 {
                    haveItems = true
                    break
                }
            }
            let rows = middleTableView?.numberOfRows(inSection: 0)
            let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex!] as! Int
            for index in 0..<rows! {
                if  dataSourceFlags.numberOfOtherItemsInItem && (dataSource?.menu(self, numberOfOtherItemsInItem: index, row: currentSelectedMenudRow, column: currentSelectedMenudIndex!))! > 0 {
                    haveOtherItems = true
                    break
                }
            }
        }
        let leftWidth = CGFloat(tableScale.leftScale()) * self.w
        let midWidth = CGFloat(tableScale.midScale()) * self.w
        let rightWidth = CGFloat(tableScale.rightScale()) * self.w
        if show {
            resetButton?.frame = CGRect(x: x, y: y + h, w: w/2, h: 0)
            determineButton?.frame = CGRect(x: x + w/2, y: y + h, w: w/2, h: 0)
            tagBottomView?.frame = CGRect(x: x, y: y + h, w: w, h: 0)
            tagView?.frame = CGRect(x: x, y: 0, w: w, h: 0)
            if haveItems {
                if  haveOtherItems {
                    if isShowTag! {
                        self.superview?.addSubview(tagBottomView!)
                    }
                    leftTableView?.frame = CGRect(x: x, y: y + h, w: leftWidth, h: 0)
                    middleTableView?.frame = CGRect(x: x + leftWidth, y: y + h, w: midWidth, h: 0)
                    rightTableView?.frame = CGRect(x: x + w-rightWidth, y: y + h, w: rightWidth, h: 0)
                    self.superview?.addSubview(leftTableView!)
                    self.superview?.addSubview(middleTableView!)
                    self.superview?.addSubview(rightTableView!)
                    if isShowTag! {
                        
                        self.superview?.addSubview(resetButton!)
                        self.superview?.addSubview(determineButton!)
                    }
                }else {
                    leftTableView?.frame = CGRect(x: x, y: y + h, w: w/2, h: 0)
                    middleTableView?.frame = CGRect(x: x + w/2, y: y + h, w: w/2, h: 0)
                    rightTableView?.frame = CGRect(x: x + w-rightWidth, y: y + h, w: rightWidth, h: 0)
                    
                    self.superview?.addSubview(leftTableView!)
                    self.superview?.addSubview(middleTableView!)
                }
            }else {
                leftTableView?.frame = CGRect(x: x, y: y + h, w: w, h: 0)
                middleTableView?.frame = CGRect(x: x + leftWidth, y: y + h, w: midWidth, h: 0)
                rightTableView?.frame = CGRect(x: x + w-rightWidth, y: y + h, w: rightWidth, h: 0)
                self.superview?.addSubview(leftTableView!)
    
            }
            
            buttomImageView?.frame = CGRect(x: x, y: y + h, w: w, h: CGFloat(kButtomImageViewHeight))
            self.superview?.addSubview(buttomImageView!)
            
            var tableViewH: CGFloat = 0
            
            var tableY: CGFloat = self.y + self.h
            
            if let num = leftTableView?.numberOfRows(inSection: 0) {
               tableViewH = num*kTableViewCellHeight > Int(tableViewHeight!)+1 ? CGFloat(tableViewHeight!)-kButtonHeight : CGFloat(num*kTableViewCellHeight+1)-kButtonHeight
            }
            UIView.animate(withDuration: 0.2, animations: {
                if haveItems {
                    if haveOtherItems {
                        if self.isShowTag! {
                            let tagViewHeight = (self.tagView?.intrinsicContentSize.height)!
                            self.tagBottomView?.frame = CGRect(x: self.x, y: self.y + self.h, w: self.w, h: tagViewHeight > 0 ? tagViewHeight + tagTopMagin*2 : tagViewHeight)
                            self.tagView?.frame = CGRect(x: self.x, y: tagTopMagin, w: self.w, h: tagViewHeight)
                            tableY = (self.tagBottomView?.frame.maxY)!
                        }
                        self.leftTableView?.frame = CGRect(x: self.x, y: tableY, w: leftWidth, h: tableViewH)
                        self.middleTableView?.frame = CGRect(x: self.x + leftWidth, y: tableY, w: midWidth, h: tableViewH)
                        self.rightTableView?.frame = CGRect(x: self.x + self.w - rightWidth, y: tableY, w: rightWidth, h: tableViewH)
                        if self.isShowTag! {
                            self.resetButton?.frame = CGRect(x: self.x, y: (self.leftTableView?.frame.maxY)!, w: self.w/2, h: kButtonHeight)
                            self.determineButton?.frame = CGRect(x: self.x+self.w/2, y: (self.leftTableView?.frame.maxY)!, w: self.w/2, h: kButtonHeight)
                        }
                    }else {
                        self.leftTableView?.frame = CGRect(x: self.x, y: tableY, w: self.w/2, h: tableViewH)
                        self.middleTableView?.frame = CGRect(x: self.x + self.w/2, y: tableY, w: self.w/2, h: tableViewH)
                    }
                    
                }else {
                    self.leftTableView?.frame = CGRect(x: self.x, y: tableY, w: self.w, h: tableViewH)
                }
                if haveOtherItems && self.isShowTag! {
                    self.buttomImageView?.frame = CGRect(x: self.x, y: (self.resetButton?.frame.maxY)! - 2, w: self.w, h: CGFloat(kButtomImageViewHeight))
                }else {
                    self.buttomImageView?.frame = CGRect(x: self.x, y: (self.leftTableView?.frame.maxY)! - 2, w: self.w, h: CGFloat(kButtomImageViewHeight))
                }
                
            })
        }else {
            UIView.animate(withDuration: 0.2, animations: {
                if haveItems {
                    if haveOtherItems {
                        if self.isShowTag! {
                            self.tagBottomView?.frame = CGRect(x: self.x, y: self.y + self.h, w: self.w, h: 0)
                            self.tagView?.frame = CGRect(x: self.x, y: 0, w: self.w, h: 0)
                            self.resetButton?.frame = CGRect(x: self.x, y: self.y + self.h + 10, w: self.w/2, h: 0)
                            self.determineButton?.frame = CGRect(x: self.x+self.w/2, y: self.y + self.h + 10, w: self.w/2, h: 0)
                        }
                        self.leftTableView?.frame = CGRect(x: self.x, y: self.y + self.h, w: leftWidth, h: 0)
                        self.middleTableView?.frame = CGRect(x: self.x + leftWidth, y: self.y + self.h, w: midWidth, h: 0)
                        self.rightTableView?.frame = CGRect(x: self.x + self.w - rightWidth, y: self.y + self.h, w: rightWidth, h: 0)
                    }else {
                        self.leftTableView?.frame = CGRect(x: self.x, y: self.y + self.h, w: self.w/2, h: 0)
                        self.middleTableView?.frame = CGRect(x: self.x + self.w/2, y: self.y + self.h, w: self.w/2, h: 0)
                    }
                    
                }else {
                    self.leftTableView?.frame = CGRect(x: self.x, y: self.y + self.h, w: self.w, h: 0)
                }
                
                self.buttomImageView?.frame = CGRect(x: self.x, y: (self.leftTableView?.frame.maxY)! - 2, w: self.w, h: CGFloat(kButtomImageViewHeight))
            }, completion: { (finished) in
                if self.isShowTag! {
                    self.tagBottomView?.removeFromSuperview()
                    self.resetButton?.removeFromSuperview()
                    self.determineButton?.removeFromSuperview()
                }
                if ((self.middleTableView?.superview) != nil) {
                    self.middleTableView?.removeFromSuperview()
                }
                if ((self.rightTableView?.superview) != nil) {
                    self.rightTableView?.removeFromSuperview()
                }
                self.leftTableView?.removeFromSuperview()
                self.buttomImageView?.removeFromSuperview()
            })
        }
        complete()
    }
    
    func animateTitle(_ title: CATextLayer, show: Bool, complete: ()->()) {
        let size = calculateTitleSizeWithString(title.string as! String)
        let sizeWidth: CGFloat = (size.width < (frame.size.width / CGFloat(numOfMenu!)) - 25) ? size.width : frame.size.width / CGFloat(numOfMenu!) - 25
        title.bounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: sizeWidth, height: CGFloat(size.height))
        if !show {
            title.foregroundColor = textColor?.cgColor
        }
        else {
            title.foregroundColor = textSelectedColor?.cgColor
        }
        complete()
    }
    
    func animateIdicator(_ indicator:CAShapeLayer, background: UIView, tableView: UITableView, title: CATextLayer, forward: Bool, complete: ()->()) {
        animateIdicator(indicator, forward: forward) { 
            animateTitle(title, show: forward, complete: { 
                animateBackGroundView(background, show: forward, complete: { 
                    animateTableView(tableView, show: forward, complete: {
                        let pointX = title.position.x + title.bounds.size.width < (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10 ? title.position.x + title.bounds.size.width : (CGFloat(currentSelectedMenudIndex!) + 1) * (self.w / CGFloat(self.numOfMenu!)) - 10
                        indicator.position = CGPoint(x: pointX, y: self.h/2)
                    })
                })
            })
        }
        complete()
    }
}
// MARK: init support
extension DropDownMenu {
    
    func createBgLayerWithColor(_ color: UIColor, position: CGPoint) -> CALayer {
        let layer = CALayer()
        layer.position = position
        layer.bounds = CGRect(x: 0, y: 0, w: self.w/CGFloat(numOfMenu!), h: self.h - 1)
        layer.backgroundColor = color.cgColor
        return layer
    }
    
    func createIndicatorWithColor(_ color: UIColor, point: CGPoint) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: 4, y: 5))
        path.close()
        layer.path = path.cgPath
        layer.lineWidth = 0.8
        layer.fillColor = color.cgColor
        let bound = layer.path?.copy(strokingWithWidth: layer.lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: layer.miterLimit)
        layer.bounds = (bound?.boundingBox)!
        layer.position = point
        return layer
    }
    
    func createSeparatorLineWithColor(_ color: UIColor, point: CGPoint) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 160, y: 0))
        path.addLine(to: CGPoint(x: 160, y: 20))
        layer.path = path.cgPath
        layer.lineWidth = 1
        layer.strokeColor = color.cgColor
        let bound = layer.path?.copy(strokingWithWidth: layer.lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: layer.miterLimit)
        layer.bounds = (bound?.boundingBox)!
        layer.position = point
        return layer
    }
    
    func createTextLayerWithNSString(_ string: String, color: UIColor, point: CGPoint) -> CATextLayer {
        let size = calculateTitleSizeWithString(string)
        let layer = CATextLayer()
        let sizeWidth = size.width < (self.w / CGFloat(numOfMenu!)) - 25 ? size.width : (self.w / CGFloat(numOfMenu!)) - 25
        layer.bounds = CGRect(x: 0, y: 0, w: sizeWidth, h: size.height)
        layer.string = string
        layer.fontSize = CGFloat(menuFontSize!)
        layer.alignmentMode = kCAAlignmentCenter
        layer.truncationMode = kCATruncationEnd
        layer.foregroundColor = color.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.position = point
        return layer
    }
    
    func calculateTitleSizeWithString(_ string: String) -> CGSize {
        let dic: [AnyHashable: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(menuFontSize!))]
        let size = string.boundingRect(with: CGSize(width: CGFloat(280), height: CGFloat(0)), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading], attributes: dic as? [String : Any], context: nil).size
        return CGSize(width: CGFloat(ceilf(Float(size.width)) + 2), height: CGFloat(size.height))

    }
}
