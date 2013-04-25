#!/usr/bin/python

import ConfigParser
import io

def enum(*args):
    enums = dict(zip(args, range(len(args))))
    return type('Enum', (), enums) 

def printQueue(indent, msg, optionQueue):
    if len(optionQueue) == 0:
        print indent + msg + " [EMPTY QUEUE]"
    else:
        print indent + "#--------------" + msg + "------------------#" 
        print indent, 
        for option in optionQueue: 
            print "[" + option.getKeyword() + "]",
        print
        print indent + "#----------------------------------------------#" 
    
def printQofQ(indent, msg, optionQofQ):
    if len(optionQofQ) == 0:
        print indent + msg + " [EMPTY QofQ]"
    else:
        print indent + "#================" + msg + "=================#" 
        qindex=0
        for queue in optionQofQ: 
            qindex +=1
            if len(queue) == 0:
                print indent + "[EMPTY QUEUE]"
            else:
                print indent + "[" + str(qindex)+ "] ",
                for option in queue:
                    print "[" + option.getKeyword() + "]",
                print 
        print indent + "#===============================================#" 
    
class Command:
    "command to test"
    def __init__(self,command):
        self.Command = command
        self.OptionDict = {}
        self.OptionQueue = []
        self.RequiredOptionQueue = []
        self.GrowableOptionQueue = []
        self.ScenarioCandidateQueue = []
        self.OptionRuleDict = {}
        self.FinalScenarioQueue = []
        self.FinalScenarioDict = {}
        
    def computeCommandScenario(self):
        self.processOptionRule_MUST()
        self.processOptionRule_NO()
        self.processOptionRule_Required()
        self.adjustGrowableOptionQueue()
        self.processScenarioCandidate()
        
    def addOption(self,option):
        keywords = option.getKeywordList()
        for keyword in keywords:
            if self.OptionDict.has_key(keyword): #indecates error
                print "ERROR: same keyword used twice, the later one will be ignored"
            else:
                self.OptionDict[keyword] = option
                if not option in self.OptionQueue:
                    self.OptionQueue.append(option)
            
        rules = option.getcombiningRuleNameList()
        for rule in rules:
            ruleKeyword = rule.split()[0].strip()
            if ruleKeyword in self.OptionRuleDict.keys():
                currentOptions = self.OptionRuleDict[ruleKeyword]
                currentOptions.append(option)
                self.OptionRuleDict[ruleKeyword] = currentOptions
            else:
                self.OptionRuleDict[ruleKeyword] = [option]

        if option.isGrowable():
            self.GrowableOptionQueue.append(option)
        else:
            self.FinalScenarioQueue.append([option])
        
        if option.isRequired():
            self.RequiredOptionQueue.append(option)
        
    def getOption(self,keyword):
        if keyword in self.OptionDict.keys():
            return self.OptionDict[keyword]

    def processOptionRule_MUST(self):
        for option in self.OptionQueue:
            mustHaveFollowers = option.computeMustHaveFollower(option, self.OptionDict, 0)
            option.setMustHaveFollowers(mustHaveFollowers)
            
    def processOptionRule_NO(self):
        for option in self.OptionQueue:
            conflicts = option.computeConflicts(self.OptionDict)
            option.setConflictOptions(conflicts)
            
    def processOptionRule_Required(self):
        printQueue("", "before process required queue", self.RequiredOptionQueue)
        effectiveRequired = []
        for option in self.RequiredOptionQueue:
            mustHaveFollowers = option.getMustHaveFollowers()
            effectiveRequired += [option] + mustHaveFollowers
        self.RequiredOptionQueue = list( set(effectiveRequired))
        printQueue("", "After process required queue", self.RequiredOptionQueue)

    def adjustGrowableOptionQueue(self):
        effectiveGrowableOptions = self.GrowableOptionQueue[:]
        for option in self.GrowableOptionQueue:
            if option in self.RequiredOptionQueue:
                effectiveGrowableOptions.remove(option)
                conflictOptions = option.getConflictOptions()
                for conflictOption in conflictOptions:
                    if conflictOption in effectiveGrowableOptions:
                        effectiveGrowableOptions.remove(conflictOption)
        
        self.GrowableOptionQueue = effectiveGrowableOptions
        
        printQueue("", "After process required queue, the current growable options are", self.GrowableOptionQueue)
        
        optionQueueForCommand = []
        for option in self.GrowableOptionQueue:
            followers = self.computeAllFollower(option,0)
            printQofQ("", "self.computeAllFollower(" + option.getKeyword()+")", followers)
            
            option.setAllFollower(followers)
            print "Option: " + option.getKeywordString()
            for queue in followers:
                full = [option] + queue
                optionQueueForCommand.append(full)
                print "\t[-]\t" + " ".join([o.getKeyword() for o in queue])
        
        self.ScenarioCandidateQueue = self.removeDuplicateQofQ(optionQueueForCommand)
        printQofQ("", "Final Report of Candidates", self.ScenarioCandidateQueue)
        
    def processScenarioCandidate(self):
        first = self.ScenarioCandidateQueue[0]
        rest = self.ScenarioCandidateQueue[1:]
        allPossibleCombination = self.computePermutationAndCombination(first,rest,0)
        allScenario = self.sortQofQ(self.removeDuplicateQofQ(allPossibleCombination))
        
        sortedRequiredOptionQueue = sorted(self.RequiredOptionQueue)
        for scenario in allScenario: 
            completeScenario = sortedRequiredOptionQueue + scenario
            self.FinalScenarioQueue.append(completeScenario)

        conflictQueue=[]
        for option in self.OptionQueue:
            conflictOptions = option.getConflictOptions()
            if len(conflictOptions) > 0:
                for conflictOption in conflictOptions:
                    print "Option:(" + option.getKeyword() + ") -- check conflict option [" + conflictOption.getKeyword() + "]"
                    for scenario in self.FinalScenarioQueue:
                        if (option in scenario) and (conflictOption in scenario): 
                            conflictQueue.append(scenario)
                            printQueue("\t\t", "mark Conflict scenario", scenario)
        
        for scenario in conflictQueue:
            if scenario in self.FinalScenarioQueue:
                self.FinalScenarioQueue.remove(scenario) 
                
        self.FinalScenarioDict = self.regroupQofQ(self.FinalScenarioQueue)
        #printQofQ ("","====== final all possible combinations ======", self.FinalScenarioQueue)
        
    def computePermutationAndCombination(self,queue,candidate,counter):
        cn=[]
        printQueue("\t"*counter, "index=["+ str(counter)+"] passin queue", queue)
        printQofQ("\t"*counter, "index=["+ str(counter)+"] passin candidate", candidate)
        counter +=1
        cn.append(queue)
        
        if len(candidate)>0:
            first = candidate[0]
            rest = candidate[1:]
            subcn = self.computePermutationAndCombination(first, rest,counter) 
            subcn = self.removeDuplicateQofQ(subcn)
            for subQueue in subcn:
                cn.append(subQueue)
                cn.append(queue + subQueue)
        cleanCN = self.removeDuplicateQofQ(cn)
        printQofQ("\t"*counter, "index=["+str(counter)+"] returns", cleanCN)
        return cleanCN
            
    def computeAllFollower(self, currentOption, counter):  
        indent = "   " * counter
        counter += 1
        currentKeyword = currentOption.getKeyword()
        print indent + "Enter: (" + currentKeyword + " : "+ str(counter) + ")"
        myQofQ = []
        mustHaveQofQ = currentOption.getMustHaveFollowers()
        printQueue (indent, "FinalMustHave of option:(" + currentOption.getKeyword()+")", mustHaveQofQ)

        #build final myQofQ result
        myQofQ.append(mustHaveQofQ)
        
        finalQofQ = self.removeDuplicateQofQ(myQofQ)
        print indent + "Leave: (" + currentKeyword + " : "+ str(counter) + ")"
        printQofQ (indent, "[" + currentKeyword + "] :final list:", finalQofQ) 
        return finalQofQ
    
    def regroupQofQ(self,QofQ):
        Groups={}
        for queue in QofQ:
            numOfOptions = len(queue)
            key = str(numOfOptions)
            if key in Groups.keys():
                existingQofQ = Groups[key]
                existingQofQ.append(queue)
                Groups[key] = existingQofQ
            else:
                Groups[key] = [queue]
        return Groups
    
    def sortQofQ(self,QofQ):
        finalSorted =[]
        ordered = {}
        maxOfOptions = 0
        for queue in QofQ:
            numOfOptions = len(queue)
            maxOfOptions = max(maxOfOptions, numOfOptions)
            key = str(numOfOptions)
            if key in ordered.keys():
                existingQofQ = ordered[key]
                existingQofQ.append(queue)
                ordered[key] = existingQofQ
            else:
                ordered[key] = [queue]
        
        for i in range(maxOfOptions+1):
            key = str(i)
            if key in ordered.keys():
                subQofQ = ordered[key]
                sortedSubQofQ =[]
                QofQDict = {}
                printQofQ("","before sorting",subQofQ)
                for queue in subQofQ: 
                    queueSignture = self.getQueueSignture(queue)
                    QofQDict[queueSignture] = queue
                    
                for signture in sorted(QofQDict.keys()):
                    sortedSubQofQ.append(QofQDict[signture])
                
                printQofQ("","after sorting",sortedSubQofQ)
                
                for queue in sortedSubQofQ:
                    finalSorted.append(queue)
                
        return finalSorted
    
    def removeDuplicateQofQ(self, QofQ):
        finalQofQ =[]
        signtureSet = set()
        for queue in QofQ:
            uniqSet = set(queue)
            uniqQueue = sorted(list(uniqSet))
            queueSignture = self.getQueueSignture(uniqQueue)
            if not queueSignture in signtureSet:
                signtureSet.add(queueSignture)
                finalQofQ.append(uniqQueue)
        return finalQofQ                          
    
    def getQueueSignture(self,queue):
        signture = []
        signtureString = ""
        for option in queue:
            keyword = option.getKeyword()
            signture.append(keyword)
        sortedSignture = sorted(signture)
        for keyword in sortedSignture:
            signtureString = signtureString + keyword
        return signtureString
    
