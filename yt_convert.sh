#!/bin/bash

# Pitch change  audio  and convert to HD 720p for You Tube upload

# Video and Sound apps:
#   ffmpeg: https://www.ffmpeg.org
#      sox: http://sox.sourceforge.net/sox.html

# How to split and join video and audio:
# https://www.youtube.com/watch?v=owfmDQcxyCE

# Using Sox for audio:
# http://chipmusic.org/forums/topic/10353/live-databending-with-ffmpeg-and-sox/

# Sox noise reduction
# http://www.zoharbabin.com/how-to-do-noise-reduction-using-ffmpeg-and-sox/

# Pitch adjustment. 100 cents = 1 semitone. 1200 = 1 octave.  Can be +ve or -ve
PITCH=-200

TMPDIR=`pwd`/Temp
INPDIR=`pwd`/Saved
OUTDIR=`pwd`/Upload

echo "TMPDIR=$TMPDIR"
echo "INPDIR=$INPDIR"
echo "OUTDIR=$OUTDIR"

[ -d "$INPDIR" ] || { echo "$INPDIR: Failed to find directory.  It should contain your recorded videos" >&2; exit 1; }
[ -d "$OUTDIR" ] || mkdir "$OUTDIR" || exit 1
[ -d "$TMPDIR" ] || mkdir "$TMPDIR" || exit 1

# trap 0 1 2 15 'rm -fr "$TMPDIR"'

# Turn on debug tracing so we can see the final ffmp.exe and sox.exe commands that execute

#ECHO=echo

for inp in Saved/*.avi
do
    rm "$TMPDIR"/*

    name=`basename $inp | sed 's/\.avi$//' `
    echo "name=$name"

    # split input video $inp into audio and video files.
    $ECHO bin/ffmpeg -i "$inp" -vcodec copy -an "$TMPDIR/inp_video.avi"   # extract the video (just copy it - not reencode) and -an = NO audio
    $ECHO bin/ffmpeg -i "$inp" "$TMPDIR/inp_audio.wav"                    # extract the audio into a .wav format file (no compression)

    $ECHO bin/sox "$TMPDIR/inp_audio.wav" "$TMPDIR/out_audio.wav" pitch $PITCH   # Adjust audio pitch

    # bin/ffmpeg -i "$TMPDIR/input.avi" -i "$TMPDIR/output.wav" -vcodec copy "$OUTDIR/$name.mpg"

    # Encode video and stream copy the audio for You Tube.
    # The output should be a similar quality as the input and will hopefully be a more manageable size.
    #  We might need to use -c:a aac for audio

    # bin/ffmpeg -i "$TMPDIR/input.avi" -i "$TMPDIR/output.wav" -c:v libx264 -preset slow -crf 18 -c:a copy -pix_fmt yuv420p "$OUTDIR/$name.mkv"

    $ECHO bin/ffmpeg -i "$TMPDIR/inp_video.avi" -i "$TMPDIR/out_audio.wav" -s hd720 -c:v libx264 -preset slow -crf 23 -c:a aac -strict -2 "$OUTDIR/$name.mp4"

done

# sox -S "$mp3" -C 192 "$output" pitch 50
