import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0

Page {
    id: page

    allowedOrientations: defaultAllowedOrientations

    property var splitViewRef

    AppBar {
        id: searchHeader

        AppBarSearchField {
            id: searchField
            placeholderText: qsTr("Title name")

            Component.onCompleted: focus = true

            EnterKey.onClicked: {
                searchModel.clear()

                var xhr = new XMLHttpRequest();
                xhr.open("GET", 'https://api.anilibria.app/api/v1/app/search/releases?query=' + searchField.text, true);

                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            var jsonResponse = JSON.parse(xhr.responseText);
                            for (var key in jsonResponse) {
                                searchModel.append({
                                    image: 'https://api.anilibria.app' + jsonResponse[key].poster.optimized.src,
                                    name: jsonResponse[key].name.main,
                                    description: jsonResponse[key].description,
                                    id: jsonResponse[key].id
                                })
                            }
                        }
                    }
                };

                xhr.send();
                focus = false;
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-filter"
            enabled: false
        }
    }

    SilicaListView {
        id: searchListView

        anchors {
            top: searchHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            margins: Theme.horizontalPageMargin
        }

        clip: true
        spacing: Theme.paddingLarge

        VerticalScrollDecorator { flickable: updatesListView }

        model: ListModel {
            id: searchModel
            property var image
            property var name
            property var description
            property var id
        }

        delegate: Loader {
            width: parent.width
            source: "../components/TitleElement.qml"
        }
    }
}
