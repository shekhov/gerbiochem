__author__ = 'Anton Shekhov'
import unittest
import getopt
import sys
import os.path

from get_eic import *

class InputTestClass (unittest.TestCase):
        """ Check the inputs for error handilg """
        
        def setUp (self):
                self.rightPath = "-iTestFiles"
                self.rightFile = "-ftest.ascii"
                self.rightEIC = "-e23.5-22.1"
                #self.dic = input_handler ((self.rightPath+ self.rightFile+ self.rightEIC))
        
        def testWrongPath (self):
                """ Path should exist"""
                self.assertRaises (InputFolderError, input_handler, ("-i", "P://L", self.rightEIC, self.rightFile))
                
        def testNoFile (self):
                """ File should exist"""
                self.assertRaises (InputFileError, input_handler, ())
                self.assertRaises (InputFileError, input_handler, (self.rightPath, self.rightEIC, "-f", "test2.ascii"))
                
        def testWrongFile (self):
                """ File shoult be with right extention"""
                self.assertRaises (InputFileError, input_handler, (self.rightPath, self.rightEIC, "-f", "test.cdf"))
                
        def testWrongEIC (self):
                """ EIC should be possible to convert to floats """
                self.assertRaises (InputEICError, input_handler, ("-e", "12.3-poo"))
                
        def testReturnValues (self):
                """ Dictionary should contain right information """
                dic = input_handler ((self.rightPath, self.rightFile, self.rightEIC))
                self.assertEqual (dic['e'], [23.5, 22.1])
                self.assertEqual (dic['i'], os.path.join (os.getcwd(), "TestFiles"))
                self.assertEqual (dic['f'], "test.ascii")

if __name__ == '__main__':
        unittest.main()