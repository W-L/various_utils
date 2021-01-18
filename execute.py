
def execute(command, printout=True):
    running = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               encoding='utf-8', shell=True)
    stdout, stderr = running.communicate()

    if printout is True:
        print(stdout)
        print(stderr) 
