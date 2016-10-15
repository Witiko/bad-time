.PHONY: all music images video implode clean
MUSIC=mix.flac mix.mp3 mix.ogg
IMAGES=sans.png
VIDEO=mix.mkv sans-animation.mp4
AUXILIARY=ffmpeg2pass-0.log
OUTPUT=$(MUSIC) $(IMAGES) $(VIDEO)

SYNFIG_RESOURCES=sans-animation.sif sans-character-bw.sif sans-character.sif sans-character-silhouette.sif sans-character-silhouette2.sif

# FFMPEG_OPTIONS=-c:v libx265 -preset veryslow -crf 23 -c:a libfdk_aac -b:a 128k
FFMPEG_OPTIONS=-c:v libx265 -preset ultrafast -crf 23 -c:a libfdk_aac -b:a 128k
ID3V2_OPTIONS=-t 'Bad Times: Reincarnation' -a 'Vít Novotný' -y '2016' -g 'Game;Rap;JPop'
# SYNFIG_OPTIONS=-t ffmpeg --video-codec libx264-lossless --video-bitrate 10000 -a 30 -Q 1 -q
SYNFIG_OPTIONS=-t ffmpeg --video-codec libx264-lossless --video-bitrate 10000 -a 1 -Q 9 -w 480 -h 270 --begin-time 0f --end-time 9600f -q

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
	ffmpeg -i $< -i $(word 3,$^) -map 0:0 -map 1:0 -vf ass=$(word 2,$^) $(FFMPEG_OPTIONS) -pass 1 -f matroska -y /dev/null
	ffmpeg -i $< -i $(word 3,$^) -map 0:0 -map 1:0 -vf ass=$(word 2,$^) $(FFMPEG_OPTIONS) -pass 2 -y $@

# @require synfig
%.mp4: %.sif $(SYNFIG_RESOURCES)
	synfig $< $(SYNFIG_OPTIONS) -o $@

# @require inkscape
%.png: %.svg
	inkscape $< --export-png=$@ -w 2000 -h 2000

clean:
	rm -f $(AUXILIARY)

implode: clean
	rm -f $(OUTPUT)
