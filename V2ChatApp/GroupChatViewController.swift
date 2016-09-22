//
//  GroupChatViewController.swift
//  V2ChatApp
//
//  Created by Kunal Parekh on 12/09/16.
//  Copyright © 2016 V2Solutions. All rights reserved.
//

import UIKit
import XMPPFramework
import xmpp_messenger_ios

class GroupChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GroupMessageDelegate,UITextFieldDelegate {
  
  //MARK: - iVar Declaration
  
  var stringGroupName: String!
  
  @IBOutlet var tableViewGroupChat: UITableView!
  @IBOutlet var textFieldMessage: UITextField!
  @IBOutlet var buttonSendMessage: UIButton!
  
  var arrayGroupMessages = NSMutableArray()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    OneMessage.sharedInstance.delegateGroupMessage = self
    OneRoom.createRoom(stringGroupName) { (sender) in
      
      
      
    }
    
    self.tableViewGroupChat.rowHeight = 50
    
    // Do any additional setup after loading the view.
  }
  
  // MARK: UITableView Datasources
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrayGroupMessages.count
  }
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  // MARK: UITableView Delegates
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    let dict = arrayGroupMessages.objectAtIndex(indexPath.row)
    
    if let name = dict["message"] as? String {
      cell!.textLabel!.text = name
    }
    
    return cell!
  }
  
  // MARK: UITableView Delegates
  
  @IBAction func sendMessageClicked(sender: UIButton) {
    
    OneRoom.sharedInstance.sendMessage(textFieldMessage.text!)
    textFieldMessage.text = ""
  }
  
  // MARK: GroupMessageDelegate Delegates
  
  func messageReceived(message: [String : String])
  {
    self.arrayGroupMessages.addObject(message)
    self.tableViewGroupChat.reloadData()
    
    let indexPath = NSIndexPath(forRow: self.arrayGroupMessages.count-1, inSection: 0)
    self.tableViewGroupChat.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
  }
  
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool{
    
    self.textFieldMessage.resignFirstResponder()
    return true
    
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
  
    self.textFieldMessage.resignFirstResponder()
    return true
    
  }
  
  //MARK: - MemoryManagement Method
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
