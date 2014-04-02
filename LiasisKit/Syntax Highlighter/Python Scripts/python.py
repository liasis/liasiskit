import __builtin__
import collections
import keyword
import re

##
# \details A string constant defining the regular expression pattern for triple
#          quotes that begin and end a docstring.
#
DOCSTRING_QUOTES_PATTERN = r"""
    \"\"\"(?:[\s\S]*?\"\"\")|  # closed double quote docstring
    '''(?:[\s\S]*?''')|  # closed double quote docstring
    \"\"\"[\s\S]*|  # open double quote docstring
    '''[\s\S]*  # open single quote docstring
    """

##
# \details A string constant defining the regular expression pattern for a
#          string enclosed in quotations on a single line. An open string is
#          ended with a newline character.
#
STRING_PATTERN = r"(?:\".*?\")|\".*|" \
                 r"(?:'.*?')|'.*"

##
# \details A string constant defining the regular expression pattern for a
#          comment beginning with the pound character (#). Comments continue
#          until a newline.
#
COMMENT_PATTERN = r"\#.*"

##
# \details A string constant defining the regular expression pattern for a
#          number that may be in scientific notation.
#
NUMBER_PATTERN = r"""(?:^|(?<=\W))  # start of string or previous non-word char
                     (?:
                         [0-9]+\.?[0-9]*[eE][-+]?[0-9]*|  # scientific notation
                         [0-9]+\.?[0-9]*|  # possible values after decimal
                         [0-9]*\.?[0-9]+  # possible values before decimal
                     )
                  """

# NUMBER_PATTERN = r"[0-9]+\.?[0-9]*[eE][-+]?[0-9]*|" \
#                  r"(?:[,:=(){}\[\]]|\b)([0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)"

DOCSTRING = "Docstring"
STRING = "String"
COMMENT = "Comment"
NUMBER = "Number"
KEYWORD = "Keyword"
EXCEPTION = "Exception"
FUNCTION = "Function name"


def get_coloring_dict(text):
    """ Return the ranges to apply syntax coloring.

    This function uses regular expressions to parse the text for docstrings,
    strings, numbers, comments, and builtin keywords, functions, and classes.
    A dict of lists is returned where keys are the group names of matches and
    the lists contain tuples of the matched range as (start index, length).

    Input arguments:
        text -> the text string to parse for syntax coloring ranges.

    """
    
    groups = collections.OrderedDict([('Docstring', DOCSTRING_QUOTES_PATTERN),
                                      ('String', STRING_PATTERN),
                                      ('Number', NUMBER_PATTERN),
                                      ('Comment', COMMENT_PATTERN)])
    groups.update(_keywords_regex())
    pattern = '|'.join(['(?P<{0}>{1})'.format(n.replace(' ', '_'), v)
                        for n, v in groups.items()])
    regex = re.compile(pattern, re.VERBOSE)
    matches = {group: [] for group in groups}
    for match in regex.finditer(unicode(text, 'UTF-8')):
        group = match.lastgroup.replace('_', ' ')
        match_start, match_end = match.span()
        matches[group].append((match_start, match_end - match_start))
    return matches


def _keywords_regex():
    """ Return a dict regex pattern to match builtin keywords.

    This function returns patterns for builtin keywords, functions, and classes.
    The dict keys are the group name of the pattern.

    """
    
    keywords = {group: [] for group in [KEYWORD, EXCEPTION, FUNCTION]}
    keywords[KEYWORD] = keyword.kwlist
    for builtin in dir(__builtin__):
        if builtin.startswith('_'):
            continue
        if builtin[0].isupper():
            keywords[EXCEPTION].append(builtin)
        else:
            keywords[FUNCTION].append(builtin)

    keywords_regex = dict.fromkeys(keywords.keys())
    for group in keywords_regex:
        regex = r"\b(?:{0})\b".format('|'.join(keywords[group]))
        keywords_regex[group] = regex

    return keywords_regex
