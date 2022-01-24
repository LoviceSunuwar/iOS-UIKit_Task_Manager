//
//  AddEditViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 19/01/2022.
//

import UIKit
import CoreData
import AVFoundation

class AddEditViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addAudioSection: UIStackView!
    @IBOutlet weak var addAudioButton: UIButton!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var saveAudioButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var cancelAudioButton: UIButton!
    @IBOutlet var recordingTimeLabel: UILabel!
    @IBOutlet weak var displayAudio: UIStackView!
    @IBOutlet weak var audioName: UILabel!
    @IBOutlet weak var playSavedAudio: UIButton!
    @IBOutlet weak var addSubTaskSection: UIStackView!
    @IBOutlet weak var subtaskTV: UITableView!
    
    // For Audio Recorder and Player
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    var recordingUrl:URL!;
    
    
    //    var category = [Category]()
    var selectedCategory: Category!
    var subTaskList = [SubTask]()
    
    var task: Task! = nil
    var taskList = [Task]()
    
    var images: [Data] = []
    var imagePicker: ImagePicker?
    
    var loadTask:(()->())?
    
    var audio = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addAudioSection.isHidden = true
        displayAudio.isHidden = true
        setupCollectionView()
        setupTableView()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = (task != nil ? "Edit" : "Add") + " Task"
    }
    
    func setupData() {
        if task != nil {
            getSubTask()
            taskTitleTextField.text = task!.title
            subtaskTV.isHidden = subTaskList.count < 1
            //            let categoryIndex = category.firstIndex(of: task.category!)!
            //            pickerView.selectRow(categoryIndex, inComponent: 0, animated: true)
            self.images = task.images!
            createButton.setTitle("Update", for: .normal)
            datePicker.date = task.endDate!.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss Z") ?? Date()
            self.title = "Update Task"
            if task.audio != nil {
                recordingUrl =  URL(fileURLWithPath: task.audio!)
                addAudioButton.isHidden = true
                displayAudio.isHidden = false
                audioName.text = "\(task.audio?.split(separator: "/").last ?? "")"
            }
            
        } else {
            createButton.setTitle("Create", for: .normal)
            self.title = "Add Task"
            subtaskTV.isHidden = true
            addSubTaskSection.isHidden = true
        }
        
        
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupTableView() {
        subtaskTV.dataSource = self
        subtaskTV.delegate = self
    }
    
    func reloadCollectionView() {
        self.collectionView.reloadData()
    }
    
    // MARK: @IBAction
    @IBAction func createButtonHandler(_ sender: UIButton) {
        guard let title = taskTitleTextField.text, !title.isEmpty else {
            self.alert(message: "Title is required", title: "Alert", okAction: nil)
            return
        }
        
        if task == nil {
            let newTask = Task(context: context)
            newTask.title = title
            newTask.category = selectedCategory
            newTask.createdDate = "\(Date())"
            newTask.endDate = "\(datePicker.date)"
            newTask.images = images
            newTask.isCompleted = false
            if recordingUrl != nil {
                newTask.audio = recordingUrl.path
            }
            
            appDelegate.saveContext()
            self.loadTask?()
        } else {
            task.title = title
            task.category = selectedCategory
            task.endDate = "\(datePicker.date)"
            task.images = images
            if recordingUrl != nil {
                task.audio = recordingUrl.path
                
            }
            appDelegate.saveContext()
            self.loadTask?()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addSubTask(_ sender: UIButton) {
        saveSubTask(subtask: nil, index: nil)
        subtaskTV.isHidden = false
    }
    
    @IBAction func addAudio(_ sender: UIButton) {
        if !taskTitleTextField.text!.isEmpty {
            checkRecordPermission()
            addAudioSection.isHidden = sender != addAudioButton
            addAudioButton.isHidden = sender == addAudioButton
            saveAudioButton.isHidden = sender == addAudioButton
            if sender == cancelAudioButton {
                saveAudioButton.isHidden = true
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                if isRecording {
                    audioRecorder.stop()
                }
                
                if isPlaying {
                    audioPlayer.stop()
                }
            }
        } else {
            self.alert(message: "Title is required", title: "Alert", okAction: nil)
        }
        
    }
    
    @IBAction func recordingHandler(_ sender: UIButton) {
        
        if(isRecording) {
            finishAudioRecording(success: true)
            recordingButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            recordingButton.tintColor = .systemRed
            recordingButton.setTitle("", for: .normal)
            playButton.isEnabled = true
            isRecording = false
            saveAudioButton.isEnabled = true
            saveAudioButton.isHidden = false
        } else {
            recordingButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            recordingButton.tintColor = .black
            
            setupRecorder()
            
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            playButton.isEnabled = false
            saveAudioButton.isEnabled = false
            isRecording = true
        }
    }
    
    @IBAction func saveAudio(_ sender: UIButton) {
        addAudioSection.isHidden = true
        displayAudio.isHidden = false
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        if(isPlaying)
        {
            audioPlayer.stop()
            recordingButton.isEnabled = true
            saveAudioButton.isEnabled = true
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playSavedAudio.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlaying = false
        }
        else
        {
            if FileManager.default.fileExists(atPath: recordingUrl.path)
            {
                recordingButton.isEnabled = false
                saveAudioButton.isEnabled = false
                playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                playSavedAudio.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                preparePlay()
                audioPlayer.play()
                isPlaying = true
            }
            else
            {
                alert(message: "Audio file is missing.", title: "Error", okAction: nil)
            }
        }
    }
    
    @IBAction func deleteAudio(_ sender: UIButton) {
        recordingUrl = nil;
        addAudioButton.isHidden = false
        
        
        UIView.animate(withDuration: 0.25) {
            self.displayAudio.isHidden = true
        }
    }
    
    // MARK: Custom Functions
    func alert(message: String?, title: String? = nil, okAction: (()->())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            okAction?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveSubTask(subtask: SubTask!, index: Int!) {
        var subtaskTitle = UITextField()
        let isEdit = subtask != nil
        let alert = UIAlertController(title: (!isEdit ? "Add" : "Edit") + " Subtask", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: (!isEdit ? "Add" : "Edit"), style: .default) { (action) in
            if !subtaskTitle.text!.isEmpty {
                if !isEdit {
                    if self.subTaskList.first(where: {$0.title == subtaskTitle.text}) == nil {
                        let newSubtask = SubTask(context: context)
                        newSubtask.title = subtaskTitle.text
                        newSubtask.parentTask = self.task
                        newSubtask.isCompleted = false
                        self.task.isCompleted = false
                        self.subTaskList.append(newSubtask)
                        
                    } else {
                        self.alert(message: "Subtask already exists", title: nil, okAction: nil)
                    }
                } else {
                    subtask.title = subtaskTitle.text
                    self.subTaskList[index] = subtask
                }
                appDelegate.saveContext()
                self.subtaskTV.reloadData()
                self.loadTask?()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            subtaskTitle = field
            subtaskTitle.placeholder = "Subtask"
            if isEdit {
                subtaskTitle.text = subtask.title
            }
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Core Data Methods
    func getSubTask(){
        if task != nil {
            let request: NSFetchRequest<SubTask> = SubTask.fetchRequest()
            do {
                let subTasks = try context.fetch(request)
                subTaskList = subTasks.filter({ (task) -> Bool in
                    return task.parentTask == self.task
                })
            } catch {
                print("Error loading tasks ",error.localizedDescription)
            }
        }
    }
    
    // MARK: Audio Methods
    func checkRecordPermission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL
    {
        let filename = taskTitleTextField.text! + "-audio" + ".m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        audioName.text = filename
        return filePath
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                recordingUrl = getFileUrl()
                audioRecorder = try AVAudioRecorder(url: recordingUrl, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                alert(message: error.localizedDescription, title: "Error", okAction: nil)
            }
        }
        else {
            alert(message: "Don't have access to use your microphone.", title: "Error", okAction: nil)
        }
    }
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingButton.setTitle(totalTimeString, for: .normal)
            audioRecorder.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool) {
        if success {
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
        }
        else {
            alert(message: "Recording failed.", title: "Error", okAction: nil)
        }
    }
    
    func preparePlay() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordingUrl)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch{
            print("Error")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag
        {
            finishAudioRecording(success: false)
        }
        playButton.isEnabled = true
        saveAudioButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordingButton.isEnabled = true
        saveAudioButton.isEnabled = true
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playSavedAudio.setImage(UIImage(systemName: "play.fill"), for: .normal)
        isPlaying = false
    }
}

// MARK: For Collection View START
extension AddEditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        
        if images.count != indexPath.row {
            //not a last index
            cell.image = images[indexPath.row]
            cell.deleteButton.isHidden = false
            cell.deleteButtonTapped = {
                let deleteActionSheetController = UIAlertController(title: "Alert", message: "Are you sure you want to delete?", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                    self.images.remove(at: indexPath.row)
                    self.reloadCollectionView()
                }
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                    
                }
                
                deleteActionSheetController.addAction(deleteAction)
                deleteActionSheetController.addAction(cancelAction)
                
                self.present(deleteActionSheetController, animated: true, completion: nil)
            }
        } else {
            // last index add button should be shown
            cell.setupEmptyData()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if images.count == indexPath.row {
            // add new image
            imagePicker = ImagePicker(presentationController: self)
            imagePicker?.present(from: self.view)
            imagePicker?.completion = { [weak self] selectedImage in
                guard let self = self else { return }
                let imageData = selectedImage.jpegData(compressionQuality: 0.8)!
                self.images.append(imageData)
                self.reloadCollectionView()
            }
        }
    }
    
    
}

extension AddEditViewController: UICollectionViewDelegateFlowLayout {
    // Define size of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height
        return CGSize(width: height, height: height) // square cell
    }
    
    // Padding for inner view in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

extension UICollectionView {
    
    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }
    
}
// For Collection View END

// MARK: UITableViewDelegate
extension AddEditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: UITableViewDataSource
extension AddEditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTaskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = subTaskList[indexPath.row]
        let cell = subtaskTV.dequeueReusableCell(withIdentifier: "subtaskCell", for: indexPath) as! SubtaskTableViewCell
        cell.setCell(obj: obj)
        
        cell.radioButtonTapped = {
            obj.isCompleted = !obj.isCompleted
            appDelegate.saveContext()
            self.subtaskTV.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveSubTask(subtask: subTaskList[indexPath.row], index: indexPath.row)
        
    }
    
    
}

