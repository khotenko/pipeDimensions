//
//  ViewController.swift
//  pipeDimensions
//
//  Created by Nick Khotenko on 2020-06-07.
//  Copyright © 2020 Nick Khotenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var wtHeader: UILabel!
    @IBOutlet weak var wtmmHeader: UILabel!
    @IBOutlet weak var lbftHeader: UILabel!
    @IBOutlet weak var kgmHeader: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var schHeader: UILabel!
    
    var p : [pipeData] = []
    var wanted : [pipeData] = []
    
    @IBOutlet weak var selector: UIPickerView!
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    @IBOutlet weak var WTinchesBoldButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var inches_mm_space: NSLayoutConstraint!
    @IBOutlet weak var mm_lbft_space: NSLayoutConstraint!
    @IBOutlet weak var lbft_kg_space: NSLayoutConstraint!
    @IBOutlet weak var sch_space_fromright: NSLayoutConstraint!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var WTInchesWidth: NSLayoutConstraint!
  
    
    var dataManager = DataManager()
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var WTmmBold: UIButton!
    
    @IBAction func WTmmBoldPressed(_ sender: UIButton) {
        
      
        defaults.set(true, forKey: "mmBold")
        defaults.set(false, forKey: "inBold")
        
        mmPref = true
        inPref = false
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            wtHeader.Style15_Subhead()
            wtmmHeader.Style17_HeadlineBold()
        default:
            wtHeader.Style17_HeadlineThin()
            wtmmHeader.Style17_HeadlineBold()
        }
        
       
        self.tableView.reloadData()
        
    }
    
    
    @IBAction func WTInchesBoldPressed(_ sender: UIButton) {
        
        defaults.set(false, forKey: "mmBold")
        
        defaults.set(true, forKey: "inBold")
        
        mmPref = false
        inPref = true
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            wtHeader.Style17_HeadlineBold()
            wtmmHeader.Style15_Subhead()
        default:
            wtHeader.Style17_HeadlineBold()
            wtmmHeader.Style17_HeadlineThin()
        }
     
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
       
        mmPref = defaults.bool(forKey: "mmBold")
         inPref = defaults.bool(forKey: "inBold")
   
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            if mmPref == true {
                
                wtHeader.Style15_Subhead()
                wtmmHeader.Style17_HeadlineBold()
            }
           else {
               if inPref == true {
                   wtHeader.Style17_HeadlineBold()
                   wtmmHeader.Style15_Subhead()
                          
               } else {
                   wtHeader.Style15_Subhead()
                   wtmmHeader.Style17_HeadlineBold()

               }

            }
            
            lbftHeader.Style15_Subhead()
            kgmHeader.Style15_Subhead()
            schHeader.Style15_Subhead()
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            

            if mmPref == true {
                
                wtHeader.Style17_HeadlineThin()
                wtmmHeader.Style17_HeadlineBold()
            }
           else {
               if inPref == true {
                   wtHeader.Style17_HeadlineBold()
                   wtmmHeader.Style17_HeadlineThin()
                          
               } else {
                   wtHeader.Style17_HeadlineThin()
                   wtmmHeader.Style17_HeadlineBold()

               }

            }
            
            lbftHeader.Style17_HeadlineThin()
            kgmHeader.Style17_HeadlineThin()
            schHeader.Style17_HeadlineThin()
            
            let hW = headerView.frame.width
            
   
            
            if UIApplication.shared.preferredContentSizeCategory < .extraLarge {
     
             
                headerHeight.constant = 45
                pickerHeight.constant = 175.0
                
                if hW <= 320 {
                 
                    
                    inches_mm_space.constant = 5
                    mm_lbft_space.constant = 5
                    
                    lbft_kg_space.constant = 17
                    
                    sch_space_fromright.constant = 10
                }
                
                
                if  hW > 320 && hW < 490 {
          
                    
                    inches_mm_space.constant = (75/280)*hW - 85.714
                    
                    mm_lbft_space.constant = 0.225*hW - 50
                    
                    lbft_kg_space.constant = 0.225*hW - 55
                    
                    
                    sch_space_fromright.constant = 10
                }
                
                if hW >= 490 && hW < 600  {
                   
                    inches_mm_space.constant = (75/280)*hW - 85.714
                    
                    mm_lbft_space.constant = 0.225*hW - 50
                    
                    lbft_kg_space.constant = 0.225*hW - 50
                    
                    sch_space_fromright.constant = 10
                }
                
                
                if hW == 600  {
                  
                    
                    inches_mm_space.constant = 75
                    
                    mm_lbft_space.constant = 85
                    
                    lbft_kg_space.constant = 85
                    
                    sch_space_fromright.constant = 10
                    
                }
                
                selector.updateConstraintsIfNeeded()
                
            } else {
             
                headerHeight.constant = 60
                pickerHeight.constant = 275
                
                
                if hW <= 320 {
            
              
                    
                    inches_mm_space.constant = 5
                    mm_lbft_space.constant = 5
                    lbft_kg_space.constant = 17
                    
                    sch_space_fromright.constant = 5
                }
                
                if hW > 320 && hW < 490 {
               
                    WTInchesWidth.constant = 60
                    
                    inches_mm_space.constant = (75/280)*hW - 80.714
                    
                    
                    mm_lbft_space.constant = 0.225*hW - 50
                    lbft_kg_space.constant = 0.225*hW - 60
                    
                    sch_space_fromright.constant = 10
                }
                
                if hW > 490 && hW < 600  {
               
                    WTInchesWidth.constant = 60
                    
                    inches_mm_space.constant = (75/280)*hW - 80.714
                    
                    mm_lbft_space.constant = 0.225*hW - 50
                    lbft_kg_space.constant = 0.225*hW - 50
                    
                    sch_space_fromright.constant = 10
                }
                
                if hW == 600 {
                    
                    WTInchesWidth.constant = 60
                    
                    inches_mm_space.constant = 80
                    mm_lbft_space.constant = 80
                    lbft_kg_space.constant = 80
                    
                    sch_space_fromright.constant = 10
                    
                }
                
                selector.updateConstraintsIfNeeded()
                
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        
        selector.dataSource = self
        selector.delegate = self
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "pipeCell")
        
        if let url = Bundle.main.url(forResource: "actualData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([pipeData].self, from: data)
                p = jsonData
                
            } catch {
                print("error:\(error)")
                
                
            }
        }
        
        mmPref = defaults.bool(forKey: "mmBold")
         inPref = defaults.bool(forKey: "inBold")
        
          
    }
}

