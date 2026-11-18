"""Original 25-second ReelMind API pilot. Pillow + ffmpeg required.
Run from package root: python tools/render_api_reel.py --font-dir PATH
Font directory must contain DejaVuSans.ttf and DejaVuSans-Bold.ttf.
"""
from pathlib import Path
from functools import lru_cache
import argparse, math, struct, subprocess, wave
from PIL import Image, ImageDraw, ImageFont

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
parser.add_argument('--font-dir',type=Path,default=Path('/usr/share/fonts/truetype/dejavu'))
parser.add_argument('--output',type=Path,default=Path('assets/videos'))
parser.add_argument('--preview-only',action='store_true')
args=parser.parse_args();args.output.mkdir(parents=True,exist_ok=True)
@lru_cache(None)
def font(size,bold=False):
 return ImageFont.truetype(str(args.font_dir/('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf')),size)
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
def render(t,lang):
 if t<6:s,e=0,t
 elif t<12:s,e=1,t-6
 elif t<19:s,e=2,t-12
 else:s,e=3,t-19
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

def audio(path):
 rate=48000;notes=[(.4,523.25),(6.1,587.33),(12.1,659.25),(19.1,783.99)];data=bytearray()
 for i in range(rate*DURATION):
  t=i/rate;v=0
  for start,f in notes:
   dt=t-start
   if 0<=dt<.9:
    env=min(1,dt/.025)*math.exp(-5*dt)
    v+=.1*env*(math.sin(2*math.pi*f*dt)+.25*math.sin(4*math.pi*f*dt))
  data+=struct.pack('<h',int(max(-1,min(1,v))*32767))
 with wave.open(str(path),'wb') as wav:
  wav.setnchannels(1);wav.setsampwidth(2);wav.setframerate(rate);wav.writeframes(data)

if __name__=='__main__':
 for lang in ('tr','en'):
  for t in (3,8,15,22):render(t,lang).resize((360,640)).save(args.output/f'preview_{lang}_{t}.png')
 if not args.preview_only:
  wav=args.output/'api_cues.wav';audio(wav)
  for lang in ('tr','en'):
   out=args.output/f'api_intro_{lang}_001.mp4'
   proc=subprocess.Popen(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgb24','-s',f'{W}x{H}','-r',str(FPS),'-i','pipe:0','-i',str(wav),'-map','0:v:0','-map','1:a:0','-c:v','libx264','-preset','veryfast','-crf','23','-profile:v','high','-pix_fmt','yuv420p','-c:a','aac','-b:a','64k','-movflags','+faststart','-t',str(DURATION),str(out)],stdin=subprocess.PIPE)
   try:
    for i in range(FPS*DURATION):proc.stdin.write(render(i/FPS,lang).tobytes())
   finally:proc.stdin.close()
   if proc.wait()!=0:raise SystemExit('ffmpeg failed')
   print(f'Created {out}: {out.stat().st_size/1024/1024:.2f} MiB',flush=True)
  wav.unlink()
