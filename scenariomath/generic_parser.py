#!/usr/bin/python

test=""" 
    os version = rhel 6.4, rhel 6.3
    os=i386, x86_64
    build= ipa 2.2, ipa 3.0
    feature = ipa-password , ipa-client-install, ca-less install: NOT ipa 2.2, force : ONLY i386
    # this line will be skipped
    ask = os version * os * build * feature
    """
    
class SyntaxParser:    
    """Parse syntax string"""
    
    def __init__(self,syntaxString):
        self.input=syntaxString
        self.data={}
        self.rules={}
        self.askElements=[]
        self.error=""
        self.log=""
        self.ask=""
        self.answer=[]
        
        allInfo = [x.strip() for x in syntaxString.split("\n")]
        for info in allInfo:
            if not info.startswith("#") and info.find("=") > 0:
                elements = info.split("=") 
                if len(elements) == 2:
                    groupName = elements[0].strip()
                    groupMemberString = elements[1].strip() 
                    if groupName == "ask":
                        self.ask = groupMemberString
                    else:
                        groupMembers = [x.strip() for x in groupMemberString.split(",")]
                        cleanGroupMembers = []
                        for eachMember in groupMembers:
                            if eachMember.find(":") > 0:
                                properties = [x.strip() for x in eachMember.split(":")]
                                name = properties[0]
                                rule = properties[1]
                                cleanGroupMembers.append(name)
                                self.rules[name] = rule
                            else:
                                cleanGroupMembers.append(eachMember)
                        self.data[groupName] = cleanGroupMembers
                else:
                    self.error += "parse error in line [" + info + "], more than one '=' used, item skipped"

        self.askElements = [x.strip() for x in self.ask.split("*")]
        for element in self.askElements:
            if not element in self.data.keys():
                self.error += "asking [" + element + "] not defined, assume this is itself"
                self.data[element] = element
                
    def doMultiply(self, queue):
        returnQueue = []
        if len(queue) <= 0:
            return []
        elif len(queue) == 1:
            queueItem = queue[0]
            itemValues = self.data[queueItem] 
            for value in itemValues:
                returnQueue.append([value])
            return returnQueue
        else:
            firstItem = queue[0]
            correspondingValues = self.data[firstItem] 
            restItems = queue[1:]
            restQueue = self.doMultiply(restItems)
            
            for value in correspondingValues:
                for queue in restQueue:
                    newQueue = [value] + queue
                    returnQueue.append(newQueue)
            return returnQueue
        
    def doMath(self):
        self.answer = self.doMultiply(self.askElements)
        print "\n[doMath]"
        index=1
        for scenario in self.answer:
            print str(index) + ".   " + " & ".join(scenario)
            index += 1
        self.checkRules()
        
    def checkRules(self):
        newAnswer = []
        if len(self.rules.keys()) > 0:
            print "[rules] will be applied"
            for name in self.rules.keys():
                rule = self.rules[name]
                print name + " --> " + rule
                for scenario in self.answer: 
                    if name in scenario: 
                        self.applyRule(rule, scenario, newAnswer)
                    else:
                        newAnswer.append(scenario)
            self.answer = newAnswer
        else:
            print "[rules] empty"
            
    def applyRule(self, rule, scenario, result):
        #ca-less install: NOT [ipa 2.2]
        if rule.startswith("NOT"):
            ruleTargets = [x.strip() for x in rule[4:].split(";")]
            for target in ruleTargets:
                if target in scenario:
                    print "apply rule [" + rule + "] remove this scenario: " + " X ".join(scenario)
                else:
                    result.append(scenario)
        if rule.startswith("ONLY"):
            ruleTargets = [x.strip() for x in rule[5:].split(";")]
            for target in ruleTargets:
                if target in scenario:
                    result.append(scenario)
                else:
                    print "apply rule [" + rule + "] remove this scenario: " + " X ".join(scenario)
                    
    def readme(self):
        print "[input] \n" + "\n".join([x.strip() for x in self.input.split("\n")])
        self.printData()
        print "asking: " + self.ask
        print "parsing error: " + self.error
        
    def printData(self):
        if self.data.keys() > 0:
            print "[data]"
            for key in self.data.keys():
                print "[" + key + "] => [" + " ".join(self.data[key]) + "]"
    
    def finalAnswer(self):
        print "[final answer]"
        index=1
        for scenario in self.answer:
            print str(index) + ".   " + " & ".join(scenario)
            index += 1
        
    def finalAnswer_html(self):
        answer=""
        index=1
        for scenario in self.answer:
            answer += str(index) + ".   " + " & ".join(scenario) + "<br>"
            index += 1
        return answer
               
# t=SyntaxParser(test)
# t.readme()
# t.doMath()
# t.finalAnswer()
