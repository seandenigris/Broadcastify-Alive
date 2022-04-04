Class {
	#name : #BcRecording,
	#superclass : #Object,
	#instVars : [
		'date',
		'start',
		'end',
		'file'
	],
	#classVars : [
		'DB'
	],
	#category : #Broadcastify
}

{ #category : #accessing }
BcRecording class >> all [
	^ DB ifNil: [ DB := SortedCollection sortUsing: #startTimestamp descending ]
]

{ #category : #accessing }
BcRecording class >> checkModelHealth [

	| missingFiles files orphans |
	missingFiles := self all reject: [ :e | e file exists ].
	missingFiles ifNotEmpty: [ self notify: 'missing files' ].
	
	files := self folder allFiles select: [ :e | e extension = 'mp3' ].
	orphans := files select: [ :e | self all noneSatisfy: [ :rec | rec file asFileReference = e asFileReference ] ].
	orphans ifNotEmpty: [ 
		| oRows |
		self notify: 'orphans'.
		oRows := orphans collect: [ :e | 
			| wfrom |
			wfrom := e cwExtendedAttributes whereFroms detect: [ :wf | wf includesSubstring: 'broadcast' ] ifNone: [ '' ].
			{ wfrom asUrl file. e basename. e } ].
		oRows sort: #second descending ].
]

{ #category : #accessing }
BcRecording class >> folder [
	^ FileLocator dynabookData / 'Dynabook' / 'Broadcastify'
]

{ #category : #persistence }
BcRecording class >> restoreFrom: anObject [

	DB := anObject.
]

{ #category : #persistence }
BcRecording class >> spData [

	^ DB.
]

{ #category : #printing }
BcRecording >> = rhs [
	^ self date = rhs date and: [ self start = rhs start and: [ self end = rhs end ] ]
]

{ #category : #'as yet unclassified' }
BcRecording >> currentPosition: aTime in: container [
	| targetOffset |
	targetOffset := (aTime subtractTime: self start) asDuration.
	self rlResource seekTo: targetOffset in: container
]

{ #category : #'as yet unclassified' }
BcRecording >> currentTimeIn: container [
	^ self rlResource currentTimeIn: container
]

{ #category : #accessing }
BcRecording >> date [

	^ date
]

{ #category : #accessing }
BcRecording >> date: anObject [

	date := anObject
]

{ #category : #accessing }
BcRecording >> end [

	^ end
]

{ #category : #accessing }
BcRecording >> end: anObject [

	end := anObject
]

{ #category : #accessing }
BcRecording >> file [

	^ file
]

{ #category : #accessing }
BcRecording >> file: anObject [

	file := anObject
]

{ #category : #printing }
BcRecording >> hash [
	^ (self date bitXor: self start) bitXor: self
]

{ #category : #accessing }
BcRecording >> isPlayingIn: container [
	^ self rlResource isPlayingIn: container
]

{ #category : #accessing }
BcRecording >> newPlayer [
	^ (LlMediaPlayer on: self)
		driver: LlPythonMpv new;
		yourself
]

{ #category : #accessing }
BcRecording >> pauseIn: container [ 
	self rlResource pauseIn: container
]

{ #category : #accessing }
BcRecording >> playIn: container [
	self rlResource playIn: container
]

{ #category : #printing }
BcRecording >> printOn: aStream [

	date ifNotNil: [ aStream nextPutAll: date mmddyyyy ].
	start ifNotNil: [ aStream space; nextPutAll: start hhmm24 ].
	end ifNotNil: [ aStream nextPutAll: ' - '; nextPutAll: end hhmm24 ].
	file ifNotNil: [ aStream space; print: file ].
]

{ #category : #accessing }
BcRecording >> rlResource [
	^ self file asRlResource
]

{ #category : #accessing }
BcRecording >> start [

	^ start
]

{ #category : #accessing }
BcRecording >> start: anObject [

	start := anObject
]

{ #category : #accessing }
BcRecording >> startTimestamp [
	^ DateAndTime date: self date time: self start
]
