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

    function appendToLineModel(lat, lon) {
        lineModel.append({"latitude": lat , "longitude": lon});
    }

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
                 line.color: 'red'
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
            model:lineModel
            scale: 1
            property int modelIndexMarkerPoint : 0


            delegate: MapQuickItem {
                id: markerPoint
                property var modelData: model // create persistent modelData property
                property var itemIndex: index // New property

                coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
                anchorPoint.x: rec.width / 2
                anchorPoint.y: rec.height / 2

                sourceItem: Rectangle {
                    id:rec
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
                        lineModel.set(markerPoint.itemIndex, {"latitude": coorinate3.latitude, "longitude": coorinate3.longitude});
                    }
                    onPositionChanged: {
                        var coorinate3 = parent.coordinate
                        lineModel.set(markerPoint.itemIndex, {"latitude": coorinate3.latitude, "longitude": coorinate3.longitude});

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
                            menu.close();
                        }
                    }
                }
            }
        }

    }
}
