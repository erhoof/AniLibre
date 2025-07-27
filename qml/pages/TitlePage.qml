import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0
import ru.erhoof.pagefetcher 1.0

Page {
    id: page

    allowedOrientations: defaultAllowedOrientations

    property var jsonData

    PageFetcher {
        id: pageFetcher
    }

    onStatusChanged: {
        if (PageStatus.Activating == status) {
            startReadingButton.updateButton()
        }
    }

    AppBar {
        id: appBar
        headerText: jsonData.name.main

        AppBarSpacer {}

        AppBarButton {
            property var isFavorite
            text: jsonData.added_in_users_favorites

            Component.onCompleted: {
                isFavorite = pageFetcher.isFavorite(jsonData.id)
                if(isFavorite) {
                    icon.source = "image://theme/icon-m-favorite-selected"
                } else {
                    icon.source = "image://theme/icon-m-favorite"
                }
            }

            onClicked: {
                isFavorite = !isFavorite
                pageFetcher.setFavorite(jsonData.id, isFavorite, jsonData.poster.optimized.src);
                if(isFavorite) {
                    icon.source = "image://theme/icon-m-favorite-selected"
                } else {
                    icon.source = "image://theme/icon-m-favorite"
                }
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-more"
            enabled: false
        }
    }

    SilicaFlickable {
        anchors {
            top: appBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            topMargin: Theme.paddingMedium
            leftMargin: Theme.horizontalPageMargin
        }

        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator { flickable: column }

        Column {
            id: column
            width: parent.width - Theme.horizontalPageMargin
            spacing: Theme.paddingMedium
            clip: true

            Image {
                id: image
                anchors.horizontalCenter: parent.horizontalCenter
                source: 'https://api.anilibria.app' + jsonData.poster.optimized.src

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: image.width
                        height: image.height
                        radius: 10
                    }
                }

                BusyIndicator {
                    size: BusyIndicatorSize.Medium
                    anchors.centerIn: image
                    running: image.status != Image.Ready
                }
            }

            RowLayout {
                width: parent.width
                spacing: Theme.paddingMedium

                Button {
                    id: startReadingButton
                    Layout.fillWidth: true
                    text: qsTr("Start watching")
                    enabled: false

                    property int savedEpisode: 0

                    onClicked: {
                        var id = savedEpisode;
                        if(!savedEpisode) {
                            if(!episodesModel.count) {
                                return
                            }

                            id += 1
                            pageFetcher.setWatchStatus(page.jsonData.id, id)
                        }

                        var data = episodesModel.get(id - 1).jsonData
                        pageStack.push(Qt.resolvedUrl("PlayerPage.qml"), {jsonData: page.jsonData, episodeJsonData: data});
                    }

                    function updateButton() {
                        var status = pageFetcher.getWatchStatus(jsonData.id)
                        console.log(status)
                        if(!status.status) {
                            text = qsTr("Start watching");
                            return;
                        }

                        text = qsTr("Continue")
                                + " - "
                                + qsTr("Episode") + " " + status.status.episode;
                        savedEpisode = status.status.episode
                    }
                }

                Button {
                    icon.source: "image://theme/icon-s-more"
                    enabled: false
                }
            }

            Rectangle {
                width: parent.width
                height: infoColumn.height + Theme.paddingMedium * 1.5
                color: Qt.rgba(1, 1, 1, 0.2)
                radius: 8

                Column {
                    id: infoColumn
                    anchors.verticalCenter: parent.verticalCenter
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingMedium
                    }

                    Label {
                        width: parent.width
                        text: jsonData.name.main
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        width: parent.width
                        text: jsonData.name.english
                        wrapMode: Text.WordWrap
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Update:")
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                        }

                        Label {
                            color: Theme.secondaryHighlightColor
                            text: Qt.formatDateTime(jsonData.updated_at, "dd MMMM yyyy, hh:mm")
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: Theme.paddingLarge
                        color: "transparent"
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 2
                            color: Theme.secondaryColor
                            opacity: 0.8
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Season:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: jsonData.year + " " + jsonData.season.description;
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Type:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: jsonData.type.description
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Genres:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            property string joined: jsonData.genres.map(
                                                        function(genre) { return genre.name; }).join(", ")

                            color: Theme.secondaryColor
                            text: joined
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        property var kindFilter: jsonData.members.filter(function(member) {
                            return member.role.value === "voicing";
                        })

                        property string nicknames: kindFilter.map(function(member) {
                            return member.nickname;
                        }).join(", ")

                        visible: nicknames.length != 0

                        Label {
                            text: qsTr("Voice acting:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: parent.nicknames
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        property var kindFilter: jsonData.members.filter(function(member) {
                            return member.role.value === "timing";
                        })

                        property string nicknames: kindFilter.map(function(member) {
                            return member.nickname;
                        }).join(", ")

                        visible: nicknames.length != 0

                        Label {
                            text: qsTr("Timing:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: parent.nicknames
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        property var kindFilter: jsonData.members.filter(function(member) {
                            return member.role.value === "editing";
                        })

                        property string nicknames: kindFilter.map(function(member) {
                            return member.nickname;
                        }).join(", ")

                        visible: nicknames.length != 0

                        Label {
                            text: qsTr("Editors:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: parent.nicknames
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("State:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: jsonData.is_ongoing ? qsTr("Ongoing") : qsTr("Finished")
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }

            Text {
                width: parent.width

                color: Theme.secondaryColor
                text: jsonData.description
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }

            RowLayout {
                width: parent.width

                Column {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Support AniLibria")
                    }

                    Text {
                        color: Theme.secondaryColor
                        wrapMode: Text.WordWrap
                        text: qsTr("Liked our voice? Support us")
                    }
                }

                Icon {
                    Layout.alignment: Qt.AlignRight
                    source: "image://theme/icon-m-battery-saver"
                }
            }

            ListView {
                id: episodesListView

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: contentHeight

                clip: true
                spacing: Theme.paddingMedium

                model: ListModel {
                    id: episodesModel
                    property var episode
                    property var updateTime
                    property var name
                    property var jsonData
                }
                delegate: BackgroundItem {
                    id: episodesItem
                    width: parent.width
                    height: 100

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(1, 1, 1, 0.2)
                        radius: 8

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: Theme.paddingMedium
                            }

                            RowLayout {
                                width: parent.width

                                Label {
                                    Layout.alignment: Qt.AlignLeft
                                    text: qsTr("Episode") + " " + model.episode
                                }

                                Label {
                                    font.pixelSize: Theme.fontSizeSmall
                                    Layout.alignment: Qt.AlignRight
                                    text: Qt.formatDateTime(model.updateTime, "dd MMMM yyyy, hh:mm")
                                    color: Theme.secondaryHighlightColor
                                }
                            }

                            Label {
                                text: model.name
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("PlayerPage.qml"), {jsonData: page.jsonData, episodeJsonData: model.jsonData});
                        pageFetcher.setWatchStatus(page.jsonData.id, model.episode)
                    }
                }

                Component.onCompleted: {
                    console.log("Loading episodes")
                    for (var key in jsonData.episodes) {
                        episodesModel.append({
                            episode: jsonData.episodes[key].ordinal,
                            updateTime: jsonData.episodes[key].updated_at,
                            name: jsonData.episodes[key].name,
                            jsonData: jsonData.episodes[key],
                        })
                    }

                    if(jsonData.episodes.length) {
                        startReadingButton.enabled = true
                    }
                }
            }
        }
    }
}
