//
//  CompleteNotesDAO.swift
//  NotePad
//
//  Created by Fiona on 15/7/28.
//  Copyright (c) 2015年 楼顶. All rights reserved.
//

import UIKit

class OldNote : NSObject {
    var text: String?
}


class CompleteNotesDAO: BaseDao, IBaseDao {
    static func createTable(db: FMDatabase) -> Bool {
        var createTableSql = "CREATE TABLE TB_OldNote ( " +
//            " noteid INTEGER PRIMARY KEY ," +
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
    class func findNotes() -> [OldNote]? {
//        var sql = " SELECT noteid, note FROM TB_OldNote "
        var sql = " SELECT note FROM TB_OldNote "
        var args : [AnyObject] = [ ]
        var notes:[OldNote]?
        DBManager.shareInstance().executeQuery(sql, args: args) { (resultSet, error) -> Void in
            if error == nil
            {
                notes = [OldNote]()
                while resultSet!.next()
                {
                    var note = OldNote()
                    note.text = resultSet!.stringForColumn("note")
                    notes?.append(note)
                }
            }
        }
        return notes
    }
    
    // 增加
    class func save(note:OldNote,db: FMDatabase) -> Bool {
        
//        var sql = "replace INTO TB_OldNote (noteid, note) VALUES (?, ?) "
        var sql = "replace INTO TB_OldNote (note) VALUES (?) "
        
        var args : [AnyObject] = [note.text!]
        
        if !db.executeUpdate(sql, withArgumentsInArray: args)
        {
            //            appLog.error("执行SQL:\(sql) 参数:\(args) 报错信息:\(db.lastErrorMessage()) \(db.lastError().description)")
            return false
        }
        return true
    }
    
    // 删除
    class func deleteById(note: String) -> Bool {
        var sql = "DELETE from TB_OldNote WHERE note = ? "
        var args : [AnyObject] = [ note ]
        return DBManager.shareInstance().executeUpdate(sql, withArgumentsInArray: args)
    }

}
