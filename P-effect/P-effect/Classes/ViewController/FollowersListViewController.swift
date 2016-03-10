//
//  FollowersViewController.swift
//  P-effect
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

final class FollowersListViewController: UIViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Profile

    private var router: protocol<ProfilePresenter, AlertManagerDelegate>!
    
    private var user: User!
    private var followType: FollowType!
    
    private lazy var followerAdapter = FollowerAdapter()
    private weak var locator: ServiceLocator!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigavionBar()
        setupAdapter()
    }
    
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func setFollowType(type: FollowType) {
        self.followType = type
    }
    
    func setRouter(router: FollowersListRouter) {
        self.router = router
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(FollowerViewCell.cellNib, forCellReuseIdentifier: FollowerViewCell.identifier)
    }
    
    private func setupNavigavionBar() {
        navigationItem.title = followType.rawValue
    }
    
    private func setupAdapter() {
        tableView.dataSource = followerAdapter
        followerAdapter.delegate = self
        let activityService: ActivityService = router.locator.getService()
        if followType == .Followers {
            activityService.fetchFollowers(forUser: user) { activities, error in
                if let activities = activities {
                    
                    let followers = activities.map({$0.fromUser})
                    self.followerAdapter.update(withFollowers: followers, action: .Reload)
                    
                    print(followers)
                }
            }
            
        } else {
            activityService.fetchFollowedBy(forUser: user) { activities, error in
                if let activities = activities {
                    let followers = activities.map({$0.toUser})
                    self.followerAdapter.update(withFollowers: followers, action: .Reload)
                    
                    print(followers)

                }
            }
        
        }
    }
    
}

extension FollowersListViewController: FollowerAdapterDelegate {
    
    func followerAdapterRequestedViewUpdate(adapter: FollowerAdapter) {
        tableView.reloadData()
    }

}


extension FollowersListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let follower = followerAdapter.getFollower(atIndexPath: indexPath)
        router.showProfile(follower)
    }
    
}
