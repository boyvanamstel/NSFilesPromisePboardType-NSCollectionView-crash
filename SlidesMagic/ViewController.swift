/*
 * ViewController.swift
 * SlidesMagic
 *
 * Created by Gabriel Miro on 7/11/15.
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Cocoa

class ViewController: NSViewController {
  
  @IBOutlet weak var collectionView: NSCollectionView!
  
  let imageDirectoryLoader = ImageDirectoryLoader()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let initialFolderUrl = URL(fileURLWithPath: "/Library/Desktop Pictures", isDirectory: true)
    imageDirectoryLoader.loadDataForFolderWithUrl(initialFolderUrl)
    configureCollectionView()
  }
  
  func loadDataForNewFolderWithUrl(_ folderURL: URL) {
    imageDirectoryLoader.loadDataForFolderWithUrl(folderURL)
    collectionView.reloadData()
  }
  
  fileprivate func configureCollectionView() {
    // 1
    let flowLayout = NSCollectionViewFlowLayout()
    flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
    flowLayout.sectionInset = EdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0)
    flowLayout.minimumInteritemSpacing = 20.0
    flowLayout.minimumLineSpacing = 20.0
    collectionView.collectionViewLayout = flowLayout
    view.wantsLayer = true
    collectionView.layer?.backgroundColor = NSColor.black.cgColor
    
    // Drag drop
    collectionView.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
  }
  
  // 1
  @IBAction func showHideSections(_ sender: AnyObject) {
    let show = (sender as! NSButton).state
    imageDirectoryLoader.singleSectionMode = (show == NSOffState)
    imageDirectoryLoader.setupDataForUrls(nil)
    collectionView.reloadData()
  }
  
}

extension ViewController : NSCollectionViewDataSource {
  
  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    return imageDirectoryLoader.numberOfSections
  }
  
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageDirectoryLoader.numberOfItemsInSection(section)
  }
  
  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    
    let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
    guard let collectionViewItem = item as? CollectionViewItem else {return item}
    
    let imageFile = imageDirectoryLoader.imageFileForIndexPath(indexPath)
    collectionViewItem.imageFile = imageFile
    
    if let selectedIndexPath = collectionView.selectionIndexPaths.first , selectedIndexPath == indexPath {
      collectionViewItem.setHighlight(true)
    } else {
      collectionViewItem.setHighlight(false)
    }
    
    return item
  }
  
  func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
    let view = collectionView.makeSupplementaryView(ofKind: NSCollectionElementKindSectionHeader, withIdentifier: "HeaderView", for: indexPath) as! HeaderView
    view.sectionTitle.stringValue = "Section \((indexPath as NSIndexPath).section)"
    let numberOfItemsInSection = imageDirectoryLoader.numberOfItemsInSection((indexPath as NSIndexPath).section)
    view.imageCount.stringValue = "\(numberOfItemsInSection) image files"
    return view
  }
  
}

extension ViewController : NSCollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
    return imageDirectoryLoader.singleSectionMode ? NSZeroSize : NSSize(width: 1000, height: 40)
  }
  
}

extension ViewController : NSCollectionViewDelegate {
  
  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else {return}
    guard let item = collectionView.item(at: indexPath) else {return}
    (item as! CollectionViewItem).setHighlight(true)
  }
  
  func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else {return}
    guard let item = collectionView.item(at: indexPath) else {return}
    (item as! CollectionViewItem).setHighlight(false)
  }
  
  ////////////////////
  //
  // Working setup for Sierra. Drag-drop does not work on El Capitan.
  //
  // writeItemsAt indexPaths & forDraggedItemsAt indexPaths
  //
  ////////////////////
  
//  func collectionView(_ collectionView: NSCollectionView, writeItemsAt indexPaths: Set<IndexPath>, to pasteboard: NSPasteboard) -> Bool {
//    pasteboard.clearContents()
//    pasteboard.declareTypes([NSFilesPromisePboardType], owner: self)
//    pasteboard.setPropertyList(["jpg"], forType: NSFilesPromisePboardType)
//    return true
//  }
//
//  func collectionView(_ collectionView: NSCollectionView, namesOfPromisedFilesDroppedAtDestination dropURL: URL, forDraggedItemsAt indexPaths: Set<IndexPath>) -> [String] {
//    
//    // Write to file
//    
//    return [dropURL.appendingPathComponent("test.jpg").absoluteString]
//  }

  ////////////////////
  //
  // Crashes on both Sierra and El Capitan. Takes Finder with it, needing Relaunch.
  //
  // writeItemsAt indexes & forDraggedItemsAt indexes
  //
  ////////////////////

//  func collectionView(_ collectionView: NSCollectionView, writeItemsAt indexPaths: Set<IndexPath>, to pasteboard: NSPasteboard) -> Bool {
//    pasteboard.clearContents()
//    pasteboard.declareTypes([NSFilesPromisePboardType], owner: self)
//    pasteboard.setPropertyList(["jpg"], forType: NSFilesPromisePboardType)
//    return true
//  }
//
//  // Required by El Capitan, but crashes after drop
//  func collectionView(_ collectionView: NSCollectionView, namesOfPromisedFilesDroppedAtDestination dropURL: URL, forDraggedItemsAt indexes: IndexSet) -> [String] {
//    
//    // Write to file
//    
//    return [dropURL.appendingPathComponent("test.jpg").absoluteString]
//  }

  ////////////////////
  //
  // Works on Sierra, crashes on El Capitan. Takes Finder with it, needs Relaunch.
  //
  // writeItemsAt indexes & forDraggedItemsAt indexes & forDraggedItemsAt indexPaths
  //
  ////////////////////
  
  func collectionView(_ collectionView: NSCollectionView, writeItemsAt indexPaths: Set<IndexPath>, to pasteboard: NSPasteboard) -> Bool {
    pasteboard.clearContents()
    pasteboard.declareTypes([NSFilesPromisePboardType], owner: self)
    pasteboard.setPropertyList(["jpg"], forType: NSFilesPromisePboardType)
    return true
  }
  
  func collectionView(_ collectionView: NSCollectionView, namesOfPromisedFilesDroppedAtDestination dropURL: URL, forDraggedItemsAt indexPaths: Set<IndexPath>) -> [String] {
    
    // Write to file
    
    return [dropURL.appendingPathComponent("test.jpg").absoluteString]
  }

  // Seems redundant, but it's required by El Capitan. It causes a crash when running on El Capitan.
  func collectionView(_ collectionView: NSCollectionView, namesOfPromisedFilesDroppedAtDestination dropURL: URL, forDraggedItemsAt indexes: IndexSet) -> [String] {
    
    // Write to file
    
    return [dropURL.appendingPathComponent("test.jpg").absoluteString]
  }
  
  ////////////////////
  //
  // Other
  //
  ////////////////////

  // Not called on Sierra nor El Capitan
//  func collectionView(_ collectionView: NSCollectionView, writeItemsAt indexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {
//    pasteboard.clearContents()
//    pasteboard.declareTypes([NSFilesPromisePboardType], owner: self)
//    pasteboard.setPropertyList(["jpg"], forType: NSFilesPromisePboardType)
//    return true
//  }

  // Makes no difference
//  override func namesOfPromisedFilesDropped(atDestination dropDestination: URL) -> [String]? {
//    return ["test.jpg"]
//  }
  
}

