"""Render ReelMind's narrated lessons. See docs/api_pilot.md."""
from pathlib import Path
from functools import lru_cache
import argparse, json, math, os, shutil, subprocess, tempfile, wave
from PIL import Image, ImageDraw, ImageFont
from interest_reel import render_interest
from sky_reel import render_sky

W,H,FPS,DURATION=1080,1920,24,25
BG='#0A1325'; WHITE='#F4F8FF'; MUTED='#A4B6CC'; CYAN='#65E5EC'; MINT='#91F0B8'
TEXT={
 'tr':{
  'head':['API nedir?','İsteği gönder.','Cevabı al.','Yazılımlar iletişim kurar.'],
  'sub':['Hava durumu uygulaması\nbilgiyi nereden alır?',
         'Uygulama, servisin API’sine\nhava durumu isteği gönderir.',
         'Servis veriyi döndürür.\nUygulama sonucu gösterir.',
         'API, kuralları tanımlanmış\nbir iletişim arayüzüdür.'],
  'app':'UYGULAMA','service':'HAVA SERVİSİ','waiting':'Veri bekleniyor','data':'Örnek veri',
  'request':'İSTEK','response':'CEVAP',
  'foot':['Bir örnekle keşfet.','Örnek istek: İstanbul','Örnek cevap: 22 °C','Uygulamalar veri alışverişi yapar.']},
 'en':{
  'head':['What is an API?','Send a request.','Receive a response.','Software communicates.'],
  'sub':['Where does a weather app\nget its information?',
         'The app requests weather data\nthrough the service’s API.',
         'The service returns data.\nThe app displays the result.',
         'An API is an interface\nwith defined rules for communication.'],
  'app':'APP','service':'WEATHER SERVICE','waiting':'Waiting for data','data':'Example data',
  'request':'REQUEST','response':'RESPONSE',
  'foot':['Let’s follow an example.','Example request: Istanbul','Example response: 22 °C','Applications exchange data.']}}

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--font-dir',type=Path,help='Directory containing DejaVuSans.ttf and DejaVuSans-Bold.ttf')
parser.add_argument('--output',type=Path)
parser.add_argument('--preview-only',action='store_true')
parser.add_argument('--voice-dir',type=Path,default=Path('build/reel-voice'))
parser.add_argument('--lesson',choices=['api','sky','interest','both','all'],default='api')
args=parser.parse_args()
@lru_cache(None)
def font(size,bold=False):
 if not args.font_dir and os.name == 'nt':
  path = Path(os.environ['WINDIR']) / 'Fonts' / ('arialbd.ttf' if bold else 'arial.ttf')
 else:
  path = (args.font_dir or Path('/usr/share/fonts/truetype/dejavu')) / ('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf')
 return ImageFont.truetype(str(path),size)
base=Image.new('RGB',(W,H),BG);d=ImageDraw.Draw(base)
for y in range(0,H,72):d.line((0,y,W,y),fill='#101D32')
for x in range(0,W,72):d.line((x,0,x,H),fill='#101D32')
d.rounded_rectangle((80,275,1000,1130),radius=46,fill='#101F36',outline='#243A55',width=2)
def centered(dr,text,y,size=44,color=WHITE,bold=False):
 for line in text.split('\n'):
  f=font(size,bold);assert dr.textlength(line,font=f)<=840,(line,size)
  dr.text((540,y),line,font=f,fill=color,anchor='mt');y+=int(size*1.34)
def sun(dr,x,y):
 r=29;dr.ellipse((x-r,y-r,x+r,y+r),fill='#F9D68C')
 for i in range(8):
  a=i*math.pi/4
  dr.line((x+math.cos(a)*(r+8),y+math.sin(a)*(r+8),x+math.cos(a)*(r+18),y+math.sin(a)*(r+18)),fill='#F9D68C',width=4)
def arrow(dr,start,end,y,color,label,t):
 dr.line((start,y,end,y),fill='#344963',width=5);direction=1 if end>start else -1
 dr.polygon([(end,y),(end-direction*17,y-10),(end-direction*17,y+10)],fill=color)
 x=start+(end-start)*((t*.52)%1);dr.ellipse((x-9,y-9,x+9,y+9),fill=color)
 dr.text(((start+end)/2,y-19),label,font=font(25,True),anchor='mb',fill=color)
