import Quickshell
import Quickshell.Services.Pipewire
import qs.Commons
pragma Singleton

Singleton {
    id: root
    // Devices
    readonly property var sink: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property real maxVolume: 1
    readonly property real stepVolume: 5 / 100
      // Internal state for feedback loop prevention
  property bool isSettingOutputVolume: false

    signal volumeAtMaximum()
    signal volumeAtMinimum()

    function clampOutputVolume(vol: real) : real {
        if (vol === undefined || isNaN(vol))
            return 0;

        return Math.max(0, Math.min(root.maxVolume, vol));
    }

     readonly property real volume: clampOutputVolume(sink.audio.volume)

    function increaseVolume() {
        if (!Pipewire.ready || (!sink?.audio))
            return ;

        if (volume >= root.maxVolume) {
            volumeAtMaximum();
            return ;
        }
        setVolume(Math.min(root.maxVolume, volume + stepVolume));
    }

    function decreaseVolume() {
    if (!Pipewire.ready || (!sink?.audio)) {
      return;
    }
    if (volume <= 0) {
      volumeAtMinimum();
      return;
    }
    setVolume(Math.max(0, volume - stepVolume));
  }

  function setVolume(newVolume: real) {
    if (!Pipewire.ready || (!sink?.audio)) {
      Logger.w("AudioService", "No sink available or not ready")
      return;
    }

    const clampedVolume = clampOutputVolume(newVolume);
    const delta = Math.abs(clampedVolume - volume);
    if (delta < root.epsilon) {
      return;
    }


    if (!sink?.ready || !sink?.audio) {
      Logger.w("AudioService", "No sink available or not ready")
      return;
    }

    // Set flag to prevent feedback loop, then set the actual volume
    isSettingOutputVolume = true;
    sink.audio.volume = clampedVolume;


    // Clear flag after a short delay to allow external changes to be detected
    Qt.callLater(() => {
                   isSettingOutputVolume = false;
                 });
  }

}
