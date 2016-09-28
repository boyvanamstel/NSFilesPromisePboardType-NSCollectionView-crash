Implementing drag-drop from an NSCollectionView with a NSFilesPromisePboardType causes some unexpected behaviour when used on macOS Sierra and El Capitan. The implementation that works for macOS Sierra, crashes on El Capitan.

I've used [the SlidesMagic NSCollectionView project from Ray Wendelich(https://www.raywenderlich.com/120494/collection-views-os-x-tutorial) as a base for this project.

The project contains various setups that can be used for testing in `ViewController.swift`.

## Steps to Reproduce:

* Setup the NSCollectionView to allow content to be dragged from the grid.

```Swift
override func viewDidLoad() {
  super.viewDidLoad()
  collectionView.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
}

extension ViewController : NSCollectionViewDelegate {

  [...]

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

}

* Compile the project and deploy it to a Mac running macOS El Capitan and one running macOS Sierra.

* Try dragging one of the images from the NSCollectionView onto your Desktop, or a Finder window.

* Drop the item.

## Expected Results:

* The application should indicate that the item is draggable and show its intent to drop.

* After dropping, nothing much should happen, but the app should keep running.

## Actual Results:

### On Sierra

The app keeps running.

### On El Capitan

The app crashes, taking Finder with it, with the following crash report:

```
Process:               SlidesMagic [913]
Path:                  /Users/USER/Desktop/SlidesMagic.app/Contents/MacOS/SlidesMagic
Identifier:            com.razeware.SlidesMagic
Version:               1.0 (1)
Code Type:             X86-64 (Native)
Parent Process:        ??? [1]
Responsible:           SlidesMagic [913]
User ID:               501

Date/Time:             2016-09-28 11:35:18.315 +0200
OS Version:            Mac OS X 10.11.6 (15G31)
Report Version:        11
Anonymous UUID:        E2E828C4-F4C1-2EE0-6239-2E04C93C5A34

Sleep/Wake UUID:       FF367448-5269-4753-9E1F-5EA813163500

Time Awake Since Boot: 7300 seconds

System Integrity Protection: enabled

Crashed Thread:        0  Dispatch queue: com.apple.main-thread

Exception Type:        EXC_BAD_INSTRUCTION (SIGILL)
Exception Codes:       0x0000000000000001, 0x0000000000000000
Exception Note:        EXC_CORPSE_NOTIFY

[...]

Thread 0 Crashed:: Dispatch queue: com.apple.main-thread
0   libswiftFoundation.dylib        0x000000010bf5b353 _TZFV10Foundation8IndexSet36_unconditionallyBridgeFromObjectiveCfGSqCSo10NSIndexSet_S0_ + 307
1   SlidesMagic                     0x000000010b910b15 _TToFC11SlidesMagic14ViewController14collectionViewfTCSo16NSCollectionView40namesOfPromisedFilesDroppedAtDestinationV10Foundation3URL17forDraggedItemsAtVS2_8IndexSet_GSaSS_ + 101
2   com.apple.AppKit                0x00007fff8b5e0f75 -[NSCollectionView namesOfPromisedFilesDroppedAtDestination:] + 100
3   com.apple.AppKit                0x00007fff8b56024d -[NSFilePromiseDragSource getFilenamesAndDropLocation] + 70
4   com.apple.AppKit                0x00007fff8b0b9923 -[NSFilePromiseDragSource pasteboard:provideDataForType:itemIdentifier:] + 79
5   com.apple.AppKit                0x00007fff8b0b83e7 __NSPasteboardProvideData + 331
6   com.apple.CoreFoundation        0x00007fff94f3cc04 __CFPasteboardClientCallBack + 1364
7   com.apple.CoreFoundation        0x00007fff94f18628 __CFMessagePortPerform + 584
8   com.apple.CoreFoundation        0x00007fff94e80019 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 41
9   com.apple.CoreFoundation        0x00007fff94e7ff89 __CFRunLoopDoSource1 + 473
10  com.apple.CoreFoundation        0x00007fff94e779bb __CFRunLoopRun + 2171
11  com.apple.CoreFoundation        0x00007fff94e76ed8 CFRunLoopRunSpecific + 296
12  com.apple.CoreFoundation        0x00007fff94edc925 CFMessagePortSendRequest + 949
13  com.apple.HIServices            0x00007fff9330e7dc SendDragIPCMessage + 530
14  com.apple.HIServices            0x00007fff93306b29 SendDropMessage + 64
15  com.apple.HIServices            0x00007fff93305807 DragInApplication + 505
16  com.apple.HIServices            0x00007fff933046cf CoreDragStartDragging + 705
17  com.apple.AppKit                0x00007fff8b01f369 -[NSCoreDragManager _dragUntilMouseUp:accepted:] + 1010
18  com.apple.AppKit                0x00007fff8b01c557 -[NSCoreDragManager dragImage:fromWindow:at:offset:event:pasteboard:source:slideBack:] + 1212
19  com.apple.AppKit                0x00007fff8b01c089 -[NSWindow(NSDrag) dragImage:at:offset:event:pasteboard:source:slideBack:] + 135
20  com.apple.AppKit                0x00007fff8b5e1543 -[NSCollectionView _startDragWithItemsAtIndexPaths:event:pasteboard:] + 345
21  com.apple.AppKit                0x00007fff8b5e178a -[NSCollectionView _writeToPasteboardAndBeginDragForIndexPaths:event:] + 182
22  com.apple.AppKit                0x00007fff8b45559f -[NSCollectionViewMouseSession _performDragFromMouseDown:] + 774
23  com.apple.AppKit                0x00007fff8b455c5e -[NSCollectionViewMouseSession handleEvent:] + 927
24  com.apple.AppKit                0x00007fff8b45644d -[NSCollectionViewMouseSession trackWithEvent:] + 132
25  com.apple.AppKit                0x00007fff8b5e0724 -[NSCollectionView mouseDown:] + 213
26  com.apple.AppKit                0x00007fff8aeed634 forwardMethod + 126
27  com.apple.AppKit                0x00007fff8aeed634 forwardMethod + 126
28  com.apple.AppKit                0x00007fff8aeed634 forwardMethod + 126
29  com.apple.AppKit                0x00007fff8afdbc8e -[NSControl mouseDown:] + 1091
30  com.apple.AppKit                0x00007fff8b5303c9 -[NSWindow _handleMouseDownEvent:isDelayedEvent:] + 6322
31  com.apple.AppKit                0x00007fff8b5313ad -[NSWindow _reallySendEvent:isDelayedEvent:] + 212
32  com.apple.AppKit                0x00007fff8af70539 -[NSWindow sendEvent:] + 517
33  com.apple.AppKit                0x00007fff8aef0a38 -[NSApplication sendEvent:] + 2540
34  com.apple.AppKit                0x00007fff8ad57df2 -[NSApplication run] + 796
35  com.apple.AppKit                0x00007fff8ad21368 NSApplicationMain + 1176
36  SlidesMagic                     0x000000010b916cb4 main + 84
37  libdyld.dylib                   0x00007fff975f25ad start + 1
```
