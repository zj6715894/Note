//
//  NoteDAO.swift
//  NotePad
//
//  Created by Fiona on 15/7/24.
//  Copyright (c) 2015年 楼顶. All rights reserved.
//

import UIKit

class Note: NSObject {
    var id: Int?
    var text: String?
}

class NoteDAO: BaseDao, IBaseDao {
    static func createTable(db: FMDatabase) -> Bool {
        
        var createTableSql = "CREATE TABLE TB_Note ( " +
            " noteid INTEGER PRIMARY KEY ," +
            " note VARCHAR(200)  " +
        " ) "
        
        if !db.executeUpdate(createTableSql, withArgumentsInArray: []) {
//            appLog.error("创建用户表失败 failure: \(db.lastError())")
            return false
        }else{
//            appLog.debug("创建用户表成功")
            return true
        }
    }
    
    // 查找
    class func findNotes() -> [Note]? {
        var sql = " SELECT noteid, note FROM TB_Note "
        var args : [AnyObject] = [ ]
        var notes:[Note]?
        DBManager.shareInstance().executeQuery(sql, args: args) { (resultSet, error) -> Void in
            if error == nil
            {
                notes = [Note]()
                while resultSet!.next()
                {
                    var note = Note()
                    note.id = Int(resultSet!.intForColumn("noteid"))
                    note.text = resultSet!.stringForColumn("note")
                    notes?.append(note)
                }
            }
        }
        return notes
    }
    
    // 增加
    class func save(note:Note,db: FMDatabase) -> Bool {
        
        var sql = "replace INTO TB_Note (noteid, note) VALUES (?, ?) "
        
        var args : [AnyObject] = [note.id!, note.text!]
        
        if !db.executeUpdate(sql, withArgumentsInArray: args)
        {
//            appLog.error("执行SQL:\(sql) 参数:\(args) 报错信息:\(db.lastErrorMessage()) \(db.lastError().description)")
            return false
        }
        return true
    }
    
    // 删除
    class func deleteById(note: String) -> Bool {
        var sql = "DELETE from TB_Note WHERE note = ? "
        var args : [AnyObject] = [ note ]
        return DBManager.shareInstance().executeUpdate(sql, withArgumentsInArray: args)
    }
    
    // 更新
    class func update(#id : Int , note : String)->Bool
    {
//        appLog.debug("更新数据库 infotype : \(infotype) --info \(info) " )
        return DBManager.shareInstance().executeUpdate("UPDATE TB_Note SET note = ? WHERE noteid = ?  ", withArgumentsInArray:[note, id])

    }
    
    
}
