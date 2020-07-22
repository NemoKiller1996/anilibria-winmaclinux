import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import Anilibria.Services 1.0
import "../Theme"
import "../Controls"

Page {
    id: root
    anchors.fill: parent
    background: Rectangle {
        color: ApplicationTheme.pageBackground
    }

    property var downloads: []

    signal navigateFrom()
    signal navigateTo()

    onNavigateTo: {
        downloadItems.clear();
        const downloads = JSON.parse(localStorage.getDownloads());
        root.downloads = downloads;

        const releases = localStorage.getDownloadsReleases();
        for (const release of releases) {
            const releaseModel = JSON.parse(release);
            const releaseDownloads = downloads.filter(a => a.releaseId === releaseModel.id);
            releaseModel.countHdDownloads = releaseDownloads.filter(a => a.quality === 1).length;
            releaseModel.countHdDownloadsCompleted = releaseDownloads.filter(a => a.quality === 1 && a.downloaded).length;
            releaseModel.countSdDownloads = releaseDownloads.filter(a => a.quality === 2).length;
            releaseModel.countSdDownloadsCompleted = releaseDownloads.filter(a => a.quality === 2 && a.downloaded).length;
            downloadItems.append(releaseModel);
        }
    }

    ListModel {
        id: downloadItems
    }

    DownloadManager {
        id: downloadManager
        url: "https://de8.libria.fun/get/g28o9Wzv092760bVDE--yw/1595013300/mp4/8671/0001.mp4?download=OreGairu%203-1-hd.mp4"
        destination: ""
        onError: {
            console.log(errorString);
        }
    }

    Rectangle {
        id: mask
        width: 180
        height: 260
        radius: 10
        visible: false
    }

    RowLayout {
        id: panelContainer
        anchors.fill: parent
        spacing: 0
        Rectangle {
            color: ApplicationTheme.pageVerticalPanel
            width: 40
            Layout.fillHeight: true
            Column {
                IconButton {
                    height: 45
                    width: 40
                    iconColor: "white"
                    iconPath: "../Assets/Icons/menu.svg"
                    iconWidth: 29
                    iconHeight: 29
                    onButtonPressed: {
                        drawer.open();
                    }
                }
                IconButton {
                    id: startDownload
                    height: 45
                    width: 40
                    iconColor: "white"
                    iconPath: "../Assets/Icons/refresh.svg"
                    iconWidth: 34
                    iconHeight: 34
                    onButtonPressed: {
                        downloadManager.start();
                    }
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: "Запустить скачивание видео файлов"
                }
            }
        }

        ColumnLayout {
            id: itemContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 2

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                height: 45
                color: ApplicationTheme.pageUpperPanel

                PlainText {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: downloadManager.running
                    fontPointSize: 12
                    text: "Скачивается " + downloadManager.displayBytesInSeconds + " " + Math.floor(downloadManager.progress)
                }
            }

            ListView {
                id: downloadReleases
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: downloadItems
                clip: true
                spacing: 4
                delegate: Rectangle {
                    width: itemContainer.width
                    height: 220
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        radius: 10
                        color: ApplicationTheme.panelBackground

                        RowLayout {
                            anchors.fill: parent

                            Rectangle {
                                color: "transparent"
                                height: parent.height
                                Layout.preferredWidth: 130
                                Layout.leftMargin: 6

                                Image {
                                    anchors.centerIn: parent
                                    source: localStorage.getReleasePosterPath(id, poster)
                                    sourceSize: Qt.size(180, 270)
                                    fillMode: Image.PreserveAspectCrop
                                    width: 110
                                    height: 200
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: mask
                                    }
                                }
                            }

                            Rectangle {
                                height: parent.height
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"

                                ColumnLayout {
                                    spacing: 4
                                    anchors.fill: parent

                                    AccentText {
                                        id: titleText
                                        Layout.preferredHeight: 20
                                        Layout.topMargin: 8
                                        fontPointSize: 12
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        text: title
                                    }

                                    PlainText {
                                        id: hdSeriesDownloadedText
                                        Layout.preferredHeight: 20
                                        visible: countHdDownloads > 0
                                        fontPointSize: 10
                                        height: 60
                                        text: countHdDownloads + " cерий в HD качестве, скачано " + countHdDownloadsCompleted
                                    }

                                    PlainText {
                                        visible: countSdDownloads > 0
                                        Layout.preferredHeight: 20
                                        fontPointSize: 10
                                        text: "Серий в SD качестве " + countSdDownloads + " скачано " + countSdDownloadsCompleted
                                    }

                                    Item {
                                        Layout.fillHeight: true
                                    }
                                }
                            }
                            Rectangle {
                                Layout.preferredWidth: 200
                                Layout.rightMargin: 6
                                height: parent.height
                                color: "transparent"
                            }
                        }
                    }
                }
            }
        }
    }
}
