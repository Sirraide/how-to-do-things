ffmpeg -threads 32 -i /PATH/TO/INPUT/FILE -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov /PATH/TO/OUTPUT/FILE.mov
