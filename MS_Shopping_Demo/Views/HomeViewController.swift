//
//  HomeViewController.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import UIKit
import RxViewController
import RxSwift


class HomeViewController: BaseViewController {
    
    // MARK: Properties
    private var homeCollectionView: UICollectionView!
    let viewModel: HomeViewModelType
    
    enum HomeSection: CaseIterable {
        case banner
        case goods
    }
    
    typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, AnyHashable>
    var dataSource: HomeDataSource! = nil
    var snapshot = NSDiffableDataSourceSnapshot<HomeSection, AnyHashable>()
    
    // MARK: Initilizer
    init(viewModel: HomeViewModelType = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        snapshot.appendSections([.banner, .goods])
        
        self.view.backgroundColor = .white
        configureCollectionView()
        configureStyle()
        setupConstraints()
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: Configuration methods
    override func configureStyle() {
    }
    
    override func setupConstraints() {
        self.view.addSubview(homeCollectionView)

        homeCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView
extension HomeViewController {
    private func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = .clear
        
        // Register
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.identifier)
        collectionView.register(GoodsCell.self, forCellWithReuseIdentifier: GoodsCell.identifier)
        collectionView.dataSource = dataSource
        
        homeCollectionView = collectionView
        dataSource = setupDiffableDataSource()
        dataSource.apply(snapshot, animatingDifferences: true)
        homeCollectionView.dataSource = dataSource
    }
    
    /** Compositional 레이아웃 생성*/
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                //item.contentInsets.trailing = 2
                //item.contentInsets.bottom = 16
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .paging
                
                return section
            } else {
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
        }
    }
    
    /** DiffableDataSource 생성 */
    
    
    private func setupDiffableDataSource() -> UICollectionViewDiffableDataSource<HomeSection, AnyHashable> {
        var homedDataSource: UICollectionViewDiffableDataSource<HomeSection, AnyHashable>
        homedDataSource = UICollectionViewDiffableDataSource<HomeSection, AnyHashable>(collectionView: homeCollectionView, cellProvider: { collectionView, indexPath, item in
            if let bannerItem = item as? BannerModel {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.identifier, for: indexPath) as? BannerCell else { return UICollectionViewCell() }
                
                cell.configure(with: bannerItem)
                
                return cell
            } else if let goodsItem = item as? GoodsModel {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoodsCell.identifier, for: indexPath) as? GoodsCell else { return UICollectionViewCell() }
                
                cell.configure(with: goodsItem)
                
                return cell
            }
            
            return nil
        })
        
        return homedDataSource
    }
    
    /**
    ///사용하지 않는 코드입니다.
    private func setupSnapshot() {
        snapshot.appendSections([.banner, .goods])
        snapshot.appendItems([
                        BannerModel(id:0, image: "1번"),
                        BannerModel(id:1, image: "2번"),
                        BannerModel(id:2, image: "3번"),
                        BannerModel(id:3, image: "1번"),
        ], toSection: .banner)
        
        snapshot.appendItems([
            GoodsModel(id: 0, name: "상품1", image: "상품1", actual_price: 1000, price: 1200, is_new: true, sell_count: 0)
        ], toSection: .goods)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    */
}



// MARK: - Rx Setup
extension HomeViewController {
    func setupBindings() {
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
//        let reload = collectionView.refreshControl?.rx
//            .controlEvent(.valueChanged)
//            .map{_ in ()} ?? Observable.just(())
        
        firstLoad
            .bind(to: viewModel.fetchHome)
            .disposed(by: disposeBag)
        
        
        viewModel.pushBanners.bind{ [weak self] value in
            self?.snapshot.appendItems(value, toSection: .banner)
            self?.snapshot.reloadSections([.banner])
            self?.dataSource.apply(self!.snapshot)
        }.disposed(by: disposeBag)
        
        viewModel.pushGoods.bind{ [weak self] value in
            self?.snapshot.appendItems(value, toSection: .goods)
            self?.snapshot.reloadSections([.banner, .goods])
            self?.dataSource.apply(self!.snapshot)

        }.disposed(by: disposeBag)
        
    }
}
