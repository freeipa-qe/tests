#!/usr/bin/python

import ConfigParser
import subprocess
import io
import os

def appendToRecordFile(filename, record):
    if not os.path.isfile(filename):
        os.system("touch " + filename)
    reportRecords = open(filename, "a") 
    if reportRecords and record:
        recordID = record["id"]
        reportRecords.write("[" + recordID + "]\n")
        for key in sorted(record.keys()):
            if key == "testcase":
                testcase = record["testcase"]
                testdata=""
                for option in testcase:
                    testdata += option.getTest() + " "
                reportRecords.write(str(key) + "=" +  testdata + "\n")
            elif key != "id":
                reportRecords.write(str(key) + "=" +  str(record[key])+ "\n")
        reportRecords.write("\n")
        reportRecords.close()
        
def loadScenarioFile(scenarioFile):
    testScenario = {}
    source = open(scenarioFile, 'r')
    line=source.readline()
    while line:
        parts = [x.strip() for x in line.split(":")]
        if len(parts) == 2:
            testID = parts[0].strip()
            scenario= parts[1].strip()
            testScenario[testID] = scenario
        line=source.readline()
    return testScenario

def computeMissingBitMap(rawData): 
#    Usage:
#     data =" 57-64, 76-93, 177, 180, 188, 196, 199-204, 207-216, 227, 232, 236-253, 258-283, 301-668, 697-739, 742-791, 814-828, 853-854, 904-905, 912-913, 917-923, 927-931, 935-939, 948-949, 961-967, 979-982, 990-997, 1008-1012, 1027-1030, 1034, 1044, 1055, 1068, 1072-1074, 1080-1081, 1113-1115, 1128-1129, 1138-1139, 1153-1154, 1173-1180, 1191-1192, 1201-1226, 1240, 1246-1247, 1272-1300, 1307, 1310, 1321-1323, 1328, 1345-1348, 1365, 1384-1412, 1422-1431, 1459-1471, 1474, 1479-1480, 1484-1485, 1492-1493, 1497-1499, 1502-1514, 1562, 1566, 1575-1581, 1587-1591, 1595-1616, 1625-1662, 1667, 1669, 1676-1677, 1704-1705, 1708-1709, 1712-1713, 1718-1720, 1722-1723, 1727-1731, 1742-1747, 1750-1752, 1754-1755, 1758-1784, 1796-1808, 1814-1819, 1828-1831, 1834-1837, 1840-1844, 1847-1850, 1853-1859, 1863-1866, 1869, 1871-1882, 1889-1893, 1913, 1924-1927, 1934, 1937-1939, 1953-1956, 1960, 1974-1975, 1982-1983, 1985-1986, 1995-2013, 2017-2039, 2046-2048, 2054-2057, 2081-2085, 2090-2091, 2098-2099, 2109-2110, 2116, 2122-2124, 2130-2136, 2149, 2157-2158, 2163-2186, 2196-2197, 2202-2229, 2236, 2252-2255, 2258-2259, 2268-2269, 2273-2274, 2279-2285, 2290-2295, 2313-2315, 2318-2329, 2334-2341, 2357, 2373, 2376-2380, 2384-2390, 2399-2402"
#     missingMap = computeMissingBitMap(data)
#     print bin(missingMap)
    mapint_raw = [x.strip() for x in rawData.split(",")]
    mapint=[]
    for number in mapint_raw:
        dash = number.find("-")
        if dash == -1:
            mapint.append(int(number))
        else:
            start = number[:number.find("-")]
            end = number[number.find("-")+1:]
            for i in range(int(start), int(end)+1):
                mapint.append(i)
#     print "\n".join([str(i) for i in mapint])
    missing = 0
    for i in mapint:
        lineNumber = 2 ** i 
        missing += lineNumber
    return missing

