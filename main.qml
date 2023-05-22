import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtLocation 5.15
import QtPositioning 5.15
import Qt.labs.qmlmodels 1.0
import Qt.labs.platform 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    ListModel {id: lineModel}

    function updatePropery(idx,lat,lon){
        var newCoordinate = QtPositioning.coordinate(lat, lon)
        var distance = 0
        var azimuth = 0
        var prevCoordinate
        if (idx > 0) {
            var lastPoint = lineModel.get(idx - 1)
            console.log ("Index " + idx)
            console.log ("lastPoint.latitide" + lastPoint.latitude)
            prevCoordinate = QtPositioning.coordinate(lastPoint.latitude, lastPoint.longitude)
            distance = prevCoordinate.distanceTo(newCoordinate)
            azimuth = prevCoordinate.azimuthTo(newCoordinate)
        }
        lineModel.set(idx, {"distance" :distance, "azimuth" : azimuth  });

    }

    function appendToLineModel(lat, lon) {
        var newCoordinate = QtPositioning.coordinate(lat, lon)
        var prevCoordinate
        var distance = 0
        var azimuth = 0
        if (lineModel.count > 0) {
            var lastPoint = lineModel.get(lineModel.count - 1)
            prevCoordinate = QtPositioning.coordinate(lastPoint.latitude, lastPoint.longitude)
            distance = prevCoordinate.distanceTo(newCoordinate)
            azimuth = prevCoordinate.azimuthTo(newCoordinate)
        }
        lineModel.append({"latitude": lat, "longitude": lon, "distance": distance, "azimuth": azimuth});

//        lineModel.append({"latitude": lat , "longitude": lon});

    }

    function updateLineModel () {


    }

    function angleBetweenPoints(p1, p2) {
        var dy = p2.y - p1.y;
        var dx = p2.x - p1.x;
        var theta = Math.atan2(dy, dx); // range (-PI, PI]
        theta *= 180 / Math.PI; // rads to degrees, range (-180, 180]
        return theta;
    }
    function toWindowCoordinates(coordinate) {
        var point = map.fromCoordinate(coordinate);
        return Qt.point(point.x, point.y);
    }
//    function angleBetweenPoints2(p1, p2) {
//        var dy = p2.y - p1.y;
//        var dx = p2.x - p1.x;
//        var theta = Math.atan2(dy, dx); // range (-PI, PI]
//        theta *= 180 / Math.PI; // rads to degrees, range (-180, 180]
//        // add 90 to theta here if the text is rotated by 90 degrees
//        return theta;
//    }
    function angleBetweenPoints3(p1, p2) {
        var dy = p2.y - p1.y;
        var dx = p2.x - p1.x;
        var theta = Math.atan2(dy, dx); // range (-PI, PI]
        theta *= 180 / Math.PI; // rads to degrees, range (-180, 180]
        if (theta < 0) theta = 360 + theta; // convert to 0-360 degrees range
        return theta;
    }
    function angleBetweenPoints2(p1, p2) {
        let dx = p2.x - p1.x;
        let dy = p2.y - p1.y;
        let angle = Math.atan2(dy, dx) * 180 / Math.PI;
        return (angle < 0) ? angle + 360 : angle;
    }
    function adjustAngle(p1, p2) {
        let angle = angleBetweenPoints2(p1, p2);
        let adjustedAngle = 90 - angle;
        return adjustedAngle;
    }
