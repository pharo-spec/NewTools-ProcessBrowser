Class {
	#name : 'StProcessBrowser',
	#superclass : 'StPresenter',
	#instVars : [
		'processListPresenter',
		'stackListPresenter',
		'codePresenter',
		'model',
		'processToolbarActions',
		'processToolbarPresenter',
		'generalToolbarPresenter',
		'generalToolbarActions',
		'contextToolbarActions'
	],
	#category : 'NewTools-ProcessBrowser',
	#package : 'NewTools-ProcessBrowser'
}

{ #category : 'accessing' }
StProcessBrowser class >> defaultExtent [

	^ 800@550
]

{ #category : 'instance creation' }
StProcessBrowser class >> open [
	<script>
	
	^ self new open
]

{ #category : 'accessing' }
StProcessBrowser class >> title [

	^ 'Process Browser'
]

{ #category : 'actions' }
StProcessBrowser >> browseSelectedContext [

	self flag: #TODO
]

{ #category : 'private' }
StProcessBrowser >> buildContextToolbarActions [

	^ SpActionGroup new
		addActionWith: [ :action | action 
			name: 'Inspect';
			iconName: #smallInspectIt;
			description: 'Inspect selected context.';
			shortcut: $i actionModifier;
			action: [ self inspectSelectedContext ] ];
		addActionWith: [ :action | action 
			name: 'Browse';
			iconName: #smallSystemBrowser;
			description: 'Browse context.';
			shortcut: $b actionModifier;
			action: [ self browseSelectedContext ] ];
		yourself
]

{ #category : 'private' }
StProcessBrowser >> buildGeneralToolbarActions [
	
	^ SpActionGroup new
		addActionWith: [ :action | action 
			name: 'CPU Watcher';
			iconName: #watch;
			description: 'Toggle CPU watcher.';
			beToggleButton; 
			action: [ self toggleCPUWatcher: action presenter state ] ];
		addActionWith: [ :action | action 
			name: 'Auto update';
			iconName: #autoUpdate;
			description: 'Toggle auto processes update.';
			beToggleButton;
			action: [ self toggleAutoUpdate: action presenter state ] ];
		addActionWith: [ :action | action 
			name: 'Refresh';
			iconName: #refresh;
			description: 'Refresh list of process.'; 
			action: [ self refreshProcessList ] ];
		yourself
]

{ #category : 'private' }
StProcessBrowser >> buildProcessToolbarActions [

	^ SpActionGroup new
		addActionWith: [ :action | action 
			name: 'Terminate';
			iconName: #stop; 
			description: 'Terminate selected process.';
			shortcut: $t actionModifier;
			action: [ self terminateSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		addActionWith: [ :action | action 
			name: 'Suspend';
			iconName: #pause; 
			description: 'Suspend selected process.';
			shortcut: $s actionModifier;
			action: [ self suspendSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		addActionWith: [ :action | action 
			name: 'Priority';
			iconName: #priority; 
			description: 'Change priority of selected process.';
			shortcut: $p actionModifier;
			action: [ self changePriorityOfSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		addActionWith: [ :action | action 
			name: 'Debug';
			iconName: #smallDebug; 
			description: 'Debug selected process.';
			shortcut: $d actionModifier;
			action: [ self debugSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		addActionWith: [ :action | action 
			name: 'Profile';
			iconName: #smallProfile; 
			description: 'Profile selected process.';
			action: [ self profileSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		addActionWith: [ :action | action 
			name: 'Inspect';
			iconName: #smallInspectIt;
			description: 'Inspect selected process.';
			shortcut: $i actionModifier;
			action: [ self inspectSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		yourself
]

{ #category : 'actions' }
StProcessBrowser >> changePriorityOfSelectedProcess [

	self flag: #TODO.
]

{ #category : 'initialization' }
StProcessBrowser >> connectPresenters [

	processListPresenter outputActivationPort
		transmitTo: stackListPresenter defaultInputPort
			transform: [ :aProcess | self model stackListFor: aProcess ].
			
	processListPresenter outputSelectionPort 
		transmitDo: [ self updateToolbar ].
		
	stackListPresenter outputActivationPort
		transmitDo: [ :aContext | self updateCodeFromContext: aContext ]
]

{ #category : 'private - accessing' }
StProcessBrowser >> contextToolbarActions [
	
	^ contextToolbarActions ifNil: [ contextToolbarActions := self buildContextToolbarActions ]
]

{ #category : 'actions' }
StProcessBrowser >> debugSelectedProcess [

	self flag: #TODO.
]

{ #category : 'api - focus' }
StProcessBrowser >> defaultKeyboardFocus [

	^ processListPresenter 
]

{ #category : 'layout' }
StProcessBrowser >> defaultLayout [

	^ SpBoxLayout newTopToBottom 
		add: (SpBoxLayout newLeftToRight 
				add: processToolbarPresenter;
				add: generalToolbarPresenter expand: false;
				yourself) 
			expand: false;
		add: (SpPanedLayout newTopToBottom
			"positionOfSlider: (self class defaultExtent y / 2) asInteger;"
			add: (SpPanedLayout newLeftToRight
				add: processListPresenter;
				add: stackListPresenter;
				yourself);
			add: codePresenter;
			yourself);
		yourself
]

{ #category : 'initialization' }
StProcessBrowser >> displayForContext: aContext [
	
	^ aContext method printString lines first
]

{ #category : 'initialization' }
StProcessBrowser >> displayForProcess: aProcess [
	
	^ '({1}) {2}' format: { aProcess priority. aProcess name }
]

{ #category : 'private' }
StProcessBrowser >> ensureAllWatchersAreClosed [

	self flag: #TODO. "This is to cleanup the processes for watching/auto-update"
]

{ #category : 'private - accessing' }
StProcessBrowser >> generalToolbarActions [	
	
	^ generalToolbarActions	 ifNil: [ generalToolbarActions := self buildGeneralToolbarActions ]
]

{ #category : 'initialization' }
StProcessBrowser >> initializePresenters [

	(processToolbarPresenter := self newToolbar)
		displayMode: self application toolbarDisplayMode;
		addStyle: 'stToolbar';
		fillWith: self processToolbarActions.

	(generalToolbarPresenter := self newToolbar)
		displayMode: self application toolbarDisplayMode;
		addStyle: 'stToolbar';
		fillWith: self generalToolbarActions.
			
	(processListPresenter := self newEasyListView)
		activateOnSingleClick;
		addActionGroup: self processToolbarActions;
		display: [ :aProcess | self displayForProcess: aProcess ].

	(stackListPresenter := self newEasyListView)
		activateOnSingleClick;
		addActionGroup: self contextToolbarActions;
		display: [ :aContext | self displayForContext: aContext ].
	
	codePresenter := self newCode.
	codePresenter enabled: false
]

{ #category : 'initialization' }
StProcessBrowser >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: self class title;
		initialExtent: self class defaultExtent;
		whenClosedDo: [ self ensureAllWatchersAreClosed ]
]

{ #category : 'actions' }
StProcessBrowser >> inspectSelectedContext [

	self flag: #TODO
]

{ #category : 'actions' }
StProcessBrowser >> inspectSelectedProcess [
	| process |

	(process := self selectedProcess) ifNil: [ ^ self ].
	process inspect
]

{ #category : 'accessing - model' }
StProcessBrowser >> model [

	^ model ifNil: [ model := StProcessBrowserModel new ]
]

{ #category : 'private - accessing' }
StProcessBrowser >> processToolbarActions [
	
	^ processToolbarActions ifNil: [ processToolbarActions := self buildProcessToolbarActions ]
]

{ #category : 'actions' }
StProcessBrowser >> profileSelectedProcess [

	self flag: #TODO.
]

{ #category : 'actions' }
StProcessBrowser >> refreshProcessList [

	self model updateProcessList.
	processListPresenter updateItemsKeepingSelection: self model processList
]

{ #category : 'private - accessing' }
StProcessBrowser >> selectedContext [

	^ stackListPresenter selectedItem
]

{ #category : 'private - accessing' }
StProcessBrowser >> selectedProcess [

	^ processListPresenter selectedItem
]

{ #category : 'actions' }
StProcessBrowser >> suspendSelectedProcess [
	| process |

	(process := self selectedProcess) ifNil: [ ^ self ].
	process suspend.
	self updatePresenter

]

{ #category : 'actions' }
StProcessBrowser >> terminateSelectedProcess [
	| process |

	(process := self selectedProcess) ifNil: [ ^ self ].
	process terminate.
	self updatePresenter

]

{ #category : 'actions' }
StProcessBrowser >> toggleAutoUpdate: aBoolean [

	aBoolean crTrace
]

{ #category : 'actions' }
StProcessBrowser >> toggleCPUWatcher: aBoolean [

	aBoolean crTrace
]

{ #category : 'initialization' }
StProcessBrowser >> updateCodeFromContext: aContext [

	aContext ifNil: [ 
		codePresenter
			clearInteractionModel;
			text: ''; 
			enabled: false.
		^ self ].
	
	codePresenter
		enabled: true;
		beForMethod: aContext method;
		text: aContext method sourceCode
]

{ #category : 'initialization' }
StProcessBrowser >> updatePresenter [

	self model ifNil: [ ^ self ].
	processListPresenter items: self model processList.
	self updateToolbar
]

{ #category : 'private - updating' }
StProcessBrowser >> updateToolbar [

	self processToolbarActions allCommands
		do: [ :each | each updateEnableStatus ]
]
