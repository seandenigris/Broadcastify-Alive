Class {
	#name : #BroadcastifyDB,
	#superclass : #SpFileDatabase,
	#category : #'Broadcastify-Persistence'
}

{ #category : #accessing }
BroadcastifyDB class >> backupDirectoryParent [

	^ FileLocator dynabookData
]

{ #category : #'loading/saving' }
BroadcastifyDB class >> schema [

	^ {
			BcRecording.
		}.
]
