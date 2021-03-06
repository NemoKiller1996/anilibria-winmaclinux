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
    property var downloadingRelease: ({})
    property var currentDownload: ({})

    signal navigateFrom()
    signal navigateTo()

    onNavigateTo: {
        downloadItems.clear();
        refreshDownloads();

        const releases = localStorage.getDownloadsReleases();
        for (const release of releases) {
            const releaseModel = JSON.parse(release);
            const releaseDownloads = downloads.filter(a => a.releaseId === releaseModel.id);
            releaseModel.countHdDownloads = releaseDownloads.filter(a => a.quality === 1).length;
            releaseModel.countHdDownloadsCompleted = releaseDownloads.filter(a => a.quality === 1 && a.downloaded).length;
            releaseModel.countSdDownloads = releaseDownloads.filter(a => a.quality === 2).length;
            releaseModel.countSdDownloadsCompleted = releaseDownloads.filter(a => a.quality === 2 && a.downloaded).length;
            releaseModel.isSelected = false;
            downloadItems.append(releaseModel);
        }
    }

    ListModel {
        id: downloadItems
    }

    DownloadManager {
        id: downloadManager
        url: ""
        onError: {
            applicationNotification.sendNotification(
                {
                    type: "error",
                    message: `Ошибка скачивания серии ${root.downloadingRelease.videoId} в релизе ${root.currentDownload.title}.`
                }
            );
        }
        onFinished: {
            applicationNotification.sendNotification(
                {
                    type: "info",
                    message: `Cерия ${root.downloadingRelease.videoId} в релизе ${root.currentDownload.title} успешно скачана.`
                }
            );

            localStorage.finishDownloadItem(root.downloadingRelease.id, root.currentDownload.videoId, root.currentDownload.quality, downloadedPath);

            refreshDownloads();

            takeNextDownloadItem();
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
                    visible: !downloadManager.running
                    height: 45
                    width: 40
                    iconColor: "white"
                    iconPath: "../Assets/Icons/startdownload.svg"
                    iconWidth: 34
                    iconHeight: 34
                    onButtonPressed: {
                        takeNextDownloadItem();
                    }
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: "Запустить скачивание видео файлов"
                }
                IconButton {
                    id: stopDownload
                    visible: downloadManager.running
                    height: 45
                    width: 40
                    iconColor: "white"
                    iconPath: "../Assets/Icons/stopdownload.svg"
                    iconWidth: 34
                    iconHeight: 34
                    onButtonPressed: {
                        downloadManager.stop();
                    }
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: "Остановить скачивание файлов"
                }
                IconButton {
                    id: trashDownload
                    height: 45
                    width: 40
                    iconColor: "white"
                    iconPath: "../Assets/Icons/trash.svg"
                    iconWidth: 30
                    iconHeight: 30
                    onButtonPressed: {
                        takeNextDownloadItem();
                    }
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: "Удалить все видео файлы выбранных релизов"
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
                    text: "Выполняется скачивание, скорость " + downloadManager.displayBytesInSeconds + " скачано " + Math.floor(downloadManager.progress) + "%"
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
                        border.color: ApplicationTheme.selectedItem
                        border.width: isSelected ? 3 : 0

                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                toggleSelected(id);
                            }
                        }

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

                                        PlainText {
                                            visible: root.downloadingRelease && root.downloadingRelease.id === id
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 10
                                            fontPointSize: 10
                                            text: " >> Скачивается серия " + (root.currentDownload ? root.currentDownload.videoId : "")
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: rightBlock
                                Layout.preferredWidth: 200
                                Layout.fillHeight: true
                                Layout.rightMargin: 6
                                height: parent.height
                                color: "transparent"

                                Column {
                                    anchors.centerIn: parent

                                    Item {
                                        width: rightBlock.width
                                        height: 40

                                        Image {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 40
                                            height: 40
                                            mipmap: true
                                            source: root.downloadingRelease.id === id ? "../Assets/Icons/downloading.svg" : (countHdDownloads === countHdDownloadsCompleted ? "../Assets/Icons/downloadcheck.svg" : "../Assets/Icons/idledownload.svg")
                                        }
                                    }

                                    Item {
                                        width: rightBlock.width
                                        height: 40

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: root.downloadingRelease.id === id ? "Скачивается" : (countHdDownloads === countHdDownloadsCompleted ? "Скачано" : "В очереди")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function refreshDownloads() {
        root.downloads = JSON.parse(localStorage.getDownloads());
    }

    function getReleaseById(id) {
        for (let i = 0; i < downloadItems.count; i++) {
            const release = downloadItems.get(i);
            if (release.id === id) return release;
        }

        return null;
    }

    function takeNextDownloadItem() {
        const downloadItem = root.downloads.find(a => !a.downloaded);
        root.downloadingRelease = getReleaseById(downloadItem.releaseId);
        root.currentDownload = downloadItem;
        const videos = JSON.parse(root.downloadingRelease.videos);
        const video = videos.find(a => a.id === downloadItem.videoId + 1);

        const url = downloadItem.quality === 2 ? video.srcSd : video.srcHd;
        downloadManager.url = url;
        downloadManager.saveFileName = `${root.downloadingRelease.id}${downloadItem.videoId}.mp4`;
        downloadManager.start();
    }

    function toggleSelected(id) {
        for (let i = 0; i < downloadItems.count; i++) {
            const release = downloadItems.get(i);
            if (release.id === id) {
                release.isSelected = !release.isSelected;
                break;
            }
        }
    }

}
