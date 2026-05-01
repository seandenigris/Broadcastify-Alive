Class {
	#name : 'BroadcastifyDB',
	#superclass : 'SpFileDatabase',
	#category : 'Broadcastify-Persistence',
	#package : 'Broadcastify',
	#tag : 'Persistence'
}

{ #category : 'accessing' }
BroadcastifyDB class >> backupDirectoryParent [

	^ FileLocator dynabookData
]

{ #category : 'loading/saving' }
BroadcastifyDB class >> schema [

	^ {
			BcArchive.
		}.
]
