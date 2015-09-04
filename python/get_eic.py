import sys
import os
import csv
import getopt


class Error (Exception):
        """Base error for this module"""
        pass

class InputError (Error):
        """ Exceptions raised when input was wrong
                Attributes:
                        msg -- explanation of the error
        """
        def __init__(self, msg):
                self.msg = msg
                pass
                
class InputFolderError (InputError): pass
class InputFileError (InputError): pass
class InputEICError (InputError): pass

                
def input_handler (argv):
        inputFolder=""
        inputFile=""
        eic=[]
        r=0.5
        
        def Usage ():
                errorMSG="Usage:\nget_eic.py -i <inputFolder> -f <file.ascii> -e <n1-n2-n3-etc> -r <range>\nuse -h or -help to print help message"
                print (errorMSG)
                sys.exit()

        try:
                opts, rest = getopt.getopt (argv, 'hi:f:e:r:', ["help", "inputFolder=", "inputFile=", "eic=", "range="])
        except getopt.GetoptError:
                Usage()

        for opt, arg in opts:
                if opt in ("-h", "--help"):
                        print ("\n\tTransform report from Brucer DataAnalysis to EIC for quantity analysis")
                        print ("Usage:\nget_eic.py -i <inputFolder> -f <file.ascii> -e <n1-n2-n3-etc> -r <range>")
                        print ("Or: \tget_eic.py --inputFolder <inputFolder> --inputFile <file.ascii> --e ic <n1-n2-n3-etc> -range <range>>")
                        print ("Arguments: ")
                        print ("\t-i (--inputFolder) a location of folder with file to convert. If not specified, use a current folder")
                        print ("\t-f (--inputFile) A name of the DataAnalysis report file with extention (.ascii). No default value")
                        print ("\t-e (--eic) Ions to extract separated by dash. ")
                        print ("\t-r (--range) Difference in masses from eic to collect. Default value is 0.5")
                        sys.exit(2)

                elif opt in ("-i", "--inputFolder"):
                        path = os.path.join(os.getcwd(), arg)
                        if os.path.isdir (path) == True:
                                inputFolder = path
                        else: raise InputFolderError (path+ " is not a directory")
                        
                elif opt in ("-f", "--inputFile"):
                        name = arg.split(".")
                        if name[-1] == 'ascii':
                                inputFile = arg
                        else: raise InputFileError ( "Wrong file type was given or file does not exist. " + arg  + " was given. Read help")
                
                elif opt in ("-e", "--eic"):
                        e = arg.split("-")
                        for i in e: 
                                try:
                                        eic.append (float(i))
                                except:
                                        raise InputEICError ("Number expected, but " + i + " was given")
                        
                elif opt in ("-r", "--range"):
                        r = abs(arg)

        if len (inputFolder) == 0: inputFolder = os.getcwd()
        if not os.path.isfile (os.path.join(inputFolder, inputFile)): raise InputFileError ("File does not exist! " + inputFile + " was given")
        if len(inputFile) == 0: raise InputFileError ("No file name was given, Read help")
        if len (eic) == 0: raise InputEICError ("No ions to extract was given")
        
        return {'i':inputFolder, 'f':inputFile, 'e':eic, 'r':r}


        
def main (argv):
        # Proceed options've been passed through the function call
        input = input_handler (argv)
        
        # Assign parameters
        inputFolder=input['i']
        inputFile=input['f']
        eic=input['e']
        r=input['r']
        
        
        
        
if __name__== "__main__":
        main (sys.argv[1:])