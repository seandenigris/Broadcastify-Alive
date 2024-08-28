"
Manage your recordings as live, meta-described objects. See {{gtClass:BcRecording}} for a good entry point.
"
Class {
	#name : #BaselineOfBroadcastify,
	#superclass : #BaselineOf,
	#category : #BaselineOfBroadcastify
}

{ #category : #testing }
BaselineOfBroadcastify class >> isDynabook [
	^ true
]

{ #category : #baselines }
BaselineOfBroadcastify >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec 
			baseline: #'SimplePersistence' with: [
				spec repository: 'github://seandenigris/Simple-Persistence' ];
			package: #'Broadcastify'  with: [
				spec requires: #(#'SimplePersistence' ) ] ]
]
