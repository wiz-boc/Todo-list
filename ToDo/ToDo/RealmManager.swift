//
//  RealmManager.swift
//  ToDo
//
//  Created by wizz on 5/9/23.
//

import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    private(set) var localRealm: Realm?
    @Published private(set) var tasks: [Task] = []
    
    init(){
        openRealm()
        getTasks()
    }
    
    func openRealm(){
        do{
            let config = Realm.Configuration(schemaVersion: 1) { migration, oldSchemaVersion in
                if oldSchemaVersion > 1 {
                    ///When updating schema
                }
            }
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
        }catch{
            print("Error ipenning Realm: \(error)")
        }
    }
    
    func addTask(taskTitle: String){
        if let localRealm = localRealm {
            do{
                try localRealm.write({
                    let newTask = Task(value: ["title": taskTitle, "completed": false] as [String : Any])
                    localRealm.add(newTask)
                    getTasks()
                    print("Added new task to Realm: \(newTask)")
                })
            }catch{
                print("Error adding task to Realm \(error)")
            }
        }
    }
    
    func getTasks(){
        if let localRealm = localRealm {
            let allTasks = localRealm.objects(Task.self).sorted(byKeyPath: "completed")
            tasks = []
            allTasks.forEach { task in
                if !task.isInvalidated {
                    tasks.append(task)
                }
            }
        }
    }
    
    func updateTask(id: ObjectId, completed: Bool){
        if let localRealm = localRealm {
            do{
                let taskToUpdate = localRealm.objects(Task.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToUpdate.isEmpty else { return }
                try localRealm.write({
                    taskToUpdate[0].completed = completed
                    getTasks()
                    print("Updated task with id \(id)! Completed status: \(completed)")
                })
            }catch{
                print("Error updating task \(id) : \(error)")
            }
        }
    }
    
    func deleteTask(id: ObjectId){
        if let localRealm = localRealm {
            do{
                let taskToDelete = localRealm.objects(Task.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write({
                    localRealm.delete(taskToDelete)
                    getTasks()
                    print("Delete task with id \(id)!")
                })
            }catch{
                print("Error deleting task \(id) : \(error)")
            }
        }
    }
}
