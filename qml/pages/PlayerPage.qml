import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtMultimedia 5.6
import Nemo.KeepAlive 1.2

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations
    backgroundColor: "black"
    showNavigationIndicator: false

    property var jsonData
    property var episodeJsonData
    property string resolution

    Component.onCompleted: {
        videoPlayer.source = episodeJsonData.hls_480;
        resolution = "480"
        console.log(jsonData.id)
    }

    DisplayBlanking {
        preventBlanking: videoPlayer.playbackState == MediaPlayer.PlayingState
    }

    DockedPanel {
        id: topPanel

        width: parent.width
        height: Theme.itemSizeSmall

        dock: Dock.Top

        RowLayout {
            anchors {
                fill: parent
                leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
            }

            Label {
                text: jsonData.name.main
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeSmall
                Layout.preferredWidth: 400
            }

            Column {
                Layout.alignment: Qt.AlignRight
                //Layout.fillWidth: true

                Label {
                    text: qsTr("Episode") + " " + episodeJsonData.ordinal
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    text: episodeJsonData.name
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
        }
    }

    BackgroundItem {
        clip: panel.expanded
        highlightedColor: "transparent"

        anchors {
            top: topPanel.bottom
            bottom: panel.top
            left: parent.left
            right: parent.right
        }

        Video {
            id: videoPlayer
            anchors.fill: parent
            autoPlay: true

            onPlaybackStateChanged: {
                if(videoPlayer.playbackState === MediaPlayer.PlayingState) {
                    playPauseButton.icon.source = "image://theme/icon-m-pause"
                } else {
                    playPauseButton.icon.source = "image://theme/icon-m-play"
                }
            }

            onDurationChanged: {
                slider.maximumValue = videoPlayer.duration / 1000;
            }
        }

        onClicked: {
            panel.open = !panel.open
            topPanel.open = !topPanel.open
        }
    }

    DockedPanel {
        id: panel

        width: parent.width
        height: Theme.itemSizeSmall

        dock: Dock.Bottom

        RowLayout {
            width: parent.width
            height: parent.height

            IconButton {
                id: playPauseButton
                anchors {
                    leftMargin: Theme.paddingLarge
                }

                icon.source: "image://theme/icon-m-pause"

                onClicked: {
                    if(videoPlayer.playbackState === MediaPlayer.PlayingState) {
                        videoPlayer.pause();
                    } else {
                        videoPlayer.play();
                    }
                }
            }

            IconButton {
                icon.source: "image://theme/icon-m-previous"
                enabled: false
            }

            IconButton {
                icon.source: "image://theme/icon-m-next"
                enabled: false
            }

            Slider {
                id: slider

                Layout.fillWidth: true

                leftMargin: 0
                rightMargin: Theme.paddingMedium

                minimumValue: 0
                maximumValue: 100

                onReleased: {
                    videoPlayer.seek(value * 1000);
                }
            }

            Label {
                id: positionLabel
                Layout.preferredWidth: 230
            }

            IconButton {
                icon.source: "image://theme/icon-m-browser-sound"
                enabled: false
            }

            PopupMenu {
                id: popupMenu

                PopupMenuItem {
                    id: r480
                    text: "480p"
                    hint: (resolution === "480") ? qsTr("Selected") : ""
                    enabled: (page.episodeJsonData.hls_480 !== null) && (page.episodeJsonData.hls_480 !== undefined)

                    onClicked: {
                        if (resolution === "480") {
                            return
                        }

                        var lastPosition = videoPlayer.position
                        videoPlayer.source = episodeJsonData.hls_480
                        videoPlayer.seek(lastPosition)
                        resolution = "480"
                    }
                }

                PopupMenuItem {
                    id: r720
                    text: "720p"
                    hint: (resolution === "720") ? qsTr("Selected") : ""
                    enabled: (page.episodeJsonData.hls_720 !== null) && (page.episodeJsonData.hls_720 !== undefined)

                    onClicked: {
                        if (resolution === "720") {
                            return
                        }

                        var lastPosition = videoPlayer.position
                        videoPlayer.source = episodeJsonData.hls_720
                        videoPlayer.seek(lastPosition)
                        resolution = "720"
                    }
                }

                PopupMenuItem {
                    id: r1080
                    text: "1080p"
                    hint: (resolution === "1080") ? qsTr("Selected") : ""
                    enabled: (page.episodeJsonData.hls_1080 !== null) && (page.episodeJsonData.hls_1080 !== undefined)

                    onClicked: {
                        if (resolution === "1080") {
                            return
                        }

                        var lastPosition = videoPlayer.position
                        videoPlayer.source = episodeJsonData.hls_1080
                        videoPlayer.seek(lastPosition)
                        resolution = "1080"
                    }
                }
            }

            IconButton {
                icon.source: "image://theme/icon-m-setting"

                onClicked: popupMenu.open()
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        function formatTime(ms) {
            var totalSeconds = Math.floor(ms / 1000);
            var minutes = Math.floor(totalSeconds / 60);
            var seconds = totalSeconds % 60;
            return (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds);
        }

        onTriggered: {
            if (videoPlayer.playbackState === MediaPlayer.PlayingState) {
                slider.value = videoPlayer.position / 1000;
                positionLabel.text = formatTime(videoPlayer.position) + " / " + formatTime(videoPlayer.duration);
            }
        }
    }
}
