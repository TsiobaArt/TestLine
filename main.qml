import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1
import Qt.labs.qmlmodels 1.0
import Qt.labs.platform 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    property int totalPoints: lineModel.count
    property real totalDistance: 0
    property real totalAngle: 0

    function updateProperties() {
        totalPoints = lineModel.count
        totalDistance = calculateTotalDistance()
        totalAngle = calculateTotalAngle()
    }

    function calculateTotalDistance() {
        var total = 0
        for (var i = 1; i < lineModel.count; ++i) {
            var coord1 = QtPositioning.coordinate(lineModel.get(i-1).latitude, lineModel.get(i-1).longitude)
            var coord2 = QtPositioning.coordinate(lineModel.get(i).latitude, lineModel.get(i).longitude)
            total += coord1.distanceTo(coord2)
        }
        return total / 1000 // convert from meters to kilometers
    }

    function calculateTotalAngle() {
        var total = 0
        for (var i = 2; i < lineModel.count; ++i) {
            var coord1 = QtPositioning.coordinate(lineModel.get(i-2).latitude, lineModel.get(i-2).longitude)
            var coord2 = QtPositioning.coordinate(lineModel.get(i-1).latitude, lineModel.get(i-1).longitude)
            var coord3 = QtPositioning.coordinate(lineModel.get(i).latitude, lineModel.get(i).longitude)
            var angle1 = coord1.azimuthTo(coord2)
            var angle2 = coord2.azimuthTo(coord3)
            total += Math.abs(angle2 - angle1)
        }
        return total
    }

    ListModel {id: lineModel}
    property bool rulerMode: true

    function appendToLineModel(lat, lon) {
        lineModel.append({"latitude": lat , "longitude": lon});
    }

    function updatePolyline() {
        var path = [];
        for (var i = 0; i < lineModel.count; ++i) {
            var coord = lineModel.get(i);
            path.push(QtPositioning.coordinate(coord.latitude, coord.longitude));
        }
        linePolyline.path = path;
    }

    Map {
        id:map
        anchors.fill: parent
        plugin: Plugin {name: "mapboxgl"}
        center: QtPositioning.coordinate(50.527887655789385, 30.614663315058465)
        zoomLevel: 14

        MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                if(rulerMode) {
                    var clickedCoordinaye = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                    appendToLineModel(clickedCoordinaye.latitude, clickedCoordinaye.longitude)
                    updateProperties()
                }
                console.log (lineModel.count)
                updatePolyline();

            }

        }

        MapItemGroup {
            id:lineGroup
            z:1

            MapPolyline {
                id: linePolyline
                line.color: "orange"
                line.width: 2
            }

            MapItemView {
                model:lineModel
                scale: 1

                delegate: MapQuickItem {
                    id: markerPoint
                    property var modelData: model // create persistent modelData property
                    coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
                    anchorPoint.x: rec.width / 2
                    anchorPoint.y: rec.height / 2
                    sourceItem: Rectangle {
                        id:rec
                        width: 28
                        height: 28
                        radius: 28
                        color: "red"

                        Rectangle {
                            width: 22
                            height: 22
                            radius: 22
                            anchors.centerIn: parent
                            color: "black"

                            Rectangle {
                                width: 16
                                height: 16
                                radius: 16
                                anchors.centerIn: parent
                                color: "white"
                                Text {
                                    text: index
                                    color:  "black"
                                    font.pixelSize: 11
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        // hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        drag.target: parent
                        onPositionChanged: {
                            var newCoordinate = map.toCoordinate(map.mapFromItem(parent, mouse.x, mouse.y));
                            lineModel.setProperty(index, "latitude", newCoordinate.latitude); // Изменяет свойство элемента по индексу в модели списка на значение.
                            lineModel.setProperty(index, "longitude", newCoordinate.longitude);
                            updatePolyline();
                        }
                        onPressed:  {
                            console.log("onPressed")
                            if (mouse.button == Qt.RightButton) {
                                markerMenu.target = markerPoint.modelData // use modelData instead of model
                                markerMenu.open()
                            }
                        }
                    }
                    Menu {
                        id: markerMenu

                        property var target: null
                        MenuItem {
                            text: "Delete"
                            onTriggered: {
                                for (var i = 0; i < lineModel.count; ++i) {
                                    var item = lineModel.get(i);
                                    if (item.latitude === markerMenu.target.latitude && item.longitude === markerMenu.target.longitude) {
                                        lineModel.remove(i);
                                        break;
                                    }
                                }
                                updatePolyline()
                                menu.close();
                            }
                        }
                    }
                }
            }
        }
        Button {
            text: "Clear All"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            onClicked: {
                lineModel.clear()
                updatePolyline();

            }
        }

        Rectangle {
            width: 200
            height: 150
            color: "#A6A1A1"
            anchors.top: parent.top
            anchors.left: parent.left
            Column {
                id: textLine
                anchors.fill: parent
                anchors.topMargin: 15
                spacing: 15

                Text {
                    id: pointsText
                    text: "Кількість точок: " + totalPoints
                    font.family: "Agency FB"
                    color: "#FFFFFF"
                    font.pointSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: distanceText
                    text: "Загальна відстань: " + totalDistance + " км"
                    font.family: "Agency FB"
                    color: "#FFFFFF"
                    font.pointSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: angleText
                    text: "Загальний кут: " + totalAngle + " градусів"
                    font.family: "Agency FB"
                    color: "#FFFFFF"
                    font.pointSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
