import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtLocation 5.15
import QtPositioning 5.15
import Qt.labs.qmlmodels 1.0
import Qt.labs.platform 1.0
import QtCharts 2.15

Item {
    id:graficItem
    width: parent.width
    height: parent.height / 3
    z:1
    anchors.bottom: parent.bottom

    function updateChartData() {
//        lineSeriesDistance.clear()
        lineSeriesAzimuth.clear()
        for (var i = 0; i < lineModel.count; i++) {
            var item = lineModel.get(i)
//            lineSeriesDistance.append(i, item.distance)
            lineSeriesAzimuth.append(i, item.azimuth)
            scatterSeriesAzimuth.append(i, item.distance)
        }
    }
    ChartView {
           id: chartView
           anchors.fill: parent
           theme: ChartView.ChartThemeDark
           legend.visible: true
           title: "Azimuth"
           dropShadowEnabled: true
           opacity: 0.4
           antialiasing: true // функція для зглажування графіка
           MouseArea {
            anchors.fill: parent
           }
           ValueAxis {
               id: valueAxisXDistance
               titleText: "Distance (m)"
               min: 0
               max: 100000
           }

           ValueAxis {
               id: valueAxisYAzimuth
               titleText: "Azimuth (degrees)"
               min: 0
               max: 360
           }

           LineSeries {
               id: lineSeriesAzimuth
               name: "Azimuth"
               axisX: valueAxisXDistance
               axisY: valueAxisYAzimuth
               pointsVisible: true
           }

           ScatterSeries {
               id: scatterSeriesAzimuth
               name: "Azimuth Points"
               axisX: valueAxisXDistance
               axisY: valueAxisYAzimuth
               markerSize: 10
           }

       }
//    ChartView {
//        id: chartView
//        anchors.fill: parent
//        theme: ChartView.ChartThemeDark
//        legend.visible: true
//        title: "Distance and Azimuth"

//        ValueAxis {
//            id: valueAxisX
//            titleText: "Distance (m)"
//        }

//        ValueAxis {
//            id: valueAxisYAzimuth
//            titleText: "Azimuth (degrees)"
//        }

//        LineSeries {
//            id: lineSeriesDistance
//            name: "Distance"
//            axisX: valueAxisX
//        }

//        LineSeries {
//            id: lineSeriesAzimuth
//            name: "Azimuth"
//            axisX: valueAxisX
//            axisY: valueAxisYAzimuth
//        }
//    }
}
