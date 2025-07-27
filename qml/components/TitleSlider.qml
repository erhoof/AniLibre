import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0
import ru.erhoof.pagefetcher 1.0

Column {
    anchors {
        left: parent.left
        right: parent.right
    }
    height: 360

    property string sliderTitle: "Default Title"
    property string sliderID: "0"
    property string sliderType: ""

    PageFetcher {
        id: pageFetcher
    }

    function update() {
        sliderModel.clear()
        if(sliderType == "favorites") {
            console.log("reading favs")
            var list = pageFetcher.getFavorites()
            console.log(list)
            for (var key in list) {
                sliderListView.model.append({
                    image: 'https://api.anilibria.app' + list[key].cover,
                    id: list[key].id
                })
            }
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/schedule/now', true);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    for (var key in jsonResponse.today) {
                        sliderModel.append({
                            image: 'https://api.anilibria.app' + jsonResponse.today[key].release.poster.optimized.src,
                            id: jsonResponse.today[key].release.id,
                        })
                    }
                }
            }
        };

        xhr.send();
    }

    SectionHeader {
        anchors {
            left: parent.left
            right: parent.right
        }
        horizontalAlignment: Qt.AlignLeft
        text: sliderTitle
    }

    SilicaListView {
        id: sliderListView

        height: 300
        anchors {
            left: parent.left
            right: parent.right
        }

        spacing: Theme.paddingMedium
        orientation: ListView.Horizontal
        clip: true

        HorizontalScrollDecorator { flickable: sliderListView }

        model: ListModel {
            id: sliderModel
            property var image
            property var id
        }
        delegate: BackgroundItem {
            id: sliderItem

            width: 200
            height: parent.height

            Image {
                id: itemImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: model.image
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: itemImage.width
                        height: itemImage.height
                        radius: 10
                    }
                }

                BusyIndicator {
                    size: BusyIndicatorSize.Medium
                    anchors.centerIn: itemImage
                    running: itemImage.status != Image.Ready
                }
            }

            onClicked: {
                var xhr = new XMLHttpRequest();
                xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/releases/' + model.id, true);

                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            var jsonResponse = JSON.parse(xhr.responseText)
                            pageStack.push(Qt.resolvedUrl("../pages/TitlePage.qml"), {jsonData: jsonResponse})
                        }
                    }
                };

                xhr.send();
            }
        }
    }
}
