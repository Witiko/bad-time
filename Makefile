.PHONY: all music images video implode clean
MUSIC=mix.flac mix.mp3 mix.ogg
IMAGES=sans.png
VIDEO=mix.mkv sans-animation.mp4
OUTPUT=$(MUSIC) $(IMAGES) $(VIDEO)

AUXILIARY=\
	ffmpeg2pass-0.log \
	thread1.ts \
	thread1.mp4 \
	thread1.out \
	thread1.err \
	thread2.ts \
	thread2.mp4 \
	thread2.out \
	thread2.err

SYNFIG_RESOURCES=\
	blaster-animation.sif \
	blaster-animation-transparent.sif \
	blaster-head-fiery.sif \
	blaster-head.sif \
	blaster-head-silhouette-blur.sif \
	blaster-jaw-bg.sif \
	blaster-jaw.sif \
	blaster-jaw-silhouette-blur.sif \
	sans-animation.sif \
	sans-character-bw.sif \
	sans-character.sif \
	sans-character-silhouette.sif \
	sans-character-silhouette2-blur.sif \
	sans-character-silhouette2.sif \
	blaster-glow.png \
	sans-eye.png \
	sans-eye-fiery.png

# FFMPEG_OPTIONS=-c:v libx265 -preset veryslow -crf 23 -c:a libfdk_aac -b:a 128k
FFMPEG_OPTIONS=-c:v libx264 -preset ultrafast -crf 18 -c:a libfdk_aac -b:a 128k
ID3V2_OPTIONS=-t 'Bad Times: Reincarnation' -a 'Vít Novotný' -y '2016' -g 'Game;Rap;JPop'
SYNFIG_OPTIONS=-t ffmpeg --video-codec libx264-lossless --video-bitrate 10000 -a 30 -Q 1 -q
# SYNFIG_OPTIONS=-t ffmpeg --video-codec libx264-lossless --video-bitrate 10000 -w 480 -h 270 -a 1 -Q 10 -q
SYNFIG_THREAD1_OPTIONS=--begin-time=0f    --end-time=8729f
SYNFIG_THREAD2_OPTIONS=--begin-time=8730f --end-time=17460f

all: $(OUTPUT) clean
music: $(MUSIC)
images: $(IMAGES)
video: $(VIDEO)

# @require flac idv3 <witiko/audacity-bridge/aupexport> audacity
%.flac: %.aup sans.png
	-aupexport $< $@
	metaflac --remove-all-tags $@
	id3v2 $(ID3V2_OPTIONS) $@
	metaflac --import-picture-from=$(word 2,$^) $@

# @require ffmpeg
%.mp3: %.flac
	ffmpeg -i $< -c:a libmp3lame -q:a 0 -b:a 320k -abr 1 -y $@

%.ogg: %.flac
	ffmpeg -i $< -c:a libvorbis -q:a 10 -map a -y $@

%.mkv: %.flac %.ass sans-animation.mp4
	ffmpeg -i $< -i $(word 3,$^) -map 0:0 -map 1:0 -vf ass=$(word 2,$^) $(FFMPEG_OPTIONS) -y $@

# @require synfig ffmpeg
%.mp4: %.sif $(SYNFIG_RESOURCES)
	synfig $< $(SYNFIG_OPTIONS) $(SYNFIG_THREAD1_OPTIONS) 2>thread1.err -o thread1.mp4 | tee thread1.out & \
	synfig $< $(SYNFIG_OPTIONS) $(SYNFIG_THREAD2_OPTIONS) 2>thread2.err -o thread2.mp4 | tee thread2.out & wait
	ffmpeg -i thread1.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts thread1.ts
	ffmpeg -i thread2.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts thread2.ts
	ffmpeg -i 'concat:thread1.ts|thread2.ts' -c copy -bsf:a aac_adtstoasc $@

# @require inkscape
%.png: %.svg
	inkscape $< --export-png=$@ -w 2000 -h 2000

clean:
	rm -f $(AUXILIARY)

implode: clean
	rm -f $(OUTPUT)
