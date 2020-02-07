//
//  EventCell.swift
//  EstudoRxSwift
//
//  Created by Thiago Machado Faria on 07/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var tituloLb: UILabel!
    
    @IBOutlet weak var dataLb: UILabel!
    
    @IBOutlet weak var textoLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(event: EOEvent) {
        
        tituloLb.text = event.title
        dataLb.text = convertData(data: event.closeDate ?? Date())
        textoLb.text = event.description
        
    }
    
    func convertData(data: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(for: data) ?? ""
        
    }
    
}
