//
//  PostTableViewController.swift
//  The Oakland Post
//
//  Created by Andrew Clissold on 6/13/14.
//  Copyright (c) 2014 Andrew Clissold. All rights reserved.
//

import UIKit

class PostTableViewController: BugFixTableViewController, MWFeedParserDelegate {

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    var baseURL: String!
    var feedParser: FeedParser!
    var parsedItems = [MWFeedItem]()
    var dateFormatter: NSDateFormatter!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl

        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle

        feedParser = FeedParser(baseURL: baseURL, length: 15, delegate: self)
        feedParser.parseInitial()

        tableView.addInfiniteScrollingWithActionHandler(loadMorePosts)
    }

    func refresh() {
        tableView.userInteractionEnabled = false
        parsedItems.removeAll()
        feedParser.parseInitial()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func loadMorePosts() {
        tableView.userInteractionEnabled = false
        feedParser.parseMore()
    }

    // MARK: MWFeedParserDelegate methods

    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        parsedItems.append(item)
    }

    func feedParserDidFinish(parser: MWFeedParser!) {
        tableView.reloadData()
        refreshControl.endRefreshing()
        tableView.userInteractionEnabled = true
        tableView.infiniteScrollingView.stopAnimating()
    }

    // MARK: Segues

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == readPostID {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let item = parsedItems[indexPath.row] as MWFeedItem
            (segue.destinationViewController as PostViewController).url = item.link
        }
    }

    // MARK: Table View

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return parsedItems.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as PostCell

        let item = parsedItems[indexPath.row] as MWFeedItem

        // Set the cell's thumbnail image
        if let enclosures = item.enclosures {
            if enclosures[0] is NSDictionary {
                let dict = item.enclosures[0] as NSDictionary
                if dict["type"].containsString("image") {
                    let URL = NSURL(string: dict["url"] as String)
                    cell.thumbnail.setImageWithURL(URL, placeholderImage: UIImage(named: "Placeholder"))
                }
            }
        } else {
            // Set it to nil so a dequeued cell's image isn't displayed
            cell.thumbnail.image = nil
        }

        cell.descriptionLabel.text = item.title

        // Figure out and set the cell's date label
        var time = -item.date.timeIntervalSinceNow / 60.0
        var unit = "m"
        if time >= 60.0 {
            time /= 60.0
            unit = "h"
            if time >= 24.0 {
                time /= 24.0
                unit = "d"
            }
        }
        cell.dateLabel.text = "\(Int(time))\(unit) ago"

        return cell
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return tableViewRowHeight;
    }

}