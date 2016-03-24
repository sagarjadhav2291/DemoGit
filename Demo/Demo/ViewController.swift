//
//  ViewController.swift
//  Demo
//
//  Created by Sagar Jadhav on 02/03/16.
//  Copyright © 2016 Globant. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goToNextScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let secondVC:SecondViewController = storyBoard.instantiateViewControllerWithIdentifier("SecondViewController") as! SecondViewController

        print(self.navigationController)
        self.navigationController?.pushViewController(secondVC, animated: true)
        self.post(NSDictionary() as! Dictionary<String, String>, url: "") { (succeeded, msg) -> () in
            print(succeeded)
            print(msg)
        }
    }
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var body:NSData
        do{
            body = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        }catch{
            body  = NSData()
        }
        request.HTTPBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            var json:NSDictionary;
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
            } catch{
                json = NSDictionary()
            }
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON:NSDictionary = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                if let success = parseJSON["success"] as? Bool {
                    print("Succes: \(success)")
                    postCompleted(succeeded: success, msg: "Logged in.")
                }
                return
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
                postCompleted(succeeded: false, msg: "Error")
                
                
            }
        })
        
        task.resume()
    }



}

