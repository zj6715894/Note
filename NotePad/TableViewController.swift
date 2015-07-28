//
//  TableViewController.swift
//  NotePad
//
//  Created by Fiona on 15/7/24.
//  Copyright (c) 2015年 楼顶. All rights reserved.
//

import UIKit



class TableViewController: UITableViewController, ViewControllerProtocol {

    var notesDict = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView ()
        loadDataByDAO()
    }

    func initView () {
        self.title = "未完成"
        var footView = UIView()
        footView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = footView
    }
    
    func loadDataByDAO () {
        notesDict = NoteDAO.findNotes()!
        UIApplication.sharedApplication().applicationIconBadgeNumber = notesDict.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        UIApplication.sharedApplication().applicationIconBadgeNumber = notesDict.count
        return notesDict.count
    }

    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "删除"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        var note = notesDict[indexPath.row]
        cell.textLabel!.text = note.text

        return cell
    }
    
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            NoteDAO.deleteById(notesDict[indexPath.row].text!)
            DBManager.shareInstance().executeUpdate({ (db) -> Bool in
                var old = OldNote()
                old.text = self.notesDict[indexPath.row].text!
                return CompleteNotesDAO.save(old, db: db)
            })
            notesDict.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var vc = storyBoard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        vc.delegate = self
        var text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
        vc.initWithText(text, indexPath: indexPath, isAppend: false)
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func newBtnClicked(sender: UIBarButtonItem) {
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var vc = storyBoard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        vc.delegate = self

        
        var indexPath = NSIndexPath(forRow: notesDict.count, inSection: 1)
        vc.initWithText(nil, indexPath: indexPath, isAppend: true)
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func setTextLabel (text: String, indexPath: NSIndexPath, isAppend: Bool) {
        println(text)
        if isAppend {
            if !text.isEmpty {
                var note = Note()
                if notesDict.count == 0 {
                    note.id = 0
                }
                else {
                    note.id = notesDict[indexPath.row-1].id! + 1
                }
                
                note.text = text
                notesDict.append(note)
                tableView.reloadData()
                DBManager.shareInstance().executeUpdate { (db) -> Bool in
                    NoteDAO.save(note, db: db)
                }
            }
        }
        else {
            tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text = text
            NoteDAO.update(id: notesDict[indexPath.row].id!, note: text)
            println(notesDict[indexPath.row].id!)
        }
    }
    

}
