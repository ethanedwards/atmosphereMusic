//Type of weather

//Sunrise
//Sunset to determine time of day, length of day

//Temp

//Humidity

//Wind spped

//Clouds

//Date (Season)


print_off()
load("IIR")
load("MBANDEDWG")
srand() /* srand with no seed will use system clock for seed */
//droneSpace = .5
//droneSub = 2
//windamp = 100
//chimeGap = 5
//chimeInt = .5
//chimeRange = 10
//chimeFreq = 600
//chimeUp = 50
//chimeMin = 2
//chimeDur = 7.0
chimes = 4

//droneGap = 7
//droneInt = 5
//droneDur = 4
//droneFreq = 100
//drone1 = 10
//drone2 = 20
//droneRange = 7

//make drone pitches
pitches = {}
for(i = 0; i < droneRange; i = i + 1){
    pitches[i] = droneFreq
    //droneFreq = droneFreq + trand(drone1, drone2)
    droneFeq = pitches[0] * (1.059463094359^(i+1))
}
//make chime pitches
chimePitches = {}
for(i = 0; i < chimeRange; i = i + 1){
    chimePitches[i] = chimeFreq
    chimeFreq = chimeFreq + trand(chimeUp, chimeUp*2)
}

end = 30
ampenv = maketable("line", 1000, 0,0, 1,1, 8, .2, 15,0)
amp = 5000
wave = maketable("wave", 1000, "square5")

windenv = maketable("line", 1000, 0,0, 1,1, 5,1, 10,0)

//pitches = { 6.05, 6.07, 6.08, 6.10, 7.00, 7.02, 7.05, 7.07, 7.10 }
lengthpitches = len(pitches)

//drone
start = 0
for(w = 0; start < end; w = w + 1){
    index = trand(0, lengthpitches)
    for(k = 0; k < voices; k = k + 1){
        if(index+k*2<lengthpitches){
            pch = pitches[index+k*2]
        }
        dur = droneDur
        for (j = 0; j < droneSub; j = j+1) {
            WAVETABLE(start+irand(0.0, droneSpace), dur, amp*ampenv, pch + irand(0.001, 0.004), j/3, wave)
        }
    }
    start = start + irand(droneInt, droneGap)
}

//chimePitches = { 500, 600, 650, 425 }
pl = len(chimePitches)

st = 0
for(k = 0; st < end; k = k + 1){
    st = st + irand(chimeMin, chimeGap)
    for (i = 0; i < chimes; i = i+1) {
        freqindex = trand(0, pl)
        freq = chimePitches[freqindex]

        MBANDEDWG(st, chimeDur, 20000, freq, 0.5, 1, 0.9, 0, 0, 0.99, 0, 0.5)
//should change to be random or procedural
        st = st + irand(chimeMin, chimeInt)
    }
}

ws = 0.0
cf = 900

while(ws<end){
    cf = cf + irand(-1.5, 1)
    setup(cf, 400, 1)
    NOISE(ws, 0.5, windamp*windenv, irand(0, 1))
    ws = ws + irand(0, 0.007)
}
