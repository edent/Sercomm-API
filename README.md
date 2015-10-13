# Sercomm Camera API

This is designed to be a fairly comprehensive set of API documentation for [SerComm IP Cameras](http://www.sercomm.com/contpage.aspx?langid=1&type=prod2&L1id=2&L2id=3&L3id=9).

These API calls have been tested on the following cameras:

* RC8221 - a basic internal camera.
* OC821D - an external camera with weatherproof features.
* RC8230 - a pan/tilt camera.

Sercomm supplies cameras to a number of partners - each with a custom firmware.  It is possible your camera does not have access to all these API calls.

## Accessing The Cameras
Your camera may have been supplied with a username and password.  If you do not know what these credentials are, you can reset the camera to its defaults.

### Process
* Unplug the power from the camera.
* Plug in a network cable and connect it to your network.
* Hold a pin/paperclip in the "reset" hole on the back of the device.
* With the pin still held in, connect the power to the camera.
* Keep the pin in for 10 seconds, then release it.
* (You may need to power cycle the camera again without holding in the reset button if it doesn't connect to the network).
* Visit the IP address of the camera.
* Click on "Administration"
* The default username is `administrator`. There is **no** password.
* You will now be able to create a new admin user with a strong password.
* **Note:** you will need to log in quickly, or ensure that the camera cannot connect to the Internet. Some cameras will "phone home" and reconfigure themselves with the vendor's username & password.

## API Calls
The API is RESTful - although it isn't very communicative.  

All API calls are `GET` except where noted.

Responses are in plain text except where noted.

### Increase Resolution
Many cameras have a "hidden" 720p resolution.  This can be activated for video and still images.

* Set Video to 720p
    * `/adm/set_group.cgi?group=H264&resolution=4`
        * Response `OK`
        
* Set JPG to 720p
    * `/adm/set_group.cgi?group=JPEG&resolution=4`
        * Response `OK`


### Get Still Image
* To get a JPEG of what the camera is currently seeing.
    * `/img/snapshot.cgi`
        * Response is a JPEG encoded image.
* Parameters
    * Set the resolution of the image with
        * `size=1` 1280*720
        * `size=2` 320*240
        * `size=3` 640*480
    * Set the quality of the image. The higher the JPEG quality, the larger the file.
        * `quality=1` JPEG quality 85
        * `quality=2` JPEG quality 70
        * `quality=3` JPEG quality 55
        * `quality=4` JPEG quality 40
        * `quality=5` JPEG quality 25

### Pan / Tilt Movement
For cameras which have moveable lenses, it is possible to control the direction the camera is facing.

* Left
    * `/pt/ptctrl.cgi?mv=L,11`
* Right
    * `/pt/ptctrl.cgi?mv=R,11`
* Up
    * `/pt/ptctrl.cgi?mv=U,10`
* Down
    * `/pt/ptctrl.cgi?mv=D,10`

There is no response sent in reply to these commands - although you should be able to see the camera move.


### Arming
Arming a camera allows you to create triggers for specific events.  For example, send an email on motion detection.

* Check arming status
    * `/adm/get_group.cgi?group=EVENT`
        * Response 
 
```ini
[EVENT]
event_trigger=0
event_schedule=1
event_define1=
event_define2=
event_define3=
event_define4=
event_define5=
event_define6=
event_define7=
event_define8=
event_define9=
event_define10=
event_interval=0
event_mt=email:0;ftpu:1;httpn:0;httppost:0;smbc:0
event_attach=mp4,1,5,10
event_audio=email:0;ftpu:1;httpn:0;httppost:0;smbc:0
event_httpc=email:0;ftpu:0;httpn:0;httppost:0;smbc:0
```


* If `event_trigger=0` the camera is **not** armed.
* If `event_trigger=1` the camera **is** armed
* Arm
    *  `/adm/set_group.cgi?group=EVENT&event_trigger=1`
      * Response `OK`
* Disarm
    *  `/adm/set_group.cgi?group=EVENT&event_trigger=0`
        * Response `OK`


### Viewing Video
There are several ways you can get video and audio out of the cameras.

#### MJPEG
* Motion JPEG is a simple format for viewing video (no audio) in your browser.
    * `/img/video.mjpeg`

#### SDP (MPEG-4/H.264 video/MJPEG)
*    Video
    * `/img/media.sdp`

#### RTP/RTSP 
The following cn be accessed via the `rtsp://` protocol.

* Video and Audio
    * `/img/media.sav`
* Video
    * `/img/video.sav`
* Audio
    * `/img/audio.sav`

#### Flash
* Should you want to view the video in Flash
    * `/img/media.swf`
    * `/img/media.flv`

### Motion Detection
This is *really* tricky!

Some cameras can support up to 4 areas of motion detection.   For example, you might have a camera pointed at your door, but are only interested in seeing when the handle or the letter box moves.

No matter what resolution your camera is, the motion detection is defined on a 640*480 grid with the top left corner being position `0,0` and the bottom right being `639,479`.

```
         640
+-------------------+  
|(0,0)              |
|                   |
|                   |480
|                   |
|                   |
+-------------------+
                    (639,479)
```

* Get the currently configured motion detection settings.
    * `/adm/get_group.cgi?group=MOTION`
    * Response:
    
```ini
[MOTION]
md_mode=1
md_switch1=1
md_switch2=0
md_switch3=0
md_switch4=0
md_name1=Window 1
md_name2=Window 2
md_name3=Window 3
md_name4=Window 4
md_window1=0,0,639,479
md_window2=0,0,160,120
md_window3=0,0,160,120
md_window4=0,0,160,120
md_threshold1=80
md_threshold2=127
md_threshold3=127
md_threshold4=127
md_sensitivity1=6
md_sensitivity2=6
md_sensitivity3=6
md_sensitivity4=6
md_update_freq1=90
md_update_freq2=90
md_update_freq3=90
md_update_freq4=90
md_point=0,0

```

As you can see, there are 4 windows, each with their own switch, name, co-ordinates, threshold, sensitivity, and update frequency.

It may help to think of them being grouped like this:

```ini
md_switch1=1
md_name1=Window 1
md_window1=0,0,639,479
md_threshold1=80
md_sensitivity1=6
md_update_freq1=90

md_switch2=0
md_name2=Window 2
md_window2=0,0,160,120
md_threshold2=127
md_sensitivity2=6
md_update_freq2=90

```

* Each parameter can be retrieved individually
    * `/adm/get_group.cgi?group=MOTION.md_name1`
        * Response 
```
[MOTION]
md_name1=Window 1
```


* Each parameter can be set using
    * `/adm/set_group.cgi?group=MOTION&`
    * e.g. `/adm/set_group.cgi?group=MOTION&md_window2=30,60,100,120`
        * Response `OK`

### Notification
You can set the cameras to perform an action when motion is detected.

#### HTTP Notification
* Get the current configuration
    * `/adm/get_group.cgi?group=MOTION`
    * Response

```
[HTTP_NOTIFY]
http_notify=1
http_url=
http_proxy=
http_proxy_no=80
http_method=1
http_user=
http_password=
proxy_user=
proxy_password=
event_data_flag=0

```

* Each parameter can be retrieved individually
    * `/adm/get_group.cgi?group=HTTP_NOTIFY.http_notify`
        * Response 
```
[HTTP_NOTIFY]
http_notify=1
```

* Each parameter can be set using
    * `/adm/set_group.cgi?group=HTTP_NOTIFY&`
    * e.g. `/adm/set_group.cgi?group=HTTP_NOTIFY&http_url=http://example.com`
        * Response `OK`

### System Settings

#### Device Information
* To see information about the camera
    * `/util/query.cgi`
        * Response


```ini
hostname=Camera
description=
defname=SC92FFF7
mpeg4_resolution=640
mjpeg_resolution=1280
h264_resolution=1280
h264_resolution2=320
h264_resolution3=320
mic_in=on
speaker_out=off
ptctrl=on
wlled=off
irled=off
serial=off
resolutions=1280x720,640*480,320*240,160*120
mac=00:0e:8f:92:ff:f7
privacy_button=off
pir_sensor=off
wps_pin_code=1234567
ioctrl=off
company_name=Xanboo
model_number=RC8230
wireless=on
sw_pppoe=yes
```
* For extra information
    * `/util/query.cgi?extension=yes`
        * Response

```ini
fw_ver=V1.0.15R00
ip_addr=192.168.0.42
netmask=255.255.255.0
gateway=192.168.0.1
timezone=26
current_time=10/13/2015 08:56:42
http_port=80
rtsp_port=554
https_port=443
```

* System information
    * `/adm/sysinfo.cgi`
        * Response

```ini
Firmware Version: V1.0.15
Serial Number:12345
Firmware Release Date: Mar 01,2013

```

#### User Access
* To see what features of the camera the current user has access to.
    * `/img/query.cgi`
         * Response

```ini
mic_in=on
speaker_out=on
ptctrl=on
ioctrl=off

```

### Get IR Filter
* Some cameras have an InfraRed filter to enable them to see in the darkness.
    * `/io/query_filter.cgi`
        * Response `filter=0` filter is off.
        * Response `filter=1` filter is on.


#### Date And Time
* To get the date and time information
    * `/adm/date.cgi?action=get`
    * Response

```ini
timezone=26
year=2015
month=10
day=13
hour=08
minute=19
second=57

```

* To set the date and time information
     * `/adm/date.cgi?action=set&`
        * Parameters
            * `year`
            * `month`
            * `day`
            * `second`
        * Response `OK`

#### Configuration Settings
* Download the camera's configuration settings
    * `/adm/admcfg.cfg`
    *  Response is a Base64 encoded representation of the configuration file.  According to the specification:
    > There is the hidden check sum data inside the configuration content to validate the data, Because we use the dword-aligned checksum algorithm, so we will ignore the last data misaligned by dword.
    * The Sercomm cameras have a custom BASE64 table:
        * `ACEGIKMOQSUWYBDFHJLNPRTVXZacegikmoqsuwybdfhjlnprtvxz0246813579=+/`
    * For comparison, a standard table is:
        * `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=`
    
* Upload a configuration file. *Note* this is an HTTP **POST**
    * `/adm/upload.cgi`
    
#### Log Files
* Get the event log of the camera
    * `/adm/log.cgi`
        * Response:
        
```ini
2015-10-13 07:12:33 DHCP: Lease renewal successfully.
2015-10-13 07:11:28 WATCHDOG: Haven't received HTTP requests for 1200 seconds, reconnecting WIFI.
2015-10-13 06:55:12 NTP: Synchronization OK.
2015-10-13 06:53:47 DHCP: Lease renewal successfully.
2015-10-13 06:51:11 Network: Wireless activated.
```

### Networking

#### WiFi Environment
* To see all available WiFi networks
    * `/adm/site_survey.cgi`
        * Response is in **XML**
        
```
<?xml version="1.0" encoding="utf-8"?>
<SiteList>
   <Site>
        <SSID>MyWiFiNetwork</SSID>
        <BSSID>34:44:11:A9:C2:D4</BSSID>
        <Mode>Infrastructure</Mode>
        <Security>WPA2-PSK</Security>
        <AUTH>SharedKey</AUTH>
        <Encryption>AES</Encryption>
        <Channel>1</Channel>
        <Signal>100</Signal>
        <WPS>Yes</WPS>
    </Site>
    ...
```

#### WiFi Status
* See the camera's WiFi status
    * `/adm/wireless_status.cgi`
        * Response:
        
```
signal_strength=100
signal_strength-A=0
signal_strength-B=0
essid=MyWiFiNetwork
domain=Europe
channel=11
bssid=C1:15:A2:01:1D:11
wps_pin_code=123456

```

#### Samba
The cameras can upload images and videos to local network shares.

* LAN survey for SMB/CIFS shares
    * `/adm/smb_survey.cgi?`
        * Response in **XML**
        
```
<?xml version="1.0" encoding="utf-8"?>
<List>
    <WorkGroup>
        <Name>WORKGROUP</Name>
        <List>
            <Server>
                <Name>MYSERVER</Name>
                <Comment>Samba 4.1.6-Ubuntu</Comment>
            </Server>
        </List>
    </WorkGroup>
</List>
```

* Optional parameters
    * `timeout=` value in seconds between 5 - 120. Default is 30. Camera will stop searching after this time.
    * `action=stop` force the camera to stop searching.
    
## TODO!
If you can help with these missing piece of functionality, I would be most grateful.

### Sending Audio
With the speakers enabled, it should be possible to POST an audio file to the cameras, either in G.726, or G.711 (a-law or u-law).   I've not been able to get this working.  [See further discussion](http://stackoverflow.com/questions/19686996/post-audio-to-a-network-camera).