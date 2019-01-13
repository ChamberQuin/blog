# URL Encoding Characters

## Character Encoding Chart

| Classification | Included Characters | Encoding Required? |
| --- | --- | --- |
| Safe characters | Alphanumerics [0-9a-zA-Z], special characters $-_.+!*'(),, and reserved characters used for their reserved purposes (e.g., question mark used to denote a query string) | NO |
| ASCII Control characters | Includes the ISO-8859-1 (ISO-Latin) character ranges 00-1F hex (0-31 decimal) and 7F (127 decimal.) | YES|
| Non-ASCII characters | Includes the entire “top half” of the ISO-Latin set 80-FF hex (128-255 decimal.) | YES |
| Reserved characters | ; / ? : @ = & (does not include blank space)<span class="Apple-tab-span" style="white-space:pre"></span> | YES1 |
| Unsafe characters | Includes the blank/empty space and " < > # % { } \| \ ^ ~ [ ] ` | YES |

> 1 Reserved characters only need encoded when not used for their defined, reserved purposes.

## Unsafe Characters

Characters can be unsafe for a number of reasons. The space character is unsafe because significant spaces may disappear and insignificant spaces may be introduced when URLs are transcribed or typeset or subjected to the treatment of word-processing programs. The characters “<” and “>” are unsafe because they are used as the delimiters around URLs in free text; the quote mark (“"”) is used to delimit URLs in some systems. The character “#” is unsafe and should always be encoded because it is used in World Wide Web and in other systems to delimit a URL from a fragment/anchor identifier that might follow it. The character “%” is unsafe because it is used for encodings of other characters. Other characters are unsafe because gateways and other transport agents are known to sometimes modify such characters. These characters are “{”, “}”, “|”, “\”, “^”, “~”, “[”, “]”, and “`”.

All unsafe characters must always be encoded within a URL. For example, the character “#” must be encoded within URLs even in systems that do not normally deal with fragment or anchor identifiers, so that if the URL is copied into another system that does use them, it will not be necessary to change the URL encoding.

## Reserved Characters

Many URL schemes reserve certain characters for a special meaning: their appearance in the scheme-specific part of the URL has a designated semantics. If the character corresponding to an octet is reserved in a scheme, the octet must be encoded. The characters “;”, “/”, “?”, “:”, “@”, “=” and “&” are the characters which may be reserved for special meaning within a scheme. No other characters may be reserved within a scheme.

Usually a URL has the same interpretation when an octet is represented by a character and when it encoded. However, this is not true for reserved characters: encoding a character reserved for a particular scheme may change the semantics of a URL.

Thus, only alphanumerics, the special characters “$-_.+!*'(),”, and reserved characters used for their reserved purposes may be used unencoded.

On the other hand, characters that are not required to be encoded (including alphanumerics) may be encoded within the scheme-specific part of a URL, as long as they are not being used for a reserved purpose.

## Reference

[RFC 1738](https://www.ietf.org/rfc/rfc1738.txt)
[RFC 3986](https://www.ietf.org/rfc/rfc3986.txt)
[(Please) Stop Using Unsafe Characters in URLs](https://perishablepress.com/stop-using-unsafe-characters-in-urls/)

