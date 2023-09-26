Class {
	#name : #StProcessBrowser,
	#superclass : #StPresenter,
	#instVars : [
		'processListPresenter',
		'stackListPresenter',
		'codePresenter',
		'model',
		'toolbarPresenter',
		'lastToolbarPresenter'
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

{ #category : #initialization }
StProcessBrowser >> connectPresenters [

	processListPresenter 
		transmitTo: stackListPresenter
		transform: [ :aProcess | self model stackListFor: aProcess ].
		
	stackListPresenter 
		transmitDo: [ :aContext | self updateCodeFromContext: aContext ]
]

{ #category : #layout }
StProcessBrowser >> defaultLayout [

	^ SpBoxLayout newTopToBottom 
		add: (SpBoxLayout newLeftToRight 
				add: toolbarPresenter;
				add: lastToolbarPresenter expand: false;
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

{ #category : #initialization }
StProcessBrowser >> initializePresenters [

	(toolbarPresenter := self newToolbar)
		displayMode: self application toolbarDisplayMode;
		addStyle: 'stToolbar';
		fillWith: self toolbarActions.

	(lastToolbarPresenter := self newToolbar)
		displayMode: self application toolbarDisplayMode;
		addStyle: 'stToolbar';
		fillWith: self lastToolbarActions.
			
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

	self flag: #TODO
]

{ #category : #initialization }
StProcessBrowser >> lastToolbarActions [
	
	^ SpActionGroup new
		addActionWith: [ :action | action 
			name: 'Refresh';
			iconName: #refresh;
			description: 'Refresh list of process.'; 
			action: [ self refreshProcessList ] ];
		yourself
]

{ #category : #'accessing - model' }
StProcessBrowser >> model [

	^ model ifNil: [ model := StProcessBrowserModel new ]
]

{ #category : #actions }
StProcessBrowser >> refreshProcessList [

	self model updateProcessList.
	self updatePresenter
]

{ #category : #actions }
StProcessBrowser >> terminateSelectedProcess [

	self flag: #TODO
]

{ #category : #initialization }
StProcessBrowser >> toolbarActions [
	
	^ SpActionGroup new
		addActionWith: [ :action | action 
			name: 'Terminate';
			iconName: #stop; 
			description: 'Terminate selected process.';
			action: [ self terminateSelectedProcess ] ];
		addActionWith: [ :action | action 
			name: 'Inspect';
			iconName: #smallInspectIt;
			description: 'Inspect selected process.';
			action: [ self inspectSelectedProcess ] ];
		yourself
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
	processListPresenter items: self model processList
]
