## Installation
The SDK is installed in the project via CocoaPods

Podfile
``` bash
source ‘https://github.com/G-Core/ios-video-calls-SDK.git’

...

pod "mediasoup_ios_client", '1.5.3'
pod "GCoreVideoCallsSDK", ‘2.6.0’
```

## Init
``` swift
import GCoreVideoCallsSDK

var gcMeet = GCoreMeet.shared
```

## Connection

``` swift
 // Activating the logger
 GCoreRoomLogger.activateLogger()
 
 // In order for the SDK to manage the audio session, you need to call this method
 gcMeet.audioSessionActivate()

 let userParams = GCoreLocalUserParams(name: "UserName", role: .common)

 // For example: if you join the web version, then take the id from the url - https://meet.gcorelabs.com/call/?roomId=someId
 let roomParams = GCoreRoomParams(id: "someId")
 
  // If necessary, you can specify your host for authorization on the Gcore side
 let roomParams = GCoreRoomParams(id: "someId", host: "https://yourhost.com")
 
 gcMeet.connectionParams = (userParams, roomParams)
 
 // Assign a listener for room events and optionally (if the user is a moderator) for moderator events
 gcMeet.moderatorListener = self
 gcMeet.roomListener = self
        
 try? gcMeet.startConnection()
```

## User actions
To use the user's functions, you need to refer to the localUzer property, which is created after connection

``` swift 
 gcMeet.localUser?.toggleCam(isOn: true)
```
Common user actions:
``` swift
    func flipCam(completion: @escaping (Error?) -> Void)
    func toggleCam(isOn: Bool)    
    func toggleMic(isOn: Bool)
    func changeDisplayName(newName: String)
    func askModeratorToEnable(mediaTrack: GCoreMediaTrackKind)
```

Moderators actions:
``` swift
    func toggleWaitingRoom(isOn: Bool)
    func setUsersPermission(mediaTrack: GCoreMediaTrackKind, isOn: Bool) 
    func askUserToEnable(userId: String, mediaTrack: GCoreMediaTrackKind) 
    func disableMediaTrackForUser(userId: String, mediaTrack: GCoreMediaTrackKind)
    func disableMediaTracksForOtherUsers(mediaTrack: GCoreMediaTrackKind)
    func acceptAllRequestsToJoin()
    func rejectAllRequestsToJoin(userIDs: [String])
    func acceptRequestToJoin(userId: String)
    func rejectRequestToJoin(userId: String)
    func acceptUserPermission(userId: String, mediaTrack: GCoreMediaTrackKind) 
    func rejectUserPermission(userId: String, mediaTrack: GCoreMediaTrackKind)
    func removeUser(userId: String)
```

## Room Listener

It is used to intercept events from the server and redraw the UI in accordance, respond to errors, include videos from other users
``` swift
    // Getting errors that may occur during the SDK operation
    func roomClientHandle(error: GCoreRoomError)
    
    // Getting the parameters intended for all users after entering the room
    func roomClientHandle(_ client: GCoreRoomClient, forAllRoles joinData: GCoreJoinData)
    
    // Transmits remote user-related updates from the server
    func roomClientHandle(_ client: GCoreRoomClient, remoteUsersEvent: GCoreRemoteUsersEvent)
    
    // Transmits media-related updates from the server
    func roomClientHandle(_ client: GCoreRoomClient, mediaEvent: GCoreMediaEvent)
    
    // Updating the connection status
    func roomClientHandle(_ client: GCoreRoomClient, connectionEvent: GCoreRoomConnectionEvent)
    
    // Called when the activity of the waiting room is switched
    func roomClient(_ client: GCoreRoomClient, waitingRoomIsActive: Bool)
    
    // Current session and device that the SDK uses
    func roomClient(_ client: GCoreRoomClient,
                    captureSession: AVCaptureSession,
                    captureDevice: AVCaptureDevice)

```
## Moderator Listener 
It is used to intercept moderator events from the server
``` swift
    // A request from a remote user to include something
    ///
    /// - Parameter requestToModerator: model with request type
    func roomClient(_ client: GCoreRoomClient, requestToModerator: GCoreRequestToModerator)
    
    /// Called when the remote user wants to enter the room
    ///
    /// - Parameter moderatorIsAskedToJoin: model with remote user
    func roomClient(_ client: GCoreRoomClient, moderatorIsAskedToJoin: GCoreRemoteUser)
    
    /// Moderator allowed the remote user to use the functionality
    ///
    /// - parameter remoteUserId: for which user to change the permission
    /// - parameter kind: stream type (audio/video/share)
    func roomClient(_ client: GCoreRoomClient, acceptedPermissionTo remoteUserId: String, kind: GCoreMediaTrackKind)
    
    /// Another moderator declined entry to the room to a remote user
    func roomClient(_ client: GCoreRoomClient, moderatorRejectedRemoteJoinRequest remoteUserId: String)
    
    /// Another moderator refused permission to use the media to a remote user
    func roomClient(_ client: GCoreRoomClient, moderatorRejectedPermission type: GCoreMediaTrackKind, to remoteUserId: String)
    
    /// Getting the parameters intended for moderators after entering the room
    func roomClientHandle(_ client: GCoreRoomClient, forModerator joinData: GCoreJoinData)
   ```

## Draw remote user video
The video class is used to display the video. an instance of which is added to the received stream and WebRTC itself renders the image to the view. It would be best to wrap this view in a structure and use it to distinguish the user id
``` swift
struct RemoteUser {
  let view = RTCEAGLVideoView()
  let id: String
  let name: String
}
```

``` swift
func roomClientHandle(_ client: GCoreRoomClient, remoteUsersEvent peerEvent: GCoreRemoteUsersEvent) {
  switch peerEvent {
  case .handleRemote(user: let user):
    remoteUsers += [RemoteUser(id: user.id, name: user.name)]
  ...
  }
}

func roomClientHandle(_ client: GCoreRoomClient, mediaEvent: GCoreMediaEvent) {
  switch mediaEvent {
  case .handledRemoteVideo(let videoObject):
    guard let remoteUser = remoteUsers.firts(where: { $0.id == videoObject.userId }) else { return }
    videoObject.rtcVideoTrack.add(remoteUser.view)
  ...
  }
}
```

## Screen Sharing
Currently, the SDK does not support the produce of screen sharing from the device, but allows you to receive from the outside.  

In the method:
``` swift
func roomClientHandle(_ client: GCoreRoomClient, mediaEvent: GCoreMediaEvent)
```
The event case is coming:

``` swift
.handledRemoteScreenSharing(VideoObject: let object)
```

videoObject has a trackID field on it you can track when the video stream with screen sharing closes.
