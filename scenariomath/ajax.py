#!/env python

from google.appengine.ext.webapp.util import run_wsgi_app
import webapp2 
import generic_parser


class AjaxExample(webapp2.RequestHandler):
    def get(self):
        print "get is being called"
        self.response.write(AjaxHtml)

    def post(self):
        content = self.request.get("content")
        userInput=""
        answer=""
        print "ajax called"
        if content:
            userInput ="<p style=\"background-color:gray; color:white ; font-weight:bold\">" + content + "</p> "
            syntaxParser = generic_parser.SyntaxParser(content)
            syntaxParser.doMath()
            answer = syntaxParser.finalAnswer_html()
        else:
            answer="no input"
        self.response.write(userInput + answer)

test_syntax = """
    os version = rhel 6.4, rhel 6.3 <br>
    os = i386, x86_64 <br>
    build = ipa 2.2, ipa 3.0 <br>
    feature = ipa-password , ipa-client-install, ca-less install: NOT ipa 2.2, force : ONLY i386 <br>
    <hr>
    ask = os version * os * build * feature <br>
"""
ajaxscript="""
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
<script type="text/javascript">
function submit(){
    $.post("/ajax",{"content" : $("#content").val()},function(response){
            $("#result").empty().append(response);
        }, "html");
}
</script>
"""
html_test_syntax = "<table align=center width=80%><tr><td><b>Example:</b><br><div style=\"background-color:e5eecc; color:006600; padding:10px; font-weight:bold\">" + test_syntax + "</div></td></tr></table><br>"
html_header   = "<html><head><title>Ajax Example::Generic Scenario P&C Tool</title>" + ajaxscript + "</head><body>"
html_siteinfo = "<h3><center>AJAX Example ::: Generic Scenario P&C Tool</center></h3><hr>"
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

html_form = """ 
        <div align=center><textarea id=content  rows=8 cols=120></textarea></div>
        <div align=center><input type=submit value="Compute Combination" onclick="submit()"></div> 
"""
html_result = "<div id=result></div>"
html_footer = "<hr width=60% align=center><p align=center>--- be simple by yi zhang @ 2013 ---</p></body></html>"
AjaxHtml = html_header + html_siteinfo + html_usage + html_test_syntax + html_form + html_result +  html_footer


#app = webapp2.WSGIApplication([('/matrix', Matrix)], debug=True) 
# def main():
#     run_wsgi_app(app)
# 
# if __name__ == "__main__":
#     main()
