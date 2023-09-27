Class {
	#name : #StProcessBrowser,
	#superclass : #StPresenter,
	#instVars : [
		'processListPresenter',
		'stackListPresenter',
		'codePresenter',
		'model',
		'processToolbarActions',
		'processToolbarPresenter',
		'generalToolbarPresenter',
		'generalToolbarActions'
	],
	#category : #'NewTools-ProcessBrowser'
}

{ #category : #accessing }
StProcessBrowser class >> defaultExtent [

	^ 800@550
]

{ #category : #'instance creation' }
StProcessBrowser class >> open [
	<script>
	
	^ self new open
]

{ #category : #accessing }
StProcessBrowser class >> title [

	^ 'Process Browser'
]

{ #category : #private }
StProcessBrowser >> buildGeneralToolbarActions [
	
	^ SpActionGroup new
		addActionWith: [ :action | action 
			name: 'Refresh';
			iconName: #refresh;
			description: 'Refresh list of process.'; 
			action: [ self refreshProcessList ] ];
		yourself
]

{ #category : #private }
StProcessBrowser >> buildProcessToolbarActions [

	^ SpActionGroup new
		addActionWith: [ :action | action 
			name: 'Terminate';
			iconName: #stop; 
			description: 'Terminate selected process.';
			action: [ self terminateSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		addActionWith: [ :action | action 
			name: 'Suspend';
			iconName: #pause; 
			description: 'Suspend selected process.';
			action: [ self suspendSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		addActionWith: [ :action | action 
			name: 'Inspect';
			iconName: #smallInspectIt;
			description: 'Inspect selected process.';
			action: [ self inspectSelectedProcess ];
			actionEnabled: [ self selectedProcess notNil ] ];
		yourself
]

{ #category : #initialization }
StProcessBrowser >> connectPresenters [

	processListPresenter 
		transmitTo: stackListPresenter
		transform: [ :aProcess | self model stackListFor: aProcess ].
		
	processListPresenter 
		transmitDo: [ self updateToolbar ].
		
	stackListPresenter 
		transmitDo: [ :aContext | self updateCodeFromContext: aContext ]
]

{ #category : #layout }
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

{ #category : #initialization }
StProcessBrowser >> displayForContext: aContext [
	
	^ aContext method printString lines first
]

{ #category : #initialization }
StProcessBrowser >> displayForProcess: aProcess [
	
	^ '({1}) {2}' format: { aProcess priority. aProcess name }
]

{ #category : #'private - accessing' }
StProcessBrowser >> generalToolbarActions [	
	
	^ generalToolbarActions	 ifNil: [ generalToolbarActions := self buildGeneralToolbarActions ]
]

{ #category : #initialization }
StProcessBrowser >> initializePresenters [

	(processToolbarPresenter := self newToolbar)
		displayMode: self application toolbarDisplayMode;
		addStyle: 'stToolbar';
		fillWith: self processToolbarActions.

	(generalToolbarPresenter := self newToolbar)
		displayMode: self application toolbarDisplayMode;
		addStyle: 'stToolbar';
		fillWith: self generalToolbarActions.
			
	processListPresenter := self newEasyListView.
	processListPresenter display: [ :aProcess | self displayForProcess: aProcess ].

	stackListPresenter := self newEasyListView.
	stackListPresenter display: [ :aContext | self displayForContext: aContext ].
	
	codePresenter := self newCode
]

{ #category : #initialization }
StProcessBrowser >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: self class title;
		initialExtent: self class defaultExtent
]

{ #category : #actions }
StProcessBrowser >> inspectSelectedProcess [
	| process |

	(process := self selectedProcess) ifNil: [ ^ self ].
	process inspect
]

{ #category : #'accessing - model' }
StProcessBrowser >> model [

	^ model ifNil: [ model := StProcessBrowserModel new ]
]

{ #category : #'private - accessing' }
StProcessBrowser >> processToolbarActions [
	
	^ processToolbarActions ifNil: [ processToolbarActions := self buildProcessToolbarActions ]
]

{ #category : #actions }
StProcessBrowser >> refreshProcessList [

	self model updateProcessList.
	self updatePresenter
]

{ #category : #'private - accessing' }
StProcessBrowser >> selectedContext [

	^ stackListPresenter selectedItem
]

{ #category : #'private - accessing' }
StProcessBrowser >> selectedProcess [

	^ processListPresenter selectedItem
]

{ #category : #actions }
StProcessBrowser >> suspendSelectedProcess [
	| process |

	(process := self selectedProcess) ifNil: [ ^ self ].
	process suspend.
	self updatePresenter

]

{ #category : #actions }
StProcessBrowser >> terminateSelectedProcess [
	| process |

	(process := self selectedProcess) ifNil: [ ^ self ].
	process terminate.
	self updatePresenter

]

{ #category : #initialization }
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

{ #category : #initialization }
StProcessBrowser >> updatePresenter [

	self model ifNil: [ ^ self ].
	processListPresenter items: self model processList.
	self updateToolbar
]

{ #category : #'private - updating' }
StProcessBrowser >> updateToolbar [

	self processToolbarActions allCommands
		do: [ :each | each updateEnableStatus ]
]
