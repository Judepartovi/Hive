//
//  VoteWithTableViewController.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 7/13/22.
//

// TODO: Submit button should be

import UIKit
import Messages

class VoteViewController: StyleViewController {
    
    //var delegate: VoteViewControllerDelegate?
    static let storyboardID = String(describing: VoteViewController.self)
    
    @IBOutlet weak var promptLabel: StyleLabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayAndTimeLabel: UILabel!
    
    @IBOutlet weak var voteTable: UITableView!
    
    @IBOutlet weak var submitButton: HexButton!
    
    @IBOutlet weak var createEventButton: HexButton!
    
    
    @IBOutlet var clientConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var hostConstraints: [NSLayoutConstraint]!
    
    
    
    let cellInsets: CGFloat = 8
    
    var myID: String!
    var mURL: URL!
    var isHost: Bool = false
    
    var loadedEvent: Event!
    
    var voteGroups: [String] = []
    var voteItems: [[String]] = []
    var voteTallies: [[Int]] = []
    var initialVoteTallies: [[Int]] = []
    var isOpen: [Bool] = []
    var voteSelections: [[Int]] = []
    var multiSelectable: [Bool] = []
    
    var votesChanged = false
    
    
    var daysAndTimesMagicIndexes: [Int] = []
    var daysAndTimesGroupIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadedEvent = Event(url: mURL)
        decodeEvent(loadedEvent)
        decodeRSVPs(url: mURL)

        voteTable.dataSource = self
        voteTable.delegate = self
        voteTable.separatorStyle = .none
        voteTable.showsVerticalScrollIndicator = false
        voteTable.reloadData()
                
        submitButton.size(size: 150, textSize: 25)
        //submitButton.style(title: "Submit")
        submitButton.grey(title: "Submit")
        