def computeCoveredBitMap(rawData): 
    mapint_raw = [x.strip() for x in rawData.split(",")]
    mapint=[]
    for number in mapint_raw:
        dash = number.find("-")
        if dash == -1:
            mapint.append(int(number))
        else:
            start = number[:number.find("-")]
            end = number[number.find("-")+1:]
            for i in range(int(start), int(end)+1):
                mapint.append(i) 
    
    coveredLines=[]
    for i in range(max(mapint)):
        if not ( i in mapint):
            coveredLines.append(i) 
#     print "raw: " + rawData
#     print "out: " +  " ".join([str(i) for i in coveredLines])  
    covered = 0
    for i in coveredLines:
        lineNumber = 2 ** i 
        covered += lineNumber
    return covered
    
def bitMapToLineNumber(bitmap):
    strmap = list(str(bin(bitmap)))
    smap = strmap[2:]
    orderedMap = smap[::-1]
    lineNumbers = []
    for i in range(len(orderedMap)):
        if orderedMap[i] == "1":
            lineNumbers.append(i)
    return lineNumbers

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
                print indent + "[%3d ] " % (qindex),
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
        self.SelfStandOptionQueue = []
        self.RequiredOptionQueue = []
        self.GrowableOptionQueue = []
        self.ScenarioCandidateQueue = []
        self.OptionRuleDict = {}
        self.BaseScenarioQueue = []
        self.ComplexScenarioQueue = []
        self.FinalScenarioDict = {}
        self.TestCase = [] 
        self.executionOrder = ["SelfStand", "BaseCase", "Complex"]
        self.TestExecution = {} #store missing bit map
        self.SinificantTestCase = {}
        
    def computeTestScenario(self):
        self.processOptionRule_MUST()
        self.processOptionRule_NO_Step1_addressConflictOptions()
        self.processOptionRule_Required()
        self.adjustGrowableOptionQueue()
        self.processScenarioCandidate()
        self.processOptionRule_NO_Step2_removeConflictOptions()
        self.extractBaseScenario()
        self.completeFinalScenario()
        
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

        if option.isSelfStand():
            self.SelfStandOptionQueue.append([option])
            
        if option.isGrowable():
            self.GrowableOptionQueue.append(option)
            
        # FIXME: not sure how to evaluate the option type: 
#         else:
#             self.ComplexScenarioQueue.append([option])
#             self.BaseScenarioQueue.append([option])
            
        if option.isRequired():
            self.appendRequiredOption(option)
        
    def getOption(self,keyword):
        if keyword in self.OptionDict.keys():
            return self.OptionDict[keyword]

    def appendRequiredOption(self,option):
        queue = self.RequiredOptionQueue + [option]
        self.RequiredOptionQueue = sorted(queue)
        
    def processOptionRule_MUST(self):
        for option in self.OptionQueue:
            mustHaveFollowers = option.computeMustHaveFollower(option, self.OptionDict, 0)
            option.setMustHaveFollowers(mustHaveFollowers)
            
    def processOptionRule_NO_Step1_addressConflictOptions(self):
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
        self.ComplexScenarioQueue = self.sortQofQ(self.removeDuplicateQofQ(allPossibleCombination))
        
