import HTMLParser
import cgi

def unescape_html(input_str):
    h = HTMLParser.HTMLParser()
    return h.unescape(input_str)

def escape_html(input_str):
    return cgi.escape(input_str)

