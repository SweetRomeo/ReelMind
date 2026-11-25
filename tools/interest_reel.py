"""A square represents ten lira in the compound-interest lesson."""

from functools import lru_cache

from PIL import Image, ImageDraw


PRINCIPAL = '#649C98'
FIRST_YEAR = '#A7D4C4'
ON_PRINCIPAL = '#78E9AE'
ON_INTEREST = '#FFC783'
WHITE = '#F3FBF6'
SECONDARY = '#C0D8CF'

COPY = {
    'tr': {
        'stages': ('Başlangıç bakiyesi', 'Birinci yılın sonunda', 'İkinci yılın sonunda'),
        'amounts': ('1.000 TL', '1.100 TL', '1.210 TL'),
        'calculation': ('Yıllık %10 faiz', '1.000 TL × %10 = 100 TL', '1.100 TL × %10 = 110 TL'),
        'key': 'Her kare 10 TL',
        'initial': ('100 kare', 'Başlangıçtaki birikim'),
        'first': 'Hesapta kalan faiz',
        'principal': 'Anaparadan', 'interest': 'İlk yılın faizinden',
    },
    'en': {
        'stages': ('Starting balance', 'End of year one', 'End of year two'),
        'amounts': ('1,000 TL', '1,100 TL', '1,210 TL'),
        'calculation': ('10% annual interest', '1,000 TL × 10% = 100 TL', '1,100 TL × 10% = 110 TL'),
        'key': 'Each square is 10 TL',
        'initial': ('100 squares', 'Original deposit'),
        'first': 'Interest kept in the account',
        'principal': 'On the original deposit', 'interest': "On last year's interest",
    },
}


@lru_cache(maxsize=1)
def backdrop():
    image = Image.new('RGB', (1080, 1920))
    draw = ImageDraw.Draw(image)
    stops = [(0, (8, 28, 33)), (550, (20, 55, 55)),
             (1010, (16, 47, 49)), (1550, (8, 23, 31)), (1920, (8, 18, 28))]
    for (top, first), (bottom, last) in zip(stops, stops[1:]):
        for y in range(top, bottom):
            fraction = (y - top) / (bottom - top)
            rgb = tuple(round(a + (b - a) * fraction) for a, b in zip(first, last))
            draw.line((0, y, 1080, y), fill=rgb)
    return image


def square(draw, column, row, color):
    # The feed's category chip occupies the lower left on compact phones.
    x = 608 + column * 26
    y = 565 + row * 26
    draw.rounded_rectangle((x, y, x + 21, y + 21), radius=4, fill=color)


def render_interest(t, lang, font, starts):
    scene = max(i for i, start in enumerate(starts) if t >= start)
    elapsed = t - starts[scene]
    copy = COPY[lang]
    image = backdrop().copy()
    draw = ImageDraw.Draw(image)

    draw.text((100, 321), copy['stages'][scene], font=font(43), fill=SECONDARY, anchor='lt')
    draw.text((96, 394), copy['amounts'][scene], font=font(109, True), fill=WHITE, anchor='lt')
    draw.text((104, 489), copy['calculation'][scene], font=font(39), fill=WHITE, anchor='lt')

    # The extra column holds the first year's interest. The square above
    # it is the interest earned on that column in year two.
    for row in range(1, 11):
        for column in range(10):
            square(draw, column, row, PRINCIPAL)
    if scene >= 1:
        count = 10 if scene == 2 else min(10, int(elapsed * 5))
        for row in range(11 - count, 11):
            square(draw, 10, row, FIRST_YEAR)
    if scene == 2:
        for column in range(min(10, int(elapsed * 4))):
            square(draw, column, 0, ON_PRINCIPAL)
        if elapsed >= 3.8:
            square(draw, 10, 0, ON_INTEREST)
    draw.text((608, 865), copy['key'], font=font(30), fill=SECONDARY, anchor='lt')

    def entry(y, amount, label, color):
        draw.rounded_rectangle((104, y, 111, y + 71), radius=3, fill=color)
        draw.text((134, y), amount, font=font(46, True), fill=color, anchor='lt')
        draw.text((134, y + 47), label, font=font(32), fill=WHITE, anchor='lt')

    if scene == 0:
        entry(625, *copy['initial'], PRINCIPAL)
    elif scene == 1:
        entry(625, '+100 TL', copy['first'], FIRST_YEAR)
    else:
        entry(544, '+100 TL', copy['principal'], ON_PRINCIPAL)
        if elapsed >= 3.8:
            entry(636, '+10 TL', copy['interest'], ON_INTEREST)
    return image
