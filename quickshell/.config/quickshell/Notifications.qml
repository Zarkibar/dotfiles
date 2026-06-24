import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "config.js" as Config

Scope {
    id: root

    property bool centerOpen: false

    ListModel {
        id: history
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        onNotification: n => {
            history.insert(0, {
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            })
            n.tracked = true
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { root.centerOpen = !root.centerOpen }
        function show(): void { root.centerOpen = true }
        function hide(): void { root.centerOpen = false }
    }

    // ── Live notification toasts ──────────────────────────────────────────
    PanelWindow {
        anchors { top: true; right: true }
        margins { top: 50; right: 12 }
        implicitWidth: 380
        implicitHeight: Math.max(1, toastCol.implicitHeight)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: toastCol
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications
                delegate: Rectangle {
                    id: card
                    required property var modelData

                    Timer {
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: 5000
                        onTriggered: card.modelData.dismiss()
                    }

                    Layout.fillWidth: true
                    implicitHeight: toastInner.implicitHeight + 20

                    radius: 8
                    color: Config.colors.bg
                    border.width: 2
                    border.color: modelData.urgency === NotificationUrgency.Critical
                        ? Config.colors.red : Config.colors.purple

                    RowLayout {
                        id: toastInner
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 10
                        }
                        spacing: 10

                        Image {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            source: card.modelData.image || card.modelData.appIcon || ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Config.colors.cyan
                                font.family: Config.bar.fontFamily
                                font.pixelSize: Config.bar.fontSize
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Config.colors.fg
                                font.family: Config.bar.fontFamily
                                font.pixelSize: Config.bar.fontSize - 1
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                    }
                }
            }
        }
    }

    // ── Notification center panel ─────────────────────────────────────────
    PanelWindow {
        id: centerWindow
        visible: root.centerOpen
        anchors { top: true; right: true }
        margins { top: 50; right: 12 }
        implicitWidth: 380

        // Cap height: either fit content exactly, or stop at 90% of screen height
        property int screenHeight: centerWindow.screen?.height ?? 1080
        property int maxPanelHeight: Math.floor(screenHeight * 0.9) - 50  // subtract top margin
        property int naturalHeight: headerBar.implicitHeight + 24 + 24 + notifFlickable.contentHeight
        implicitHeight: Math.min(naturalHeight, maxPanelHeight)

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            width: parent.width
            height: parent.height
            radius: 10
            color: Config.colors.bg
            border.width: 2
            border.color: Config.colors.purple

            // ── Header (never scrolls away) ──────────────────────────────
            RowLayout {
                id: headerBar
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 12
                }

                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: Config.colors.cyan
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize + 2
                    font.bold: true
                }

                Text {
                    text: "Clear All"
                    visible: history.count > 0
                    color: Config.colors.red
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize - 1

                    MouseArea {
                        anchors.fill: parent
                        onClicked: history.clear()
                    }
                }
            }

            // ── Scrollable cards area ────────────────────────────────────
            Flickable {
                id: notifFlickable
                anchors {
                    top: headerBar.bottom
                    topMargin: 10
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: 12
                    rightMargin: 12
                    bottomMargin: 12
                }

                clip: true
                // contentHeight drives the Flickable — must use implicitHeight of
                // a plain Column, NOT ColumnLayout (ColumnLayout won't report height
                // inside a Flickable)
                contentHeight: cardCol.implicitHeight
                contentWidth: width

                ScrollBar.vertical: ScrollBar {
                    policy: notifFlickable.contentHeight > notifFlickable.height
                        ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                // ── Empty state ──────────────────────────────────────────
                Text {
                    visible: history.count === 0
                    width: parent.width
                    text: "No notifications"
                    color: Config.colors.muted
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize - 1
                    horizontalAlignment: Text.AlignHCenter
                    topPadding: 4
                    bottomPadding: 4
                }

                // ── Card column — plain Column, not ColumnLayout ─────────
                // ColumnLayout never reports implicitHeight inside a Flickable;
                // Column does it correctly.
                Column {
                    id: cardCol
                    width: history.count > 0
                        ? notifFlickable.width - (notifFlickable.contentHeight > notifFlickable.height ? 14 : 0)
                        : notifFlickable.width
                    spacing: 8
                    visible: history.count > 0

                    Repeater {
                        model: history
                        delegate: Rectangle {
                            width: cardCol.width
                            // implicitHeight from inner Column
                            implicitHeight: cardContent.implicitHeight + 16

                            radius: 6
                            color: "transparent"
                            border.width: 1
                            border.color: Config.colors.purple

                            Column {
                                id: cardContent
                                width: parent.width - 16
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: 8
                                spacing: 3

                                // Title row
                                Row {
                                    width: parent.width
                                    spacing: 6

                                    Text {
                                        width: parent.width - timeText.width - dismissText.width - 12
                                        text: model.summary
                                        color: Config.colors.fg
                                        font.family: Config.bar.fontFamily
                                        font.pixelSize: Config.bar.fontSize
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        id: timeText
                                        text: model.time
                                        color: Config.colors.muted
                                        font.family: Config.bar.fontFamily
                                        font.pixelSize: Config.bar.fontSize - 3
                                    }

                                    Text {
                                        id: dismissText
                                        text: "✕"
                                        color: Config.colors.muted
                                        font.family: Config.bar.fontFamily
                                        font.pixelSize: Config.bar.fontSize - 1

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: history.remove(index)
                                        }
                                    }
                                }

                                Text {
                                    width: parent.width
                                    visible: model.body !== ""
                                    text: model.body
                                    color: Config.colors.fg
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize - 1
                                    wrapMode: Text.WordWrap
                                }

                                Text {
                                    visible: model.appName !== ""
                                    text: model.appName
                                    color: Config.colors.muted
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize - 3
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
