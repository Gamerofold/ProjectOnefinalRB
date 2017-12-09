//
//  ToDoItem.swift
//  ProjectOne
//
//  Created by Robert Whitehead on 10/27/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import Foundation
import Firebase

struct ToDoItem {
    
    let key: String
    let title: String
    let status: String
    let summary: String
    let imagePtr: Int
    let addedByUser: String
    let ref: DatabaseReference?
    var completed: Bool
    
    init(title: String, status: String, summary: String, imagePtr: Int, addedByUser: String, completed: Bool, key: String = "") {
        self.key = key
        self.title = title
        self.status = status
        self.summary = summary
        self.imagePtr = imagePtr
        self.addedByUser = addedByUser
        self.completed = completed
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        status = snapshotValue["status"] as! String
        summary = snapshotValue["summary"] as! String
        imagePtr = snapshotValue["imagePtr"] as! Int
        addedByUser = snapshotValue["addedByUser"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "title": title,
            "status": status,
            "summary": summary,
            "imagePtr": imagePtr,
            "addedByUser": addedByUser,
            "completed": completed
        ]
    }
    
}
