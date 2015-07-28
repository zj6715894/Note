//
//  BaseDao.swift
//  isflyer
//
//  Created by 楼顶 on 15/5/11.
//  Copyright (c) 2015年 楼顶. All rights reserved.
//

import UIKit

protocol IBaseDao
{
    static func createTable(db:FMDatabase) -> Bool
}

class BaseDao: NSObject {
   
   static func DBV(oValue:AnyObject?) -> AnyObject!
    {
        return oValue == nil ? NSNull() : oValue!
    }

}
