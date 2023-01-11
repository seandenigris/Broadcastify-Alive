"
`table := page elementLocatorFromSelector: 'table#archiveTimes'`
"
Class {
	#name : #BcArchivePage,
	#superclass : #LlAppleScriptWebPage,
	#instVars : [
		'recordingsCount'
	],
	#category : #Broadcastify
}

{ #category : #accessing }
BcArchivePage >> activeDate [
	| urlString timestamp |
	urlString := self doJavascript: (self locatorForRow: 1), '.querySelector("a").href'.
	timestamp := DateAndTime fromUnixTime: (urlString splitOn: $-) last asNumber.
	^ timestamp asDate.
]

{ #category : #accessing }
BcArchivePage >> downloadAll [

	(1 to: self recordingsCount) do: [ :i |
		self ensureRecordingAt: i ]
]

{ #category : #accessing }
BcArchivePage >> downloadRecordingAt: index [
	
	| rowLocator linkLocator download destination |
	[ 
		rowLocator := self locatorForRow: index.
		linkLocator := rowLocator, '.querySelector("a")'.
		
		self downloadedFiles size > 0 ifTrue: [ self error: 'previous downloads exist' ].
		
		self doJavascript: linkLocator, '.click()'.
		[ 
			self downloadedFiles isEmpty ] whileTrue: [ 0.5 seconds wait ]
		]
			valueWithin: 10 seconds
			onTimeout: [].
			
	download := self downloadedFiles first.
	destination := self folder / download basename.
	download moveTo: destination.
	^ destination
]

{ #category : #accessing }
BcArchivePage >> downloadedFiles [
	| activeDatePattern previousDatePattern datePattern |
	activeDatePattern := self activeDate yyyymmdd select: #isDigit.
	previousDatePattern := (self activeDate subtractDays: 1) yyyymmdd select: #isDigit.
	datePattern := '(', activeDatePattern, '|', previousDatePattern, ')'.
	^ (FileLocator home / 'Downloads') files select: [ :f | f basename matchesRegex: datePattern, '.*-', self feedID asString, '.mp3' ]
]

{ #category : #accessing }
BcArchivePage >> ensureRecordingAt: index [
	| timesString times recording linkLocator rowLocator linkHref file |
	
	rowLocator := self locatorForRow: index.
	timesString := self doJavascript: rowLocator, '.innerText'.
	times := (timesString splitOn: Character tab) collect: #asTime.
		
	recording := BcRecording new
		date: self activeDate;
		start: times first;
		end: times second;
		yourself.
			
	(BcRecording all includes: recording) ifTrue: [ ^ self ].
		
	linkLocator := rowLocator, '.querySelector("a")'.
	linkHref := self doJavascript: linkLocator, '.href'.
		
	file := self folder files 
		detect: [ :e | e cwExtendedAttributes whereFroms anySatisfy: [ :wf | wf = linkHref ] ]
		ifNone: [ self downloadRecordingAt: index ].
			
	recording file: file.
	BcRecording all add: recording
]

{ #category : #accessing }
BcArchivePage >> feedID [
	^ 8799
]

{ #category : #accessing }
BcArchivePage >> folder [
	^ (BcRecording folder / self feedID asString) ensureCreateDirectory
]

{ #category : #accessing }
BcArchivePage >> initialize [
	super initialize.
	url := 'https://m.broadcastify.com/archives/feed' asUrl / self feedID asString.
	browser := CwSafari reference
]

{ #category : #accessing }
BcArchivePage >> locatorForRow: index [
	^ self rowsLocator, '[', index asString, ']'.
]

{ #category : #accessing }
BcArchivePage >> recordingsCount [
	| rowCount |
	recordingsCount ifNotNil: [ ^ recordingsCount ].
	
	rowCount := self doJavascript: self rowsLocator, '.length'.
	^ recordingsCount := rowCount - 1 "minus header row"
]

{ #category : #accessing }
BcArchivePage >> rowsLocator [
	^ 'document.querySelectorAll("table#archiveTimes tr")'
]
