import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
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
                    // implicitHeight bubbles up from the inner layout
                    implicitHeight: toastInner.implicitHeight + 20

                    radius: 8
                    color: Config.colors.bg
                    border.width: 2
                    border.color: modelData.urgency === NotificationUrgency.Critical
                        ? Config.colors.red : Config.colors.purple

                    RowLayout {
                        id: toastInner
                        // anchor left/right + top only; let height be implicit
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
        visible: root.centerOpen
        anchors { top: true; right: true }
        margins { top: 50; right: 12 }
        implicitWidth: 380
        // PanelWindow height = outer padding (24) + the ColumnLayout's natural height
        implicitHeight: centerCol.implicitHeight + 24
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            // Match the window exactly
            width: parent.width
            height: parent.height
            radius: 10
            color: Config.colors.bg
            border.width: 2
            border.color: Config.colors.purple

            // ColumnLayout drives its own height; do NOT anchors.fill here
            ColumnLayout {
                id: centerCol
                width: parent.width - 24   // 12px padding each side
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 12
                spacing: 10

                // ── Header ──────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true

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

                // ── Empty state ──────────────────────────────────────────
                Text {
                    visible: history.count === 0
                    Layout.fillWidth: true
                    text: "No notifications"
                    color: Config.colors.muted
                    font.family: Config.bar.fontFamily
                    font.pixelSize: Config.bar.fontSize - 1
                    horizontalAlignment: Text.AlignHCenter
                    Layout.bottomMargin: 4
                }

                // ── History cards ────────────────────────────────────────
                Repeater {
                    model: history
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 4

                        radius: 6
                        color: "transparent"
                        border.width: 1
                        border.color: Config.colors.purple

                        // implicitHeight from inner layout — this is what lets
                        // centerCol grow/shrink correctly as items are added/removed
                        implicitHeight: cardInner.implicitHeight + 16

                        ColumnLayout {
                            id: cardInner
                            // width only, no anchors.fill — height stays implicit
                            width: parent.width - 16
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 8
                            spacing: 3

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    Layout.fillWidth: true
                                    text: model.summary
                                    color: Config.colors.fg
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: model.time
                                    color: Config.colors.muted
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize - 3
                                }

                                Text {
                                    text: "✕"
                                    color: Config.colors.red
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize - 1

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: history.remove(index)
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
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
