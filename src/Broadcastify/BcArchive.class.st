Class {
	#name : #BcArchive,
	#superclass : #Object,
	#instVars : [
		'feedID',
		'recordings'
	],
	#classVars : [
		'Client',
		'DB'
	],
	#category : #Broadcastify
}

{ #category : #accessing }
BcArchive class >> all [

	^ DB ifNil: [ DB := Bag new ]
]

{ #category : #accessing }
BcArchive class >> client [
	^ Client ifNil: [ Client := ZnClient new ]
]

{ #category : #accessing }
BcArchive class >> logIn [
	self client 
		url: 'https://m.broadcastify.com/login/';
		formAt: 'username' put: '';
		formAt: 'password' put: '';
		formAt: 'action' put: 'auth';
		formAt: 'redirect' put: '/';
		post
]

{ #category : #'instace creation' }
BcArchive class >> newRochelleFire [
	| feedID |
	feedID := '8799'.
	^ self all
		detect: [ :e | e feedID = feedID ]
		ifNone: [
			| result |
			result := self new
				feedID: feedID;
				yourself.
			self all add: result  ]
]

{ #category : #persistence }
BcArchive class >> restoreFrom: anObject [

	DB := anObject.
]

{ #category : #persistence }
BcArchive class >> spData [

	^ DB.
]

{ #category : #accessing }
BcArchive >> client [
	^ self class client
]

{ #category : #accessing }
BcArchive >> ensureDownloadedRecordingsFor: aDate [
	| data |
	data := self recordingDataFor: aDate.
	data do: [ :datum |
		| file |
		file := self folder / datum first, 'mp3'.
		file exists ifFalse: [ 
			| downloadUrl |
			downloadUrl := 'https://m.broadcastify.com/archives/downloadv2' asUrl / datum first.
			[ self client
				url: downloadUrl;
				downloadTo: file
			]
				ensure: [ self client streaming: false ] ].
		self recordings 
			detect: [ :e | e file = file ]
			ifNone: [
				| recording |
				recording := BcRecording new
					date: aDate;
					start: datum second asTime;
					end: datum third asTime;
					file: file;
					yourself.
				self recordings add: recording ] ]
]

{ #category : #accessing }
BcArchive >> feedID [

	^ feedID
]

{ #category : #accessing }
BcArchive >> feedID: anObject [

	feedID := anObject
]

{ #category : #accessing }
BcArchive >> folder [
	^ (BcRecording folder / self feedID asString) ensureCreateDirectory
]

{ #category : #accessing }
BcArchive >> printOn: aStream [

	aStream
		nextPutAll: 'Broadcastify feed ';
		nextPutAll: self feedID;
		nextPutAll: ' archive'
]

{ #category : #accessing }
BcArchive >> recordingDataFor: aDate [ 
	| dataString dictionary url |
	url := 'https://m.broadcastify.com/archives/ajax.php' asUrl
		queryAt: #feedId put: self feedID;
		queryAt: #date put: aDate mmddyyyy.
	dataString := self client get: url.
	dictionary := STON fromString: dataString.
	^ dictionary at: #data
]

{ #category : #accessing }
BcArchive >> recordingFor: aDateAndTime [
	^ self recordings detect: [ :e | e includes: aDateAndTime ]
]

{ #category : #accessing }
BcArchive >> recordings [
	^ recordings ifNil: [ recordings := SortedCollection sortUsing: #startTimestamp descending ]
]

{ #category : #accessing }
BcArchive >> recordingsFor: aDate [
	| age |
	age := Date today yearsSince: aDate.
	age <= (366/365) ifTrue: [ self ensureDownloadedRecordingsFor: aDate ].
	^ self recordings select: [ :e | e date = aDate ]
]
