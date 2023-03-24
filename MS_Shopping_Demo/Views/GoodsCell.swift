//
//  GoodsCell.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import UIKit
import SnapKit
import Then
import Kingfisher

final class GoodsCell: UICollectionViewCell {
    static let identifier = "ItemCell"
    
    private var goodsImage = UIImageView().then {
        $0.backgroundColor = .systemBlue
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "house.fill")
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private var priceStack = UIStackView().then {
        $0.backgroundColor = .clear
        $0.distribution = .fillProportionally
        $0.spacing = 4
    }
    
    private var discountPercentageLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .accentRed
    }
    
    private var priceLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .text_primary
    }
    
    private var titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .text_secondary
        $0.numberOfLines = 3
    }
    
    private var additionalStack = UIStackView().then {
        $0.axis = .horizontal
        $0.backgroundColor = .clear
        $0.distribution = .fillProportionally
        $0.spacing = 5
    }
    
    private var isNewView = UIView().then {
        $0.layer.addBorder(width: 0.2, color: .text_primary, radius: 2)
        $0.backgroundColor = .clear
    }
    
    private var isnewLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textColor = .text_primary
        $0.text = "NEW"
    }
    
    private var sellCountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .text_secondary
    }
    
    private var separatorView = UIView().then {
        $0.backgroundColor = .systemGray4
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStyle()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureStyle() {
        self.contentView.addSubview(goodsImage)
        self.contentView.addSubview(priceStack)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(additionalStack)
        self.contentView.addSubview(separatorView)
        
        self.isNewView.addSubview(isnewLabel)
        
        self.priceStack.addArrangedSubview(discountPercentageLabel)
        self.priceStack.addArrangedSubview(priceLabel)
    }
    
    private func setupConstraints() {
        goodsImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(goodsImage.snp.width).multipliedBy(1)
            make.leading.equalToSuperview().offset(16)
        }
        
        priceStack.snp.makeConstraints { make in
            make.top.equalTo(goodsImage.snp.top).offset(2)
            make.leading.equalTo(goodsImage.snp.trailing).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(priceStack.snp.bottom).offset(8)
            make.leading.equalTo(priceStack.snp.leading)
            make.trailing.equalToSuperview().offset(-32)
        }
        
        additionalStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(priceStack.snp.leading)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(additionalStack.snp.bottom).offset(20)
            make.height.equalTo(0.2)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(with viewModel: GoodsModel) {
        guard let url = viewModel.image else {
            goodsImage.image = UIImage(systemName: "house")
            return
        }
        goodsImage.kf.setImage(with: URL(string: url))
        
        guard let actualPrice = viewModel.actual_price,
              let price = viewModel.price else {
            discountPercentageLabel.text = nil
            priceLabel.text = nil
            return
        }
        discountPercentageLabel.text = String((100 - (100 * price) / actualPrice)) + "%"
        priceLabel.text = price.numberStringWithComma()
        
        guard let goodsTitle = viewModel.name else {
            titleLabel.text = nil
            return
        }
        titleLabel.text = goodsTitle
        
        guard let isNew = viewModel.is_new else {
            print("nil입니다.")
            return
        }
        if isNew == true {
            isNewView.addSubview(isnewLabel)
            isnewLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(2)
                make.leading.equalToSuperview().offset(5)
                make.centerX.centerY.equalToSuperview()
            }
            additionalStack.addArrangedSubview(isNewView)
        }
        
        guard let sellCount = viewModel.sell_count else {
            return
        }
        
        if sellCount >= 10 {
            sellCountLabel.text = sellCount.numberStringWithComma() + "개 구매중"
            additionalStack.addArrangedSubview(sellCountLabel)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