struct pipeData: Decodable {
    
    var Name: String
    let WT_inch: Float
    let WT_mm : Float
    let lb_per_ft : Float
    let kg_per_m: Float
    let Sch_1: String
    let Sch_2: String
}



extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return dataManager.diameterArray.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return dataManager.diameterArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = dataManager.diameterArray[row]
        label.Style17_HeadlineLight()
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        if UIApplication.shared.preferredContentSizeCategory < .extraLarge {
            return 35
            
        } else {
            
            return 50
        }
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedPipe = dataManager.diameterArray[row]
        if selectedPipe != "NPS [inches]  OD [mm]" {
            
            wanted = p.filter({return $0.Name == selectedPipe})
        }
        
        if selectedPipe == "NPS [inches]  OD [mm]" {
            wanted = []
            
        }
        
        tableView.reloadData()
        
    }
    
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return wanted.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let wanteddata = wanted[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pipeCell", for: indexPath) as! TableViewCell
        
        cell.inches.text = String(format: "%.3f", wanteddata.WT_inch)
        cell.mm.text = String(format: "%.2f", wanteddata.WT_mm)
        cell.lbft.text = String(format: "%.1f", wanteddata.lb_per_ft)
        cell.kgm.text = String(format: "%.1f", wanteddata.kg_per_m)
        cell.sch1.text = wanteddata.Sch_1
        cell.sch2.text = wanteddata.Sch_2
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            
            if mmPref == true {
                
                cell.inches.Style15_Subhead()
                cell.mm.Style17_HeadlineBold()
            }
           else {
               if inPref == true {
                   cell.inches.Style17_HeadlineBold()
                   cell.mm.Style15_Subhead()
                          
               } else {
                   cell.inches.Style15_Subhead()
                   cell.mm.Style17_HeadlineBold()

               }

            }
            
            
            cell.lbft.Style15_Subhead()
            cell.kgm.Style15_Subhead()
            cell.sch1.Style13_Footnote()
            cell.sch2.Style13_Footnote()
            
           
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
        
            
            if mmPref == true {
                
                cell.inches.Style17_HeadlineThin()
                cell.mm.Style17_HeadlineBold()
            }
           else {
               if inPref == true {
                   cell.inches.Style17_HeadlineBold()
                   cell.mm.Style17_HeadlineThin()
                          
               } else {
                   cell.inches.Style17_HeadlineThin()
                   cell.mm.Style17_HeadlineBold()

               }

            }
            
            
            
            cell.lbft.Style17_HeadlineThin()
            cell.kgm.Style17_HeadlineThin()
            cell.sch1.Style15_Subhead()
            cell.sch2.Style15_Subhead()
            
        }
        
       
        return cell
        
    }
}
