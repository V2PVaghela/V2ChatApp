//
//  OneMUC.swift
//  OneChat
//
//  Created by Paul on 03/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public typealias OneRoomCreationCompletionHandler = (sender: XMPPRoom) -> Void

public protocol OneRoomDelegate {
  func reciveGroupList(groupList: NSMutableArray)
}

public class OneRoom: NSObject {
  
  public var delegate: OneRoomDelegate?
  var xmppRoom: XMPPRoom!
  var intDelegationIncrement:Int = 0
  
  var didCreateRoomCompletionBlock: OneRoomCreationCompletionHandler?
  
  // MARK: Singleton
  public class var sharedInstance : OneRoom {
    struct OneRoomSingleton {
      static let instance = OneRoom()
    }
    return OneRoomSingleton.instance
  }
  
  //Handle nickname changes
  public class func createRoom(roomName: String, delegate: AnyObject? = nil, completionHandler completion:OneRoomCreationCompletionHandler) {
    sharedInstance.didCreateRoomCompletionBlock = completion
    
    let roomMemoryStorage = XMPPRoomMemoryStorage()
    let domain = OneChat.sharedInstance.xmppStream!.myJID.domain
    //let roomJID = XMPPJID.jidWithString("\(roomName)@conference.\(domain)")
    let roomJID = XMPPJID.jidWithString("\(roomName)")
    sharedInstance.xmppRoom = XMPPRoom(roomStorage: roomMemoryStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())
    
    sharedInstance.xmppRoom.activate(OneChat.sharedInstance.xmppStream)
    sharedInstance.xmppRoom.addDelegate(delegate, delegateQueue: dispatch_get_main_queue())
    print(OneChat.sharedInstance.xmppStream!.myJID.bare())
    sharedInstance.xmppRoom.joinRoomUsingNickname(OneChat.sharedInstance.xmppStream!.myJID.bare(), history: nil, password: nil)
    sharedInstance.xmppRoom.fetchConfigurationForm()
  }
  
  public func getRooms(){
    
    let server: String = "conference.v2mummac0024.local"
    let servrJID: XMPPJID = XMPPJID.jidWithString(server)
    let iq: XMPPIQ = XMPPIQ.iqWithType("get", to: servrJID)
    iq.addAttributeWithName("id", stringValue: "chatroom_list")
    iq.addAttributeWithName("from", stringValue: OneChat.sharedInstance.xmppStream!.myJID.bare())
    let query = DDXMLElement.elementWithName("query")
    query.addAttributeWithName("xmlns", stringValue: "http://jabber.org/protocol/disco#items")
    iq.addChild(query as! DDXMLElement)
    
    if(intDelegationIncrement == 0){
      OneChat.sharedInstance.xmppStream!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
      intDelegationIncrement = 1
    }
    
    OneChat.sharedInstance.xmppStream!.sendElement(iq)
  }
  
  public func sendMessage(message: String){
    xmppRoom.sendMessageWithBody(message)
  }
}

extension OneRoom: XMPPRoomDelegate {
  /**
   * Invoked with the results of a request to fetch the configuration form.
   * The given config form will look something like:
   *
   * <x xmlns='jabber:x:data' type='form'>
   *   <title>Configuration for MUC Room</title>
   *   <field type='hidden'
   *           var='FORM_TYPE'>
   *     <value>http://jabber.org/protocol/muc#roomconfig</value>
   *   </field>
   *   <field label='Natural-Language Room Name'
   *           type='text-single'
   *            var='muc#roomconfig_roomname'/>
   *   <field label='Enable Public Logging?'
   *           type='boolean'
   *            var='muc#roomconfig_enablelogging'>
   *     <value>0</value>
   *   </field>
   *   ...
   * </x>
   *
   * The form is to be filled out and then submitted via the configureRoomUsingOptions: method.
   *
   * @see fetchConfigurationForm:
   * @see configureRoomUsingOptions:
   **/
  
  
  func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
    
    let queryElements = iq.elementForName("query", xmlns:"http://jabber.org/protocol/disco#items")
    
    if((queryElements) != nil){
      let  itemElements = queryElements.elementsForName("item") as NSArray
      let arrayGroup = NSMutableArray()
      
      for item in itemElements{
        
        let jid = item.attributeForName("jid").stringValue()
        let name = item.attributeForName("name").stringValue()
        
        var dictGroup = [String: String]()
        
        dictGroup.updateValue(jid, forKey: "jid")
        dictGroup.updateValue(name, forKey: "name")
        
        arrayGroup.addObject(dictGroup)
      }
      
      self.delegate?.reciveGroupList(arrayGroup)
      
      return true
    }
    
    return false
  }
  
  public func xmppRoomDidCreate(sender: XMPPRoom!) {
    didCreateRoomCompletionBlock!(sender: sender)
  }
  public func xmppRoomDidLeave(sender: XMPPRoom!) {
    //
  }
  
  public func xmppRoomDidJoin(sender: XMPPRoom!) {
    print("room did join")
  }
  
  public func xmppRoomDidDestroy(sender: XMPPRoom!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
    print("did fetch config \(configForm)")
  }
  
  public func xmppRoom(sender: XMPPRoom!, willSendConfiguration roomConfigForm: XMPPIQ!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didConfigure iqResult: XMPPIQ!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didNotConfigure iqResult: XMPPIQ!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, occupantDidLeave occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, occupantDidUpdate occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
    //
  }
  
  /**
   * Invoked when a message is received.
   * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
   **/
  
  public func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
    
  }
  
  public func xmppRoom(sender: XMPPRoom!, didFetchBanList items: [AnyObject]!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didNotFetchBanList iqError: XMPPIQ!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didFetchMembersList items: [AnyObject]!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didNotFetchMembersList iqError: XMPPIQ!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didFetchModeratorsList items: [AnyObject]!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didNotFetchModeratorsList iqError: XMPPIQ!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didEditPrivileges iqResult: XMPPIQ!) {
    //
  }
  
  public func xmppRoom(sender: XMPPRoom!, didNotEditPrivileges iqError: XMPPIQ!) {
    //
  }
}