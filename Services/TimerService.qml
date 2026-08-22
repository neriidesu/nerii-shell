import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
pragma Singleton

Singleton {
    property int timerIndex: 0
    property var timers: null
    property var timerMessages: []

    function start(message, time) {
        Logger.i("TimerService", "Timer started:", timerIndex, message, time);
        Quickshell.execDetached(["systemd-run", "--user", `--unit=nerii-shell-remind-${timerIndex}`, `--on-active=${time}`, "/bin/qs", "-c", "nerii-shell", "ipc", "call", "remind", "complete", message]);
        timerMessages.push(message);
        timerIndex++;
    }

    function complete(message) {
        Logger.i("TimerService", "Completed timer with message:", message);
        ToastService.showNotice("Reminder Complete", message);
        Quickshell.execDetached(["aplay", Quickshell.shellDir + "/Assets/notification.wav"]);
    }

    function updateTimerList() {
        listTimersProc.running = true;
    }

    function getTimers() {
        return timers;
    }

    function deleteById(id) {
        Quickshell.execDetached(["systemctl", "--user", "stop", `${id}.timer`]);
        getTimers();
    }

    Process {
        id: listTimersProc

        command: ["systemctl", "--user", "list-timers", "nerii-shell-remind-*"]

        stdout: StdioCollector {
            onStreamFinished: {
                var _timers = [];
                var rawTimers = this.text.split('\n');
                for (const rawTimer of rawTimers) {
                    if (rawTimer.includes('NEXT'))
                        continue;

                    if (!rawTimer.includes("timer"))
                        break;

                    var rawTimerArr = rawTimer.split(' ');
                    var timer = {
                        "id": rawTimer.slice(rawTimer.lastIndexOf("nerii-shell-remind-"), -8),
                        "time": rawTimer.slice(0, 28),
                        "name": timerMessages[rawTimer.slice(rawTimer.lastIndexOf("nerii-shell-remind-") + 19, -8)]
                    };
                    _timers.push(timer);
                }
                timers = _timers;
            }
        }

    }

    Timer {
        id: fetchTimer

        running: true
        interval: 1000
        repeat: true
        onTriggered: {
            updateTimerList();
        }
    }

}
