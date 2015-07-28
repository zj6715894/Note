//
//  ViewController.swift
//  NotePad
//
//  Created by Fiona on 15/7/24.
//  Copyright (c) 2015年 楼顶. All rights reserved.
//

import UIKit

protocol ViewControllerProtocol {
    func setTextLabel (text: String, indexPath: NSIndexPath, isAppend: Bool)
}

class ViewController: UIViewController, UITextViewDelegate {
    private var text: String!
    var indexPath: NSIndexPath!
    var isAppend: Bool!
    var editable = false
    var delegate: ViewControllerProtocol?
    
    @IBOutlet weak var textView: UITextView!
    
    func initWithText(text: String!, indexPath: NSIndexPath, isAppend: Bool) {
        self.text = text
        self.indexPath = indexPath
        self.isAppend = isAppend
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView () {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Done, target: self, action: "editTextView")
        if text == nil {
            textView.becomeFirstResponder()
            editable = true
        }
        else {
            textView.text = text
            self.navigationItem.rightBarButtonItem!.title = "编辑"
        }
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        if let d = delegate {
            d.setTextLabel(textView.text, indexPath: indexPath, isAppend: isAppend)
        }
    }
    
    func editTextView () {
        if editable {
            textView.endEditing(true)
            self.navigationItem.rightBarButtonItem!.title = "编辑"
        }
        else {
            textView.becomeFirstResponder()
            self.navigationItem.rightBarButtonItem!.title = "完成"
        }
        editable != editable
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        println("textViewDidBeginEditing")
        editable = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        println("textViewDidEndEditing")
        editable = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