#    def printTestSuite(self, testSuiteTemlate, testCaseTemplate):
#        template = 
    
    def printCmdScenario(self):
        print "====== Scenario list for command [" + self.Command + " ] (" + str(len(self.FinalScenarioQueue)) + ") ========"
        index = 0
        for queue in self.FinalScenarioQueue:
            finalword=[]
            for option in queue:
                finalword.append(option.getSyntax())
            print "[%5d ] " %(index), 
            print " ".join(finalword) 
            index +=1
        print "==============================================================="
        
    def printFinalQueue(self):
        print "====== Scenario list for command [" + self.Command + " ] (" + str(len(self.FinalScenarioQueue)) + ") ========"
        index = 0
        for queue in self.FinalScenarioQueue:
            finalword=[]
            for option in queue:
                finalword.append(option.getKeyword())
            print "[%5d ] " %(index), 
            print " ".join(finalword) 
            index +=1
        print "==============================================================="
        
    def printRuleStatus(self):
        print "Rule status:"
        if len(self.OptionRuleDict.keys()) == 0:
            print "no rules saved"
        else:
            for rule,options in self.OptionRuleDict.items():
                print "[" + rule + "]:"
                for option in options:
                    print "\t(" + option.getKeywordString() + ":" + ",".join(option.getcombiningRuleNameList()) + ")"
                
    def printCandidateQueue(self):
        print "Candidate queue:"
        for candidate in self.ScenarioCandidateQueue:
            for c in candidate:
                    print c.getKeywordString(),
            print

    def readMe(self):
        if (len(self.OptionQueue)>0):
            print self.Command
            for p in self.OptionQueue:
                print '\t%-15s %-9s # %s'% (p.getKeywordString(), "[" + " ".join(p.getcombiningRuleNameList()) + "]", p.Comment)

