#!/env python

import cmd_dsl


RULES=("SELF_STAND","NO","ANY","MUST")

class CMDSyntaxParser:
    """Parse syntax string"""
    
    def __init__(self,syntaxString):
        self.syntax = syntaxString
        self.cmd = cmd_dsl.Command("TestCommand")
        self.keywordArray = []
        self.optionArray = []
        self.error = ""
        self.log=""
        
    def parse(self):
        self.syntaxCheck()
        if len(self.keywordArray) > 0:
            for option in self.optionArray:
                self.cmd.addOption(option)
                
            for option in self.optionArray:
                currentKeyword = option.getKeyword()
                relatedOptionKeywords = [opt.getKeyword() for opt in option.MustHaveFollower] + [opt.getKeyword() for opt in option.ConflictOptions] 
                optionRules = option.getcombiningRuleNameList()
                for rule in optionRules:
                    if not rule in RULES:
                        self.error += "<br>" + "option '" + currentKeyword + "' has unsupported rule: '" + rule + "'"
                for keyword in relatedOptionKeywords:
                    if keyword in self.keywordArray:
                        pass
                    else:
                        self.error += "<br>" + "Parse keyword'" + currentKeyword + "' : connected keyword '" + keyword + "' not found"
        else:
            self.error += "<br>" + "No usable keyword found"
        return self.error
                        
    def syntaxCheck(self):
        options = self.syntax.split("*")
        options = [x.strip() for x in options]
        for optionInfo in options: 
            self.log += "parse :" + optionInfo + "<br>"
            if optionInfo == "": 
                continue
            else:
                (required, keyword, rule, error) = self.getDetails(optionInfo.strip())
                if error == "":
                    self.log += "       : " + "keyword=" + keyword + "<br>"
                    option = cmd_dsl.Option(keyword,"",rule,required,"","")
                    self.optionArray.append(option)
                    self.keywordArray.append(keyword)
                else:
                    self.error += "<br>" + error
        
    def getDetails(self,optionInfo):
        required="no"
        keyword=""
        rule=""
        error=""
        if optionInfo.startswith("(") and optionInfo.endswith(")"):
            required = "yes"
        elif optionInfo.startswith("[") and optionInfo.endswith("]"):
            required = "no"
        else:
            error="Parse '" + optionInfo + "' Has Syntax Error: no pair of '()' or '[]' found" 

        if len(error) == 0:
            self.log += "optionInfo=" + optionInfo
            optionInfo = optionInfo[1:len(optionInfo)-1]
            indexOfColon = optionInfo.find(":")
            self.log += "indexOfColon=" + str(indexOfColon) + "<br>"
            if indexOfColon>0 and indexOfColon<len(optionInfo)-1:
                tempArray = optionInfo.split(":")
                self.log += "tempArray=" + ":".join(tempArray) + "<br>"
                if len(tempArray) != 2:
                    error="Parse '" + optionInfo + "' Has Syntax Error: more than one ':' used"
                else:
                    keyword = tempArray[0].strip()
                    rule = tempArray[1].strip()
            else:
                error="Parse '" + optionInfo + "' Has Syntax Error: ':' not found or in wrong place"
        else:
            self.log += "error found: ("+ error+ str(len(error)) + ") <br>"
            
        return (required, keyword,rule, error)

    def getTestScenario_html(self):
        self.cmd.computeTestScenario()
        return self.cmd.getAllTestCases_html()