Class {
	#name : #StProcessBrowser,
	#superclass : #StPresenter,
	#instVars : [
		'processListPresenter',
		'stackListPresenter',
		'codePresenter',
		'model',
		'toolbarPresenter'
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
				hAlignEnd;
				add: toolbarPresenter expand: false;
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
StProcessBrowser >> initializePresenters [


	toolbarPresenter := self newToolbar.
	toolbarPresenter add: (self newToolbarButton
		label: 'Refresh';
		icon: (self iconNamed: #refresh);
		action: [ self refreshProcessList ];
		yourself).
			
	processListPresenter := self newEasyListView.
	processListPresenter display: [ :aProcess | 
		'({1}) {2}' format: { aProcess priority. aProcess name } ].

	stackListPresenter := self newEasyListView.
	stackListPresenter display: [ :aContext | aContext method printString ].
	
	codePresenter := self newText
]

{ #category : #initialization }
StProcessBrowser >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: self class title;
		initialExtent: self class defaultExtent
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

{ #category : #initialization }
StProcessBrowser >> updateCodeFromContext: aContext [

	aContext ifNil: [ 
		codePresenter
			"clearInteractionModel; "
			text: ''; 
			enabled: false.
		^ self ].
	
	codePresenter 
		enabled: true;
		"beForMethod: aContext method;"
		text: aContext method sourceCode
]

{ #category : #initialization }
StProcessBrowser >> updatePresenter [

	self model ifNil: [ ^ self ].
	processListPresenter items: self model processList
]
