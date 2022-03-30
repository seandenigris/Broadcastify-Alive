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

{ #category : #printing }
BcRecording >> = rhs [
	^ self date = rhs date and: [ self start = rhs start and: [ self end = rhs end ] ]
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

{ #category : #printing }
BcRecording >> printOn: aStream [

	date ifNotNil: [ aStream nextPutAll: date mmddyyyy ].
	start ifNotNil: [ aStream space; nextPutAll: start hhmm24 ].
	end ifNotNil: [ aStream nextPutAll: ' - '; nextPutAll: end hhmm24 ].
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