        if isHost {
            for constraint in clientConstraints {
                constraint.isActive = false
            }
            for constraint in hostConstraints {
                constraint.isActive = true
            }
            createEventButton.isHidden = false
        }
        
    }
    
    func decodeEvent(_ event: Event) {
        
        promptLabel.style(text: "Join for " + event.title + "!")
        locationLabel.isHidden = true
        if event.locations.count == 1 {
            locationLabel.isHidden = false
            if let address = event.locations[0].address {
                locationLabel.text = event.locations[0].title + ": " + address
            } else {
                locationLabel.text = event.locations[0].title
            }
        } else if event.locations.count > 1 {
            voteGroups.append("Location")
            var allLoc: [String] = []
            for location in event.locations {
                allLoc.append(location.title)
            }
            voteItems.append(allLoc)
            voteTallies.append([Int](repeating: 0, count: event.locations.count))
            isOpen.append(false)
            voteSelections.append([])
            multiSelectable.append(false)
        }
           
        
        // EVERY COMBO
        /*
                        multiple times | 1 time | no times
         multiple days      *GRID       *string   *string
         1 day              string        label     label
         */
        
        // Multiple days
        if event.days.count > 1 {
            var mulDayMulTimeFlag = false
            var dayTimeCount = 0
            for day in event.days {
                let times = event.daysAndTimes[day]!
                daysAndTimesMagicIndexes.append(dayTimeCount)
                dayTimeCount += times.count
                if times.count > 1 {
                    mulDayMulTimeFlag = true
                }
            }
            
            // Multiple days multiple times
            if mulDayMulTimeFlag {
                // GRID LAYOUT
                daysAndTimesGroupIndex = voteGroups.count
                // name the voteGroups entry "Days and Times"
                voteGroups.append("Days and Times")
                voteItems.append([String](repeating: "", count: dayTimeCount)) //not needed with grid view
                voteTallies.append([Int](repeating: 0, count: dayTimeCount))
                isOpen.append(false)
                voteSelections.append([])
                multiSelectable.append(false)
                return
            }
            
            // Multiple days no time
            if event.daysAndTimes[event.days[0]]!.isEmpty {
                // ADD DAY: day.formatDate()
                
                voteGroups.append("days")
                var days = [String]()
                for var day in event.days {
                    days.append(day.formatDate())
                }
                voteItems.append(days)
                voteTallies.append([Int](repeating: 0, count: event.days.count))
                isOpen.append(false)
                voteSelections.append([])
                multiSelectable.append(true)
                return
            } else {
                
                // Multiple days 1 time
                voteGroups.append("daysAndTime")
                var daysAndTime = [String]()
                for var day in event.days {
                    daysAndTime.append(day.formatDate(time: event.daysAndTimes[day]![0], duration: event.duration))
                }
                voteItems.append(daysAndTime)
                voteTallies.append([Int](repeating: 0, count: event.days.count))
                isOpen.append(false)
                voteSelections.append([])
                multiSelectable.append(true)
                return
            }
        }
        
        // 1 Day
        var day = event.days[0]
        let times = event.daysAndTimes[day]!
        
        // 1 day 0/1 time
        dayAndTimeLabel.isHidden = true
        if times.count == 0 {
            dayAndTimeLabel.isHidden = false
            dayAndTimeLabel.text = day.formatDate()
        } else if times.count == 1 {
            dayAndTimeLabel.isHidden = false
            dayAndTimeLabel.text = day.formatDate(time: times[0], duration: event.duration)
        } else {
            // 1 day multiple times
            voteGroups.append("dayAndTimes")
            var dayAndTimes = [String]()
            for time in times {
                dayAndTimes.append(day.formatDate(time: time, duration: event.duration))
            }
            voteItems.append(dayAndTimes)
            voteTallies.append([Int](repeating: 0, count: times.count))
            isOpen.append(false)
            voteSelections.append([])
            multiSelectable.append(true)
        }
    }
    
    
    /*var voteGroups = ["A", "B", "C", "D (multi-select)"]
    var voteItems = [["p", "q"], ["r", "s", "t", "u"], ["x", "y", "z"], ["m", "n", "o", "p"]]
    var voteTallies = [[3, 2], [1, 0, 4, 0], [2, 1, 2], [5, 3, 1, 4]]
    var isOpen = [false, false, false, false]
    var voteSelections = [[], [], [], []] as [[Int]]
    var multiSelectable = [false, false, false, true]*/
    
    
    func decodeRSVPs(url: URL) {
        let components = URLComponents(url: url,
                resolvingAgainstBaseURL: false)
        
        var endFlag = false
        var meFlag = false
        for (_, queryItem) in (components!.queryItems!.enumerated()){
            let name = queryItem.name
            let value = queryItem.value
            
            if name == "hostID" && value == myID {
                isHost = true
            } else if name == "endEvent" {
                endFlag = true
            } else if endFlag {
                
                if name == myID && value == "start" {
                    meFlag = true
                } else if name == myID && value == "end" {
                    break
                } else if meFlag {
                    voteSelections[Int(name)!].append(Int(value!)!)
                }
                
                if (value != "start") && (value != "end") {
                    voteTallies[Int(name)!][Int(value!)!] += 1
                }
            }
        
        //Dummy code
        /*for (indexA, voteList) in voteItems.enumerated(){
            for _ in voteList {
                voteTallies[indexA].append(0)
            }
        }*/
        initialVoteTallies = voteTallies
        }
    }
    
    func updateSubmitButton() {
        
        if initialVoteTallies == voteTallies {
            submitButton.grey(title: "Submit")
            votesChanged = false
        } else {
            submitButton.color(title: "Submit")
            votesChanged = true
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if votesChanged {
            let url = prepareVoteURL()
            prepareMessage(url)
        }
    }
    
    @IBAction func createEventButtonPressed(_ sender: UIButton) {
        
        let url = prepareVoteURL()
        
        let inputeventVC = (storyboard?.instantiateViewController(withIdentifier: InputEventViewController.storyboardID) as? InputEventViewController)!
        inputeventVC.myID = myID
        inputeventVC.mURL = url
        inputeventVC.voteGroups = voteGroups
        inputeventVC.voteItems = voteItems
        inputeventVC.voteTallies = voteTallies
        inputeventVC.isOpen = isOpen
        inputeventVC.voteSelections = [Int?](repeating: nil, count: voteGroups.count)
        inputeventVC.daysAndTimesMagicIndexes = daysAndTimesMagicIndexes
        inputeventVC.daysAndTimesGroupIndex = daysAndTimesGroupIndex
        self.navigationController?.pushViewController(inputeventVC, animated: true)
        
    }
    
    
    
    func prepareVoteURL() -> URL{
        
        var components = URLComponents(url: mURL,
                resolvingAgainstBaseURL: false)
        
        var endFlag = false
        var meFlag = false
        var startIndex = 0
        var endIndex = 0
        for (index, queryItem) in (components!.queryItems!.enumerated()){
            let name = queryItem.name
            let value = queryItem.value
            
            if name == "endEvent" {
                endFlag = true
            } else if endFlag {
                
                if name == myID && value == "start" {
                    startIndex = index
                    meFlag = true
                } else if name == myID && value == "end" {
                    endIndex = index
                    break
                }
                
            }
        }
        
        var newItems: [URLQueryItem] = []
        for (indexA, voteList) in voteSelections.enumerated(){
            for (_, oneVote) in voteList.enumerated(){
                newItems.append(URLQueryItem(name: String(indexA), value: String(oneVote)))
            }
        }
        
        
        if meFlag {
            newItems = Array((components?.queryItems!)!.prefix(through: startIndex)) + newItems + Array((components?.queryItems!)!.suffix(from: endIndex))
            components?.queryItems = newItems
        } else {
            components?.queryItems! += [URLQueryItem(name: myID, value: "start")] + newItems + [URLQueryItem(name: myID, value: "end")]
        }
        
        return (components?.url!)!
    }
    
    func prepareMessage(_ url: URL) {
        
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }

        let message = MSMessage(session: (conversation.selectedMessage?.session)!)
        

        let messageLayout = MSMessageTemplateLayout()
        
        messageLayout.caption = "Poll for " + loadedEvent.title
        messageLayout.image = UIImage(named: "MessageHeader")
        messageLayout.imageTitle = ""
        messageLayout.imageSubtitle = ""
        messageLayout.trailingCaption = ""
        messageLayout.subcaption = ""
        messageLayout.trailingSubcaption = ""
        
        message.layout = messageLayout
        message.url = url
        message.summaryText = messageSummaryText
        
        conversation.insert(message)
        //conversation.insertText(url.absoluteString)
        self.requestPresentationStyle(.compact)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.compact {
            
        } else if presentationStyle == MSMessagesAppPresentationStyle.expanded {
            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {

        
    }
    
    @objc func sectionHeaderTouchDown(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            
            let shadeView = UIView(frame: CGRect(x: 0, y: 0, width: recognizer.view!.frame.width, height: recognizer.view!.frame.height))
            shadeView.layer.cornerRadius = shadeView.frame.height/2
            shadeView.backgroundColor = Style.greyColor
            shadeView.layer.borderWidth = 3
            shadeView.layer.borderColor = Style.greyColor.cgColor
            shadeView.alpha = 0.5
            recognizer.view!.addSubview(shadeView)
            
        } else if recognizer.state == .ended {
            
            let indexPath = NSIndexPath(row: 0, section: recognizer.view!.tag)
            if (indexPath.row == 0) {
                
                isOpen[indexPath.section] = !isOpen[indexPath.section]
                let range = NSMakeRange(indexPath.section, 1)
                let sectionToReload = NSIndexSet(indexesIn: range)
                voteTable.reloadSections(sectionToReload as IndexSet, with:UITableView.RowAnimation.fade)
                if indexPath.section == daysAndTimesGroupIndex {
                    for (index, _) in daysAndTimesMagicIndexes.enumerated() {
                        (voteTable.cellForRow(at: IndexPath(row: index, section: daysAndTimesGroupIndex)) as? VotingDayAndTimesCell)?.timesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    /*
    @objc func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {

    }
    */
    override func willResignActive(with conversation: MSConversation) {
        self.view.window!.rootViewController?.dismiss(animated: false)
        super.willResignActive(with: conversation)
    }
}

extension VoteViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        voteGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isOpen[section] {
            if voteGroups[section] == "Days and Times" {
                return daysAndTimesMagicIndexes.count
            } else {
                return voteItems[section].count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if voteGroups[indexPath.section] == "Days and Times" {
            let cell = voteTable.dequeueReusableCell(withIdentifier: VotingDayAndTimesCell.reuseIdentifier, for: indexPath) as! VotingDayAndTimesCell
            cell.curView = self
            cell.curIndex = indexPath.row
            var day = loadedEvent.days[indexPath.row]
            cell.dayLabel.text = day.formatDate()
            cell.duration = loadedEvent.duration
            cell.timesCollectionView.reloadData()
            return cell
        }
        let cell = voteTable.dequeueReusableCell(withIdentifier: VoteCell.reuseIdentifier, for: indexPath) as! VoteCell
        let cellView = UIView(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
        cellView.backgroundColor = Style.lightGreyColor
        cell.voteCount.backgroundColor = Style.greyColor
        for selection in voteSelections[indexPath.section] {
            if selection == indexPath.row {
                cellView.backgroundColor = Style.secondaryColor
                cell.voteCount.backgroundColor = Style.primaryColor
            }
        }
        cell.backgroundView = cellView
        cell.label.text = voteItems[indexPath.section][indexPath.row]
        cell.counter.text = String(voteTallies[indexPath.section][indexPath.row])
        let voteMax = voteTallies.reduce(0, {x, y in max(x, y.max()!)}) + 1
        cell.voteCount.frame.size.width = CGFloat(voteTallies[indexPath.section][indexPath.row])/CGFloat(voteMax) * self.view.frame.width * 2/3
        cell.voteCount.frame.size.height = cell.contentView.frame.height - (cellInsets)
        cell.voteCount.layer.cornerRadius = cell.voteCount.frame.height/2
        //cell.voteCount.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let verticalPadding: CGFloat = cellInsets
        let maskLayer = CALayer()
        maskLayer.cornerRadius = cell.layer.cornerRadius
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
}

extension VoteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if voteGroups[indexPath.section] == "Days and Times" {
            // TODO: Maybe make it so that all of the times get selected?
            return
        }
        if voteSelections[indexPath.section].contains(indexPath.row) {
            voteSelections[indexPath.section] = voteSelections[indexPath.section].filter {$0 != indexPath.row}
            voteTallies[indexPath.section][indexPath.row] = voteTallies[indexPath.section][indexPath.row] - 1
        } else {
            if !multiSelectable[indexPath.section] && voteSelections[indexPath.section] != [] {
                voteTallies[indexPath.section][voteSelections[indexPath.section][0]] = voteTallies[indexPath.section][voteSelections[indexPath.section][0]] - 1
                voteSelections[indexPath.section] = []
            }
            voteSelections[indexPath.section].append(indexPath.row)
            voteTallies[indexPath.section][indexPath.row] = voteTallies[indexPath.section][indexPath.row] + 1
        }
        voteTable.reloadSections(IndexSet(integersIn: 0..<voteGroups.count), with: .fade)
        updateSubmitButton()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        voteGroups[section]
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        headerView.layer.cornerRadius = headerView.frame.height/2
        headerView.backgroundColor = Style.primaryColor
        headerView.tag = section
        
        headerView.layer.borderWidth = 3
        headerView.layer.borderColor = Style.secondaryColor.cgColor
        
        let headerString = UILabel(frame: CGRect(x: 13, y: 10, width: tableView.frame.size.width-10, height: 30))
        headerString.text = voteGroups[section]
        headerString.textColor = Style.lightTextColor
        headerView.addSubview(headerString)
        
        
        let headerSelection = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-20, height: 30))
        
        if multiSelectable[section] {
            var selectedItems = [String]()
            for (index, voteItem) in voteItems[section].enumerated() {
                if voteSelections[section].contains(index) {
                    selectedItems.append(voteItem)
                }
            }
            headerSelection.text = Style.commaList(items: selectedItems)//tempText
            
        } else if voteSelections[section] != [] {
            headerSelection.text = voteItems[section][voteSelections[section][0]]
        }
        
        headerSelection.textAlignment = NSTextAlignment.right
        headerView.addSubview(headerSelection)
        
        //let headerTapped = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped))
        //headerView.addGestureRecognizer(headerTapped)
        
        let headerTouchDown = UILongPressGestureRecognizer(target: self, action: #selector(sectionHeaderTouchDown))
        headerTouchDown.minimumPressDuration = 0
        headerView.addGestureRecognizer(headerTouchDown)
        
        return headerView
    }
}

class VotingDayAndTimesCell: UITableViewCell {
    
    var curView: VoteViewController!
    var curIndex: Int!
    
    static let reuseIdentifier = String(describing: VotingDayAndTimesCell.self)
    
    static let cornerRadius: CGFloat = 20
    
    //var times = [(time: Time, isVoted: Bool, votes: Int)]()
    var duration: Duration? = nil
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let timesCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 105, height: 30)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(VotingTimeCell.self, forCellWithReuseIdentifier: VotingTimeCell.reuseIdentifier)
        collectionView.backgroundColor = Style.lightGreyColor
        return collectionView
    }()
    
    // TODO: Add a delete button??
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //self.layer.cornerRadius = self.frame.height / 2
        
        self.backgroundColor = Style.lightGreyColor
        
        contentView.addSubview(timesCollectionView)
        contentView.addSubview(dayLabel)
    
        timesCollectionView.dataSource = self
        timesCollectionView.delegate = self
        timesCollectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let inset: CGFloat = 10

        NSLayoutConstraint.activate([
            dayLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dayLabel.widthAnchor.constraint(equalToConstant: 45),
            
            timesCollectionView.leftAnchor.constraint(equalTo: dayLabel.rightAnchor, constant: 5),
            timesCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            timesCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            timesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        
        timesCollectionView.layer.cornerRadius = 5
    }
}

extension VotingDayAndTimesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let magicIndex = curView.daysAndTimesMagicIndexes[curIndex] + indexPath.row
        let cell = timesCollectionView.dequeueReusableCell(withReuseIdentifier: VotingTimeCell.reuseIdentifier, for: indexPath) as! VotingTimeCell
        cell.timeLabel.text = curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]![indexPath.row].format(duration: nil)
        cell.voteCountLabel.text = String(curView.voteTallies[curView.daysAndTimesGroupIndex][magicIndex])
        if curView.voteSelections[curView.daysAndTimesGroupIndex].contains(magicIndex) {
            cell.backgroundColor = Style.primaryColor
            cell.timeLabel.textColor = Style.lightTextColor
        } else {
            cell.backgroundColor = Style.greyColor
            cell.timeLabel.textColor = UIColor.white
        }
        return cell
    }
    
    
}

