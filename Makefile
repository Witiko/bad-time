.PHONY: all music images video implode
MUSIC=mix.flac mix.mp3 mix.ogg
IMAGES=badtime.png sans.png sans-youtube.png sans-youtube-1080p.png sans-youtube-2160p.png
VIDEO=mix.mkv mix-extended.mkv
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
	id3v2 -t 'Having a Bad Time' -a 'Vít Novotný' -y `LC_ALL=C stat $< | sed -n '/^Modify:/s/^Modify: \(....\).*/\1/p'` -g Game $@
	metaflac --import-picture-from=$(word 2,$^) $@

# @require imagemagick
%-1080p.png: %.png
	convert $< -resize '1920x1080!' $@

%-2160p.png: %.png
	convert $< -resize '3840x2160!' $@

# @require ffmpeg
%.mp3: %.flac
	ffmpeg -i $< -c:a libmp3lame -q:a 0 -b:a 320k -abr 1 -y $@

%.ogg: %.flac
	ffmpeg -i $< -c:a libvorbis -q:a 3 -map a -y $@

%.aac: %.flac
	ffmpeg -i $< -c:a aac -b:a 384k -y $@

%.mkv: %.ogg sans-youtube-1080p.png
	ffmpeg -framerate 1 -r 25 -loop 1 -i $(word 2,$^) -i $< -c:v libx265 -c:a copy -shortest -vf ass=mix.ass -y $@

%-extended.mkv: %-extended.aac sans-youtube-2160p.png
	ffmpeg -threads 12 -hwaccel auto -framerate 60 -loop 1 -i $(word 2,$^) -i $< -c:v libx264 -crf 17 -preset ultrafast -tune stillimage -movflags +faststart -c:a copy -vf "fade=t=in:st=0.2:d=4,fade=t=out:st=28748.5:d=15.5" -pix_fmt yuv420p -shortest -y mix-extended.mkv

# @require gimp
%.png: %.xcf
	./gimp-export.sh $< $@

implode:
	rm -f $(OUTPUT) $(AUXILIARY)
