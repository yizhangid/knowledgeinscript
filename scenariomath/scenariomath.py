#!/env python

from google.appengine.ext.webapp.util import run_wsgi_app
import webapp2 
import dsl

class SyntaxParser:
    """Parse syntax string"""
    
    def __init__(self,syntaxString):
        self.syntax = syntaxString
        self.cmd = dsl.Command("TestCommand")
        
    def parse(self):
        options = self.syntax.split("*")
        options = [x.strip() for x in options]
        for optionInfo in options: 
            (required, keyword, rule) = self.getDetails(optionInfo)
            option = dsl.Option(keyword,"",rule,required,"","")
            self.cmd.addOption(option)
    
    def getDetails(self,optionInfo):
        required="no"
        if optionInfo.startswith("(") and optionInfo.endswith(")"):
            required = "yes"
        optionInfo = optionInfo[1:len(optionInfo)-1]
        tempArray = optionInfo.split(":")
        keyword = tempArray[0].strip()
        rule = tempArray[1].strip()
        return (required, keyword,rule)

    def getTestScenario_html(self):
        self.cmd.computeTestScenario()
        return self.cmd.getAllTestCases_html()
        
class MainPage(webapp2.RequestHandler):
    def get(self):
        self.response.write(MAIN_PAGE_HTML)

    def post(self):
        content = self.request.get("content")
        syntaxParser = SyntaxParser(content)
        syntaxParser.parse() 
        scenario = syntaxParser.getTestScenario_html()
        userInput ="<p style=\"background-color:gray; color:white ; font-weight:bold\">" + content + "</p> "
        output = "<div style=\" color:navy\">" + scenario + "</div>" 
        self.response.write(html_header)
        self.response.write(html_siteinfo)
        self.response.write(html_form)
        self.response.write(userInput)
        self.response.write(output)
        self.response.write(html_footer)

test_syntax = "[--h:SELF_STAND] * [--domain:ANY] * [--server:MUST --domain]* [--realm:ANY] *[--principal:ANY]* [--password:NO -W]* [-W:NO -U] * [--ntp-server:NO -N] * [--force-ntpd:NO --no-ntp] * [--unattended:NO -W, MUST --principal --password --server]"

html_header   = "<html><head><title>Scenario Math</title></head><body>"
html_siteinfo = "<h3><center>Scenario Math tool</center></h3><hr>"
html_form     = "<form action=\"/\" method=\"post\">" + \
                "<div align=center><textarea name=\"content\" rows=\"8\" cols=\"120\">" + \
                test_syntax + \
                "</textarea></div>" + \
                "<div align=center><input type=\"submit\" value=\"Scenario Math\"></div>" + \
                "</form>"
html_footer = "<hr><p align=center>--- be simple ---</p></body></html>"
MAIN_PAGE_HTML = html_header + html_siteinfo + html_form + html_footer

app = webapp2.WSGIApplication([('/', MainPage)], debug=True) 


def main():
    run_wsgi_app(app)

if __name__ == "__main__":
    main()
