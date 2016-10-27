# Sercomm Camera API

This is designed to be a fairly comprehensive set of API documentation for [SerComm IP Cameras](http://www.sercomm.com/contpage.aspx?langid=1&type=prod2&L1id=2&L2id=3&L3id=9).

These API calls have been tested on the following cameras:

* RC8221 - a basic internal camera.
* RC8221D - a modified version of the above camera.
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

### Enable the UI
Some cameras don't show a menu by default.

* This command is used to [activate the administration menu](https://github.com/edent/Sercomm-API/issues/1) on vendor modified firmwares such as Comcast Xfinity, Cox Homelife and ADT Pulse.
   * `/adm/enable_ui.cgi`
   * Response `OK`


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

* The pan/tilt can be controlled in to different ways.
    * `/pt/ptctrl.cgi?mv=$Direction,$Distance`

Where `$Direction` can be `U`p, `D`own, `L`eft, `R`ight.

And `$Distance` can be any positive integer.

The maximum `U` and `D` value is `64`.

The maximum `L` and `R` value is `??`.

For example:

* Left
    * `/pt/ptctrl.cgi?mv=L,10`
* Right
    * `/pt/ptctrl.cgi?mv=R,10`
* Up
    * `/pt/ptctrl.cgi?mv=U,10`
* Down
    * `/pt/ptctrl.cgi?mv=D,10`

Diagonal moves can also be made:

* Up Left
    * `/pt/ptctrl.cgi?mv=UL,10`
* Up Right
    * `/pt/ptctrl.cgi?mv=UR,10`
* Down Left
    * `/pt/ptctrl.cgi?mv=DL,10`
* Down Right
    * `/pt/ptctrl.cgi?mv=DR,10`
    
There are preset locations which can be accessed

* Motion Detection (Unsure TODO!)
    * `/pt/ptctrl.cgi?preset=move,100`
* Camera Patrol (Unsure TODO!)
    * `/pt/ptctrl.cgi?preset=move,101`
* Pan right, then left (once)
    * `/pt/ptctrl.cgi?preset=move,102`
* Move to home position
    * `/pt/ptctrl.cgi?preset=move,103`
* Calibration (Move the full range of motion)
    * `/pt/ptctrl.cgi?preset=move,104`

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
The following can be accessed via the `rtsp://` protocol.

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
    
* With a GUI
    * `/img/sc_flvplayer.swf`

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
        
* Properties which can be set using `/adm/set_group.cgi?group=MOTION&$property=$value`.
    * `md_mode` Motion detection mode 
        * `0` Off
        * `1` On (Default)
    * `md_point`  The position of motion using PT mode. The format is `X,Y` 
        * X's range is `-63` to `63`
        * X's range is `-36` to `28`
    * `md_switch` `[1-4]` Set whether a motion detection window is active.
        * `0` Off
        * `1` On 
    * `md_name` `[1-4]` Set the name of a motion detection window.
        * Maximum 12 ASCII characters.
    * `md_window` `[1-4]` Set the co-ordinates of the motion detection window. No matter the resolution of the camera, the area is considered to be 640*480 is active.
    * The format is X0,Y0,X1,Y1.
        * X's range is `0` to `639`
        * Y's range is `0` to `479` 
    * `md_threshold` `[1-4]` Set the threshold(???) for the motion detection window.
        * Range is `0` to `255`

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
    
## Other Configuration Groups
Sercomm's configuration API uses the concept of "groups".

* For example, you can **get** all the "System" group properties by calling:
    * `/adm/get_group.cgi?group=SYSTEM`
* Each parameter can be retrieved individually
    * `/adm/get_group.cgi?group=SYSTEM.ntp_server`
* You can **set** a group's properties by calling:
    * `/adm/set_group.cgi?group=SYSTEM&$property=$value`
        * e.g. `/adm/set_group.cgi?group=SYSTEM&ntp_server=0.uk.pool.ntp.org`
    * **Note** some of the properties are *read only*.

* You can see **all** the possible groups by calling
    * `/adm/get_group.cgi`
        * Returns:
        
```
[Manufacture]
[SYSTEM]
[LOG]
[NETWORK]
[WIRELESS]
[DDNS]
[HTTP]
[RTSP_RTP]
[UPNP]
[EMAIL]
[FTP]
[SMBC]
[VIDEO]
[H264]
[MPEG4]
[JPEG]
[STREAMS]
[AUDIO]
[USER]
[IP_FILTER]
[MOTION]
[IO]
[EVENT]
[QOS]
[MCWS]
[HTTP_NOTIFY]
[HTTP_EVENT]
[PPPOE]
[BONJOUR]
[SDCARD]
[PTZ]
```

**Note:** The groups available will depend on which camera you have. For example, not all cameras have an SD Card slot.

### Manufacturer Information
* The default manufacturer information:
    * `/adm/get_group.cgi?group=Manufacture`
        * Response:
        
```
[Manufacture]
def_name=
default_ip=192.168.0.99/255.255.255.0
max_user=20
summer_chg=1
conf_status=1
```

### System Configuration
* All the "System" group properties by calling:
    * `/adm/get_group.cgi?group=SYSTEM`
        * Response:
        
```
[SYSTEM]
cfg_ver=RC8230_XANBOO_0001
host_name=MyCamera
comment=
time_format=24
date_format=1
time_zone=26
daylight_saving=1
ntp_mode=1
ntp_server=clock.via.net
ntp_date=0
ntp_hour=6
ntp_min=1
led_mode=1
reboot_time=2015-10-13 06:46:54
boot_up_time=2015-10-13 11:55:22
reboot_reason=Reboot by Internal (Reason: hydra is gone)
wd_timer_wifi=20
wd_timer_idled=300
wd_timer_acted=180
wd_reboot_num=347
wd_reboot_time=1444713006;1444585286

```

* Properties which can be set using `/adm/set_group.cgi?group=SYSTEM&$property=$value`.
    * `host_name` Camera's name. Maximum of 16 characters, 0-9, A-Z, a-z, space.
    * `comment ` Camera's description. Maximum of 32 ASCII characters. 
    * `time_format` Valid values are 
        * `24-hour`
        * `12-hour`
    * `date_format` Valid values are
        * `1` ???
        * `2` ???
        * `3` ???
    * `time_zone` Valid values are 0-75.
    * `daylight_saving` Valid values are
        * `0` Off 
        * `1` On 
    * `ntp_mode ` Synchronise with an NTP server. Valid values are
        * `0` Off 
        * `1` On 
    * `ntp_server` Which NTP server to use. Set using a domain name of up to 64 characters.
    * `led_mode` Keep the camera's information LED on. Valid values are
        * `0` Off 
        * `1` On 

### Logging
* Get all log configuration
    * `/adm/get_group.cgi?group=LOG`
        * Response:
        
```
[LOG]
log_mode=1
log_level=3
syslog_mode=0
syslog_server=
syslog_port=514
im_mode=0
im_server=
im_account=
im_password=
im_sendto=
im_message=
ftplog_mode=1
smtplog_mode=1
systemlog_mode=1
imlog_mode=1
```

* Properties which can be set using `/adm/set_group.cgi?group=LOG&$property=$value`.
    * `syslog_mode ` Valid values are 
        * `0` Off 
        * `1` On 
    * `syslog_server` Which Syslog server to use. Set using a domain name of up to 64 characters.
    * Others ???
    
### Network

* Get all Network configuration
    * `/adm/get_group.cgi?group=NETWORK`
        * Response:

```
[NETWORK]
ip_addr=192.168.0.42
netmask=255.255.255.0
gateway=192.168.0.1
dhcp=1
dns_type=1
dns_server1=192.168.0.1
dns_server2=8.8.8.8
wins_type=0
wins_ip=
```

* Properties which can be set using `/adm/set_group.cgi?group=NETWORK&$property=$value`.
    * `ip_addr` Camera's IP address.
    * `netmask` Camera's netmask as IP address.
    * `gateway` IP of the network gateway.
    * `dhcp` Valid values are 
        * `0` Fixed IP Address 
        * `1` Use DHCP 
    * `dns_type` Valid values are 
        * `0` DNS servers assigned by DHCP
        * `1` Manually assigned DNS servers
    * `dns_server1` and `dns_server2` IP addresses of the DNS servers
    * Others ???

### Wireless

* Get all WiFi configurations
    * `/adm/get_group.cgi?group=WIRELESS`
        * Response:

```
[WIRELESS]
wlan_type=1
wlan_essid=MyNetwork
wlan_channel=0
wlan_domain=5
wlan_security=2
wep_authtype=2
wep_mode=1
wep_index=1
wep_ascii=
wep_kep1=
wep_kep2=
wep_kep3=
wep_kep4=
wpa_ascii=
wmm=0
```

* Properties which can be set using `/adm/set_group.cgi?group=NETWORK&$property=$value`.
    * `wlan_type`   Valid values are 
        * `0` Ad hoc
        * `1` Infrastructure 
        * `wlan_essid` The SSID to connect to. Maximum of 32 ASCII 
characters. Case sensitive.
        * `wlan_channel` Which WiFi channel number to use.
            * `0` auto
            * `1` - `13` a specific channel.
        * `wlan_domain` Different countries have different WiFi channels
            * `1` - Africa 
            * `2` - Asia 
            * `3` - Australia 
            * `4` - Canada 
            * `5` - Europe 
            * `6` - Spain 
            * `7` - France 
            * `8` - Israel 
            * `9` - Japan 
            * `10` - Mexico 
            * `11` - South American
            * `12` - USA 
        * `wlan_security` Which wireless security mode
            * `0` - None 
            * `1` - WEP 
            * `2` - WPA/WPA2-PSK  
            * `3` - WPA PSK TKIP  
            * `4` - WPA PSK AES  
            * `5` - WPA2 PSK TKIP  
            * `6` - WPA2 PSK AES  
            * `7` - WPA enterprise 
            * `8` - WPA PSK 
            * `9` - WPA2 PSK 
        * `wpa_ascii` Set the password for WPA.  Must be between 8 and 63 characters. 
        * `connection_mode` Which wireless mode to boot up to.
            * `0` - If a connection is available over the Ethernet 
interface, the device uses Ethernet; otherwise, it uses 
wireless.
            * `1` - The device use wireless whether a connection is 
available over the Ethernet or not. 
            * `2` - The device enters WPS PBC mode over wireless 
whether a connection is available over the Ethernet or not. 
            * `3` - The device enters WPS PIN code mode over 
wireless whether a connection is available over the 
Ethernet or not. 
        * `wmm` Use [WMM mode](https://en.wikipedia.org/wiki/Wireless_Multimedia_Extensions). Valid values are 
            * `0` Off 
            * `1` On 
        * `wpa_ep_auth_type` Set WPA/WPA2 Enterprise authentication type.
            * `1` - EAP-TLS 
            * `2` - EAP-TTLS 
        * `wpa_tls_user` Set EAP-TLS user name. Maximum of 64 ASCII characters.
        * `wpa_tls_priv_keypass` Set EAP-TLS private key password. Maximum of 64 ASCII characters.
        * `wpa_ttls_auth_type` Set EAP-TTLS authentication type.
            * `1` MSCHAP 
            * `2` MSCHAPv2 
            * `3` PAP 
            * `4` EAP-MD5 
            * `5` EAP-GTC 
        * `wpa_ttls_user` Set EAP-TTLS User name. Maximum of 64 ASCII characters.
        * `wpa_ttls_pass` Set EAP-TTLS user password. Maximum of 64 ASCII characters.
        * `wpa_ttls_anony_name` Set EAP-TTLS/EAP-TLS anonymous name. Maximum of 64 ASCII characters.
        
### Dynamic DNS
* Get all Dynamic DNS configuration
    * `/adm/get_group.cgi?group=DDNS`
        * Response:

```
[DDNS]
ddns_mode=0
ddns_service=
ddns_account=
ddns_password=
ddns_host_name=
ddns_hour=12
ddns_minute=
ddns_update_unit=3
ddns_update_period=10
```

TODO! Many of the DDNS providers no longer work.

### HTTP
* Get all HTTP configuration
    * `/adm/get_group.cgi?group=HTTP`
        * Response:

```
[HTTP]
http_mode=1
http_port2=1
http_port2_num=8080
https_mode=1
ssport_enable=0
ssport_number=1025
```


### Real Time Streaming Protocol
* Get all RTSP configuration
    * `/adm/get_group.cgi?group=RTSP_RTP`
        * Response:

```
[RTSP_RTP]
rtsp_port=554
rtp_port=5000
rtp_size=1400
mcast_enable=0
mcast_video_enable=0
mcast_video_addr=224.2.0.1
mcast_video_port=2240
mcast_h264_enable=0
mcast_h264_addr=224.2.0.1
mcast_h264_port=2242
mcast_audio_enable=0
mcast_audio_addr=224.2.0.1
mcast_audio_port=2244
mcast_hops=16
```


* Properties which can be set using `/adm/set_group.cgi?group=RTSP_RTP&$property=$value`
    * `rtsp_port` RTSP port number. Valid values are
        * `554`
        * `1024` to `65535` 
    * `rtp_port` RTP port number. Valid values
        * `1024` to `65535`
        * Default of `5000`
    * `rtp_size` RTP packet size. Valid values
        * `400` to `1400`
    * `mcast_enable` RTP/RTSP multicast mode. Valid values are 
            * `0` Off (Default)
            * `1` On 
    * `mcast_video_addr` Video multicast IP address.
    * `mcast_video_port` Video port number. 
        * `1024` to `65534` **Even numbers only**.
    * `mcast_audio_addr` Audio multicast IP address. 
    * `mcast_audio_port` Audio port number.
        * `1024` to `65534` **Even numbers only**.
    * `mcast_hops` Multicast time to live value.
        * `1` to `255`

### Universal Plug and Play
* Get all UPNP configuration
    * `/adm/get_group.cgi?group=UPNP`
        * Response:

```
[UPNP]
upnp_mode=0
upnp_traversal=
upnp_camera=
```

* Properties which can be set using `/adm/set_group.cgi?group=UPNP&$property=$value`
    * `upnp_mode`
        * `0` Off (Default)
        * `1` On 

### EMAIL
* Get all Email configuration
    * `/adm/get_group.cgi?group=EMAIL`
        * Response:

```
[EMAIL]
smtp_enable=1
smtp_server=
pop_server=
smtp_port=465
smtp_auth=1
smtp_account=
smtp_password=
smtp2_enable=0
smtp2_server=
pop2_server=
smtp2_port=25
smtp2_auth=0
smtp2_account=
smtp2_password=
from_addr=
from_addr2=
to_addr1=
to_addr2=
to_addr3=
send_email=1
email_att=7
subject=
smtp_serv_flag=1
smtp2_serv_flag=1
```

**Note:** The response will *never* display your passwords.

TODO!

### FTP
* Get all FTP settings
    * `/adm/get_group.cgi?group=FTP`
        * Response:

```
[FTP]
ftp1=1
ftp1_server=
ftp1_account=
ftp1_passwd=
ftp1_path=
ftp1_passive=1
ftp1_port=21
ftp2=0
ftp2_server=
ftp2_account=
ftp2_passwd=
ftp2_path=
ftp2_passive=0
ftp2_port=21
```

**Note:** The response will *never* display your passwords.


### Samba
* Get all Samab configuration
    * `/adm/get_group.cgi?group=SMBC`
        * Response:

```
[SMBC]
smbc_enable=1
smbc_server=
smbc_path=
smbc_account=
smbc_passwd=
smbc_rec_enable=0
smbc_rec_file_ctrl=1
smbc_rec_filesize=0
smbc_rec_duration=15
smbc_rec_streaming=1
smbc_rec_mode=1
smbc_rec_server=
smbc_rec_path=
smbc_rec_account=
smbc_rec_passwd=
smbc_rec_filename_prefix=
smbc_rec_behavior=0,0,1
smbc_rec_schedule=
smbc_rec_bymd_fn_prefix=
smbc_rec_bymd_len=
```

TODO!

### Video
* Get all Video  configuration
    * `/adm/get_group.cgi?group=VIDEO`
        * Response:

```
[VIDEO]
video_schedule=0
video_define1=
video_define2=
video_define3=
video_define4=
video_define5=
video_define6=
video_define7=
video_define8=
video_define9=
video_define10=
time_stamp=1
text_overlay=0
text=
power_line=50
color=0
exposure=4
sharpness=4
flip=0
mirror=0
hue=4
saturation=4
contrast=4
default_channel=1
mask_window1=0
mask_window2=0
mask_window3=0
mask_window4=0
mask_color1=888888
mask_color2=888888
mask_color3=888888
mask_color4=888888
mask_position1=160,180,480,300
mask_position2=160,180,480,300
mask_position3=160,180,480,300
mask_position4=160,180,480,300
night_mode=0
```

* Properties which can be set using `/adm/get_group.cgi?group=VIDEO`
    * `time_stamp` Display a date / timestamp on the images
        * `0` Off
        * `1` On
    * `text_overlay` Display a line of text on the images
        * `0` Off
        * `1` On
    * `text` The text to display
        * Maximum of 20 ASCII characters
    * `power_line` Adjust the picture to reduce flicker from lights.  This should be set the to Hz of your electrical grid.
        * `50` UK / Europe
        * `60` USA  
    * `color` Configure the colour balance of the picture
        * `0` Auto
        * `1` Indoors
        * `2` White lighting
        * `3` Yellow lighting
        * `4` Outdoor
        * `5` Black and White
    * `exposure` brightness of the image. Range of `1` to `7`
        * `1` Darkest
        * `7` Brightest
    * `sharpness` Sharpness of the image. Range of `1` to `7`
        * `1` Least sharp
        * `7` Most sharp
    * `flip` Veritcally flip the images - useful if the camera has been installed upside down.
        * `0` Off
        * `1` On
    * `mirror` Horizontal flip the images
        * `0` Off
        * `1` On
     * `time_stamp` Display a date / timestamp on the images
        * `0` Off
        * `1` On
        
TODO!

### H264
* Get all H264 Video Codec configuration
    * `/adm/get_group.cgi?group=H264`
        * Response:

```
[H264]
mode=1
resolution=4
quality_type=1
quality_level=5
bit_rate=768
frame_rate=25
gov_length=25
sp_uri=
mode2=1
resolution2=2
quality_type2=0
quality_level2=3
bit_rate2=256
frame_rate2=10
gov_length2=10
sp_uri2=
mode3=1
resolution3=2
quality_type3=0
quality_level3=3
bit_rate3=64
frame_rate3=10
gov_length3=10
sp_uri3=
bandwidth=0
profile=66
cropping=0
bandwidth2=0
profile2=66
cropping2=0
bandwidth3=0
profile3=66
cropping3=0
```

TODO!

### MPEG4
* Get all MPEG4 configuration
    * `/adm/get_group.cgi?group=MPEG4`
        * Response:

```
[MPEG4]
mode=1
resolution=3
quality_type=1
quality_level=5
bit_rate=256
frame_rate=25
gov_length=10
sp_uri=
mode2=0
resolution2=1
quality_type2=1
quality_level2=3
bit_rate2=256
frame_rate2=15
gov_length2=10
sp_uri2=
mode3=0
resolution3=3
quality_type3=1
quality_level3=3
bit_rate3=1000
frame_rate3=15
gov_length3=10
sp_uri3=
bandwidth=0
cropping=0
bandwidth2=0
cropping2=0
bandwidth3=0
cropping3=0
```

TODO!

### JPEG
* Get all JPEG image configuration
    * `/adm/get_group.cgi?group=JPEG`
        * Response:

```
[JPEG]
mode=1
resolution=4
quality_level=3
frame_rate=15
sp_uri=
mode2=0
resolution2=1
quality_level2=3
frame_rate2=15
sp_uri2=
mode3=0
resolution3=3
quality_level3=3
frame_rate3=30
sp_uri3=
bandwidth=0
cropping=0
bandwidth2=0
cropping2=0
bandwidth3=0
cropping3=0
```

TODO!

### Video Streams
* Get all video streaming configuration
    * `/adm/get_group.cgi?group=STREAMS`
        * Response:

```
[STREAMS]
channel1=H264,1
channel2=JPEG,2
channel3=MPEG4,3
```

TODO!

### Audio
* Get all Audio configuration
    * `/adm/get_group.cgi?group=AUDIO`
        * Response:

```
[AUDIO]
audio_in=1
in_volume=1
in_audio_type=1
audio_out=0
out_volume=8
out_audio_type=0
audio_mode=1
operation_mode=1
in_pcm_sr=8000
audio_in2=1
in_pcm_sr2=5512
in_audio_type2=3
au_trigger_en=0
au_trigger_volume=50
au_trigger_method=0
```

TODO!

### User Database
* Get all User information  
    * `/adm/get_group.cgi?group=USER`
        * Response:

```
[USER]
login_check=1
admin_timeout=5
admin_name=admin
admin_password=
viewer_name=demo
viewer_password=
user1=viewer,
user2=
user3=
user4=
user5=
user6=
user7=
user8=
user9=
user10=
user11=
user12=
user13=
user14=
user15=
user16=
user17=
user18=
user19=
user20=
audio_in_ctrl=1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
audio_out_ctrl=1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
pt_ctrl=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
adm_ctrl=0
io_ctrl=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
```

**Note:** The response will *never* display your passwords.


TODO!

### IP Filters
* Get all IP Filters
    * `/adm/get_group.cgi?group=IP_FILTER`
        * Response:

```
[IP_FILTER]
ip_filter=0
ip_filter_rule=0
ip_filter1=
ip_filter2=
ip_filter3=
ip_filter4=
ip_filter5=
ip_filter6=
ip_filter7=
ip_filter8=
ip_filter9=
ip_filter10=
ip_filter11=
ip_filter12=
ip_filter13=
ip_filter14=
ip_filter15=
ip_filter16=
ip_filter17=
ip_filter18=
ip_filter19=
ip_filter20=
```

TODO!

### IO Pins

Some cameras have IO pins on the back.  You can use these to send signals to, or receive signals from the camera.

* Get all IO configuration
    * `/adm/get_group.cgi?group=IO`
        * Response:

```
[IO]
in1_trigger=0
in2_trigger=0
in1_type=3
in2_type=0
out1_init=1
out2_init=1
out1_button=0,0,10
out2_button=0,0,10
out1_action=1
out2_action=1
out1_pulse_duration=10
out2_pulse_duration=10
```

TODO!

### Quality of Service
* Get all QOS configuration
    * `/adm/get_group.cgi?group=QOS`
        * Response:

```
[QOS]
qos_enable=0
qos_dscp=32
qos_av_switch=0
```

TODO!

### MCWS???
* Get all ??? configuration
    * `/adm/get_group.cgi?group=MCWS`
        * Response:

```
[MCWS]
url_periodic=
url_event=
expire_hours=0
```

TODO!

### HTTP Events
* Get all HTTP POST Events configuration
    * `/adm/get_group.cgi?group=HTTP_EVENT`
        * Response:

```
[HTTP_EVENT]
http_event_en=0
http_post_en=0
http_post_user=
http_post_pass=
http_post_url=
```

**Note:** The response will *never* display your passwords.

TODO!

### Point-to-point protocol over Ethernet
* Get all PPPOE configuration
    * `/adm/get_group.cgi?group=PPPOE`
        * Response:

```
[PPPOE]
pppoe_enable=0
pppoe_username=
pppoe_password=
pppoe_dod=0
pppoe_idle_time=300
pppoe_redial_time=30
pppoe_hostname=
pppoe_mtu_type=0
pppoe_mtu=1492
```

**Note:** The response will *never* display your passwords.


### Bonjour
* Get all [ZeroConf Networking](https://en.wikipedia.org/wiki/Bonjour_%28software%29) configuration
    * `/adm/get_group.cgi?group=`
        * Response:

```
[BONJOUR]
bonjour_name=RC8230-92fff7
bonjour_mode=0
```

### SD Card

Some cameras have a slot for a MicroSD Card, onto which images and videos can be saved.

* Get SD Card configuration
    * `/adm/get_group.cgi?group=SDCARD`
        * Response:

```
[SDCARD]
sdcard_rec_enable=0
sdcard_rec_event_enable=0
sdcard_rec_audio_enable=0
sdcard_rec_file_ctrl=1
sdcard_rec_file_size=10
sdcard_rec_disk_ctrl=0
sdcard_rec_duration=60
sdcard_rec_stream_id=1
sdcard_rec_filename_prefix=
sdcard_rec_event_prefix=
sdcard_rec_schedule=
sdcard_rec_schedule1=
sdcard_rec_schedule2=
sdcard_rec_schedule3=
sdcard_rec_schedule4=
sdcard_rec_schedule5=
sdcard_rec_schedule6=
sdcard_rec_schedule7=
sdcard_rec_schedule8=
sdcard_rec_schedule9=
sdcard_rec_schedule10=
```

TODO!

### Pan/Tilt/Zoon
* Get all PTZ configuration
    * `/adm/get_group.cgi?group=PTZ`
        * Response:

```
[PTZ]
PtzMode=1
PtzMdMutex=2
Preset1Name=
Preset2Name=
Preset3Name=
Preset4Name=
Preset5Name=
Preset6Name=
Preset7Name=
Preset8Name=
Preset9Name=
Preset1Position=
Preset2Position=
Preset3Position=
Preset4Position=
Preset5Position=
Preset6Position=
Preset7Position=
Preset8Position=
Preset9Position=
Patrol1Position=
PredefineHome=0,0
PatrolInterval=
PatrolStyle=0
```

TODO!

## Firmware

### Firmware Download

* Download the camera's firmware
    * `/adm/flash_dumper.cgi`
        * Response is a file called `fw.bin`

### Firmware Upload

It is possible to upgrade the firmware via the API.  I would **strongly** recommend doing this via the GUI to ensure that the upgrade is accepted.

*Never* upload the firmware from one model of camera to a different model.

* Upgrade the camera's firmware using HTTP **POST**
    * `/adm/upgrade.cgi`
    * The firmware must be uploaded in base64
    * Wait at least 5 minutes to ensure that the firmware has been successfully flashed.
    
## Reboot and Reset

These controls allow you to reboot/restart the camera.  You can also reset it to its system defaults.

**Note:** There is *no confirmation prompt!* Once you issue these commands, they will execute immediately.

* Reboot the camera
    * `/adm/reboot.cgi`
        * Response `OK`
        * Camera will immediately restart.

* Factory reset the camera
    * `/adm/reset_to_default.cgi`
        * Response `OK`
        * Camera will immediately factory reset.
    
## Software Licenses

The cameras make extensive use of Open Source Software.  You can see the software versions and Open Source Licensing information.

* View software licenses
    * `/adm/Licenses.txt`
        * Response: a text file containing the information 
        
## Time Zones

The cameras use a somewhat baroque way of representing Timezones.  Each zone has a number.  Timezones with daylight savings are marked with an asterisk *. 

- `0` (GMT-12:00) International Date Line West 
- `1` (GMT-11:00) Midway
- `2` (GMT-10:00) Hawaii 
- `3` *(GMT-09:00) Alaska
- `4` *(GMT-08:00) Pacific Time (US & Canada), Tijuana
- `5` (GMT-07:00) Arizona
- `6` *(GMT-07:00) Chihuahua, La Paz, Mazatlan
- `7` *(GMT-07:00) Mountain Time (US & Canada)
- `8` (GMT-06:00) Central America
- `9` *(GMT-06:00) Central Time (US & Canada)
- `10` *(GMT-06:00) Guadalajara, Mexico City, Monterrey
- `11` (GMT-06:00) Saskatchewan 
- `12` (GMT-05:00) Bogota, Lima, Quito
- `13` *(GMT-05:00) Eastern Time (US & Canada) 
- `14` (GMT-05:00) Indiana (East)
- `15` *(GMT-04:00) Atlantic Time (Canada) 
- `16` (GMT-04:00) La Paz 
- `17` *(GMT-04:00) Santiago
- `18` *(GMT-03:30) Newfoundland
- `19` *(GMT-03:00) Brasilia
- `20` (GMT-03:00) Buenos Aires, Georgetown
- `21` *(GMT-03:00) Greenland 
- `22` *(GMT-02:00) Mid-Atlantic
- `23` *(GMT-01:00) Azores
- `24` (GMT-01:00) Cape Verde Is.
- `25` (GMT) Casablanca, Monrovia
- `26` *(GMT) Greenwich Mean Time: Dublin, Edinburgh, Lisbon, London
- `27` *(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
- `28` *(GMT+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague
- `29` *(GMT+01:00) Brussels, Copenhagen, Madrid, Paris
- `30` *(GMT+01:00) Sarajevo, Skopje, Warsaw, Zagreb 
- `31` (GMT+01:00) West Central Africa 
- `32` *(GMT+02:00) Athens, Istanbul, Minsk 
- `33` *(GMT+02:00) Bucharest 
- `34` *(GMT+02:00) Cairo 
- `35` (GMT+02:00) Harare, Pretoria 
- `36` *(GMT+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius 
- `37` (GMT+02:00) Jerusalem 
- `38` *(GMT+03:00) Baghdad 
- `39` (GMT+03:00) Kuwait, Riyadh 
- `40` *(GMT+03:00) Moscow, St. Petersburg, Volgograd 
- `41` (GMT+03:00) Nairobi 
- `42` *(GMT+03:30) Tehran 
- `43` (GMT+04:00) Abu Dhabi, Muscat 
- `44` *(GMT+04:00) Baku, Tbilisi, Yerevan 
- `45` (GMT+04:30) Kabul 
- `46` *(GMT+05:00) Ekaterinburg 
- `47` (GMT+05:00) Islamabad, Karachi, Tashkent 
- `48` (GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi 
- `49` (GMT+05:45) Kathmandu 
- `50` *(GMT+06:00) Almaty, Novosibirsk 
- `51` (GMT+06:00) Astana, Dhaka 
- `52` (GMT+06:00) Sri Jayawardenepura 
- `53` (GMT+06:30) Rangoon 
- `54` (GMT+07:00) Bangkok, Hanoi, Jakarta 
- `55` *(GMT+07:00) Krasnoyarsk 
- `56` (GMT+08:00) Beijing, Chongqing, Hong Kong, Urumqi 
- `57` *(GMT+08:00) Irkutsk, Ulaan Bataar 
- `58` (GMT+08:00) Kuala Lumpur, Singapore 
- `59` (GMT+08:00) Perth 
- `60` (GMT+08:00) Taipei 
- `61` (GMT+09:00) Osaka, Sapporo, Tokyo 
- `62` (GMT+09:00) Seoul 
- `63` *(GMT+09:00) Yakutsk 
- `64` *(GMT+09:30) Adelaide 
- `65` (GMT+09:30) Darwin 
- `66` (GMT+10:00) Brisbane 
- `67` *(GMT+10:00) Canberra, Melbourne, Sydney 
- `68` (GMT+10:00) Guam, Port Moresby 
- `69` *(GMT+10:00) Hobart 
- `70` *(GMT+10:00) Vladivostok 
- `71` (GMT+11:00) Magadan, Solomon Is., New Caledonia 
- `72` *(GMT+12:00) Auckland, Wellington 
- `73` (GMT+12:00) Fiji, Kamchatka, Marshall Is. 
- `74` (GMT+13:00) Nuku'alofa 
- `75` (GMT-04:30) Caracas
                
## TODO!
If you can help with these missing piece of functionality, I would be most grateful.

### Sending Audio
With the speakers enabled, it should be possible to POST an audio file to the cameras, either in G.726, or G.711 (a-law or u-law).   I've not been able to get this working.  [See further discussion](http://stackoverflow.com/questions/19686996/post-audio-to-a-network-camera).

#### Missing Functionality
Not all API calls are documented.  Not all which are in the official documentation are valid. Fill in the gaps :-)
