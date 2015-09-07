__author__ = 'Anton Shekhov'
import unittest
import getopt
import sys
import csv
import os

from get_eic import *

class InputTestCase (unittest.TestCase):
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

class ParseTestCase (unittest.TestCase):
        """ """
        def setUp (self):
                self.testLineHard = "19.2221,+,EI,ms1,-,line,33.0-417.0,226,38.1 283.17944,39.0 3934.0176,40.1 1467.1019,41.0 45749,42.0 10843.208,43.0 91100.07,44.0 1872.9056,45.0 1445.2288,50.0 161.2267,52.0 282.21283,53.0 1533.0265,54.0 4533.0947,55.0 80146.781,56.0 15973.401,57.0 63916.586,58.0 3629.8235,59.0 21688.404,60.0 550.21259,61.0 993.88177,63.1 152.19048,65.0 133.44614,66.0 286.02612,67.0 9690.1201,68.1 2510.2217,69.0 49850.988,70.0 5269.5557,71.0 18765.766,72.0 1012.2271,74.0 285253.53,75.0 98039.555,76.0 4606.8691,77.0 273.53879,78.0 163.55551,79.0 1346.9263,80.0 155.47966,81.0 6782.9331,82.0 3035.4993,83.0 35708.945,84.0 11320.863,85.1 9782.3564,87.0 235170.67,88.0 19951.93,89.0 1717.5977,90.0 172.18884,91.0 906.08813,92.1 93.942352,93.0 1342.1534,94.0 247.82365,95.0 9300.7686,96.0 4335.2476,97.0 39107.766,98.0 11374.789,99.0 1639.7719,100.1 1041.292,101.0 24036.113,102.0 2783.6462,103.9 185.24557,107.0 1387.5345,108.0 222.8367,109.1 3693.4426,110.1 1112.6116,111.0 13638.98,112.0 1264.3236,113.0 395.12949,114.0 111.76126,115.0 9090.8857,116.0 5193.1997,117.0 77.917587,118.0 101.25284,121.0 3999.2839,123.1 2431.7617,124.1 567.08954,125.1 7102.2979,126.1 208.77696,129.0 29997.746,130.0 8965.1133,133.1 168.37952,134.1 88.596169,135.1 3150.7734,136.0 196.22249,137.1 388.46347,138.1 199.97093,139.1 4051.6182,143.0 98368.375,144.1 9763.3223,145.0 164.6884,146.0 190.3587,147.0 34.574024,149.1 2525.2354,150.1 70.46022,151.1 200.05974,152.0 193.80194,153.1 2418.7244,157.1 8677.21,158.1 1976.465,160.1 164.87064,162.0 218.81009,163.1 1693.7355,165.1 119.65672,167.1 671.17358,171.1 7579.5737,172.1 2390.99,176.2 254.99225,177.1 1032.6593,178.1 17.963617,179.1 35.115166,180.1 298.10132,181.1 954.18738,182.1 106.83762,185.1 21794.838,186.1 4832.2964,190.1 815.64758,191.1 1540.8192,192.1 235.64203,194.1 527.63727,195.1 374.65118,199.1 34290.852,200.1 4658.0225,201.1 4.1975117,205.1 901.71997,206.3 300.25613,207.0 810.44849,208.1 79.761757,209.1 303.75504,210.2 628.56818,212.1 153.17375,213.1 6330.6128,214.1 1811.3717,215.2 280.98212,219.1 797.50024,220.1 188.99976,222.2 380.08237,223.1 1076.7144,224.2 478.76331,227.1 13917.443,228.1 2922.4526,229.2 473.43118,233.2 529.29413,234.0 175.21852,235.1 212.5567,236.2 305.99738,237.1 99.995247,238.2 545.15393,241.2 13883.625,242.2 3643.158,243.1 578.58746,247.2 393.69577,247.9 158,249.2 213.95157,250.2 341.92514,251.2 912.70142,252.2 436.26282,255.2 11655.075,256.2 2160.4636,257.1 63.52919,259.1 182.4241,261.1 334.90533,262.2 212.72458,263.1 234.7121,264.2 372.22479,265.2 881.79596,266.2 489.44965,269.2 6925.8589,270.2 2396.2649,271.2 498.43109,275.2 363.09766,277.2 253.52165,278.3 207.91518,279.1 598.78558,280.3 500.23709,283.2 34256.004,284.2 8673.4355,285.2 146.20926,289.2 336.12366,290.1 287.75385,291.2 268.25098,293.1 589.48181,294.2 342.26224,297.2 20451.281,298.2 4672.644,299.3 681.80249,301.9 280,303.3 336.03177,306.2 735.33801,307.2 738.33051,308.3 1043.8856,309.3 126.0139,311.2 7663.2891,312.2 1757.2535,313.2 462.31564,317.2 245.46584,321.2 599.46478,322.3 319.35159,323.2 233.95622,325.3 11605.042,326.3 3471.2261,327.2 737.94629,331.3 611.6001,332.2 371.80084,333.3 663.76678,334.4 266.37192,335.4 319.4552,339.3 86428.727,340.3 22306.313,341.3 3392.1243,342.2 451.50046,348.3 348.42105,349.3 1026.8958,351.3 21467.734,352.3 5835.7559,353.3 17451.896,354.3 5126.2266,355.2 929.79712,356.2 194.95004,367.4 259.7272,368.1 140.6868,382.4 178724.2,383.4 48068.051,384.4 8313.4492,385.4 862.75153,395.3 2619.9971,396.3 755.99969,397.3 233.99997,410.3 2325.9961,411.3 725,412.4 220.99997"
                self.testLineNone = "1.11995,+,EI,ms1,-,line,33.0-417.0,2,39.9 160.90034,55.1 146.15804"
                self.testLineOne = "1.29367,+,EI,ms1,-,line,33.0-417.0,12,46.2 646.65283,55.2 274939,60.8 611.98883,74.0 390.51254,74.8 452.39154,78.3 1352.1503,79.1 801.7135,85.1 468755.44,91.0 152.21692,95.1 171.5489,99.2 185.7182,103.1 287.42926"

        
        def testRT (self):
                """ Should give back right retention time """
                key, value = parse_line (self.testLineNone, [74, 87], 0.5)
                self.assertEqual (key, 1.11995)
                
        def testIntensities (self):
                """ Intensities should be the same as in the lines by one meaning, and as a sum when together """
                key, value = parse_line (self.testLineHard, [74, 87], 0.5)
                r1 = 285253.53
                r2 = 235170.67
                r3 = r1 + r2
                self.assertEqual (r1, value[74])
                self.assertEqual (r2, value[87])
                self.assertEqual (r3, value['signal'])
                
        def testWrongSignals (self):
                """ When no signal or just one is present, return zero values """
                key, value = parse_line (self.testLineNone, [74, 87], 0.5)
                key1, value1 = parse_line (self.testLineOne, [74, 87], 0.5)
                
                self.assertEqual (value[74], 0)
                self.assertEqual (value[87], 0)
                self.assertEqual (value['signal'], 0)
                
                self.assertEqual (value1[74], 390.51254)
                self.assertEqual (value1[87], 0)
                self.assertEqual (value1['signal'], 0)
                
        def testDictionary (self):
                """ Should return dictionary with right key-value paires """
                path = os.path.join (os.getcwd(), "TestFiles", "test.ascii")
                a, d = parse_TIC (path, [74, 87], 0.5)
                rt = 19.2221
                r1 = 285253.53
                r2 = 235170.67
                r3 = r1 + r2
                self.assertTrue (rt in a)
                self.assertTrue(rt in d)
                self.assertEqual(d[rt][74], r1)
                self.assertEqual(d[rt][87], r2)
                self.assertEqual(d[rt]['signal'], r3)
        
        def testInRange (self):
                """ Is the number in range of given frame """
                testsTrue = [73.501, 74, 74.5]
                testsFalse = [73.4, 73.499, 77.234, 77]
                for t in testsTrue:
                        self.assertEqual (74, is_In_Range(t, [74, 87], 0.5))
                for t in testsFalse:
                        self.assertFalse (is_In_Range (t, [74, 87], 0.5))

class OutputTestCase (unittest.TestCase):
        """ Test the creation of the csv file """
        
        def setUp (self):
                # Create simple file
                self.output_path = os.path.join (os.getcwd(), "TestFiles", 'file_exists.csv')
                # Check, was the file created
                report_to_csv ({19.2221:{74:285253.53, 87:235170.67, 'signal':520424.2}}, [19.2221],  self.output_path)
                self.f = open (self.output_path, 'r')
                self.reader = csv.DictReader (self.f)
        
        def tearDown (self):
                # Clear after
                self.f.close()
                os.remove (self.output_path)
        
        def testFileExists (self):
                """ Was the file even created """
                self.assertTrue (os.path.exists (self.output_path))
                
        def testHeaders (self):
                h = next (self.reader)
                self.assertIn ('rt', h)
                self.assertIn ('74', h)
                self.assertIn ('87', h)
                self.assertIn ('signal', h)

                
if __name__ == '__main__':
        unittest.main()
