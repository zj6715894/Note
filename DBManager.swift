   //
//  DBManager.swift
//  JuMiHang
//
//  Created by 刘伟 on 3/27/15.
//  Copyright (c) 2015 Louding. All rights reserved.
//

import UIKit

//数据库路径
func databasePath()->String
{
    return DirectoryUtils.documentsDirectory.URLByAppendingPathComponent("isflyer.db").absoluteString!
}

//单利类 操作数据库是线程安全的
class DBManager: NSObject {
    
    var queue: FMDatabaseQueue!
    var writeQueue: NSOperationQueue!
    var writeQueueLock: NSRecursiveLock!
    class func shareInstance()->DBManager{
        struct DBManagerSingleton{
            static var predicate:dispatch_once_t = 0
            static var instance:DBManager? = nil
        }
        dispatch_once(&DBManagerSingleton.predicate,{
            DBManagerSingleton.instance=DBManager()
            DBManagerSingleton.instance!.queue = FMDatabaseQueue(path: databasePath())
            DBManagerSingleton.instance!.writeQueue = NSOperationQueue()
            DBManagerSingleton.instance!.writeQueue.maxConcurrentOperationCount = 1
            DBManagerSingleton.instance!.writeQueueLock = NSRecursiveLock()
            }
        )
        return DBManagerSingleton.instance!
    }
    
    /**
    
    初始化数据库，创建表
    
    */
    func initDB()
    {
        var hasBeenInitialized = NSUserDefaults.standardUserDefaults().boolForKey("DBIsInitialized")
        if(hasBeenInitialized){
//            appLog.debug("数据库已经初始化: \(databasePath())")
            return
        }
        
        writeQueueLock.lock()
        
        var resultArray = [[NSObject : AnyObject]]()
        
        queue.inTransaction { (db, rollback) -> Void in
//            appLog.debug("数据库初始化开始\(databasePath())")
            if !NoteDAO.createTable(db) {
                rollback.initialize(true)
                return
            }
            
            if !CompleteNotesDAO.createTable(db) {
                rollback.initialize(true)
                return
            }
            
            //所有数据库表创建成功，则标记数据库初始化成功
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "DBIsInitialized")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        writeQueueLock.unlock()
        println("数据库初始化结束")
//        appLog.debug("数据库初始化结束")
    }
    
    
    /**
    
    数据库更新操作
    
    :param: sql :插入，更新，删除等操作
    :param: args :后面附带的参数
    
    :returns: 成功或失败
    
    */
    func executeUpdate(sql:String, withArgumentsInArray args:[AnyObject]) -> Bool
    {
        var excuteResult = false
        
        writeQueueLock.lock()
        
        queue.inDatabase { (db) -> Void in

            excuteResult = db.executeUpdate(sql, withArgumentsInArray: args)
            
            if !excuteResult
            {
//            appLog.error("执行SQL:\(sql) 参数:\(args) 报错信息:\(db.lastErrorMessage()) \(db.lastError().description)")
            }
            
        }
        writeQueueLock.unlock()
        
        return excuteResult
    }
    
    
    func executeUpdate(sql:String, withParameterDictionary args:[NSObject : AnyObject]) -> Bool
    {
        var excuteResult = false
        
        writeQueueLock.lock()
        
        queue.inDatabase { (db) -> Void in
            
            excuteResult = db.executeUpdate(sql, withParameterDictionary: args)
            
            if !excuteResult
            {
//                appLog.error("执行SQL:\(sql) 参数:\(args) 报错信息:\(db.lastErrorMessage()) \(db.lastError().description)")
            }
        }
        writeQueueLock.unlock()
        
        return excuteResult
    }
    
    func executeUpdate(inTransaction :(db:FMDatabase) -> Bool) -> Bool
    {
        var executeSuccess = false
        
        writeQueueLock.lock()
        queue.inTransaction { (db, rollback) -> Void in
            
            executeSuccess = inTransaction(db: db)
            
            if !executeSuccess
            {
                rollback.initialize(true)
            }
        }
        writeQueueLock.unlock()
        
        return executeSuccess
    }
    
    
    func executeQuery(sql:String!, args:NSArray!,onQueried:(resultSet:FMResultSet?,error:NSError?)->Void)
    {
        
        writeQueueLock.lock()
        
        var resultArray = [[NSObject : AnyObject]]()
        
        queue.inDatabase { (db) -> Void in
            
            var resultSet = db.executeQuery(sql, withArgumentsInArray: args as [AnyObject])
            if resultSet == nil
            {
//                appLog.error("执行SQL:\(sql) 参数:\(args) 报错信息:\(db.lastErrorMessage())")
                onQueried(resultSet: nil, error:db.lastError())
            }else{
                onQueried(resultSet: resultSet,error:nil)
            }
            resultSet.close()
        }
        writeQueueLock.unlock()
    }
    
    func query(sql:String!,onQueried:(resultSet:FMResultSet?,error:NSError?)->Void){
        writeQueueLock.lock()
        
        var resultArray = [[NSObject : AnyObject]]()
        
        queue.inDatabase { (db) -> Void in
            
            var resultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            if resultSet == nil
            {
                onQueried(resultSet: nil, error:db.lastError())
            }else{
                onQueried(resultSet: resultSet,error:nil)
            }
            resultSet.close()
        }
        writeQueueLock.unlock()

    }


    
}
