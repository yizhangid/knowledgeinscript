#!/env python

from google.appengine.ext.webapp.util import run_wsgi_app
import webapp2
import ConfigParser

class MainPage(webapp2.RequestHandler):
    def get(self):
        html_body = self.loadToolsConfFile(configFile)
        page = html_header + html_title + html_body + html_footer
        self.response.write(page)

    def post(self):
        return self.get()
    
    def loadToolsConfFile(self,configFile):
        config = ConfigParser.ConfigParser()
        fp = open(configFile)
        config.readfp(fp)
        fp.close()
        html = "<table border=1 align=center>"
        for keyword in config.sections():
            toolName = keyword
            comment = config.get(keyword,"comment")
            url = config.get(keyword,"url")
            row = "<tr><td><a href=\"" + url + "\" >" + toolName + "</a></td><td>" + comment + "</td></tr>"
            html += row
        html += "</table>"
        return html
   
configFile = "./site.conf"
html_header   = "<html><head><title>QA Tool to calculate test scenario permutation and combination</title></head><body>"
html_title = "<h3><center>QA Tool to calculate test scenario permutation and combination</center></h3><hr>"
html_footer = "<hr width=60% align=center><p align=center>--- yi zhang @ 2013 ---</p></body></html>"
app = webapp2.WSGIApplication([('/', MainPage)], debug=True) 
app.router.add((r'/cmd', 'cmd_scenario.CommandLineTool'))
app.router.add((r'/generic', 'generic_scenario.GenericTool'))

def main():
    run_wsgi_app(app)

if __name__ == "__main__":
    main()