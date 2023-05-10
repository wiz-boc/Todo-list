//
//  Task.swift
//  ToDo
//
//  Created by wizz on 5/9/23.
//

import Foundation
import RealmSwift

class Task: Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title = ""
    @Persisted var completed = false
}

