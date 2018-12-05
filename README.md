# DropDownMenu基本用法
由于业务需求，引用了TagListView和SVProgressHUD，代码仅供参考，可根据需求自行调整，目前为swift3.0编写。
<img src="./ezgif-1-769049883c32.gif" />
实例化

```
*let* dropMenu = DropDownMenu(origin: CGPoint(x: 0, y: navBarHeight), andHeight: 50)
dropMenu.isShowTag = *true*
dropMenu.tableScale = TableScale(left: 1.2, mid: 2, right: 0.8)
dropMenu.delegate = *self*
dropMenu.dataSource = *self*
view.addSubview(dropMenu)
```

实现菜单点击事件

```
dropMenu.menuTappedBlock = {
	                
}
dropMenu.finishedBlock = {(indexPath) -> () *in*
      
}
dropMenu.determineBlock = { (indexPaths) -> () *in*
     
}
dropMenu.tagsChangeBlock = { (indexPath,index) -> () *in*

}
```

实现各种代理，用起来让你找回tableview的感觉

```
*extension* SearchViewController: DropDownMenuDelegate,DropDownMenuDataSource {
    *func* numberOfColumnsInMenu(*_* menu: DropDownMenu) -> Int {
        *return* 2
    }
    *func* menu(*_* menu: DropDownMenu, numberOfRowsInColumn column: Int) -> Int {
        
    }
    *func* menu(*_* menu: DropDownMenu, numberOfItemsInRow row: Int, column: Int) -> Int {
        
    }
    *func* menu(*_* menu: DropDownMenu, titleForRowAtIndexPath indexPath: DropIndexPath) -> String {
        
    }
    *func* menu(*_* menu: DropDownMenu, imageNameForRowAtIndexPath indexPath: DropIndexPath) -> String {
        *return* ""
    }
    *func* menu(*_* menu: DropDownMenu, detailTextForRowAtIndexPath indexPath: DropIndexPath) -> String {
        *return* ""
    }
    *func* menu(*_* menu: DropDownMenu, titleForItemsInRowAtIndexPath indexPath: DropIndexPath) -> String {
        
    }
    *func* menu(*_* menu: DropDownMenu, imageNameForItemsInRowAtIndexPath indexPath: DropIndexPath) -> String {
        *return* ""
    }
    *func* menu(*_* menu: DropDownMenu, detailTextForItemsInRowAtIndexPath indexPath: DropIndexPath) -> String {
        *return* ""
    }
    *func* menu(*_* menu: DropDownMenu, numberOfOtherItemsInItem item: Int, row: Int, column: Int) -> Int {
        
    }
    *func* menu(*_* menu: DropDownMenu, titleForOtherItemsInItemAtIndexPath indexPath: DropIndexPath) -> String {
        
    }
    *func* menu(*_* menu: DropDownMenu, imageNameForOtherItemsInItemAtIndexPath indexPath: DropIndexPath) -> String {
        *return* ""
    }
    *func* menu(*_* menu: DropDownMenu, detailTextForOtherItemsInItemAtIndexPath indexPath: DropIndexPath) -> String {
        *return* ""
    }
    *func* menu(*_* menu: DropDownMenu, didSelectRowAtIndexPath indexPath: DropIndexPath,tableIndex: Int) {
        
    }
    *func* menu(*_* menu: DropDownMenu, willSelectRowAtIndexPath indexPath: DropIndexPath) {
        
    }
    *func* menu(*_* menu: DropDownMenu, deSelectRowAtIndexPath indexPath: DropIndexPath) {
        
    }
}
```