/*if voteSelections[indexPath.section].contains(indexPath.row) {
    
    voteSelections[indexPath.section] = voteSelections[indexPath.section].filter {$0 != indexPath.row}
    
    voteTallies[indexPath.section][indexPath.row] = voteTallies[indexPath.section][indexPath.row] - 1
} else {
    
    if !multiSelectable[indexPath.section] && voteSelections[indexPath.section] != [] {
        
        voteTallies[indexPath.section][voteSelections[indexPath.section][0]] = voteTallies[indexPath.section][voteSelections[indexPath.section][0]] - 1
        
        voteSelections[indexPath.section] = []
        
        
    }
    
    voteSelections[indexPath.section].append(indexPath.row)
    voteTallies[indexPath.section][indexPath.row] = voteTallies[indexPath.section][indexPath.row] + 1
}

voteTable.reloadSections(IndexSet(integersIn: 0..<voteGroups.count), with: .fade)*/




/*var voteGroups = ["A", "B", "C", "D (multi-select)"]
var voteItems = [["p", "q"], ["r", "s", "t", "u"], ["x", "y", "z"], ["m", "n", "o", "p"]]
var voteTallies = [[3, 2], [1, 0, 4, 0], [2, 1, 2], [5, 3, 1, 4]]
var isOpen = [false, false, false, false]
var voteSelections = [[], [], [], []] as [[Int]]
var multiSelectable = [false, false, false, true]*/


