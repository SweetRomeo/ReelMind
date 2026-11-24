"""Animated light paths for the 25-second sky lesson, in portrait coordinates."""

from functools import lru_cache
import math

from PIL import Image, ImageDraw


BLUE = '#77C9FF'
RED = '#FF9E8C'
GOLD = '#FFE3A3'
WHITE = '#F5F8FF'
CAPTIONS = {
    'tr': [
        ('Güneş ışığının renkleri', 'Beyaz görünen ışık birçok renk içerir.'),
        ('Işık havada nasıl dağılır?', 'Hava molekülleri mavi ışığı\nkırmızı ışıktan daha çok saçar.'),
        ('Gökyüzü neden mavi?', 'Saçılan mavi ışık gözümüze\nfarklı yönlerden ulaşır.'),
    ],
    'en': [
        ('The colors of sunlight', 'White light contains many colors.'),
        ('How does light scatter?', 'Air molecules scatter blue light\nmore strongly than red light.'),
        ('Why does the sky look blue?', 'Scattered blue light reaches your eyes\nfrom many directions.'),
    ],
}


@lru_cache(None)
def backdrop():
    image = Image.new('RGB', (1080, 1920))
    draw = ImageDraw.Draw(image)
    stops = [(0, (13, 24, 47)), (360, (23, 51, 80)), (780, (26, 65, 96)),
             (1050, (21, 48, 70)), (1420, (12, 27, 42)), (1920, (8, 17, 32))]
    for (top, a), (bottom, b) in zip(stops, stops[1:]):
        for y in range(top, bottom):
            ratio = (y - top) / (bottom - top)
            color = tuple(round(i + (j - i) * ratio) for i, j in zip(a, b))
            draw.line((0, y, 1080, y), fill=color)
    # A quiet horizon leaves room for the Flutter title and quiz controls.
    draw.polygon([(0, 1205), (230, 1070), (554, 1200), (806, 1102),
                  (1080, 1170), (1080, 1280), (0, 1280)], fill='#173348')
    draw.polygon([(0, 1240), (255, 1175), (490, 1240), (785, 1168),
                  (1080, 1235), (1080, 1290), (0, 1290)], fill='#132C40')
    return image


def sunlight(draw, x, y, radius):
    for extra, color in [(22, '#3C6177'), (10, '#998D72'), (0, GOLD)]:
        r = radius + extra
        draw.ellipse((x-r, y-r, x+r, y+r), fill=color)
    for n in range(12):
        a = n * math.tau / 12
        dx, dy = math.cos(a), math.sin(a)
        draw.line((x + dx*(radius+33), y + dy*(radius+33),
                   x + dx*(radius+43), y + dy*(radius+43)), fill=GOLD, width=4)


def ray(draw, start, end, color, t, width=5):
    x, y = start
    dx, dy = end[0] - x, end[1] - y
    draw.line((start, end), fill=color, width=width)
    length = math.hypot(dx, dy)
    ux, uy = dx / length, dy / length
    tip_x, tip_y = end
    draw.polygon([end, (tip_x - 15*ux + 7*uy, tip_y - 15*uy - 7*ux),
                  (tip_x - 15*ux - 7*uy, tip_y - 15*uy + 7*ux)], fill=color)
    phase = t % 1
    px, py = x + dx*phase, y + dy*phase
    draw.ellipse((px-6, py-6, px+6, py+6), fill=WHITE)


def render_sky(t, lang, font, starts):
    scene = max(i for i, start in enumerate(starts) if t >= start)
    phase = (t - starts[scene]) * 0.54
    image = backdrop().copy()
    draw = ImageDraw.Draw(image)
    title, caption = CAPTIONS[lang][scene]
    draw.text((108, 369), title, font=font(51, True), fill=WHITE, anchor='lt')
    draw.multiline_text((110, 449), caption, font=font(37), fill='#CBDFEF', spacing=8)

    if scene == 0:
        sunlight(draw, 218, 703, 49)
        ray(draw, (308, 703), (478, 703), WHITE, phase, 9)
        draw.polygon([(409, 826), (518, 630), (628, 826)],
                     fill='#4A798C', outline='#CADFEA', width=4)
        draw.line((478, 703, 571, 724), fill=WHITE, width=7)
        colors = [RED, '#FFC483', '#FFE295', '#8FDCB6', BLUE, '#AEA7EE']
        for i, color in enumerate(colors):
            ray(draw, (571, 724+i), (881, 805+i*23), color, phase+i*.05, 6)
        draw.text((515, 873), 'Prizma' if lang == 'tr' else 'Prism',
                  font=font(30), fill=WHITE, anchor='mm')
    elif scene == 1:
        center = (531, 740)
        for x, y in [(334, 620), (736, 660), (302, 828), (681, 897), (865, 814)]:
            draw.ellipse((x-9, y-9, x+9, y+9), outline='#7496AE', width=3)
        ray(draw, (169, 740), (507, 740), WHITE, phase, 7)
        ray(draw, (548, 742), (905, 775), RED, phase, 7)
        for i, end in enumerate([(398, 614), (630, 589), (759, 662), (664, 884), (407, 878)]):
            ray(draw, center, end, BLUE, phase+i*.14, 5)
        draw.ellipse((510, 719, 552, 761), fill='#D8F4FE', outline=WHITE, width=3)
        label = 'Hava molekülü' if lang == 'tr' else 'Air molecule'
        draw.text((530, 935), label, font=font(30), fill=WHITE, anchor='mm')
    else:
        eye = (547, 882)
        sunlight(draw, 202, 620, 31)
        for i, (x, y) in enumerate([(305, 698), (537, 615), (792, 678)]):
            draw.line((241, 623, x, y), fill='#ADAA91', width=3)
            draw.ellipse((x-9, y-9, x+9, y+9), fill=WHITE)
            ray(draw, (x, y+10), (eye[0]+(i-1)*17, eye[1]-40), BLUE, phase+i*.18)
        x, y = eye
        draw.polygon([(x-59,y), (x-31,y-22), (x,y-29), (x+31,y-22), (x+59,y),
                      (x+31,y+22), (x,y+29), (x-31,y+22)], fill='#E8F5FF')
        draw.ellipse((x-21,y-21,x+21,y+21), fill='#4687AA')
        draw.ellipse((x-10,y-10,x+10,y+10), fill='#142E48')
    return image
