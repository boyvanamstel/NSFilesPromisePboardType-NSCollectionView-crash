//
//  CollectionViewItem.swift
//  SlidesMagic
//
//  Created by Gabriel Miro on 28/11/15.
//  Copyright © 2015 razeware. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
  
  // 1
  var imageFile: ImageFile? {
    didSet {
      guard isViewLoaded else { return }
      if let imageFile = imageFile {
        imageView?.image = imageFile.thumbnail
        textField?.stringValue = imageFile.fileName
      } else {
        imageView?.image = nil
        textField?.stringValue = ""
      }
    }
  }
  
  // 2
  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.lightGray.cgColor
    // 1
    view.layer?.borderWidth = 0.0
    // 2
    view.layer?.borderColor = NSColor.white.cgColor  }
  
  func setHighlight(_ selected: Bool) {
    view.layer?.borderWidth = selected ? 5.0 : 0.0
  }
  
}