extension VotingDayAndTimesCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let magicIndex = curView.daysAndTimesMagicIndexes[curIndex] + indexPath.row
        if curView.voteSelections[curView.daysAndTimesGroupIndex].contains(magicIndex) {
            curView.voteSelections[curView.daysAndTimesGroupIndex] = curView.voteSelections[curView.daysAndTimesGroupIndex].filter {$0 != magicIndex}
            curView.voteTallies[curView.daysAndTimesGroupIndex][magicIndex] -= 1
        } else {
            curView.voteSelections[curView.daysAndTimesGroupIndex].append(magicIndex)
            curView.voteTallies[curView.daysAndTimesGroupIndex][magicIndex] += 1
        }
        
        for (index, _) in curView.daysAndTimesMagicIndexes.enumerated() {
            (curView.voteTable.cellForRow(at: IndexPath(row: index, section: curView.daysAndTimesGroupIndex)) as? VotingDayAndTimesCell)?.timesCollectionView.reloadData()
        }
        curView.updateSubmitButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let timeString = curView.loadedEvent.daysAndTimes[curView.loadedEvent.days[curIndex]]![indexPath.row].format(duration: nil)
        return CGSize(width: timeString.size(withAttributes: [NSAttributedString.Key.font : Style.font(size: 18)]).width + timesCollectionView.frame.height + 5, height: timesCollectionView.frame.height)
    }
}

class VotingTimeCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: VotingTimeCell.self)
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Style.font(size: 18)
        return label
    }()
    
    let voteCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Style.lightGreyColor
        label.textColor = Style.greyColor
        label.textAlignment = .center
        label.text = "1"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Apply rounded corners
        self.layer.cornerRadius = 5
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(voteCountLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.contentView.layer.cornerRadius = 5
        
        let inset: CGFloat = 5

        NSLayoutConstraint.activate([
            timeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            voteCountLabel.heightAnchor.constraint(equalToConstant: self.frame.height - (inset * 2)),
            voteCountLabel.widthAnchor.constraint(equalTo: voteCountLabel.heightAnchor),
            voteCountLabel.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: inset),
            voteCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        voteCountLabel.layer.masksToBounds = true
        voteCountLabel.layer.cornerRadius = voteCountLabel.frame.height / 2
    }
}

class VoteCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: VoteCell.self)
    
    let voteCount: UIView = {
        let count = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return count
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.darkTextColor
        return label
    }()
    
    let counter: UILabel = {
        let counter = UILabel()
        counter.translatesAutoresizingMaskIntoConstraints = false
        counter.textColor = Style.darkTextColor
        return counter
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = Style.lightGreyColor
        self.layer.cornerRadius = self.frame.height / 2
        //voteCount.frame.size.height = self.frame.height
        
        self.contentView.addSubview(voteCount)
        self.contentView.addSubview(label)
        self.contentView.addSubview(counter)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = CGFloat(20)

        NSLayoutConstraint.activate([
            voteCount.leftAnchor.constraint(equalTo: leftAnchor),
            voteCount.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            
            counter.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            counter.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}

protocol VoteViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: VoteViewController)
    
}
