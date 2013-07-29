#!/env python

from google.appengine.ext.webapp.util import run_wsgi_app
import webapp2 
import cmd_parser


class CommandLineTool(webapp2.RequestHandler):
    def get(self):
        self.response.write(MAIN_PAGE_HTML)

    def post(self):
        content = self.request.get("content")
        userInput=""
        output=""
        log=""
        if content:
            userInput ="<p style=\"background-color:gray; color:white ; font-weight:bold\">" + content + "</p> "
            syntaxParser = cmd_parser.CMDSyntaxParser(content)
            parseError = syntaxParser.parse() 
            if parseError == "":
                scenario = syntaxParser.getTestScenario_html()
                output = "<div style=\" color:navy\">" + scenario + "</div>"
            else:
                output = "<div style=\" color:red\">" + parseError + "</div>"
            log = syntaxParser.log
            
        self.response.write(html_header)
        self.response.write(html_siteinfo)
        self.response.write(html_usage)
        self.response.write(html_test_syntax)
        self.response.write(html_form)
        self.response.write(userInput)
        self.response.write(output)
        # self.response.write(log)
        self.response.write(html_footer)

test_syntax = "[--h:SELF_STAND] * [--domain:ANY] * [--server:MUST --domain] * [--realm:ANY] * [--principal:ANY] * [--password:NO -W]* [-W:NO -U] * [--ntp-server:NO -N] * [--force-ntpd:NO --no-ntp] * [--unattended:NO -W, MUST --principal --password --server]"
html_test_syntax = "<table align=center width=80%><tr><td><b>Example:</b><br><div style=\"background-color:e5eecc; color:006600; padding:10px; font-weight:bold\">" + test_syntax + "</div></td></tr></table><br>"
html_header   = "<html><head><title>Permutation and combination tool for Linux commands</title></head><body>"
html_siteinfo = "<h3><center>Permutation and combination tool for Linux commands</center></h3><hr>"
html_usage    = """
<p>
<table align=center>
<tr valign=top><td valign=top > 
<b>This is a QA tool. It used in command testing. It accepts option usage (syntax) and outputs the option combination.</b>
<br>For example: Linux command <b>"useradd"</b> has many options, to name a few:
<br>&nbsp;&nbsp;  -m, --create-home             create the user's home directory
<br>&nbsp;&nbsp;  -M, --no-create-home          do not create the user's home directory
<br>&nbsp;&nbsp;  -h, --help                    display this help message and exit  
<br>&nbsp;&nbsp;  -p, --password PASSWORD       encrypted password of the new account
<br>&nbsp;&nbsp;  -r, --system                  create a system account
<br>
<br>based on above usage information, we can use this tool to compute all possible combinations amount options. 
<br>[-m:NO -M] * [-M:NO -m] * [-h:SELF_STAND] * [-p:ANY] * [-r:ANY]
<br>
</td>

<td valign=top style="border-left-color: green; width 1px;">
<b>How to use this tool</b>
<br><b>[ ] : </b>this is optional option to command.
<br><b>( ) : </b>this is must have option
<br><b>*   : </b>"map" operation, this is only one supported right now
<br>Usage of option is defined by keywords as following:
<br><b>NO <other option> : </b>can not be used with other option. if more than one such option, use space to saperate them        
<br><b>SELF_STAND: </b>this is option that used alone, it can not be used with other options
<br><b>ANY: </b>this option can be mixed with any other option
<br><b>MUST <other option>: </b>this option muse used with other option
<br>Above keywords can be mixed by use "," to separate them, such as 
<br>[-a : NO -b, -c, MUST -d]

</td></tr>
</table>
</p>
"""
html_form     = "<form action=\"/cmd\" method=\"post\">" + \
                "<div align=center><textarea name=\"content\" rows=\"8\" cols=\"120\">" + \
                "</textarea></div>" + \
                "<div align=center><input type=\"submit\" value=\"Compute Combination\"></div>" + \
                "</form>"
html_footer = "<hr width=60% align=center><p align=center>--- yi zhang @ 2013 ---</p></body></html>"
MAIN_PAGE_HTML = html_header + html_siteinfo + html_usage + html_test_syntax + html_form + html_footer

#app = webapp2.WSGIApplication([('/', ScenarioMath)], debug=True) 
# def main():
#     run_wsgi_app(app)

# if __name__ == "__main__":
#     main()
