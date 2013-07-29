#!/env python

from google.appengine.ext.webapp.util import run_wsgi_app
import webapp2 
import generic_parser


class GenericTool(webapp2.RequestHandler):
    def get(self):
        self.response.write(MAIN_PAGE_HTML)

    def post(self):
        content = self.request.get("content")
        userInput=""
        answer=""
        log=""
        if content:
            userInput ="<p style=\"background-color:gray; color:white ; font-weight:bold\">" + content + "</p> "
            syntaxParser = generic_parser.SyntaxParser(content)
            syntaxParser.doMath()
            answer = syntaxParser.finalAnswer_html()
#             parseError = syntaxParser.parse() 
#             if parseError == "":
#                 scenario = syntaxParser.getTestScenario_html()
#                 output = "<div style=\" color:navy\">" + scenario + "</div>"
#             else:
#                 output = "<div style=\" color:red\">" + parseError + "</div>"
#             log = syntaxParser.log
            
        self.response.write(html_header)
        self.response.write(html_siteinfo)
        self.response.write(html_usage)
        self.response.write(html_test_syntax)
        self.response.write(html_form)
        self.response.write(userInput)
        self.response.write(answer)
        # self.response.write(log)
        self.response.write(html_footer)

test_syntax = """
    os version = rhel 6.4, rhel 6.3 <br>
    os = i386, x86_64 <br>
    build = ipa 2.2, ipa 3.0 <br>
    feature = ipa-password , ipa-client-install, ca-less install: NOT ipa 2.2, force : ONLY i386 <br>
    <hr>
    ask = os version * os * build * feature <br>
"""
html_test_syntax = "<table align=center width=80%><tr><td><b>Example:</b><br><div style=\"background-color:e5eecc; color:006600; padding:10px; font-weight:bold\">" + test_syntax + "</div></td></tr></table><br>"
html_header   = "<html><head><title>Generic Scenario P&C Tool</title></head><body>"
html_siteinfo = "<h3><center>Generic Scenario P&C Tool</center></h3><hr>"
html_usage    = """
<p>
It is better explained with example:</p>
<table>
<tr valign=top><td>
<b>Given:</b>
<ul>
    <li>os version = rhel 6.4, rhel 6.3 </li>
    <li>os = i386, x86_64 </li>
    <li>build = ipa 2.2, ipa 3.0 </li> 
    <li>feature = ipa-password , ipa-client-install, ca-less install: <b>NOT</b> ipa 2.2, force : ONLY i386 </li>
</ul>
<b>ask</b> = os version <b>*</b> os <b>*</b> build <b>*</b> feature
</td>
<td> 
What this example says are:<br>
Give me all possible test scenarios such that:
<li> covers feature for "ipa-password" & "ipa-client-install", "ca-less install"</li>
<li> these feature should be test in build "ipa 2.2" & "ipa 3.0"</li>
<li> and only on os arch "i386" & "x86_64" </li>
<li> that runs on "rhel6.4" & "rhel6.3"</li>
<li> be aware that 
    <ul><li>feature "ca-less install" will not available on build "ipa 2.2"</li>
        <li>feature "force" will only available on os arch "i386"</li>
    </ul>
</li>
</td></tr>
</table>
"""

html_form     = "<form action=\"/generic\" method=\"post\">" + \
                "<div align=center><textarea name=\"content\" rows=\"8\" cols=\"120\">" + \
                "</textarea></div>" + \
                "<div align=center><input type=\"submit\" value=\"Compute Combination\"></div>" + \
                "</form>"
html_footer = "<hr width=60% align=center><p align=center>--- be simple by yi zhang @ 2013 ---</p></body></html>"
MAIN_PAGE_HTML = html_header + html_siteinfo + html_usage + html_test_syntax + html_form + html_footer


#app = webapp2.WSGIApplication([('/matrix', Matrix)], debug=True) 
# def main():
#     run_wsgi_app(app)
# 
# if __name__ == "__main__":
#     main()
