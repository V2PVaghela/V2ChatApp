//
//  GroupsViewController.swift
//  V2ChatApp
//
//  Created by Kunal Parekh on 12/09/16.
//  Copyright © 2016 V2Solutions. All rights reserved.
//

import UIKit
import XMPPFramework
import xmpp_messenger_ios


class GroupsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,OneRoomDelegate {
  
  //MARK: - iVar Declaration
  
  @IBOutlet var tableViewGroupList: UITableView!
  var intGroupSelectionIndex: Int!
  
  var arrayGroupList = NSMutableArray()
  
  
  //MARK: - ViewLoad Method
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    OneRoom.sharedInstance.getRooms()
    OneRoom.sharedInstance.delegate = self
    
    self.tableViewGroupList.rowHeight = 50
    
    // Do any additional setup after loading the view.
  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
   // OneRoom.sharedInstance.delegate = nil
  }
  
  //MARK: - UITableView Datasources
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrayGroupList.count
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  //MARK: - UITableView Delegates
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    let dict = arrayGroupList.objectAtIndex(indexPath.row)
    
    if let name = dict["name"] as? String {
      cell!.textLabel!.text = name
    }
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    intGroupSelectionIndex = indexPath.row
    performSegueWithIdentifier("GROUPCHATDETAIL", sender: nil)
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    
    if let controller = segue?.destinationViewController as? GroupChatViewController {
      
      let dict = arrayGroupList.objectAtIndex(intGroupSelectionIndex)
      
      if let name = dict["jid"] as? String {
        controller.stringGroupName = name
      }
      
    }
  }
  
  //MARK: - OneRoomDelegate Delegate Method
  
  func reciveGroupList(groupList: NSMutableArray){
    for element in groupList {
      arrayGroupList.addObject(element.copy())
      
    }
    self.tableViewGroupList.reloadData()
  }

  //MARK: - MemoryManagement Method
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
