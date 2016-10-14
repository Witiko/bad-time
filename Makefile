.PHONY: all music images video implode
MUSIC=mix.flac mix.mp3 mix.ogg
IMAGES=badtime.png sans.png sans-youtube.png sans-youtube-1080p.png
VIDEO=mix.mkv
AUXILIARY=sans-youtube.png
OUTPUT=$(MUSIC) $(IMAGES) $(VIDEO)

all: $(OUTPUT)
music: $(MUSIC)
images: $(IMAGES)
video: $(VIDEO)

# @require flac idv3
%.flac: %.aup sans.png
	-aupexport $< $@
	metaflac --remove-all-tags $@
	id3v2 -t 'Bad Times: Reincarnation' -a 'Vít Novotný' -y `LC_ALL=C stat $< | sed -n '/^Modify:/s/^Modify: \(....\).*/\1/p'` -g Game $@
	metaflac --import-picture-from=$(word 2,$^) $@

# @require imagemagick
%-1080p.png: %.png
	convert $< -resize '1920x1080!' $@

# @require ffmpeg
%.mp3: %.flac
	ffmpeg -i $< -c:a libmp3lame -q:a 0 -b:a 320k -abr 1 -y $@

%.ogg: %.flac
	ffmpeg -i $< -c:a libvorbis -q:a 10 -map a -y $@

%.mkv: %.ogg sans-youtube-1080p.png
	ffmpeg -framerate 1 -r 25 -loop 1 -i $(word 2,$^) -i $< -c:v libx265 -c:a copy -shortest -vf ass=mix.ass -y $@

# @require gimp
%.png: %.svg
	inkscape $< --export-png=$@ -w 2000 -h 2000

implode:
	rm -f $(OUTPUT) $(AUXILIARY)
