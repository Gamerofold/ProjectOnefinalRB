//
//  SingleLineProjectCell.swift
//  ProjectOne
//
//  Created by Robert Whitehead on 9/27/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import UIKit

class SingleLineProjectCell: UITableViewCell {

    @IBOutlet weak var listProjectProtoImage: UIImageView!    
    @IBOutlet weak var listTitleProtoText: UITextField!
    @IBOutlet weak var listStatusProtoText: UITextField!
    @IBOutlet weak var listSummaryProtoText: UITextView!
    @IBOutlet weak var listDescribeProtoText: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
