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
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            wtHeader.Style15_Subhead()
            wtmmHeader.Style17_HeadlineBold()
            
        }
        
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            
            wtHeader.Style17_HeadlineThin()
            wtmmHeader.Style17_HeadlineBold()
        }
        tableView.reloadData()
        
       
        self.tableView.reloadData()
        
        
       
    }
    
    
    @IBAction func WTInchesBoldPressed(_ sender: UIButton) {
        
        
        
        defaults.set(false, forKey: "mmBold")
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            wtHeader.Style17_HeadlineBold()
            wtmmHeader.Style15_Subhead()
            
            
            
        }
        
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            
            
            wtHeader.Style17_HeadlineBold()
            wtmmHeader.Style17_HeadlineThin()
        }
        
        tableView.reloadData()
        print(defaults.bool(forKey: "mmBold"))
    }
    
    override func viewDidLayoutSubviews() {
        
        
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            
            
            
            if defaults.bool(forKey: "mmBold") == true {
                
                wtHeader.Style15_Subhead()
                wtmmHeader.Style17_HeadlineBold()
                
            }
            
            else {
                wtHeader.Style17_HeadlineBold()
                wtmmHeader.Style15_Subhead()
                
                
            }
            
            lbftHeader.Style15_Subhead()
            kgmHeader.Style15_Subhead()
            schHeader.Style15_Subhead()
        }
        
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            
            print(headerView.frame.width)
            
            
            if defaults.bool(forKey: "mmBold") == true {
                wtHeader.Style17_HeadlineThin()
                wtmmHeader.Style17_HeadlineBold()
                
            } else {
                wtHeader.Style17_HeadlineBold()
                wtmmHeader.Style17_HeadlineThin()
                
            }
            
            
            lbftHeader.Style17_HeadlineThin()
            kgmHeader.Style17_HeadlineThin()
            schHeader.Style17_HeadlineThin()
            
            if UIApplication.shared.preferredContentSizeCategory < .extraLarge {
                // small font
                if headerView.frame.width <= 490 {
                    // small font - smallest iPad
                    //okay!
                    headerHeight.constant = 45
                     
                     inches_mm_space.constant = 40
                     mm_lbft_space.constant = 40
                     lbft_kg_space.constant = 50
                     sch_space_fromright.constant = 20
                }
                
                if headerView.frame.width < 600 && headerView.frame.width > 490 {
                    
                    // small font - mid iPad
                    
                    
                    headerHeight.constant = 45
                     
                     inches_mm_space.constant = 45
                     mm_lbft_space.constant = 50
                     lbft_kg_space.constant = 50
                     sch_space_fromright.constant = 20
                }
                
                
                if headerView.frame.width == 600  {
                    // small font - largest iPad
                    //okay!
                    headerHeight.constant = 45
                     
                     inches_mm_space.constant = 75
                     mm_lbft_space.constant = 75
                     lbft_kg_space.constant = 80
                     sch_space_fromright.constant = 20
                    
                }
             

                pickerHeight.constant = 175.0
                selector.updateConstraintsIfNeeded()
                
            } else {
            
                // LARGE FONT
                
                
                if headerView.frame.width <= 490 {
                    //large font  - smallest iPad
                    
                    headerHeight.constant = 60
                    WTInchesWidth.constant = 60



                    inches_mm_space.constant = 50
                    mm_lbft_space.constant = 40
                    lbft_kg_space.constant = 40
                    sch_space_fromright.constant = 20
                }
                
                
                if headerView.frame.width < 600 && headerView.frame.width > 490 {
                 //large font  - mid iPad
                headerHeight.constant = 60
                WTInchesWidth.constant = 60



                inches_mm_space.constant = 50
                mm_lbft_space.constant = 50
                lbft_kg_space.constant = 50
                sch_space_fromright.constant = 20
                }
                
                
                
               if headerView.frame.width == 600 {
                    
                  //large font  - large iPad
                    headerHeight.constant = 60
                    WTInchesWidth.constant = 60

                    inches_mm_space.constant = 80
                    mm_lbft_space.constant = 80
                    lbft_kg_space.constant = 80
                    sch_space_fromright.constant = 20
                    
                }
                
                
                
                pickerHeight.constant = 275
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
            
            
            
            if defaults.bool(forKey: "mmBold") == true {
                
                cell.inches.Style15_Subhead()
                cell.mm.Style17_HeadlineBold()
                
            }
            
            if defaults.bool(forKey: "mmBold") == false {
                cell.inches.Style17_HeadlineBold()
                cell.mm.Style15_Subhead()
                
                
                
            }
            cell.lbft.Style15_Subhead()
            cell.kgm.Style15_Subhead()
            cell.sch1.Style13_Footnote()
            cell.sch2.Style13_Footnote()
            
            
            
            
            
        }
        if #available(iOS 14.0, *) {
            if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
                
                
                
                
                if defaults.bool(forKey: "mmBold") == true {
                    
                    cell.inches.Style17_HeadlineThin()
                    cell.mm.Style17_HeadlineBold()
                    
                }
                
                if defaults.bool(forKey: "mmBold") == false {
                    
                    cell.inches.Style17_HeadlineBold()
                    cell.mm.Style17_HeadlineThin()
                    
                    
                }
                
                
                cell.lbft.Style17_HeadlineThin()
                cell.kgm.Style17_HeadlineThin()
                cell.sch1.Style15_Subhead()
                cell.sch2.Style15_Subhead()
                
            }
        } else {
            // Fallback on earlier versions
            
            
        }
    
        
        return cell
        
        
        
        
        
    }
}