class Option:
    "command line option"
    
    def __init__(self, keyword=None, data="FLAG", combiningRule=None, required="no", comment=""):
        self.Syntax = {}
        self.Keywords = []
        self.TestData = ""
        self.Comment = ""
        self.Follower = []
        self.MustHaveFollower = []
        self.ConflictOptions = []
        self.OptionRuleDict = {}
        self.Rule = ""
        self.IsFlag = False
        
        if keyword:
            self.Keywords = [x.strip() for x in keyword.split(",")] 
            if data:
                data = data.strip()
                if data == "FLAG" :
                    self.IsFlag = True
                else:
                    self.IsFlag = False
                    self.TestData = data
            else:
                self.IsFlag = True
            
            if (len(self.Keywords)>0):
                if self.IsFlag:
                    for keyword in self.Keywords:
                        if (keyword.startswith("--")):
                            self.Syntax["--"] = keyword
                        elif (keyword.startswith("-")):
                            self.Syntax["-"] = keyword
                        else:
                            self.Syntax[keyword] = "Unsupported"
                else:
                    for keyword in self.Keywords:
                        if (keyword.startswith("--")):
                            self.Syntax["--"] = keyword + "=" + self.TestData
                        elif (keyword.startswith("-")):
                            self.Syntax["-"] = keyword + " " + self.TestData
                        else:
                            self.Syntax[keyword] = "Unsupported" 
        self.Comment = comment 
        self.processCombiningRules([x.strip() for x in combiningRule.split(",")])
        self.required = required

    def __lt__(self, other):
        return self.getKeyword() < other.getKeyword()
    
    def processCombiningRules(self, combiningRules):
        for rule in combiningRules:
            ruleElements = rule.split()
            if (len(ruleElements)>=2):
                ruleName = ruleElements[0].strip()
                ruleTargetList = [ x.strip() for x in ruleElements[1:] ]
                if ruleName in self.OptionRuleDict.keys():
                    existingList = self.OptionRuleDict[ruleName]
                    newList = existingList + ruleTargetList
                    self.OptionRuleDict[ruleName] = newList
                else:
                    self.OptionRuleDict[ruleName] = ruleTargetList
            elif (len(ruleElements) == 1):
                self.Rule = ruleElements[0].strip()
            else:
                self.Rule = "Not_Defined"
    
    def has_rule(self,keyword):
        if self.Rule == keyword:
            return True
        elif self.OptionRuleDict:
            if self.OptionRuleDict.has_key(keyword):
                return True
            else:
                return False
        else:
            return False 
    
    def computeMustHaveFollower(self,currentOption, allOptions, counter):
        indent = "   " * counter 
        currentKeyword = currentOption.getKeyword()
        mustHave = []
        
        if currentOption.has_rule("MUST"): 
            print indent + "Enter-MUST: (" + currentKeyword + " : "+ str(counter) + ")"
            mustHaveOptionKeywords = currentOption.getRuleTargetOptionList("MUST")
            for keyword in mustHaveOptionKeywords:
                nextOption = allOptions[keyword] 
                followersOfNextOption = self.computeMustHaveFollower(nextOption, allOptions, counter + 1)
                if len(followersOfNextOption) > 0 : 
                    queue = [nextOption] + followersOfNextOption
                    queueSet = set(queue)
                    mustHave += list(queueSet)
                else:
                    mustHave.append(nextOption)
                    
            print indent + "    Must have: next keyword: [" + currentKeyword + "] (" + str(counter) + ")", nextOption.getKeyword()
            printQueue(indent,"[" + currentKeyword + "] must have:", mustHave)
            print indent + "Leave-MUST: (" + currentKeyword + " : "+ str(counter) + ")"
        else:
            print indent + "No Must follower defined: (" + currentKeyword + " : "+ str(counter) + ")"
        
        return mustHave

    def computeConflicts(self,allOptions):
        conflicts = []
        if "NO" in self.OptionRuleDict.keys():
            conflictOptionKeywords = self.OptionRuleDict["NO"] 
            for keyword in conflictOptionKeywords:
                if keyword in allOptions.keys():
                    conflictOption = allOptions[keyword]
                    conflicts.append(conflictOption)
        return conflicts
    
    def setConflictOptions(self, conflicts):
        self.ConflictOptions = conflicts
        
    def getConflictOptions(self):
        return self.ConflictOptions
    
    def setMustHaveFollowers(self,follower):
        self.MustHaveFollower = follower
        
    def getMustHaveFollowers(self):
        return self.MustHaveFollower
    
    def setAllFollower(self,follower):
        self.Follower = follower
    
    def getAllFollower(self):
        return self.Follower
    
    def isGrowable(self):
        if self.Rule == "SELF_STAND":
            return False
        else:
            return True
        
    def getOptionRule(self):
        return self.Rule
    
    def getRuleTargetOptionList(self,ruleName):
        return self.OptionRuleDict[ruleName]
   
    def getcombiningRuleNameList(self):
        return self.OptionRuleDict.keys()
     
    def getKeyword(self):
        # return long form as default
        # example: return --password instead of -w
        if len(self.Keywords) ==0 :
            return self.Keywords[0]
        else:
            retKeyword = self.Keywords[0]
            for keyword in self.Keywords:
                if keyword.startswith("--"):
                    retKeyword = keyword
            return retKeyword
    
    def getKeywordList(self):
        return self.Keywords
    
    def getKeywordString(self):
        return ",".join(self.Syntax.keys())
        
    def getSyntax(self):
        if "--" in self.Syntax.keys():
            return self.Syntax["--"]
        elif "-" in self.Syntax.keys():
            return self.Syntax["-"]

    def isRequired(self):
        if (self.required == "no"):
            return False
        else:
            return True
        
    def isOptional(self):
        if (self.required == "yes"):
            return False
        else:
            return True


#------------------------------------------------------------ 
# main starts here
#------------------------------------------------------------
configFile = "./ipa.client.install.no.sssd.options.cfg"
#configFile = "./ipa.client.install.sssd.options.cfg"
#configFile = "./test.cfg"
config = ConfigParser.ConfigParser()
fp = open(configFile)
config.readfp(fp)
fp.close()
clientInstall = Command("ipa-client-install")
for keyword in config.sections():
    data = config.get(keyword,"data")
    comment = config.get(keyword,"comment")
    combiningRule = config.get(keyword,"combiningRule")
    required = config.get(keyword,"required")
    clientInstall.addOption(Option(keyword, data, combiningRule, required, comment))
    
clientInstall.readMe()
clientInstall.computeCommandScenario()
clientInstall.printCmdScenario()