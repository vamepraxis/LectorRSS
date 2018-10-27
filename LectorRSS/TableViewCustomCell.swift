//
//  TableViewCustomCell.swift
//  LectorRSS
//
//  Created by MacBook Pro on 20/10/18.
//  Copyright © 2018 ccc. All rights reserved.
//

import UIKit

protocol CustomCellDelegate{
    func cellTapped(_ cell: TableViewCustomCell)
}

class TableViewCustomCell: UITableViewCell {

    var buttonDelegate: CustomCellDelegate?
    
    //Home
    @IBOutlet weak var imageViewHome: UIImageView!
    @IBOutlet weak var titleHome: UILabel!
    @IBOutlet weak var descriptionHome: UILabel!
    @IBOutlet weak var dateHome: UILabel!
    
    //News
    @IBOutlet weak var titleNews: UILabel!
    @IBOutlet weak var dateNews: UILabel!
    @IBOutlet weak var imageViewNews: UIImageView!
    @IBOutlet weak var descriptionNews: UILabel!
    @IBOutlet weak var heightImageNews: NSLayoutConstraint!
    
    @IBAction func buttonTap(_ sender: Any) {
        if let delegate = buttonDelegate{
            delegate.cellTapped(self)
        }
    }
    
    //RSS
    @IBOutlet weak var nameRSS: UILabel!
    @IBOutlet weak var urlRSS: UILabel!
    
    @IBAction func deleteTap(_ sender: Any) {
        if let delegate = buttonDelegate{
            delegate.cellTapped(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