#         for scenario in allScenario: 
#             completeScenario = self.RequiredOptionQueue + scenario
#             self.ComplexScenarioQueue.append(completeScenario)

    def processOptionRule_NO_Step2_removeConflictOptions(self):
        conflictQueue=[]
        for option in self.OptionQueue:
            conflictOptions = option.getConflictOptions()
            if len(conflictOptions) > 0:
                for conflictOption in conflictOptions:
                    print "Option:(" + option.getKeyword() + ") -- check conflict option [" + conflictOption.getKeyword() + "]"
                    for scenario in self.ComplexScenarioQueue:
                        if (option in scenario) and (conflictOption in scenario): 
                            conflictQueue.append(scenario)
                            printQueue("\t\t", "mark Conflict scenario", scenario)
        
        for scenario in conflictQueue:
            if scenario in self.ComplexScenarioQueue:
                self.ComplexScenarioQueue.remove(scenario) 
    
    def extractBaseScenario(self):
        optionCounter = [len(scenario) for scenario in self.ComplexScenarioQueue]
        counterMin = min(optionCounter)
        counterMax = max(optionCounter)
        for scenario in self.ComplexScenarioQueue:
            numOfOption = len(scenario)
            #if numOfOption == counterMin or numOfOption == counterMax:
            if numOfOption == counterMin:
                self.BaseScenarioQueue.append(scenario)
        
        for scenario in self.BaseScenarioQueue:
            if scenario in self.ComplexScenarioQueue:
                self.ComplexScenarioQueue.remove(scenario)
        
    def completeFinalScenario(self):
        self.BaseScenarioQueue  = [self.RequiredOptionQueue + scenario for scenario in  self.BaseScenarioQueue ]
        self.ComplexScenarioQueue = [self.RequiredOptionQueue + scenario for scenario in  self.ComplexScenarioQueue]
        self.FinalScenarioDict["SelfStand"] = self.SelfStandOptionQueue
        self.FinalScenarioDict["BaseCase"] = self.BaseScenarioQueue
        self.FinalScenarioDict["Complex"] = self.ComplexScenarioQueue        

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
            key = "%02d" %numOfOptions # create formatted string: 01, 02... 99
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
    
    def executeTestCase(self, dataDict, reportDir, recordFile, mode):
        for option in self.OptionQueue:
            option.loadTestData(dataDict)
        index = 0 
        for groupID in self.executionOrder:
            testcaseQueue = self.FinalScenarioDict[groupID] 
            queueIndex = 0
            for testcase in testcaseQueue:
                index += 1
                queueIndex += 1
                testCaseSignture = ""
                testOptionAndTestData = []
                for option in testcase:
                    optionName = option.getKeyword()
                    testCaseSignture += optionName.replace("--","").replace("-","_") + "."
                    currentOptionAndTestData = option.getTest()
                    testOptionAndTestData.append(currentOptionAndTestData)
                fullTestCmd = self.Command + " " +  " ".join(testOptionAndTestData)
                testID="%s_%04d" %(groupID, queueIndex)
                htmlReportDir = reportDir + testCaseSignture
                (codecoverageTextReport, codecoverageBitmap, returncode) = self.executeSingleTest(testID, fullTestCmd, testCaseSignture, htmlReportDir, mode)
                
                testInfo = {}
                testInfo["testcase"] = testcase
                testInfo["id"] = testID 
                testInfo["index"] = str(index)
                testInfo["bitmap"] = codecoverageBitmap
                testInfo["test"] = fullTestCmd
                testInfo["returncode"] = returncode
                testInfo["signture"] = testCaseSignture
                testInfo["cc_html_report"] = htmlReportDir
                testInfo["cc_text_report"] = codecoverageTextReport
                appendToRecordFile(recordFile, testInfo)
                if groupID in self.TestExecution:
                    resultQueue = self.TestExecution[groupID]
                    resultQueue.append(testInfo)
                    self.TestExecution[groupID] = resultQueue
                else:
                    self.TestExecution[groupID] = [testInfo]
  
    def executeSingleTest(self,testID,singleTest,signture, htmlReportDir, mode=True):
        ret = []
        ccRunCmd = "coverage run " + singleTest
        ccReportCmd = "coverage report -m | grep ipa-client-install | cut -d'%' -f2-"
        ccReportCmd_text = "coverage report -m | grep ipa-client-install "
        ccReportCmd_html = "coverage html -d " + htmlReportDir 
        ccRawDataReserve = "cp .coverage " + htmlReportDir + "/raw.coverage"
        cleanupCmd = "/sbin/ipa-client-install --uninstall -U"
        cmd_remove_host = "ssh root@f18b.yzhang.redhat.com \"echo Secret123 | kinit admin; ipa host-del f18a.yzhang.redhat.com\" "
        
        if mode:
            print "\n=== [execution Start (" + testID + ")] ==="
            print "    test scenario: " + signture
            p = subprocess.Popen(ccRunCmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
            (output, err) = p.communicate()
            ccRunCmdReturnCode = p.returncode
            
            if ccRunCmdReturnCode == 0:
                print "  === Coverage run success, now working on produce coverage reports ==="

            else:
                print "  === install failed ==="
                print "  output: " + output
                import re
                if re.search("Installation failed", output):
                    if re.search("Failed to obtain host TGT", output):
                        print "found error, it is due to host record, now try to remove it remotally"
                        p = subprocess.Popen(cmd_remove_host, shell=True)
                        p.communicate()
                        if p.returncode == 0:
                            print "remove host record in remote server success"
                        else:
                            print "remove host record in remote server failed"
                    else:
                        print "found error, not sure what to do"
                elif re.search("IPA client is already configured on this system", output):
                    print "ipa client already installed, try to uninstall it first"
                    p = subprocess.Popen(cleanupCmd, shell=True)
                    p.wait()
                    if p.returncode == 0:
                        print "uninstall done, now reinstall with given command"
                        p = subprocess.Popen(ccRunCmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
                        (output, err) = p.communicate()
                        ccRunCmdReturnCode = p.returncode
                    else:
                        print "reinstall failed again, not sure what to do, please help"
                else:
                    print "error, not sure how to fix it"
                    print "error as below: " + output
            # regardless the fail or pass, we need collect code coverage data and clean up
            p = subprocess.Popen(ccReportCmd, stdout=subprocess.PIPE, shell=True)
            (missedLines, err) = p.communicate()
            codecoverageBitmap = computeMissingBitMap(missedLines) 
            if p.returncode == 0:
                print "got missed line and bitmap, do calculation"
            else:
                print "error: trouble getting missed line and bit map"
            if missedLines != "":
                print "missedLines= " + missedLines
                print "bitmap     = " + str(codecoverageBitmap)
            else:
                print "missedLines is empty, error occurs"
                
            p = subprocess.Popen(ccReportCmd_text, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
            (codecoverageTextReport , err) = p.communicate()
            if codecoverageTextReport != "":
                print "got full code coverage text report"
            else:
                print "trouble to get full code coverage text report"
                
            p = subprocess.Popen(ccReportCmd_html, shell=True)
            p.wait() 
            if p.returncode == 0:
                print "make html code coverage report success, html dir : " + htmlReportDir
            else:
                print "error: trouble make html code coverage report"
                
            p = subprocess.Popen(ccRawDataReserve, shell=True)
            p.wait()
            if p.returncode == 0:
                print "reserve original code coverage data success"
            else:
                print "error: reserve original code coverage data success"
                
            if ccRunCmdReturnCode == 0:
                print "  === uninstall ipa-client-install ==="
                p = subprocess.Popen(cleanupCmd, shell=True)
                p.wait()
            print "=== [execution Done, return code = " + str(ccRunCmdReturnCode) + " ] ===\n"
            ret= [codecoverageTextReport.replace("\n",""),codecoverageBitmap,str(ccRunCmdReturnCode)]

        else:
            print "\n=== [Display mode(" + testID + ")] ===",
            print "scenario: " + signture
            print "     coverage command: " + ccRunCmd
            ret = ["","0","-1"]
        return ret 
        
    def analysisCodeCoverageData(self):
        baseSum=long(0)
        if "SelfStand" in self.TestExecution.keys():
            testResultQueue = self.TestExecution["SelfStand"]
            for testResult in testResultQueue:
                self.markAsSinificantTestCase("SelfStand", testResult)
                bitmap = long(testResult["bitmap"])
                if bitmap != 0 and bitmap != 1:
                    if (baseSum == 0):
                        baseSum = bitmap
                    else:
                        baseSum = baseSum & bitmap

        if "BaseCase" in self.TestExecution.keys():
            testResultQueue = self.TestExecution["BaseCase"]
            for testResult in testResultQueue:
                self.markAsSinificantTestCase("BaseCase", testResult)
                bitmap = long(testResult["bitmap"])
                if bitmap != 0 and bitmap != 1:
                    if (baseSum == 0):
                        baseSum = bitmap
                    else:
                        baseSum = baseSum & bitmap

        bitmapSum = baseSum
        if "Complex" in self.TestExecution.keys():
            testResultQueue = self.TestExecution["Complex"]
            for testResult in testResultQueue:
                thisBitmap = long(testResult["bitmap"])
                if thisBitmap != 0 and thisBitmap != 1:
                    signture = testResult["signture"]
                    print ""
                    print "new bitmap:   %2406s" % bin(thisBitmap)
                    print "currentSum: + %2406s" % bin(bitmapSum)
                    if bitmapSum == thisBitmap & bitmapSum: 
                        print "current bitmap is covered by bitmapSum, skip it, not sinificant [" + signture + "]"
                    else:
                        diff = bitmapSum ^ thisBitmap
                        bitmapSum = bitmapSum & thisBitmap 
                        print "updatedSum: = %2406s" % bin(bitmapSum)
                        print "Different : ^ %2406s" % bin(diff) 
                        self.markAsSinificantTestCase("Complex", testResult)
                        print "found a new self.SinificantTestCase signture [" + signture + "]"

    def markAsSinificantTestCase(self,category, testResult):
        testcase = {}
        testcase["signture"] = testResult["signture"]
        testcase["testid"]   = testResult["id"]
        testcase["command"]  = testResult["test"]
        testcase["testcase"] = testResult["testcase"]
        if category in self.SinificantTestCase.keys():
            queue = self.SinificantTestCase[category]
            queue.append(testcase)
            self.SinificantTestCase[category] = queue
        else:
            self.SinificantTestCase[category] = [testcase]

    def convertSinificantTestCaseToRHTSscript(self,testSuiteName, templateFile, outputFile):
        t = open (templateFile, "r")
        output = open (outputFile,"w")
        if t and output:
            template = t.read() #load whole template at once
            print "test template file loaded: ["+templateFile+"]"
            print "output file is ready: ["+outputFile+"]"
        else:
            print "error, template file not be able to read or output file is not ready"
            return
        
        testSuite = testSuiteName + "{\n"
        testGroup = ""
        testcases = "" 
        for groupID in sorted(self.SinificantTestCase.keys()): 
            testSuite += "    " + groupID + "\n" 
            currentGroup = groupID + "{\n"
            testCaseQueue = self.SinificantTestCase[groupID] 
            for testcase in testCaseQueue:
                testcaseName   = testcase["testid"]
                command  = testcase["command"] 
                options  = testcase["testcase"]
                testcaseType = "positive"
                returncode = 0
                testData = "Test Data: "
                comment = "" 
                sinificantOptionKeywords = []
                testresultVerification = []
                for option in options:
                    testData += option.getTest()+ " " 
                    testVerification = option.getTestResultVerification()
                    if testVerification != "":
                        testresultVerification.append(testVerification + "  # Verify for: " + option.getKeyword())
                    if not option in self.RequiredOptionQueue:
                        sinificantOptionKeywords.append(option.getKeyword())  
                testData=testData.replace("=",":") 
                if len(sinificantOptionKeywords) == 1:
                    optionKeyword = sinificantOptionKeywords[0]
                    comment = "Single Option test: " + optionKeyword
                    testcaseName = testcaseName + "_single_option_test_" + optionKeyword.replace("--","").replace("-","_")
                elif len(sinificantOptionKeywords) >= 2:
                    comment = "Multi Options test: " + ",".join(sinificantOptionKeywords)
                    testcaseName = testcaseName + "_multi_options_test_" + "__".join([optionKeyword.replace("--","").replace("-","_") for optionKeyword in sinificantOptionKeywords])
                else:
                    comment = "Multiplu option test: " + ",".join([option.getKeyword() for option in options])
                
                currentTestcaseText = template
                currentTestcaseText = currentTestcaseText.replace("%testcaseName", testcaseName)
                currentTestcaseText = currentTestcaseText.replace("%testcaseComment", comment)
                currentTestcaseText = currentTestcaseText.replace("%testcaseType", testcaseType)
                currentTestcaseText = currentTestcaseText.replace("%testcaseData", testData)
                currentTestcaseText = currentTestcaseText.replace("%testcaseCommand", command)
                
                if returncode == 0:
                    currentTestcaseText = currentTestcaseText.replace("%testcaseExceptedReturnCode", "")
                else:
                    currentTestcaseText = currentTestcaseText.replace("%testcaseExceptedReturnCode", str(returncode)) 
                
                # start of block: for test verification function replacement
                allTestResultVerification = ""
                indent = ""
                import re
                regex = re.search("(\s*)%testresultVerification",currentTestcaseText)
                if regex:
                    indent = regex.group(1)
                for verification in testresultVerification:
                    allTestResultVerification += indent +  verification 
                allTestResultVerification = allTestResultVerification[:-1] #remove the last \n char
                currentTestcaseText = currentTestcaseText.replace(indent + "%testresultVerification",allTestResultVerification )
                # end of block
                
                testcases +=  currentTestcaseText + "\n"
                currentGroup += "    " + testcaseName + "  # [" + testcaseType + "] " + comment + "\n"
            currentGroup += "}\n\n"
            testGroup += currentGroup
        testSuite += "}\n"
        rhtsScript = testSuite + "\n" + testGroup + "\n" + testcases
        output.write(rhtsScript)
        output.close()
        print "write to output file: ["+outputFile + "] success"
            
    def writeCmdScenario_Text(self,textfile):
        out = open(textfile,'w') 
        if out:
            index = 0
            for testcase in self.TestCase:
                out.write( "%05d: " %(index)) 
                out.write( testcase + "\n")
                index +=1
            out.close()
            print "write to file " + textfile + " success!"
        else:
            print "can not open file " + textfile + " to write!"

    def printTestCases(self):
        print ""
        print "#----------------------------------------------------------#"
        print "#                     All Test Cases                       #"
        print "#----------------------------------------------------------#"
        for groupID in self.executionOrder:
            if groupID in self.FinalScenarioDict.keys(): 
                testcaseQueue = self.FinalScenarioDict[groupID]
                counter = len(testcaseQueue)
                printQofQ("  ", groupID + "(" + str(counter) + ")", testcaseQueue)
        print "#-----------------------------------------------------------#"
        print ""
        
    def printSinificantTestCases(self):
        print ""
        print "#-----------------------------------------------------------------#"
        print "#                     Sinificant Test Cases                       #"
        print "  -------------------------------------------------------------- "
        for groupID in self.executionOrder:
            if groupID in self.SinificantTestCase.keys(): 
                testInfoQueue = self.SinificantTestCase[groupID]
                counter = len(testInfoQueue)
                testcaseQofQ = []
                for info in testInfoQueue:
                    testcase = info["testcase"]
                    testcaseQofQ.append(testcase)
                printQofQ("    ", groupID + "(" + str(counter) + ")", testcaseQofQ)
        print "#-----------------------------------------------------------------#"
        print ""
        
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
    
    def __init__(self, keyword=None, tesDataType="FLAG", combiningRule=None, required="no", comment="", testresultVerification=""):
        self.Syntax = {}
        self.Keywords = []
        self.TestDataType = ""
        self.Data = ""
        self.Comment = ""
        self.Follower = []
        self.MustHaveFollower = []
        self.ConflictOptions = []
        self.OptionRuleDict = {}
        self.Rule = ""
        self.Test = ""
        self.IsFlag = False
        self.TestResultVerification = ""
        
        if keyword:
            self.Keywords = [x.strip() for x in keyword.split(",")] 
            if tesDataType:
                tesDataType = tesDataType.strip()
                if tesDataType == "FLAG" :
                    self.IsFlag = True
                else:
                    self.IsFlag = False
                    self.TestDataType = tesDataType
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
                            self.Syntax["--"] = keyword + "=" + self.TestDataType
                        elif (keyword.startswith("-")):
                            self.Syntax["-"] = keyword + " " + self.TestDataType
                        else:
                            self.Syntax[keyword] = "Unsupported" 
        self.Comment = comment 
        self.processCombiningRules([x.strip() for x in combiningRule.split(",")])
        self.required = required
        self.TestResultVerification = testresultVerification

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
    
    def isSelfStand(self):
        if self.Rule == "SELF_STAND":
            return True
        
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

    def loadTestData(self,dataStore):
        if not self.IsFlag:
            self.Data = dataStore.get(self.TestDataType)
            self.Test = self.getSyntax().replace(self.TestDataType,self.Data)
        else:
            self.Test = self.getSyntax() 
    
    def getTestData(self):
        return self.Data
    
    def getTest(self):
        if self.Test:
            return self.Test
        else:
            return "" #not sure if this is right thing to return
    
    def getTestResultVerification(self):
        return self.TestResultVerification
        
class DataGenerator:
    "data generator"
    dataCenter={}

    def __init__(self,testenv):
        env = open(testenv)
        print "loading test environment file: ["+testenv+"]"
        line = env.readline()
        while line:
            parts = [x.strip() for x in line.split("=")]
            if len(parts) == 2:
                key = parts[0].strip()
                value= parts[1].strip()
                self.dataCenter[key] = value
                print "loading: ["+key+"] => ["+value+"]"
            line=env.readline() 
        env.close()

    def get(self,keyword):
        if keyword in self.dataCenter.keys():
            return self.dataCenter[keyword]
        else:
            return self.generateNewTestData(keyword)
    
    def generateNewTestData(self,dataType):
        return "NotDefined:["+dataType+"]"

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

testSuiteName = "ipa_client_install_sssd_option_test"
testCommand = "/sbin/ipa-client-install"
scenarioFile = "./scenario.txt"
ccReportFile = "./cc.report.missing.txt"

reportDir  = "/export/iparhts/codecoverage/test/"
if os.path.exists(reportDir):
    print "clean up report directory: [" + reportDir + "]"
    os.system("rm -rfv " + reportDir + "*")
else:
    reportDir = "/tmp/"
    
recordFile = reportDir + "records"

templateFile = "./rhts.template"
outputFile = "./rhts.sh"

testEnvFile = "./ipa.test.env"
testData = DataGenerator(testEnvFile)

IPAClientInstall = Command(testCommand)
for keyword in config.sections():
    data = config.get(keyword,"data")
    comment = config.get(keyword,"comment")
    combiningRule = config.get(keyword,"combiningRule")
    required = config.get(keyword,"required")
    try:
        testresultVerification = config.get(keyword,"testresultVerification")
    except ConfigParser.NoOptionError:
        testresultVerification = ""
    IPAClientInstall.addOption(Option(keyword, data, combiningRule, required, comment, testresultVerification))
    
IPAClientInstall.readMe()
IPAClientInstall.computeTestScenario()
IPAClientInstall.printTestCases()
IPAClientInstall.executeTestCase(testData, reportDir, recordFile, False)
IPAClientInstall.analysisCodeCoverageData()
IPAClientInstall.convertSinificantTestCaseToRHTSscript(testSuiteName, templateFile, outputFile)
IPAClientInstall.printSinificantTestCases()
print "========== done =============="