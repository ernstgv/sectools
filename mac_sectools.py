import datetime
import os
import hashlib

def serialnumberfunc():
    serialnumberstream = os.popen('system_profiler SPHardwareDataType | grep Serial')

    serialnumber = serialnumberstream.read()

    serialnumber = str(serialnumber).lstrip()

    return serialnumber

def systemversionfunc():
    systemversion_stream = os.popen('system_profiler SPSoftwareDataType | grep "System Version"')

    systemversion = systemversion_stream.read()

    systemversion = str(systemversion).lstrip()

    return systemversion

def applistfunc():
    appliststream = os.popen("system_profiler SPApplicationsDataType | grep 'Location: /Applications' | sed 's/Location://g' | sed -e 's/^[ \t]*//'")

    applist = appliststream.read()

    return applist

def md5checksum(fname):
    md5hash = hashlib.md5()

    filetohash = open(fname, "rb")

    for byte_block in iter(lambda: filetohash.read(4096),b""):
        md5hash.update(byte_block)

    return md5hash.hexdigest()


def startfunc():
    timestampnow = datetime.datetime.today().strftime("%m%d%Y%H%M%s")

    myhostname = os.uname()[1]

    myusername = os.getlogin()

    myfilename = myhostname + "_" + timestampnow + ".txt"

    systemversionout = systemversionfunc()

    serialnumberout = serialnumberfunc()

    myapplist = applistfunc()

    outfile = open(myfilename,"w")
    outfile.writelines("Timestamp: " + timestampnow + "\n\n")
    outfile.writelines("Hostname: " + myhostname + "\n\n")
    outfile.writelines("Username: " + myusername + "\n\n")
    outfile.writelines(systemversionout + "\n")
    outfile.writelines(serialnumberout + "\n")
    outfile.writelines("\n")
    outfile.writelines("List of Applications \n\n")
    outfile.writelines(myapplist + "\n\n")
    outfile.close()

    outputfilepath = os.path.abspath(myfilename)

    submission_step = ''' 
    
                        #####  SUBMISSION INSTRUCTIONS  ####
                        
                        To OTS: Please take a screenshot of the hash output below between

                        BEGIN and END marker then send to SecAdmin via Email or TG group 

                        chat with the name of the user.


                        To EndUser: Please fillup the form that will be provided by SecAdmin.

                        In that same form, upload the generated output file from -> {0}

                        That is usually the same directory where the script has executed.

                        Do not modify the content of {1}. The hash will be counterchecked by SecAdmin.
    
    '''.format(outputfilepath, myfilename)

    print(submission_step + "\n")

    md5result = md5checksum(myfilename)

    print("------------------------------------------ BEGIN ----------------------------------------------------\n")

    print("               " + myfilename + " : " + md5result + "\n")

    print("------------------------------------------- END -----------------------------------------------------")

    print("\n\n\n")

startfunc()
