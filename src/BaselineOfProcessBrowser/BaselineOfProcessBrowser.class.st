Class {
	#name : 'BaselineOfProcessBrowser',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfProcessBrowser',
	#package : 'BaselineOfProcessBrowser'
}

{ #category : 'baselines' }
BaselineOfProcessBrowser >> baseline: spec [
	<baseline>
	
	spec for: #common do: [ 
		spec package: 'NewTools-ProcessBrowser' ]
]
