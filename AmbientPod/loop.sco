//Type of weather

//Sunrise
//Sunset to determine time of day, length of day

//Temp

//Humidity

//Wind spped

//Clouds

//Date (Season)


//print_off()
//load("IIR")
//load("MBANDEDWG")
//srand() /* srand with no seed will use system clock for seed */
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
//chimes = 4

//droneGap = 7
//droneInt = 5
//droneDur = 4
//droneFreq = 100
//drone1 = 10
//drone2 = 20
//cloud = .5
//droneRange = 4
//windV = 100
//final = 20

ampenv = maketable("line", 1000, 0,0, 1,1, 8, .2, 15, .05, final, 0)

//make drone pitches
pitches = {}
//droneFreq = 440
//droneRange = 4

origFreq = droneFreq
for(i = 0; i < droneRange; i = i + 1){
    pitches[i] = droneFreq
    //droneFreq = droneFreq + trand(drone1, drone2)
    droneFreq = pitches[0] * (pow(1.059463094359,(i*2+1)))
}
//to stop from frequencies repeating
droneFreq = origFreq

//make chime pitches
chimePitches = {}
for(i = 0; i < chimeRange; i = i + 1){
    chimePitches[i] = chimeFreq
    chimeFreq = chimeFreq + trand(chimeUp, chimeUp*2)
}

end = 45

amp = 5000*droneAmp
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
            pch = pitches[index+k]
        }
        dur = droneDur
        for (j = 0; j < droneSub; j = j+1) {
            //MAXMESSAGE(start, pch)
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

        MBANDEDWG(st, chimeDur, 20000*chimeAmp, freq, 0.5, 1, 0.9, 0, 0, 0.99, 0, 0.5)
//should change to be random or procedural
        st = st + irand(chimeMin, chimeInt)
    }
}

//melody
makegen(1, 24, 1000, 0,1, 1,1) // amplitude envelope
//melpitches = {7.00, 7.02, 7.05, 7.07, 7.10, 8.00, 8.07}
lpitches = len(melpitches)
melStart = irand(0, end)
if(random()>cloud){
for (i = 0; i < 10; i = i + 1) {
    pindex = trand(0, lpitches)
    melPitch = melpitches[pindex]
    melDur = irand(1, 3)
    START(melStart, melDur, melPitch, 1.0, 0.1, 10000.0, 1, random())
    melStart = melStart + irand(1, 3)
}
}

ws = 0.0
cf = 900

while(ws<end){
    //cf = cf + irand(-1.5, 1)
    cf = cf + irand(-windV, windV)
    setup(cf, 400, 1)
    NOISE(ws, 0.5, windamp*windenv, irand(0, 1))
    ws = ws + irand(0, 0.007)
}


//ampPres = maketable("line", 1000, 0,0, 1,1, 4,1, 5,0)
//wavePres = maketable("wave", 2000, 1)
//fadeup = maketable("line", 1000, 0,0, 1, 1)
//fadedown = maketable("line", 1000, 0,1, 1, 0)
endP = 200
outsk = 0
durPres = end + 10

MULTIWAVE(outsk, durPres, ampPres*3000*Pressure, wavePres,
irand(100, endP), fadedown, 0, random(),
irand(100, endP), fadedown, 0, random(),
irand(100, endP), fadedown, 0, random(),
irand(100, endP), fadedown, 0, random(),
irand(100, endP), fadedown, 0, random(),
irand(100, endP), fadedown, 0, random(),
irand(100, endP), fadedown, 0, random(),
irand(100, endP), fadeup, 0, random(),
irand(100, endP), fadeup, 0, random(),
irand(100, endP), fadeup, 0, random(),
irand(100, endP), fadeup, 0, random(),
irand(100, endP), fadeup, 0, random(),
irand(100, endP), fadeup, 0, random(),
irand(100, endP), fadeup, 0, random())