//    function adjustAngle(point1, point2) {
//        var angle = Math.atan2(point2.latitude - point1.latitude, point2.longitude - point1.longitude);
//        return -(angle * 180 / Math.PI);
//    }
    Map {
        id: map
        anchors.fill: parent
        plugin: Plugin {name: "mapboxgl"}
        center: QtPositioning.coordinate(50.527887655789385, 30.614663315058465)
        zoomLevel: 14

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onDoubleClicked: {
                var clickedCoordinaye = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                appendToLineModel(clickedCoordinaye.latitude, clickedCoordinaye.longitude)
            }
        }

        MapPolyline {
            id: polyline
            line.width: 3
            line.color: 'orange'
            path: {
                var coordinates = [];
                for (var i = 0; i < lineModel.count; i++) {
                    var item = lineModel.get(i);
                    coordinates.push(QtPositioning.coordinate(item.latitude, item.longitude));
                }
                return coordinates;
            }
        }

        MapItemView {
            id: itemViewLine
            model: lineModel
            scale: 1

            property int modelIndexMarkerPoint: 0

            delegate: MapQuickItem {
                id: markerPoint
                property var modelData: model // create persistent modelData property
                property var itemIndex: index // New property

                coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
                anchorPoint.x: rec.width / 2
                anchorPoint.y: rec.height / 2

                sourceItem: Rectangle {
                    id: rec
                    width: 28
                    height: 28
                    radius: 28
                    color: "lightblue"

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
                                color: "black"
                                font.pixelSize: 11
                                anchors.centerIn: parent
                            }
                        }
                    }

                    Rectangle {
                        id: distanceDisplay
                        width: 150
                        height: 20
                        color: "transparent"
                        anchors {
                            top: rec.bottom
                            horizontalCenter: rec.horizontalCenter
                        }
                        Text {
                            text: model.distance.toFixed(2) + " m, "
                            anchors.centerIn: parent
                            color: "black"
                        }
                    }

                    Rectangle {
                        id: azimuthDisplay
                        width: 150
                        height: 20
                        anchors.bottom: parent.top
                        color: "transparent"
                        anchors {
                            top: rec.top
                            horizontalCenter: rec.horizontalCenter
                        }
                        Text {
                            text: model.azimuth.toFixed(2) + " degrees"
                            anchors.centerIn: parent
                            color: "black"
                        }
                    }

                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    drag.target: markerPoint
                    hoverEnabled: true
                    drag.axis: Drag.XAndYAxis

                    onClicked:  {
                        if (mouse.button == Qt.RightButton) {
                            markerMenu.target = markerPoint.modelData // use modelData instead of model
                            markerMenu.open()
                        }
                    }

                    onEntered: {
                        itemViewLine.modelIndexMarkerPoint = index
                        console.log ("itemViewLine.modelIndexMarkerPoint " + itemViewLine.modelIndexMarkerPoint)
                    }

                    onReleased: {
                        var coorinate3 = parent.coordinate
                        lineModel.set(model.index, {"latitude": coorinate3.latitude, "longitude": coorinate3.longitude});
                    }

                    onPositionChanged: {
                        var coorinate3 = parent.coordinate
                        lineModel.set(model.index, {"latitude": coorinate3.latitude, "longitude": coorinate3.longitude});
                        updatePropery(index, coorinate3.latitude, coorinate3.longitude)

                    }
                }

                Menu {
                    id: markerMenu
                    Timer { // Додав таймер для того щоб маркери видалялися перш ніж до нього можгна буде звернутися
                        id: timerDeleteMarker;
                        interval: 200;
                        onTriggered: {
                            for (var i = 0; i < lineModel.count; ++i) {
                                var item = lineModel.get(i);
                                if (item.latitude === markerMenu.target.latitude && item.longitude === markerMenu.target.longitude) {
                                    lineModel.remove(i);
                                    break;
                                }
                            }
                            for (var k = index + 1; k < lineModel.count; ++k) { // додав щоб оновити дані після видалення
                                var point = lineModel.get(k)
                                updatePropery(k, point.latitude, point.longitude)
                            }
                        }
                    }
                    property var target: null
                    MenuItem {
                        text: "Delete"
                        onTriggered: {
                            mouseArea.enabled = false
                            timerDeleteMarker.start()
                            menu.close();
                        }
                    }
                }
            }
        }
        MapItemView {
            id: itemViewLineInfo
            model: lineModel
            delegate: MapQuickItem {
                id: markerPointInfo
                property var modelData: model
                property var itemIndex: index

                coordinate: index > 0 ? QtPositioning.coordinate(
                    (model.latitude + lineModel.get(index - 1).latitude) / 2,
                    (model.longitude + lineModel.get(index - 1).longitude) / 2
                ) : QtPositioning.coordinate(model.latitude, model.longitude)
                rotation: itemIndex > 0 ? angleBetweenPoints2(
                          toWindowCoordinates(QtPositioning.coordinate(model.latitude, model.longitude)),
                          toWindowCoordinates(QtPositioning.coordinate(lineModel.get(itemIndex - 1).latitude, lineModel.get(itemIndex - 1).longitude))
                      ) : 0
                anchorPoint.x: lineInfoLabel.width / 2
                anchorPoint.y: lineInfoLabel.height / 2

                sourceItem: Label {
                    id: lineInfoLabel
                    visible: markerPointInfo.itemIndex > 0
                    text: modelData.distance.toFixed(2) + " m, " + modelData.azimuth.toFixed(2) + " degrees"
                    color: "black"
//                    rotation: -markerPointInfo.rotation // counter-rotate the text to ensure it is horizontally readable
                }
            }
        }
    }
}
