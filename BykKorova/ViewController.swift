//
//  ViewController.swift
//  BykKorova
//
//  Created by Raikhan Khassenova on 27/07/2017.
//  Copyright © 2017 Raikhan Khassenova. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let infoText = "On a sheet of paper, the players each write a 4-digit secret number. The digits must be all different. Then, in turn, the players try to guess their opponent's number who gives the number of matches. If the matching digits are in their right positions, they are \"bulls\", if in different positions, they are \"cows\". Example:\nSecret number: 4271\nOpponent's try: 1234\nAnswer: 1 bull and 2 cows. (The bull is \"2\", the cows are \"4\" and 1\".)"
    let bykKey = "NumberOfByk"
    let korovaKey = "NumberOfKorova"
    @IBOutlet weak var korovaPicker: UIPickerView!
    @IBOutlet weak var guessNumber: UILabel!
    @IBOutlet weak var bykPicker: UIPickerView!
    var history: Array<Int> = []
    var candidates:Array<Int> = []
    var historyIsShown = false
    var infoIsShown = false
    override func viewDidLoad() {
        bykPicker.delegate = self
        bykPicker.dataSource = self
        korovaPicker.delegate = self
        korovaPicker.dataSource = self
        super.viewDidLoad()
        startNewGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func printCandidate(){
        if (candidates.count == 0){
            errorHandler()
            return
        }
        if (candidates[0]<1000){
            guessNumber.text = "Is your number \n0"+String(candidates[0])
        } else {
            guessNumber.text = "Is your number \n"+String(candidates[0])
        }
        print(candidates[0])
    }
    
    
    
    @IBAction func submitButtonIsPressed(_ sender: Any) {
        let UserResponse = getIntBy(key: bykKey) * 10 + getIntBy(key: korovaKey)
        history.append(candidates[0]*100+UserResponse)
        candidates = allNumbersThatSatisfy(candidates: candidates, bykKorovaResult: UserResponse, givenNumber: candidates[0])
        printCandidate()
    }
    
    func int2array(a: Int)->Array<Int>{
        var number = a
        var ans = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var count = 4
        while(count>0){
            ans[number%10] = count
            count = count - 1
            number = number/10
        }
        return ans
    }
    
    func bykKorova(hiddenNumber: Int, guessNumber:Int)->Int{
        let hiddenNumberArray = int2array(a: hiddenNumber)
        let guessNumberArray = int2array(a: guessNumber)
        var byk = 0
        var korova = 0
        for i in 0...9{
            if (hiddenNumberArray[i]==guessNumberArray[i] && hiddenNumberArray[i]>0){
                byk = byk+1
            } else if (hiddenNumberArray[i]>0 && guessNumberArray[i]>0){
                korova = korova + 1
            }
        }
        return (byk*10+korova)
    }
    
    func allNumbersThatSatisfy(candidates:[Int], bykKorovaResult: Int, givenNumber: Int)->Array<Int>{
        var ans: Array<Int> = []
        for candidate in candidates{
            if (bykKorova(hiddenNumber: givenNumber, guessNumber: candidate)==bykKorovaResult){
                ans.append(candidate)
            }
        }
        return ans
    }
    
    func initCandidates()->Array<Int>{
        var ans: Array<Int> = []
        for i in 99...10000{
            if (satisfy(i: i)){
                ans.append(i)
            }
        }
        return ans
    }
    
    func satisfy(i: Int)->Bool{
        if (i<100 || i>9999){
            return false
        }
        let array = int2array(a: i)
        var count = 0
        for val in array{
            if (val==0){
                count = count+1
            }
        }
        if (count==6){
            return true
        }
        return false
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var key = ""
        if (pickerView == bykPicker){
            key = bykKey
            print("byk is selected")
        } else {
            key = korovaKey
            print("korova is selected")
        }
        UserDefaults.standard.set(row, forKey: key)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func getIntBy(key: String)->Int{
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func errorHandler(){
        let warningText = "Unfortunately with given info we cannot guess your number.\nPlease try again"
        showHistoryWithText(initText: warningText)
    }
    
    func startNewGame(){
        UserDefaults.standard.set(0, forKey: bykKey)
        UserDefaults.standard.set(0, forKey: korovaKey)
        submitButton.isEnabled = true
        infoIsShown = false
        historyIsShown = false
        history = []
        candidates = initCandidates()
        printCandidate()
    }
    
    @IBAction func newGameIsPressed(_ sender: Any) {
        startNewGame()
    }
    
    func number2string(number: Int)->String{
        var result = String(number)
        if (number<1000){
            result = "0" + result
        }
        return result
    }
    func showHistoryWithText(initText:String){
        var text = initText + "\n"
        for hist in history{
            text += number2string(number: hist/100)
            let histnum = hist % 100
            text += " " + String(histnum/10)
            text += "🐂 " + String(histnum % 10) + "🐄\n"
        }
        guessNumber.text = text
        historyIsShown = true
        infoIsShown = false
        submitButton.isEnabled  = false
    }
    
    @IBAction func historyButtonIsPressed(_ sender: Any) {
        if (!historyIsShown){
            showHistoryWithText(initText: "History")
        } else {
            historyIsShown = false
            printCandidate()
        }
    }
    
    @IBAction func infoButtonIsPressed(_ sender: Any) {
        if (!infoIsShown){
            historyIsShown = false
            infoIsShown = true
            guessNumber.text = infoText
            submitButton.isEnabled = false
        } else {
            infoIsShown = false
            submitButton.isEnabled = true
            printCandidate()
        }
    }
    @IBOutlet weak var submitButton: UIButton!
}

