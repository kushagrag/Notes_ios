//
//  ViewController.swift
//  Notes
//
//  Created by Kushagra Gupta on 11/08/16.
//  Copyright © 2016 Kushagra Gupta. All rights reserved.
//

import UIKit
import CoreGraphics


class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, UITableViewDataSource {

    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var bottomLine: NSLayoutConstraint!
    
    var data = NSUserDefaults.standardUserDefaults()
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 20.0
    var keyboardFrame: CGRect = CGRect.null
    var notes:[String]?
    
    
    override func viewDidLoad() {
        notesTable.reloadData()
        notesTable.rowHeight = UITableViewAutomaticDimension
        notesTable.estimatedRowHeight = 50;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        notesTable.delegate = self
        inputText.delegate = self
        notesTable.dataSource = self
        notes = data.objectForKey("notes") as? [String]
        print(notes)
        let nib = UINib(nibName: "NotesTableViewCell", bundle: nil)
        notesTable.registerNib(nib, forCellReuseIdentifier: "cell")
        super.viewDidLoad()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        addData("")
        self.notesTable.reloadData()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        notes!.popLast()
        let text:NSString = textField.text!
        if string == ""{
            addData(text.substringToIndex(range.location) + text.substringFromIndex(range.location+range.length))
        }
        else{
          addData(text as String + string)
        }
        dispatch_async(dispatch_get_main_queue(),{
        self.notesTable.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
            })
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let data = NSUserDefaults.standardUserDefaults()
        data.setObject(notes, forKey: "notes")
        self.notesTable.reloadData()
        inputText.text = "";
            }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notes == nil{
            return 0
        }
        else {
                return notes!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NotesTableViewCell
        cell.heightAnchor
        cell.notesData.text = notes![notes!.count-indexPath.row-1]
        return cell
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let info = notification.userInfo {
            self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            self.arrangeViewOffsetFromKeyboard()
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.returnViewToInitialFrame()
    }
    
    func arrangeViewOffsetFromKeyboard()
    {
       let theApp: UIApplication = UIApplication.sharedApplication()
       
        
        
        let windowView: UIView? = theApp.delegate!.window!
        
        let textFieldLowerPoint: CGPoint = CGPointMake(self.inputText!.frame.origin.x, self.inputText!.frame.origin.y + self.inputText!.frame.size.height)
        
        let convertedTextFieldLowerPoint: CGPoint = self.view.convertPoint(textFieldLowerPoint, toView: windowView)
        
        let targetTextFieldLowerPoint: CGPoint = CGPointMake(self.inputText!.frame.origin.x, self.keyboardFrame.origin.y - kPreferredTextFieldToKeyboardOffset)
        
        let targetPointOffset: CGFloat = targetTextFieldLowerPoint.y - convertedTextFieldLowerPoint.y
        let adjustedViewFrameCenter: CGPoint = CGPointMake(self.view.center.x, self.view.center.y + targetPointOffset)
        
        UIView.animateWithDuration(0.2, animations:  {
            self.view.center = adjustedViewFrameCenter
        })
    }
    
    func returnViewToInitialFrame()
    {
        let initialViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        
        if (!CGRectEqualToRect(initialViewRect, self.view.frame))
        {
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame = initialViewRect
            });
        }
    }
    
    func addData (str: String){
        if notes != nil {
            notes?.append(str)
        } else {
            notes = [str]
        }
    
    }
    
    func delData(){
        data.setObject([], forKey: "notes")
    }
    
}

