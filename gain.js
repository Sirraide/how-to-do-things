var video = document.querySelector("video")
var context = new AudioContext()
var source = context.createMediaElementSource(video)
var gain = context.createGain()
gain.gain.value = 3 // 3 = 300% volume
source.connect(gain)
gain.connect(context.destination)