def render(t,lang,starts):
 s=max(i for i,start in enumerate(starts) if t>=start)
 e=t-starts[s]
 c=TEXT[lang];im=base.copy();dr=ImageDraw.Draw(im)
 dr.rounded_rectangle((390,302,690,346),radius=21,fill='#1C3550')
 dr.text((540,324),'REELMIND  /  API',font=font(22,True),fill=CYAN,anchor='mm')
 centered(dr,c['head'][s],376,46,bold=True)
 centered(dr,c['sub'][s],459,34,MUTED)
 dr.rounded_rectangle((142,644,374,970),radius=34,fill='#172C46',outline='#6A88AA',width=4)
 dr.rounded_rectangle((210,659,306,668),radius=4,fill='#64809E')
 dr.text((258,706),c['app'],font=font(26,True),fill=WHITE,anchor='mm');sun(dr,258,800)
 dr.text((258,871),'22 °C' if s>=2 else '— °C',font=font(44,True),fill=MINT if s>=2 else MUTED,anchor='mm')
 dr.text((258,926),c['data'] if s>=2 else c['waiting'],font=font(19),fill=MUTED,anchor='mm')
 dr.rounded_rectangle((696,644,938,970),radius=28,fill='#172C46',outline='#426582',width=3)
 dr.text((817,694),c['service'],font=font(19,True),fill=WHITE,anchor='mm')
 dr.rounded_rectangle((718,737,916,802),radius=13,fill='#24575D')
 dr.text((817,769),'API',font=font(36,True),fill=CYAN,anchor='mm')
 for yy in (844,879,914):dr.rounded_rectangle((740,yy,894,yy+10),radius=5,fill='#35546E')
 if s==0:dr.text((535,814),'?',font=font(84,True),fill=CYAN,anchor='mm')
 if s in (1,3):arrow(dr,397,674,790,CYAN,c['request'],e)
 if s in (2,3):arrow(dr,674,397,895,MINT,c['response'],e)
 centered(dr,c['foot'][s],1026,28,CYAN)
 for i in range(4):
  x=425+i*63;dr.rounded_rectangle((x,1090,x+43,1096),radius=3,fill=CYAN if i<=s else '#35506A')
 a=min(1,t/.35,(DURATION-t)/.5)
 if a<1:im=Image.blend(Image.new('RGB',(W,H),BG),im,max(0,a))
 return im

def ffmpeg_path():
    executable = shutil.which('ffmpeg')
    if executable:
        return executable
    import imageio_ffmpeg
    return imageio_ffmpeg.get_ffmpeg_exe()


def assemble_voice(ffmpeg, lesson, lang, starts, output):
    rate = 24000
    samples = bytearray(DURATION * rate * 2)
    for index, (start, end) in enumerate(zip(starts, [*starts[1:], DURATION])):
        clip = args.voice_dir / f'{lesson}_{lang}_{index}.wav'
        if not clip.is_file():
            raise FileNotFoundError(f'Missing narration: {clip}')
        pcm = subprocess.run(
            [ffmpeg, '-v', 'error', '-i', str(clip), '-ac', '1', '-ar', str(rate),
             '-f', 's16le', 'pipe:1'], check=True, stdout=subprocess.PIPE,
        ).stdout
        offset = round((start + 0.24) * rate) * 2
        if not pcm or offset + len(pcm) > round((end - 0.12) * rate) * 2:
            raise ValueError(f'{clip} must contain speech that fits the {start}–{end} s scene')
        samples[offset:offset + len(pcm)] = pcm
    with wave.open(str(output), 'wb') as track:
        track.setparams((1, 2, rate, 0, 'NONE', 'not compressed'))
        track.writeframes(samples)


def encode(ffmpeg, frame_at, wav, output, lang):
    command = [
        ffmpeg, '-v', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
        '-s', f'{W}x{H}', '-r', str(FPS), '-i', 'pipe:0', '-i', str(wav),
        '-map', '0:v:0', '-map', '1:a:0', '-c:v', 'libx264', '-threads', '4',
        '-preset', 'veryfast', '-crf', '22', '-pix_fmt', 'yuv420p',
        '-af', 'loudnorm=I=-16:TP=-1.5:LRA=7', '-ac', '1', '-ar', '44100',
        '-c:a', 'aac', '-b:a', '96k', '-metadata:s:a:0',
        'language=' + {'tr': 'tur', 'en': 'eng'}[lang],
        '-movflags', '+faststart', '-t', str(DURATION), str(output),
    ]
    with subprocess.Popen(command, stdin=subprocess.PIPE) as process:
        try:
            for i in range(FPS * DURATION):
                process.stdin.write(frame_at(i / FPS).tobytes())
        finally:
            process.stdin.close()
        if process.wait() != 0:
            raise RuntimeError(f'Failed to encode {output.name}')


if __name__ == '__main__':
    scenes = json.loads(Path(__file__).with_name('reel_narration.json').read_text(encoding='utf-8'))
    output = args.output or Path('build/reel-previews' if args.preview_only else 'assets/videos')
    output.mkdir(parents=True, exist_ok=True)
    selection = {'all': scenes.keys(), 'both': ('api', 'sky')}.get(args.lesson, (args.lesson,))
    for lesson in selection:
        starts = [scene['start'] for scene in scenes[lesson]]
        prefix = {'api': 'api_intro', 'sky': 'sky_color', 'interest': 'compound_interest'}[lesson]
        for lang in ('tr', 'en'):
            def frame_at(t):
                if lesson == 'sky':
                    return render_sky(t, lang, font, starts)
                if lesson == 'interest':
                    return render_interest(t, lang, font, starts)
                return render(t, lang, starts)

            if args.preview_only:
                for start, end in zip(starts, [*starts[1:], DURATION]):
                    frame_at((start + end) / 2).resize((360, 640)).save(output / f'{lesson}_{lang}_{start}.png')
                continue
            ffmpeg = ffmpeg_path()
            target = output / f'{prefix}_{lang}_001.mp4'
            with tempfile.TemporaryDirectory(dir=output) as staging:
                wav = Path(staging) / 'voice.wav'
                assemble_voice(ffmpeg, lesson, lang, starts, wav)
                movie = Path(staging) / target.name
                encode(ffmpeg, frame_at, wav, movie, lang)
                movie.replace(target)
            print(f'Created {target}: {target.stat().st_size / 1024**2:.2f} MiB', flush=True)
