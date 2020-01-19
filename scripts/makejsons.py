import json
import urllib.request

try:
    from BeautifulSoup import BeautifulSoup
except ImportError:
    from bs4 import BeautifulSoup

LIBRARY_ROOT = 'https://www.quantum-espresso.org/pseudopotentials/ps-library/'
UPF_ROOT = 'https://www.quantum-espresso.org'

elements = ['h', 'he', 'li', 'be', 'b', 'c', 'n', 'o', 'f', 'ne', 'na', 'mg', 'al', 'si', 'p', 's', 'cl', 'ar', 'k', 'ca', 'sc', 'ti', 'v', 'cr', 'mn', 'fe', 'co', 'ni', 'cu', 'zn', 'ga', 'ge', 'as', 'se', 'br', 'kr', 'rb', 'sr', 'y', 'zr', 'nb', 'mo', 'tc', 'ru', 'rh', 'pd', 'ag',
            'cd', 'in', 'sn', 'sb', 'te', 'i', 'xe', 'cs', 'ba', 'la', 'ce', 'pr', 'nd', 'pm', 'sm', 'eu', 'gd', 'tb', 'dy', 'ho', 'er', 'tm', 'yb', 'lu', 'hf', 'ta', 'w', 're', 'os', 'ir', 'pt', 'au', 'hg', 'tl', 'pb', 'bi', 'po', 'at', 'rn', 'fr', 'ra', 'ac', 'th', 'pa', 'u', 'np', 'pu']

for element in elements:
    url = LIBRARY_ROOT + element

    response = urllib.request.urlopen(url)
    s = response.read()

    parsed_html = BeautifulSoup(s)
    element_anchors = parsed_html.body.find_all('a', attrs={'class': 'element_anchor'})

    data = dict()
    file = '../data/' + element + '.json'
    for anchor in element_anchors:
        metadata = anchor.findNextSibling()
        data[anchor.text.strip()] = {'href': UPF_ROOT + anchor['href'], 'meta': metadata.text}

    with open(file, 'w') as f:
        json.dump(data, f)
